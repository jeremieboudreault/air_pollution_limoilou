# 2_clean_naps_database.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : Prenom.Nom@inrs.ca
# Depends : R (v4.2.1)
# License : None


# Note : Files downloaded from NAPS are messy with different headers,
#        names and columns. In this script, we clean the NAPS database
#        in a ready-to-use format.


# Librairies -------------------------------------------------------------------


library(data.table)


# Helpers ----------------------------------------------------------------------


source("R/functions/naps_helpers.R")


# Globals ----------------------------------------------------------------------


# Path to NAPS data.
naps_path <- "/Volumes/ExtDataPhD/naps"

# All pollutant files.
naps_files <- list.files(file.path(naps_path, "raw"))


# Create a table of NAPS files -------------------------------------------------


# Split files by pollutant and year.
pol_year <- do.call(cbind, tstrsplit(naps_files, "_")) |>
    as.data.table() |>
    setnames(new = c("POL", "YEAR"))

# Fix <YEAR> to integer format.
pol_year <- pol_year [, YEAR := as.integer(substr(YEAR, 1L, 4L))]

# Summarize the table.
pol_year_summ <- pol_year[
    j  = .(YEAR_MIN = min(YEAR), YEAR_MAX = max(YEAR)),
    by = "POL"
]
