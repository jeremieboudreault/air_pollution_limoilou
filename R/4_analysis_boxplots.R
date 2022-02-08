# 4_analysis_boxplots.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : jeremie [dot] bodreault [at] inrs [dot] ca
# Depends : R (v4.1.2)
# License : None


# Librairies -------------------------------------------------------------------


library(data.table)
library(ggplot2)
library(qs)


# Imports ----------------------------------------------------------------------


POLATM_QC <- qs::qread(file.path("data", "NAPS_cleaned_qc.qs"))


# Filter out pollutant only availble at Vieux Limoilou station -----------------


POLATM_QC <- POLATM_QC[!(Pollutant %in% c("CO", "SO2"))]


# Compute daily metrics --------------------------------------------------------


# Defines columns for measurements.
cols <- c(paste0("H0", 1:9), paste0("H",10:24))

# Daily maximum and daily mean.
POLATM_QC[, MAX_24H  := apply(.SD, 1L, max, na.rm = TRUE),  .SDcols = cols]
POLATM_QC[, MEAN_24H := apply(.SD, 1L, mean, na.rm = TRUE), .SDcols = cols]

# Melt results.
POLATM_QC_MELT <- data.table::melt.data.table(
    data         = POLATM_QC,
    measure.vars = c("MAX_24H", "MEAN_24H"),
    id.vars      = c("NAME", "Pollutant", "Date")
)

# Rename columns.
names(POLATM_QC_MELT) <- c("NAME", "POL", "DATE", "VAR", "VALUE")

# Convert date to Date format.
POLATM_QC_MELT[, DATE := as.Date(as.character(DATE), format = "%Y%m%d")]


# Plot :: Boxplot of pollutants concentration ----------------------------------


# Plot.
ggplot(
    data    = POLATM_QC_MELT,
    mapping = aes(
        x = NAME,
        y = VALUE
    )
) +
geom_boxplot(
    mapping     = aes(fill = NAME),
    show.legend = FALSE
) +
facet_grid(
    facets = POL ~ VAR,
    scales = "free",

) +
scale_fill_manual(
    values = RColorBrewer::brewer.pal(3L, "Accent")
) +
labs(
    title    = "Concentration de polluants atmosphériques dans trois station de la Ville de Québec",
    subtitle = "Moyenne et maximum sur 24h (2010-2019)",
    x        = "Quartier",
    y        = "Concentration du polluant"
)

# Save.
ggplot2::ggsave(
    filename = file.path("out", "boxplots.jpg"),
    width    = 8L,
    height   = 8L
)
