setwd("families/bystram")

# SOURCE SCRIPTS ----

# Processing functions
source('R/read_gedcom.R')
source('R/cleanup.R')
source('R/generations.R')
source('R/positions.R')

# Corrections
source('corrections/bystram_data_corrections.R')

# SET VARIABLES ----

# Project folder
gedcom_files <- list.files("gedcom", recursive = TRUE, pattern = "\\.ged$", full.names = TRUE)
json_file    <- file.path("json", 'bystram_data_cleaned.json')

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

