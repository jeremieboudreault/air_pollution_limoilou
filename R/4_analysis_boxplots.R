# 4_analysis_boxplots.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : Prenom.Nom@inrs.ca
# Depends : R (v4.2.1)
# Imports : jtheme (v0.0.2) [https://github.com/jeremieboudreault/jtheme]
# License : None


# Librairies -------------------------------------------------------------------


library(data.table)
library(ggplot2)
library(jtheme)


# Imports ----------------------------------------------------------------------


POLATM_QC <- data.table::fread("data/naps/naps_cleaned_qccity.csv", dec = ",")


# Filter out pollutant only available at Vieux Limoilou station ----------------


POLATM_QC <- POLATM_QC[!(POLLUTANT %in% c("CO", "SO2")), ]


# Extract daily metrics --------------------------------------------------------


# Melt results.
POLATM_QC_MELT <- data.table::melt.data.table(
    data          = POLATM_QC,
    measure.vars  = c("MEAN", "MAX"),
    id.vars       = c("NAME", "POLLUTANT", "DATE"),
    variable.name = "METRIC",
    value.name    = "VALUE"
)

# Rename lavels.
POLATM_QC_MELT[METRIC == "MAX", METRIC := "Maximum sur 24h"]
POLATM_QC_MELT[METRIC == "MEAN", METRIC := "Moyenne sur 24h"]


# Plot :: Boxplot of pollutants concentration ----------------------------------


# Plot.
ggplot(
    data    = POLATM_QC_MELT[METRIC == "Maximum sur 24h", ],
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
    facets = POLLUTANT ~ METRIC,
    scales = "free_y",

) +
scale_fill_manual(
    values = RColorBrewer::brewer.pal(4L, "Accent")
) +
labs(
    title    = "Concentration de polluants atmosphériques dans la Ville de Québec",
    x        = "Quartier",
    y        = "Concentration du polluant"
) +
jtheme(borders = "all")

# Save.
jtheme::save_ggplot("plots/fig_2_1_boxplots_max.jpg", size = "sqrbig")

# Plot.
ggplot(
    data    = POLATM_QC_MELT[METRIC == "Moyenne sur 24h", ],
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
    facets = POLLUTANT ~ METRIC,
    scales = "free",

) +
scale_fill_manual(
    values = RColorBrewer::brewer.pal(4L, "Accent")
) +
labs(
    title    = "Concentration de polluants atmosphériques dans la Ville de Québec",
    x        = "Quartier",
    y        = "Concentration du polluant"
) +
jtheme(borders = "all")

# Save.
jtheme::save_ggplot("plots/fig_2_2_boxplots_moy.jpg", size = "sqrbig")

