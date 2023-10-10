clean_data <- function(data, name_swaps, individual_corrections, family_corrections, delete_individuals, delete_families){
  
  # INDIVIDUALS
  for(id in names(data$individuals)){
    
    if(id %in% delete_individuals){
      data$individuals[[id]] <- NULL
      next
    }
    
    ind <- data$individuals[[id]]
    
    # Clean up dates
    for(field in c('BIRT', 'DEAT')){
      if(length(ind[[field]]) == 0){
        data$individuals[[id]][[field]] <- NULL
      }else{
        
        # Clean up dates
        if(!is.null(ind[[field]][['DATE']])){
          scraped_date <- .scrape_date(ind[[field]][["DATE"]])
          data$individuals[[id]][[field]][['CIRCA']] <- scraped_date$circa
          data$individuals[[id]][[field]][['YEAR']]  <- scraped_date$year
        }
        
        # Clean up places
        plac <- ind[[field]][["PLAC"]]
        if(!is.null(plac)){
          
          # Swap patterns
          matched <- sapply(name_swaps$from, function(swap) grepl(swap, plac))
          for(j in which(matched)){
            plac <- gsub(name_swaps[j, 'from'], name_swaps[j, 'to'], plac)
            
          }
          data$individuals[[id]][[field]][['PLAC']] <- plac
          
          # Remove trailing virgule
          data$individuals[[id]][[field]][['PLAC']] <- gsub(",$", "", data$individuals[[id]][[field]][['PLAC']])
        }
      }
    }
    
    # NAMES
    for(field in c('GIVN', 'SURN')){
      
      name <- ind[["NAME"]][[field]]
      
      if(!is.null(name)){
        # Remove parentheses
        name <- gsub('\\(|\\)', '', name)
        
        # Remove 'linea'
        name <- gsub(' linia.*', '', name)
        
        # Remove 0
        name <- gsub('0', '', name)
        
        # Nullify
        if(grepl('N1\\.|N\\.|No Name', name)) name <- NULL
        
        data$individuals[[id]][["NAME"]][[field]] <- name 
      }
    }
    
    # Deleted families
    for(field in c('FAMS', "FAMC")){
      if(!is.null(data$individuals[[id]][[field]])){
        fam <- data$individuals[[id]][[field]]
        fam <- fam[!fam %in% delete_families]
        if(length(fam) == 0) fam <- NULL
        data$individuals[[id]][[field]] <- fam
      }
    }
     
    
    # INDIVIDUAL CORRECTIONS
    if(id %in% names(individual_corrections)){
      data$individuals[[id]] <- .merge_lists(individual_corrections[[id]], data$individuals[[id]])
    }
  }
  
  # FAMILIES
  for(id in names(data$families)){
    
    if(id %in% delete_families){
      data$families[[id]] <- NULL
      next
    }
    
    fam <- data$families[[id]]
    
    # Clean marriage dates
    for(field in 'MARR'){
      if(length(fam[[field]]) == 0){
        data$families[[id]][[field]] <- NULL
      }else{
        
        # Clean up dates
        if(!is.null(fam[[field]][['DATE']])){
          scraped_date <- .scrape_date(fam[[field]][["DATE"]])
          data$families[[id]][[field]][['CIRCA']] <- scraped_date$circa
          data$families[[id]][[field]][['YEAR']]  <- scraped_date$year
        }
      }
    }
    
    # Deleted individuals
    for(field in c('HUSB', "WIFE", "CHIL")){
      inds <- fam[[id]][[field]]
      if(!is.null(inds)){
        
        inds <- inds[!inds %in% delete_individuals]
        if(length(inds) == 0) inds <- NULL
        data$families[[id]][[field]] <- inds
      }
    }
    
    # FAMILY CORRECTIONS
    if(id %in% names(family_corrections)){
      data$families[[id]] <- .merge_lists(family_corrections[[id]], data$families[[id]])
    }
  }
  
  return(data)
}

# x <- c('7 Sep 1752',
# '20 May 1715',
# '15/0/1747',
# 'ca. 1710',
# 'ca.1700',
# 'ca1650',
# 'po 12.4.1649',
# '?.10x.1983',
# '1675-1678'
# )

.scrape_date <- function(date_string){
  
  circa <- grepl('ca', date_string)
  
  date_split <- strsplit(date_string, ' |-|\\.|/|[alpha]')[[1]]
  
  year <- date_split[nchar(date_split) == 4]
  year <- as.integer(year)
  if(length(year) > 1){
    year <- floor(mean(year))
    circa <- TRUE
  }
  
  list(
    circa = circa,
    year = year
  )
}


.merge_lists = function(...) {
  
  stack = rev(list(...))
  names(stack) = rep('', length(stack))
  result = list()
  
  while (length(stack)) {
    # pop a value from the stack
    obj = stack[[1]]
    root = names(stack)[[1]]
    stack = stack[-1]
    
    if (is.list(obj) && !is.null(names(obj))) {
      if (any(names(obj) == '')) {
        stop("Mixed named and unnamed elements are not supported.")
      }
      
      # restack for next-level processing
      if (root != '') {
        names(obj) = paste(root, names(obj), sep='|')
      }
      stack = append(obj, stack)
    } else {
      # clear a path to store result
      path = unlist(strsplit(root, '|', fixed=TRUE))
      for (j in seq_along(path)) {
        sub_path = path[1:j]
        if (is.null(result[[sub_path]])) {
          result[[sub_path]] = list()
        }
      }
      result[[path]] = obj
    }
  }
  
  return(result)
}