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


# Create a table of NAPS files -------------------------------------------------


# Split files by pollutant and year.
pol_year <- do.call(cbind, tstrsplit(naps_files, "_")) |>
    as.data.table() |>
    setnames(new = c("POL", "YEAR"))

# Fix <YEAR> to integer format.
pol_year <- pol_year [, YEAR := as.integer(substr(YEAR, 1L, 4L))]

# Summarize the table.
pol_year_summ <- pol_year[
    j  = .(YEAR_MIN = min(YEAR), YEAR_MAX = max(YEAR)),
    by = "POL"
]


# Batch processing of all pollutant -------------------------------------------


# Loop on all pollutant. Save results to <naps_path>.
for (pol in pol_year_summ$POL) {

    # Years available for the pollutant.
    years <- pol_year_summ[POL == pol, seq.int(YEAR_MIN, YEAR_MAX)]

    # Message.
    message("Processing ", pol, " from ", min(years), " to ", max(years), ".")

    # Files for the pollutant.
    files_pol <- file.path(naps_path, "raw", paste0(pol, "_", years, ".csv"))

    # Load all files of the pollutant.
    data_pol <- lapply(files_pol, load_pol, pol = tolower(pol))

    # Checks for the number of columns.
    if (!all(alleq(do.call(cbind, lapply(data_pol, ncol))))) {
        stop("Inconsistent number of columns for ", pol, ".")
    }

    # Check for the names of the columns.
    if (!all(alleq(do.call(cbind, lapply(data_pol, colnames))))) {
        stop("Inconsistent columns names for ", pol, ".")
    }

    # Check for the format of the columns,
    if (!all(alleq(do.call(cbind, lapply(data_pol, getclass))))) {
        stop("Inconsistent classes of the columns for ", pol, ".")
    }

    # Bind all tables.
    data_pol_bind <- do.call(rbind, data_pol)

    # Replace -999 and -9999 by NA.
    for (h in 1:24) {

        # Fix values to NA (-999)
        data.table::set(
            x     = data_pol_bind,
            j     = paste0("H", h),
            i     = which(data_pol_bind[[paste0("H", h)]] %in% c(-999, -9999)),
            value = NA
        )

        # Check if negative values remains.
        if (any(data_pol_bind[[paste0("H", h)]] < -900, na.rm = TRUE)) {
            stop("Values of -999/-9999 remains in the data for column ", h, ".")
        }
    }

    # Save to .csv.
    data.table::fwrite(
        x    = data_pol_bind,
        file = file.path(naps_path, paste0(pol, ".csv")),
        dec  = ",",
        sep  = ";"
    )

    # Message.
    message("Saved to ", naps_path, "/", pol, ".csv.")

}


# Load all files and create a new database -------------------------------------


# Load all files in a list.
pols <- lapply(
    X   = file.path(naps_path, paste0(pol_year_summ$POL, ".csv")),
    FUN = data.table::fread,
    sep = ";",
    dec = ","
)

# Add names.
names(pols) <- pol_year_summ$POL

# Remove <METHOD> columns for PM2.5.
pols[["PM25"]][, METHOD := NULL]

# Check for the number, names and format of columns.
all(alleq(do.call(cbind, lapply(pols, ncol))))
all(alleq(do.call(cbind, lapply(pols, colnames))))
all(alleq(do.call(cbind, lapply(pols, getclass))))

# Bind all pollutant.
pols_all <- data.table::rbindlist(l = pols, use.names = TRUE)

# Compute <MEAN>, <MAX> and <MIN>.
pol_mat <- as.matrix(pols_all[, paste0("H", 1:24)])
pols_all[, MEAN     := apply(pol_mat, 1L, mean, na.rm = FALSE)]
pols_all[, MAX      := apply(pol_mat, 1L, max,  na.rm = FALSE)]
pols_all[, MIN      := apply(pol_mat, 1L, min,  na.rm = FALSE)]
pols_all[, MEAN_WNA := apply(pol_mat, 1L, mean, na.rm = TRUE)]
pols_all[, MAX_WNA  := apply(pol_mat, 1L, max,  na.rm = TRUE)]
pols_all[, MIN_WNA  := apply(pol_mat, 1L, min,  na.rm = TRUE)]

# Count number of hourly NAs.
pols_all[, N_NA     := apply(pol_mat, 1L, function(w) sum(is.na(w)))]

# Fix values when all values are NA.
pols_all[N_NA == 24L, `:=`(MEAN_WNA = NA, MAX_WNA = NA, MIN_WNA = NA)]

# Drop City, province, latitute, longitude, and hourly measurements.
pols_final <- pols_all[, -c(
    "CITY", "PROVINCE", "LATITUDE", "LONGITUDE", paste0("H", 1:24)
)]

# Reorder cols.
data.table::setcolorder(pols_final,
                        c("NAPSID", "DATE", "POLLUTANT", "MEAN", "MAX", "MIN", "MEAN_WNA", "MAX_WNA", "MIN_WNA", "N_NA")
)
