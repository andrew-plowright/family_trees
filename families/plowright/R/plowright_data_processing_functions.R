
qa <- function(in_data){
  
  if(any(duplicated(na.omit(in_data[["ID"]])))){ 
    stop("Non unique IDs")
  }
  
  # Data checks (all FAMC exist in FAMS)
  if(!all(in_data$FAMC %in% c(in_data$FAMS1,in_data$FAMS2, in_data$FAMS3, in_data$FAMS4))){
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
      if(is.na(x['Given Name'])){
        NA
      }else{
        paste0(x["Title"], " ", x["Given Name"])  
      }
  
    }
  })
  
  return(in_data)
}

merge_locations <- function(in_data){
  in_data[["Location"]] <- apply(in_data,1, function(x){
    
    paste(na.omit(x[c("Location 1A", "Location 1B", "Location 2")]), collapse=", ")
    
  }) 
  
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


clean_data <- function(in_data){
  
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
    
    person_data[["BIRT"]][["YEAR"]] <- if(!is.null(person[["Birth Date Circa"]])){
      paste( person[["Birth Date Circa"]], person[["Birth Date"]])
    }else{
      person[["Birth Date"]]
    } 
    person_data[["BIRT"]][["PLAC"]] <- person[["Location"]] 
    
    person_data[["DEAT"]][["YEAR"]] <- if(!is.null(person[["Death Date Circa"]])){
      paste( person[["Death Date Circa"]], person[["Death Date"]])
    }else{
      person[["Death Date"]]
    } 
    
    person_data[["HONO"]] <- person[["Honours"]]     
    
    person_data[["FAMC"]] <- person[["FAMC"]]
    person_data[["FAMS"]] <- c(person[["FAMS1"]], person[["FAMS2"]], person[["FAMS3"]], person[["FAMS4"]])
    
    person_data[["gen"]]      <- as.integer(person[["Generation"]])
    person_data[["position"]] <- as.integer(person[["Position"]])
    person_data[["note"]]     <- as.integer(person[["Note"]])
    
    person_data[lengths(person_data) == 0] <- NULL
    
    out_data[["individuals"]][[id]] <- person_data
    
    # FAMILY
    spouse <- person[["Spouse"]]

    out_data %<>% .populate_fams(person[["FAMS1"]], id, spouse)
    out_data %<>% .populate_fams(person[["FAMS2"]], id, spouse)
    out_data %<>% .populate_fams(person[["FAMS3"]], id, spouse)
    out_data %<>% .populate_fams(person[["FAMS4"]], id, spouse)
    
    FAMC <- person[["FAMC"]]
    if(!is.null(FAMC)) out_data %<>% .populate_famc(FAMC, id)
  }
  
  return(out_data)
}


.populate_fams <- function(out_data, fam, id, spouse){
  
  if(!is.null(fam)){
    
    if(is.null(out_data[["families"]][[fam]])) out_data[["families"]][[fam]] <- list()
    
    out_data[["families"]][[fam]][[spouse]] <- id
  }

  return(out_data)
}


.populate_famc <- function(out_data, fam, id){
  
  if(is.null(out_data[["families"]][[fam]])) out_data[["families"]][[fam]] <- list()
  
  out_data[["families"]][[fam]][["CHIL"]] %<>% c(., list(id))
  
  return(out_data)
}

