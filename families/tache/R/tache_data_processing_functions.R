
qa <- function(in_data){
  
  if(any(duplicated(na.omit(in_data[["ID"]])))){ 
    stop("Non unique IDs")
  }
  
  # Data checks (all FAMC exist in FAMS)
  if(!all(in_data$FAMC %in% c(in_data$FAMS1,in_data$FAMS2))){
    stop("Some FAMC do not exist FAMS")
  }
  
  # All FAMS have HUSB/WIFE
  if(!all(apply(in_data,1, function(x) if( !is.na(x["FAMS1"]) & is.na(x["Spouse"]) ) FALSE else TRUE))){
    stop("Some FAMS do not have a HUSB/WIFE")
  }
  
}

merge_title_with_name <- function(in_data){
  in_data[["Given Name"]] <- apply(in_data,1, function(x){
    
    if(is.na(x["Title"])){
      x["Given Name"]
    }else{
      paste0(x["Title"], " ", x["Given Name"])
    }
  })
  return(in_data)
}

merge_locations <- function(in_data){
  in_data[["Location"]] <- apply(in_data,1, function(x){
    if(is.na(x["Location 1"])){
      NA
    }else{
      if(is.na(x["Location 2"])){
        x["Location 1"]
      }else{
        paste0(x["Location 1"], ", ", x["Location 2"])
      }
    }
  }) 
  
  in_data[["Location 1"]] <- NULL
  in_data[["Location 2"]] <- NULL
  
  return(in_data)
  
}


initial_positions <- function(in_data){
  
  gens <- unique(in_data$Generation) %>% setNames(rep(1, length(.)), .)
  
  in_data[["position"]] <- NA
  
  for(i in 1:nrow(in_data)){

      gen <- in_data[i, "Generation"]
      current_position <- gens[gen]
      
      in_data[i, "Position"] <- current_position
      
      gens[gen] <- current_position + 1

  }
  
  return(in_data)
}


cleaned_data <- function(in_data){
  
  out_data <- list(
    individuals = list(),
    families = list()
  )
  
  for(i in 1:nrow(in_data)){
    
    # INDIVIDUAL
    person <- in_data[i,] %>% as.list %>% .[sapply(., function(x){(x != "") & (!is.na(x))} )]
    
    id <- person[["ID"]]
    
      person_data <- list(
        NAME = list(),
        BIRT = list(),
        DEAT = list()
      )
      
      person_data[["NAME"]][["GIVN"]] <- person[["Given Name"]]
      person_data[["NAME"]][["SURN"]] <- person[["Surname"]]   
      
      person_data[["BIRT"]][["YEAR"]] <- person[["Birth Date"]]
      person_data[["BIRT"]][["PLAC"]] <- person[["Location"]] 
      
      person_data[["DEAT"]][["YEAR"]] <-  person[["Death Date"]]
      
      person_data[["HONO"]] <-  person[["Honours"]]     
      
      person_data[["FAMC"]] <- person[["FAMC"]]
      person_data[["FAMS"]] <- c(person[["FAMS1"]], person[["FAMS2"]])
      
      person_data[["gen"]]      <- as.integer(person[["Generation"]])
      person_data[["position"]] <- as.integer(person[["Position"]])
      person_data[["note"]]     <- as.integer(person[["Note"]])

      person_data[lengths(person_data) == 0] <- NULL
      
      out_data[["individuals"]][[id]] <- person_data
      
      # FAMILY
      spouse <- person[["Spouse"]]
      FAMS1 <- person[["FAMS1"]]
      FAMS2 <- person[["FAMS2"]]
      
      if(!is.null(FAMS1)) out_data %<>% .populate_fams(FAMS1, id, spouse)
      if(!is.null(FAMS2)) out_data %<>% .populate_fams(FAMS2, id, spouse)
      
      FAMC <- person[["FAMC"]]
      if(!is.null(FAMC)) out_data %<>% .populate_famc(FAMC, id)
    
   
  }
  
  return(out_data)
}


.populate_fams <- function(out_data, fam, id, spouse){
  
  if(is.null(out_data[["families"]][[fam]])) out_data[["families"]][[fam]] <- list()
  
  out_data[["families"]][[fam]][[spouse]] <- id

  
  return(out_data)
  
}


.populate_famc <- function(out_data, fam, id){
  
  if(is.null(out_data[["families"]][[fam]])) out_data[["families"]][[fam]] <- list()
  
  out_data[["families"]][[fam]][["CHIL"]] %<>% c(., list(id))
  
  return(out_data)
}

