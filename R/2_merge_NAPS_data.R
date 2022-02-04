# 2_merge_NAPS_data.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : jeremie [dot] bodreault [at] inrs [dot] ca
# Depends : R (v4.1.2)
# License : None


# Librairies -------------------------------------------------------------------


library(data.table)


# Parameters -------------------------------------------------------------------


years   <- seq.int(2000L, 2019L)
pols    <- c("O3", "PM25", "PM10", "CO", "NO2", "SO2")
choices <- expand.grid(years, pols)


# Load all files ---------------------------------------------------------------


pols_list <- lapply(
    X    = paste0("data/NAPS/", choices[[2L]], "_", choices[[1L]], ".csv"),
    FUN  = data.table::fread,
    skip = 5L
)

