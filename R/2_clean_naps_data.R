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


