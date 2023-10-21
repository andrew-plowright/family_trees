
set_positions <- function(data, init_id){
  
  # Get first absolute generation
  gens_relative <- sapply(data$individuals, function(x) if(is.null(x$gen_relative)) NA else x$gen_relative)
  gens_relative_unique <- sort(unique(gens_relative, na.rm=T))
  gen_relative_first <- min(gens_relative_unique)
  
  # Sort by generation
  data$individuals <- data$individuals[order(gens_relative)]
  
  # Create list for positions
  positions <- list()
  
  .build_tree <- function(id, gen_absolute){
    
    #cat("IND: ", id, "\n", sep ="")
    
    # Get invidiual
    ind <- data$individuals[[id]]

    # Gen generation (as character)
    gen_chr <- as.character(gen_absolute)
    
    # Get spouses
    spouse_ids <- .get_spouses(data,id)
    
    # IF this individual does not have a position...
    if(!id %in% positions[[gen_chr]]){
      
      # Append to position
      positions[[gen_chr]] <<- c(positions[[gen_chr]], id) 
      
      # Set generation
      data$individuals[[id]][["gen"]] <<- gen_absolute
        
      for(fam_id in names(spouse_ids)){
        
        #cat(strrep(" ", gen_absolute), "FAM:", fam_id, "\n", "")
        
        # Ge spouse id
        spouse_id <- spouse_ids[fam_id]
      
        # Set spouse to same generation
        data$individuals[[spouse_id]][["gen"]] <<- gen_absolute
        
        # Append spouse to position
        if(!spouse_id %in% positions[[gen_chr]]){
          positions[[gen_chr]] <<- c(positions[[gen_chr]], spouse_id) 
        }

        child_ids <- .get_children(data, fam_id)
        
        for(child_id in child_ids){
          .build_tree(child_id, gen_absolute + 1)
        }
      }
      
    }
  }
  
  # Build initial tree
  gen_relative_init <- data$individuals[[init_id]][['gen_relative']] - gen_relative_first + 1
  .build_tree(init_id, gen_relative_init)
  
  # Fill in remaining
  for(id in names(data$individuals)){
    gen <- data$individuals[[id]][['gen_relative']] - gen_relative_first + 1
    .build_tree(id, gen)
  }
  
  if(!all(names(data$individuals) %in% unlist(positions))) stop("Not all positions have been determined")
  
  # Apply positions
  for(i in 1:length(positions)){
    for(j in 1:length(positions[[i]])){
      id <- positions[[i]][j]
      data$individuals[[id]][["position"]] <- j
    }
  }
  
  # Clear 'gen_relative'
  for(id in names(data$individuals)){
    data$individuals[[id]][['gen_relative']] <- NULL
  }
  
  return(data)
}



.get_spouses <- function(data, ind_id){
  
  ind <- data$individuals[[ind_id]]
  
  fams_ids <- ind[["FAMS"]]
  
  if(!is.null(fams_ids)){
    spouses <- sapply(fams_ids, function(fam_id){
      setdiff(unlist(data$families[[fam_id]][c('HUSB', 'WIFE')]), ind_id)
    })
    
    myears <- sapply(fams_ids, function(fam_id){
      myear <- data$families[[fam_id]]$MARR$YEAR
      if(is.null(myear)) NA else myear
    })
    
    morder <- order(myears)
    
    return(spouses[morder])
  }else{
    return(c())
  }
}

.get_children <- function(data, fam_id){

  chil <- data$families[[fam_id]]$CHIL

  if(is.null(chil)){
    
    return(c())
    
  }else{
    
    byears <- sapply(chil, function(x){
      byear <- data$individuals[[x]]$BIRT$YEAR
      if(is.null(byear)) NA else byear
    })
    
    border <- order(byears)
    
    return(chil[border])
  }
}


