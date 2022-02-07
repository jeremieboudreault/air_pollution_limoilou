# 3_filter_quebec_stns.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : jeremie [dot] bodreault [at] inrs [dot] ca
# Depends : R (v4.1.2)
# License : None



# Libraries --------------------------------------------------------------------


library(data.table)
library(leaflet)
library(openxlsx)
library(qs)


# Imports ----------------------------------------------------------------------


# Load data.
POLATM <- qs::qread(file.path("data", "NAPS_cleaned.qs"))

# Load stations.
STNS <- data.table::setDT(openxlsx::read.xlsx(
    xlsxFile = file.path("data", "naps_stations.xlsx"),
    startRow = 2L
))


# Filter stations in Quebec ----------------------------------------------------


# Extract STNS in Quebec.
STNS_QC <- STNS[Ville == "QUEBEC", c(
    "Identifiant_SNPA",
    "Nom.de.la.station"
)]

# Rename the columns.
names(STNS_QC) <- c("NAPSID", "RNAME")
STNS_QC$NAPSID <- as.integer(STNS_QC$NAPSID)

# Rename somes stations.
STNS_QC[RNAME == "QUÉBEC-VIEUX-LIMOILOU (DES SABLES)", NAME := "Vieux-Limoilou"]
STNS_QC[RNAME == "QUÉBEC- COLLÈGE ST-CHARLES-GARNIER", NAME := "Montcalm"]
STNS_QC[RNAME == "QUÉBEC-ÉCOLE LES PRIMEVÈRES",        NAME := "Champigny"]
