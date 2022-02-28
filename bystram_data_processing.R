# SOURCE SCRIPTS ----

source('R/1_read_gedcom.R')
source('R/2_cleanup.R')
source('R/3_generations.R')
source('R/4_positions.R')


# SET VARIABLES ----

# Corrections
source('bystram_data_corrections.R')

# Project folder
proj_folder  <- 'C:/Users/andre/Dropbox/Work/Personal/BystramGeneology'
gedcom_files <- list.files(file.path(proj_folder, "GEDCOM"), recursive = TRUE, pattern = "\\.ged$", full.names = TRUE)
json_file    <- file.path(proj_folder, "JSON", 'data.json')


# PROCESSING ----

## 1) Download data ----

## 2) Read GEDOM file ----
data <- read_gedcom(gedcom_files)

## 2) Clean data ----
data <- clean_data(data, name_swaps, individual_corrections, family_corrections, delete_individuals, delete_families)
#print_individuals(data)

## 3) Set relative generation ----
data <- set_relative_generations(data, init_id= "I109")
#print_relative_generations(data)

## 4) Set lateral positions ----
data <- set_positions(data, init_id='I213')

# Write data
jsonlite::write_json(data, json_file, pretty = TRUE)

