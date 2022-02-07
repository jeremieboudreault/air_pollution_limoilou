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


# Subset polluants measurements in Quebec city ---------------------------------


# Subset pollution data in Quebec.
POLATM_QC <- POLATM[NAPSID %in% STNS_QC$NAPSID, ]

# Add <NAME> and <DESC>.
POLATM_QC <- data.table::merge.data.table(
    x     = POLATM_QC,
    y     = STNS_QC,
    all.x = TRUE,
    by    = "NAPSID"
)


# Summary statistics -----------------------------------------------------------


# Extract number of observations per stations.
POLATM_QC_STATS <- POLATM_QC[, .(
    O3    = sum(Pollutant == "O3",    na.rm = TRUE),
    NO2   = sum(Pollutant == "NO2",   na.rm = TRUE),
    SO2   = sum(Pollutant == "SO2",   na.rm = TRUE),
    CO    = sum(Pollutant == "CO",    na.rm = TRUE),
    PM25  = sum(Pollutant == "PM2.5", na.rm = TRUE),
    PM10  = sum(Pollutant == "PM10",  na.rm = TRUE),
    LONG  = unique(Longitude),
    LAT   = unique(Latitude)
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


qs::qsave(POLATM_QC, file.path("data", "NAPS_cleaned_qc.qs"))

