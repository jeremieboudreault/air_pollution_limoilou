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
files_path <- file.path("data", "naps", "raw")
files <- list.files(files_path)

# Load all files.
pols_list <- lapply(
    X    = file.path(files_path, files),
    FUN  = data.table::fread,
    skip = 5L
)


# Updates names ----------------------------------------------------------------


# Note : Some dataset have 32 columns, other have 31. Names differ from datasets,
#        but the information is the same. Here, we harmonize all datasets.


# For datasets with 32 columns.
which_lines_32 <- which(lengths(pols_list) == 32L)
pols_list[which_lines_32] <- lapply(
    X   = pols_list[which_lines_32],
    FUN = function(x) {
        names(x) <- names(pols_list[[which_lines_32[1L]]])
        x
    }
)

# For datassets with 31 columns.
which_lines_31 <- which(lengths(pols_list) == 31L)
pols_list[which_lines_31] <- lapply(
    X   = pols_list[which_lines_31],
    FUN = function(x) {
        names(x) <- names(pols_list[[which_lines_31[1L]]])
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
        if ("Date" %in% class(x$Date)){
           data.table::set(
               x     = x,
               j     = "Date",
               value = as.integer(gsub("-", "", as.character(x$Date)))
            )
        }
    }
)


# Merge and export -------------------------------------------------------------


# Merge.
pols_dt <- data.table::rbindlist(pols_list, use.names = TRUE)

# Replace -999 with NAs.
cols <- c(paste0("H0", 1:9), paste0("H", 10:24))

# Replace -999 by NA.
for (i in seq.int(1L, 24L)) {
    col <- cols[i]
    data.table::set(
        x = pols_dt,
        i = which(pols_dt[[col]] == -999L),
        j = col,
        value = NA
    )
}


# Export -----------------------------------------------------------------------


qs::qsave(
    pols_dt, file.path("data", "naps", "naps_cleaned.qs")
)
