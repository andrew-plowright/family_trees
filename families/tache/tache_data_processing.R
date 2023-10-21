library(magrittr)

source("families/tache/R/tache_data_processing_functions.R")

xlsx_file <- "families/tache/xlsx/tache_data_cleaned.xlsx"
json_file <- "families/tache/json/tache_data_cleaned.json"

# Read in data
in_data <- xlsx::read.xlsx2(xlsx_file, 1, check.names=F)

# Clean
in_data[in_data == ""] <- NA
in_data$Collapse <- in_data$Collapse %in% "Yes"

# Unique IDs
in_data %>% qa

# Locations
in_data %<>% merge_locations

# Title
in_data %<>% merge_title_with_name

# Set initial positions
in_data %<>% initial_positions

# Populate JSON file
out_data <- populate_json(in_data)

# Populate JSON: families
jsonlite::write_json(out_data, json_file, pretty = TRUE)

