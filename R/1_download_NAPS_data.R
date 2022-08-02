# 1_download_naps_data.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : Prenom.Nom@inrs.ca
# Depends : R (v4.2.1)
# License : None



# Libraries --------------------------------------------------------------------


library(data.table)


# Set the parameters for download ----------------------------------------------


# Years to be downloaded.
years <- seq.int(1979L, 2022L)

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

        # Message.
        msg <- paste0("Downloading ", pol_type, " for ", year, ".")

        # Set the filename (example : O3_2019.csv)
        filename <- paste0(pol_type, "_", year, ".csv")

        # Download the file from the URL.
        tryCatch(
            expr = { download.file(
                url      = paste0(url_str_1, year, url_str_2, filename),
                destfile = file.path("data", "naps", "raw", filename),
                quiet    = TRUE
            )},
            error   = function(w) {
                assign("msg", paste0(msg, " >> No data") , envir = .GlobalEnv)
                file.remove(file.path("data", "naps", "raw", filename))
            },
            warning = function(w) {
                assign("msg", paste0(msg, " >> No data") , envir = .GlobalEnv)
                file.remove(file.path("data", "naps", "raw", filename))
            }
        )

        # Message
        message(msg)

    }
}
