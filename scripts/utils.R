# Utility Functions for Zurich Leerkündigungen Analysis
# This file contains helper functions for field mappings, definitions, and calculations

# Field name mappings (dataset -> conceptual)
# These map the German column names from the dataset to English conceptual names
FIELD_MAPPINGS <- list(
  year = "StichtagDatJahr",
  age_group = "AlterV20Lang",
  new_residence = "WohnortLeerkuendigungLang_noDM",
  count = "AnzBestWir"
)

# Within Zurich City categories (German labels)
# These categories indicate the person remains within Zurich city limits
WITHIN_CITY_CATEGORIES <- c(
  "gleiches Stadtquartier",      # Same city quarter
  "anderes Stadtquartier"        # Different city quarter
)

#' Map dataset field names to conceptual field names
#'
#' @param df Data frame with original dataset column names
#' @return Data frame with renamed columns and derived within_city flag
#' @export
map_fields <- function(df) {
  library(dplyr)
  
  # Rename columns from German to English conceptual names
  df_mapped <- df %>%
    rename(
      year = !!FIELD_MAPPINGS$year,
      age_group = !!FIELD_MAPPINGS$age_group,
      new_residence = !!FIELD_MAPPINGS$new_residence,
      count = !!FIELD_MAPPINGS$count
    )
  
  # Derive within_city binary flag
  df_mapped <- df_mapped %>%
    mutate(
      within_city = new_residence %in% WITHIN_CITY_CATEGORIES
    )
  
  return(df_mapped)
}

#' Calculate Cramér's V effect size for chi-square test
#'
#' @param chi_result Result object from chisq.test()
#' @param n Total sample size
#' @return Cramér's V value (0 to 1)
#' @export
cramers_v <- function(chi_result, n) {
  chi_stat <- chi_result$statistic
  df <- min(chi_result$parameter)  # Degrees of freedom
  
  # Calculate Cramér's V
  v <- sqrt(chi_stat / (n * df))
  
  return(as.numeric(v))
}

#' Interpret Cramér's V effect size
#'
#' @param v Cramér's V value
#' @return Character string with interpretation
#' @export
interpret_cramers_v <- function(v) {
  if (v < 0.1) {
    return("negligible")
  } else if (v < 0.3) {
    return("small")
  } else if (v < 0.5) {
    return("medium")
  } else {
    return("large")
  }
}

#' Check if Unknown category exists in the data
#'
#' @param df Data frame with new_residence column
#' @return Logical indicating if Unknown category exists
#' @export
has_unknown_category <- function(df) {
  any(grepl("Unbekannt|Unknown", df$new_residence, ignore.case = TRUE))
}

#' Filter out Unknown category
#'
#' @param df Data frame with new_residence column
#' @return Data frame with Unknown category removed
#' @export
filter_unknown <- function(df) {
  library(dplyr)
  df %>%
    filter(!grepl("Unbekannt|Unknown", new_residence, ignore.case = TRUE))
}

#' Format percentage for display
#'
#' @param value Numeric value between 0 and 1
#' @param digits Number of decimal places
#' @return Character string with formatted percentage
#' @export
format_pct <- function(value, digits = 1) {
  paste0(round(value * 100, digits), "%")
}

#' Format large numbers with thousands separator
#'
#' @param value Numeric value
#' @return Character string with formatted number
#' @export
format_number <- function(value) {
  format(value, big.mark = ",", scientific = FALSE)
}
