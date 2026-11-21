# =============================================================================
# R/prepare_map_data.R — Assignment 9, Step 1 (run ONCE, from the website root)
# EPPS 6356 Data Visualization, Fall 2026 — Nedret Sen Cavus
#
#   Rscript R/prepare_map_data.R        (Terminal)
#   source("R/prepare_map_data.R")      (R console, working dir = website root)
#
# Input : data/raw/tea_discipline_district_YYYY-YY.csv  (TEA downloads)
# Output: data/tea_discipline_district.csv   (district x year measures)
#         data/ccd_crosswalk_tx.csv          (CDN -> NCES LEAID / Census GEOID)
#         data/tx_school_districts.rds       (sf polygons, EPSG:4326 storage CRS)
#         ...and identical copies in _dashboard/data/ for the deployed app.
# =============================================================================

# ---- Packages ---------------------------------------------------------------
needed <- c("tidyverse", "janitor", "sf", "tigris", "jsonlite")
not_installed <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(not_installed) > 0) {
  stop("Install these packages first:\n  install.packages(c(",
       paste0('"', not_installed, '"', collapse = ", "), "))", call. = FALSE)
}
library(tidyverse)
library(janitor)
library(sf)
library(tigris)
library(jsonlite)
options(tigris_use_cache = TRUE)

# ---- Check that we are in the website root ----------------------------------
if (!file.exists("_quarto.yml")) {
  stop("Run this script from your website folder (the one containing _quarto.yml).\n",
       "Current working directory: ", getwd(), call. = FALSE)
}
if (!file.exists(file.path("R", "map_data_functions.R"))) {
  stop("R/map_data_functions.R is missing.", call. = FALSE)
}
source(file.path("R", "map_data_functions.R"))

# ---- 1. TEA discipline files ------------------------------------------------
raw_dir <- file.path("data", "raw")
tea_files <- list.files(raw_dir,
                        pattern = "^tea_discipline_district_20[0-9]{2}-[0-9]{2}\\.csv$",
                        full.names = TRUE)
if (length(tea_files) == 0) {
  stop("No TEA files found in ", raw_dir, ". Save each download as e.g.\n",
       "  data/raw/tea_discipline_district_2023-24.csv", call. = FALSE)
}
message("Reading ", length(tea_files), " TEA file(s):\n  ", paste(basename(tea_files), collapse = "\n  "))
disc <- build_discipline_table(tea_files)
message("TEA table: ", n_distinct(disc$cdn), " districts x ", n_distinct(disc$year), " years (",
        nrow(disc), " rows).")

# ---- 2. CDN -> LEAID crosswalk (NCES CCD 2022 directory) ---------------------
message("Downloading the NCES CCD crosswalk (about 1-2 minutes)...")
xwalk <- get_ccd_crosswalk(ccd_year = 2022)
message("Crosswalk: ", nrow(xwalk), " Texas LEAs.")

# ---- 3. Census boundaries (TIGER 2023 cartographic file, 1:500k) -------------
message("Downloading Census school-district boundaries with tigris...")
districts <- get_tx_boundaries(tiger_year = 2023)
message("Boundaries: ", nrow(districts), " polygons; CRS = ", st_crs(districts)$input)

# ---- 4. Write outputs (website copy + dashboard copy) ------------------------
for (out_dir in c("data", file.path("_dashboard", "data"))) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  write_csv(disc,  file.path(out_dir, "tea_discipline_district.csv"))
  write_csv(xwalk, file.path(out_dir, "ccd_crosswalk_tx.csv"))
  saveRDS(districts, file.path(out_dir, "tx_school_districts.rds"))
}
message("Done. Files written to data/ and _dashboard/data/.")
