library(magrittr)

source("families/tache/R/tache_data_processing_functions.R")

xlsx_file <- "families/tache/xlsx/tache_data_cleaned.xlsx"
data_cleaned_file <- "families/tache/json/tache_data_cleaned.json"
collapsed_file <- "families/tache/json/tache_collapsed_branches.json"


# Read all data ----

# Read in data
in_data <- xlsx::read.xlsx2(xlsx_file, "Individuals", check.names=F)
fam_data <- xlsx::read.xlsx2(xlsx_file, "Families", check.names=F)

# NAs
in_data[in_data == ""] <- NA
fam_data[["Collapse"]] <- as.logical(fam_data[["Collapse"]]) %in% TRUE

# Unique IDs
in_data %>% qa


# Cleaned data ----

  # Locations
  in_data %<>% merge_locations
  
  # Title
  in_data %<>% merge_title_with_name
  
  # Set initial positions
  in_data %<>% initial_positions
  
  # Populate JSON file
  in_data %>% 
    cleaned_data %>%
    jsonlite::write_json(data_cleaned_file, pretty = TRUE, auto_unbox=TRUE)

# Collapsed branches ----
  
  collapsed_branches <- as.list(sapply(fam_data[fam_data[["Collapse"]], "ID"], function(id){
    
    nrow(in_data[in_data$FAMC %in% id,])
    
  }))
  
  jsonlite::write_json(collapsed_branches, collapsed_file, pretty = TRUE, auto_unbox=TRUE)
  