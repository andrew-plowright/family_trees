trim_branches <- function(in_data){
  
  in_data[["Graph"]] <- TRUE
  
  for(i in 1:nrow(in_data)){
    
    person <- in_data[i,]
    
    if(person[["Collapse"]]){
      
      
      id <- person[["ID"]]
      
      # Get children
      fams <- setdiff(unlist(person[,c("FAMS1", "FAMS2")]), NA)
      famc <- in_data[which(in_data[, "FAMC"] %in% fams), "ID"]
      
      # Set 'Graph'=FALSE for children and all spouses and children of children
      for(child_id in famc){
        desc_ids <- .extended_family(in_data, child_id)
        
        in_data[in_data[["ID"]] %in% c(child_id, unique(desc_ids)), "Graph"] <- FALSE
      }
      
    }
  }
  
  
  
  return(in_data)
  
}

fill_missing_ids <- function(in_data){
  for(i in 1:nrow(in_data)){
    
    person <- in_data[i,]
    
    id <- person[["ID"]]
    
    if(is.na(id)){
      
      fams <- person[["FAMS1"]]
      
      spouse <- in_data[(1:nrow(in_data) != i) & (in_data[["FAMS1"]] %in% fams),]
      
      spouse_num <- NULL
      
      if(nrow(spouse) > 1) stop("Too many spouses for id=", id)
      
      if(nrow(spouse) == 0){
        
        spouse <- in_data[(1:nrow(in_data) != i) & (in_data[["FAMS2"]] %in% fams),]
        spouse_num <- 2
        
        if(nrow(spouse) == 0) stop("No spouse for id=", id)
      }
      
      new_id <- paste0(spouse[,"ID",drop=T], "(s",spouse_num, ")")
      in_data[i, "ID"] <- new_id
    }
  }
  return(in_data)
}

.extended_family <- function(in_data, id){
  
  person <- in_data[in_data[["ID"]] == id,]
  
  #cat(strrep(".", as.integer(person[["Generation"]])), id, "\n")
  
  fams <- setdiff(unlist(person[,c("FAMS1", "FAMS2")]), NA)
  
  spouse_ids <- in_data[(in_data[["ID"]] != id) & ((in_data[["FAMS1"]] %in% fams) | (in_data[["FAMS2"]] %in% fams)), "ID"]
  
  children_ids <- in_data[in_data[["FAMC"]] %in% fams, "ID"]
  
  desc_ids <- c()
  for(child_id in children_ids){
    desc_ids <- c(desc_ids, .extended_family(in_data, child_id))
  }
  
  return(c(spouse_ids, children_ids, desc_ids))
  
}