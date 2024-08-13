library(magrittr)

setwd("D:/Projects/personal/family_trees/families/plowright")
source("R/plowright_data_processing_functions.R")

xlsx_file <- "xlsx/plowright_data_cleaned.xlsx"
data_cleaned_file <- "json/plowright_data_cleaned.json"


# Read all data ----

  # Read in individual data
  in_data <- xlsx::read.xlsx2(xlsx_file, "Individuals", check.names=F)
  in_data[in_data == ""] <- NA
  
  # Read in list of families to collapse
  collapse_families <- xlsx::read.xlsx2(xlsx_file, "Collapse", check.names=F)[,"Collapse"]
  
  # Read in list of "wide" spouses (i.e.: where the husband and wife nodes are not right next to eachother)
  wide_spouse <-  xlsx::read.xlsx2(xlsx_file, "Wide", check.names=F)[,1]
  
  # Unique IDs
  in_data %>% qa

# Clean data ----

  # Locations
  in_data %<>% merge_locations
  
  # Title
  in_data %<>% merge_title_with_name
  
  # Set initial positions
  in_data %<>% initial_positions
  
  # Populate JSON file
  full_data <- in_data %>% clean_data

  # Set family branches to collapse
  for(fam in collapse_families){
    full_data[["collapse"]][[fam]] <- length(full_data[["families"]][[fam]][["CHIL"]])
  }
  
  # Wide
  for(fam in wide_spouse){full_data[["families"]][[fam]][["wide"]] <- TRUE}
    
  # Write data
  jsonlite::write_json(full_data, data_cleaned_file, pretty = TRUE, auto_unbox=TRUE)
