# 3_filter_qccity_stns.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : Prenom.Nom@inrs.ca
# Depends : R (v4.2.1)
# License : None



# Libraries --------------------------------------------------------------------


library(data.table)
library(leaflet)
library(qs)


# Imports ----------------------------------------------------------------------


# Load data.
POLATM <- qs::qread(file.path("data", "naps", "naps_cleaned.qs"))

# Load stations.
STNS <- data.table::fread(
    input = file.path("data", "naps", "naps_stations.csv"),
    sep   = ",",
    fill  = TRUE,
    skip  = 4L
)

# Remove unwanted rows.
i <- which(STNS$Identifiant_SNPA == "**********Definitions_Définitions**********")
STNS <- STNS[-(i:nrow(STNS)), ]


# Filter stations in Quebec ----------------------------------------------------


# Extract STNS in Quebec.
STNS_QC <- STNS[Ville == "QUEBEC", c("Identifiant_SNPA", "Nom de la station")]

# Rename the columns.
names(STNS_QC) <- c("NAPSID", "RNAME")
STNS_QC$NAPSID <- as.integer(STNS_QC$NAPSID)


# Subset polluants measurements in Quebec city ---------------------------------


# Subset pollution data in Quebec.
POLATM_QC <- POLATM[NAPSID %in% STNS_QC$NAPSID & Date > "2010-01-01", ]

# Add <NAME> and <DESC>.
POLATM_QC <- data.table::merge.data.table(
    x     = POLATM_QC,
    y     = STNS_QC,
    all.x = TRUE,
    by    = "NAPSID"
)


# Summary statistics -----------------------------------------------------------


# Add <NAME>.
POLATM_QC[RNAME == "QUÉBEC-VIEUX-LIMOILOU (DES SABLES)", NAME := "Vieux-Limoilou"]
POLATM_QC[RNAME == "QUÉBEC- COLLÈGE ST-CHARLES-GARNIER", NAME := "Montcalm"]
POLATM_QC[RNAME == "QUÉBEC-ÉCOLE LES PRIMEVÈRES",        NAME := "Champigny"]
POLATM_QC[RNAME == "QUÉBEC - HENRI IV",                  NAME := "Henry IV"]

# Extract number of observations per stations.
POLATM_QC_STATS <- POLATM_QC[, .(
    O3    = sum(Pollutant == "O3",    na.rm = TRUE),
    NO2   = sum(Pollutant == "NO2",   na.rm = TRUE),
    SO2   = sum(Pollutant == "SO2",   na.rm = TRUE),
    CO    = sum(Pollutant == "CO",    na.rm = TRUE),
    PM25  = sum(Pollutant == "PM2.5", na.rm = TRUE),
    PM10  = sum(Pollutant == "PM10",  na.rm = TRUE),
    LONG  = mean(Longitude),
    LAT   = mean(Latitude)
),
by = c("NAPSID", "RNAME", "NAME")]

# Convert to Markdown table.
knitr::kable(POLATM_QC_STATS[, -c("LONG", "LAT")])


# Maps stations with basic information -----------------------------------------


# Leaflet map.
leaflet::leaflet(
)  %>%
leaflet::addProviderTiles(
    provider = leaflet::providers$CartoDB.Voyager
) %>%
leaflet::addCircleMarkers(
    data         = POLATM_QC_STATS,
    lng          = ~ LONG,
    lat          = ~ LAT,
    radius       = 5,
    stroke       = TRUE,
    color        = "black",
    weight       = 1.6,
    opacity      = 0.8,
    fillColor    = "orange",
    fillOpacity  = 1L,
    label        = ~ NAME,
    labelOptions = leaflet::labelOptions(noHide = TRUE)
)


# Exports ----------------------------------------------------------------------


qs::qsave(POLATM_QC, file.path("data", "naps", "naps_cleaned_qc.qs"))

