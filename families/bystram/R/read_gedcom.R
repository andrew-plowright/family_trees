require(stringr)
require(tibble)
require(dplyr)

read_gedcom <- function(gedcom_files) {

  out_list <- list(
    individuals = list(),
    families = list()
  )
  
  # Rejected fields/categories
  rejects <- c()
  
  for(gedcom_file in gedcom_files){
    
    gedcom <- str_squish(readLines(gedcom_file, encoding='UTF-8'))
    
    index <- c(NA, NA, NA, NA)
    
    for (l in 1:length(gedcom)) {
      
      # Read line
      line <- gedcom[l]
      
      # Get 'level'
      level <- as.integer(substr(line,0,1)) + 2
      
      # Content that will be appended to output
      output <- NULL
      
      # Get person's ID
      if(level == 2){ 
        
        if(str_detect(line, "INDI$")){
          
          index[1] <- 'individuals'
          
          field <-  unlist(str_split(line, "@"))[2]
          
          output <- list()
          
        }else if(str_detect(line, "FAM$")){
          
          index[1] <- 'families'
          
          field <- unlist(str_split(line, "@"))[2]
          
          output <- list()
          
        }else{
          index[1] <- 'other'
          
          field <- 'OTHER'
        }
        
        # Skip anything that isn't individuals or families
      }else if(index[1] != 'other'){
        
        # Get field and content
        line_splt <- unlist(str_split(line, " "))
        field <- line_splt[2]
        if(length(line_splt) > 2){
          content <- paste(line_splt[3:length(line_splt)], collapse = " ")
        }else{
          content <- NA
        }
        
        # Acceptable categories
        if(field %in% c('NAME', 'BIRT', 'DEAT', 'MARR')){
          
          output <- list()
          
          # Acceptable fields (level-2)
        }else if(field %in% c('FAMC', 'FAMS', 'HUSB', 'WIFE', 'CHIL')){
          
          output <- gsub('@', '', content)
          
          # Acceptable fields (level-3)
        }else if(
          field %in% c('GIVN', 'SURN', 'DATE', 'PLAC') &
          index[3] %in% c('NAME', 'BIRT', 'DEAT', 'MARR')
        ){
          output <- content
        }
        
      }else next
      
      # Set field
      index[level] <- field
      
      # Trip off index information beyond current level
      index <- index[1:level]
      
      # Get existing value
      current_val <- purrr::pluck(out_list, !!!index[1:level])
      
      if(!is.null(current_val)){
        
        # Don't erase existing list
        if(is.list(output)){
          output <- NULL
        }
        
        if(!is.null(output)){
          
          # Don't duplicate values
          if(output %in% current_val){
            
            output <- NULL
            
          # Append to existing value
          }else{
            
            output <- c(current_val, output)
          }
        }
      }
      
      # Add output to list
      if(!is.null(output)){
        purrr::pluck(out_list, !!!index[1:(level-1)])[[field]] <- output
      }
    }
  }
  
  cat(unique(rejects))  
  
  return(out_list)
}

print_individuals <- function(data){
  
  individuals <- data$individuals
  
  for(i in 1:length(individuals)){
    
    id <- names(individuals)[i]
    ind <- individuals[[i]]
    
    cat(crayon::red(id), ': ', ind[["NAME"]][["SURN"]], ", ", ind[["NAME"]][["GIVN"]], '\n', sep ="")
    
    if("BIRT" %in% names(ind)){
      cat("  Born:", ind[["BIRT"]][["DATE"]], ", ", ind[["BIRT"]][["PLAC"]], '\n')
    }
    
    if("DEAT" %in% names(ind)){
      cat("  Died:", ind[["DEAT"]][["DATE"]], ", ", ind[["DEAT"]][["PLAC"]], '\n')
    }
    
    cat("\n")
  }
}

print_families <- function(data){
  
  families <- data$families
  
  for(i in 1:length(families)){
    
    id <- names(families)[i]
    fam <- families[[i]]
    
    husb <- data$individuals[[fam[["HUSB"]]]]
    husb_name <- paste0(husb[["NAME"]][["SURN"]], ", ", husb[["NAME"]][["GIVN"]])
    wife <- data$individuals[[fam[["WIFE"]]]]
    wife_name <- paste0(wife[["NAME"]][["SURN"]], ", ", wife[["NAME"]][["GIVN"]])
  
    child_names <- sapply(fam[["CHIL"]], function(cid){
      child <- data$individuals[[cid]]
      paste0(child[["NAME"]][["SURN"]], ", ", child[["NAME"]][["GIVN"]])
    })
      
    cat(crayon::green(id), ': ', husb_name, ' - ', wife_name , '\n', sep ="")
    
    for(child_name in child_names){
      cat(' ', child_name , '\n', sep ="")
    }
    cat("\n")
  }
}