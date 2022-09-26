# naps_helpers.R


# Columns names ----------------------------------------------------------------


# Colnames for O3, PM10, NO2, SO2, CO
cnames_o3 <- cnames_pm10 <- cnames_no2 <- cnames_so2 <- cnames_co <- c(
    "POLLUTANT", "NAPSID", "CITY", "PROVINCE", "LATITUDE", "LONGITUDE", "DATE",
    paste0("H", 1:24)
)

# Colnames for PM2.5.
cnames_pm25 <- c(
    "POLLUTANT", "METHOD", "NAPSID", "CITY", "PROVINCE", "LATITUDE", "LONGITUDE",
    "DATE", paste0("H", 1:24)
)


# Function to load a raw pollutant file from NAPS ------------------------------


load_pol <- function(file, pol = c("o3", "pm25", "pm10", "no2", "so2", "co")) {

    # First read first 10 lines.
    lines <- readLines(file, n = 10L)

    # Check for last occurrence of "note" in the header.
    last_line <- tail(which(tolower(substr(lines, 1L, 4L)) == "note"), 1L)

    # Load file from the note line + 1.
    x <- data.table::fread(file, skip = last_line + 1L, fill = TRUE, sep = ",")

    # Update names of columns and check for correct number of columns.
    if (ncol(x) == length(get(paste0("cnames_", pol)))) {
        names(x) <- get(paste0("cnames_", pol))
    } else {
        stop("Number of columns is not as intended.")
    }

    # Fix the uncorrect date format for the class of <DATE>.
    if (class(x$DATE)[1L] == "character") {
        x$DATE <- as.Date(x$DATE, format = "%m/%d/%Y")
    } else if (class(x$DATE)[1L] == "integer") {
        x$DATE <- as.Date(as.character(x$DATE), format = "%Y%m%d")
    } else if (class(x$DATE)[1L] == "IDate") {
        x$DATE <- as.Date(x$DATE)
    }

    # Fix numeric class of values <H1-H24> for NO2 values.
    if (pol == "no2") {
        for (h in 1:24) {
            x[[paste0("H", h)]] <- as.numeric(x[[paste0("H", h)]])
        }
    }

    # Return the table.
    return(x)

}


# Helper functions -------------------------------------------------------------


# Function to look that all values of a row are equal.
alleq <- function(x) {
    sapply(1:nrow(x), function(w) length(unique(x[w, ])) == 1L)
}

# Function to get the class of all rows in a data.table.
getclass <- function(x) {
    sapply(x, class)
}

