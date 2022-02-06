# 3_filter_quebec_stns.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : jeremie [dot] bodreault [at] inrs [dot] ca
# Depends : R (v4.1.2)
# License : None



# Libraries --------------------------------------------------------------------


library(data.table)
library(qs)


# Imports ----------------------------------------------------------------------


# Load data.
POLATM <- qs::qread(file.path("data", "NAPS_cleaned.qs"))

# Load stations.
STNS <- data.table::setDT(openxlsx::read.xlsx(
    file.path("data", "StationsNAPS-StationsSNPA.xlsx"),
    startRow = 2L
))


