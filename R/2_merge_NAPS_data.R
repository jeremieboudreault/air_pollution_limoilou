# 2_merge_naps_data.R


# Project : pollution_air_limoilou
# Author  : Jeremie Boudreault
# Email   : Prenom.Nom@inrs.ca
# Depends : R (v4.2.1)
# License : None


# Librairies -------------------------------------------------------------------


library(data.table)


# Load all downloaded files ----------------------------------------------------


# List files.
files_path <- file.path("/Volumes/ExtDataPhD/naps/")
files <- list.files(files_path)

# Split files into < 2008 and >= 2009.
files_year <- as.integer(substr(files, nchar(files) - 7L, nchar(files) - 4L))

# Files before 2008
pols_list_b2008 <- lapply(
    X      = file.path(files_path, files)[files_year <= 2008L],
    FUN    = data.table::fread,
    skip   = 5L
)

# Files after 2009.
pols_list_a2009 <- lapply(
    X      = file.path(files_path, files)[files_year >= 2009L],
    FUN    = data.table::fread,
    skip   = 7L
)

# Merge two lists.
pols_list <- c(pols_list_b2008, pols_list_a2009)


# Fix columns ------------------------------------------------------------------


# Note : PM2.5 dataset have 32 columns, while other have 31. Names also differ
#        from datasets, but the information is the same. Here, we harmonize all datasets.


# Number of values with 32 and 31 columns.
table(lengths(pols_list))
which_lines_31 <- which(lengths(pols_list) == 31L)
which_lines_32 <- which(lengths(pols_list) == 32L)

# Check for correct names for the datasets with 32 columns.
cbind(
    names(pols_list[[min(which_lines_32)]]), # This one.
    names(pols_list[[max(which_lines_32)]])
)

# Fix all names for datasets with 32 columns.
pols_list[which_lines_32] <- lapply(
    X   = pols_list[which_lines_32],
    FUN = function(x) {
        names(x) <- names(pols_list[[min(which_lines_32)]])
        x
    }
)

# Check for correct names for the dataset with 31 columns.
cbind(
    names(pols_list[[min(which_lines_31)]]), # This one.
    names(pols_list[[max(which_lines_31)]])
)

# For datassets with 31 columns.
pols_list[which_lines_31] <- lapply(
    X   = pols_list[which_lines_31],
    FUN = function(x) {
        names(x) <- names(pols_list[[min(which_lines_31)]])
        x$Method <- NA
        x
    }
)

# Final checks.
table(lengths(pols_list))
data.frame(table(unlist(lapply(pols_list, names))))


# Fix dates --------------------------------------------------------------------


pols_list <- lapply(
    X   = pols_list,
    FUN = function(x) {
        if (is.character(x$Date)){
            d <- as.Date(x$Date, "%m/%d/%Y")
        } else {
            d <- as.Date(as.character(x$Date), "%Y%m%d")
        }
        data.table::set(
            x     = x,
            j     = "Date",
            value = d
        )
    }
)


# Merge into a data.table ------------------------------------------------------


pols_dt <- data.table::rbindlist(pols_list, use.names = TRUE)


# Change -999 to NAs -----------------------------------------------------------


# Extract columns.
cols <- c(paste0("H0", 1:9), paste0("H", 10:24))

# Loop on all columns and apply the fix.
for (i in seq.int(1L, 24L)) {
    col <- cols[i]
    data.table::set(
        x = pols_dt,
        i = which(pols_dt[[col]] == -999L),
        j = col,
        value = NA
    )
}


# Final checks -----------------------------------------------------------------


# Check pollutant.
data.frame(table(pols_dt$Pollutant))

# Check data range.
range(pols_dt$Date)


# Export -----------------------------------------------------------------------


qs::qsave(
    pols_dt, file.path("data", "naps", "naps_cleaned.qs")
)
