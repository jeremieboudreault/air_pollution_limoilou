# 1_download_NAPS_data.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : jeremie [dot] bodreault [at] inrs [dot] ca
# Depends : R (v4.1.2)
# License : None



# Libraries --------------------------------------------------------------------


library(data.table)


# Set the parameters for download ----------------------------------------------


# Years to be downloaded. (2020 and 2021 are not available)
years <- seq.int(2000L, 2019L)

# Air pollutants to be downloaded. (These are the classic ones)
pol_types <- c("O3", "PM25", "PM10", "NO2", "SO2", "CO")


# Set the URL where the files are located --------------------------------------


# First part of the URL.
url_str_1 <- paste0(
    "https://data.ec.gc.ca/data/air/monitor/",
    "national-air-pollution-surveillance-naps-program/",
    "Data-Donnees/"
)

# Second part of the URL.
url_str_2 <- "/ContinuousData-DonneesContinu/HourlyData-DonneesHoraires/"


# Download ---------------------------------------------------------------------


# Loop on all pollutants.
for (pol_type in pol_types) {

    # Loop on all years.
    for (year in years) {

        # Set the filename (example : O3_2019.csv)
        filename <- paste0(pol_type, "_", year, ".csv")

        # Download the file from the URL (files are located in data/NAPS/)
        download.file(
            url      = paste0(url_str_1, year, url_str_2, filename),
            destfile = file.path("data", "NAPS", filename)
        )

    }
}
