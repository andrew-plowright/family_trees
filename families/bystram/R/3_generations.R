set_relative_generations <- function(data, init_id){
  
  # Function: Go up ancestor tree from 'init_id'
  .set_gen_ansc <- function(fam_ID, child_gen){
    
    fam <- data$families[[fam_ID]]
    
    for(child_ID in fam$CHIL){
      
      data$individuals[[child_ID]][["gen_relative"]] <<- child_gen
    }
    
    for(spouse_ID in c(fam$HUSB, fam$WIFE)){
      
      spouse <- data$individuals[[spouse_ID]]
      
      data$individuals[[spouse_ID]][["gen_relative"]] <<- child_gen - 1
      
      if('FAMC' %in% names(spouse)){
        .set_gen_ansc(spouse$FAMC, child_gen - 1)
      }
      
    }
  }
  
  # Function: Go down descendant tree from 'init_id'
  .set_gen_desc <- function(fam_ID, spouse_gen){
    
    fam <- data$families[[fam_ID]]
    
    for(child_ID in fam$CHIL){
      
      #cat(child_ID, ': gen', spouse_gen + 1, '\n')
      
      data$individuals[[child_ID]][["gen_relative"]] <<- spouse_gen + 1
      
      for(fam_id2 in data$individuals[[child_ID]][["FAMS"]]){
        .set_gen_desc(fam_id2, spouse_gen + 1)
      }
      
    }
    
    for(spouse_ID in c(fam$HUSB, fam$WIFE)){
      
      data$individuals[[spouse_ID]][["gen_relative"]] <<- spouse_gen
    }
  }
  
  # Get initial individual
  ind <- data$individuals[[init_id]]
  
  # Set generation of ancestors
  .set_gen_ansc(ind$FAMC, child_gen = 0)
  
  # Set generation of descendants
  for(fam_id in ind$FAMS){
    .set_gen_desc(fam_id, spouse_gen = 0)
  }
  
  # Cycle through families and assign remaining relative generations
  for(fam_id in names(data$families)){
    fam <- data$families[[fam_id]]
    
    .get_rel_gen <- function(id){
      gen_rel <- data$individuals[[id]][['gen_relative']]
      if(!is.null(gen_rel)) gen_rel else NA
    } 
    
    spouse_gens <- sapply(c(fam$HUSB, fam$WIFE), .get_rel_gen)
    child_gens  <- sapply(fam$CHIL, .get_rel_gen)
    
    #if(all(is.na(c(spouse_gens, child_gens)))) stop("Orphaned family!:", fam_id)
    
    spouse_gen <- unique(na.omit(spouse_gens))
    child_gen <- unique(na.omit(child_gens))
    
    if(length(spouse_gen) > 1) stop("Inconsistent spouse generations: ", fam_id)
    if(length(child_gen) > 1) stop("Inconsistent child generations: ", fam_id)
    
    if(length(spouse_gen) == 1 & length(child_gen) == 1){
      if(child_gen - spouse_gen != 1){
        stop("Inconsistent generations between spouse/children: ", fam_id)
      }
    }
    
    if(length(spouse_gen) == 0) spouse_gen <- child_gen - 1
    if(length(child_gen) == 0) child_gen <- spouse_gen + 1
    
    if(length(spouse_gen) == 1){
      for(id in c(fam$HUSB, fam$WIFE)) data$individuals[[id]][["gen_relative"]] <- spouse_gen
    }
    if(length(child_gen) == 1){
      for(id in fam$CHIL) data$individuals[[id]][["gen_relative"]] <- child_gen
    }
  }
    
  # Check if there are still missing generations
  missing_gens <- sapply(data$individuals, function(x) is.null(x$gen_relative))
  if(any(missing_gens)) stop("Some individuals still missing a relative generation")
  
  return(data)
  
}

### Helper functions ----

print_relative_generations <- function(data){
  
  gens <- lapply(data$individuals, function(x) x$gen_relative)
  gens <- unlist(gens[!sapply(gens, is.null)])
  
  for(gen in min(gens):max(gens)){
    
    gen_ids <- names(gens[gens == gen])
    
    cat('GENERATION: ', gen, ' (', length(gen_ids),' ppl.)', '\n', sep="")
    
    for(ind_id in gen_ids){
      cat('  [', ind_id, '] ', .get_ind_name(data$individuals[[ind_id]] ), '\n', sep='')
    }
  }
}

.get_ind_name <- function(ind){
  out <- paste0(ind[["NAME"]][["GIVN"]], ', ', ind[["NAME"]][["SURN"]])
  return(out)
}
