# Data Loading and Validation for Zurich Leerkündigungen Analysis
# This file contains functions to download, load, and validate the dataset

library(readr)
library(dplyr)

# Official dataset URL
DATASET_URL <- "https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv"

#' Load dataset from official Zurich OGD URL
#'
#' @param url Character string with dataset URL (default: official URL)
#' @return Data frame with raw dataset
#' @export
load_dataset <- function(url = DATASET_URL) {
  cat("Loading dataset from official URL...\n")
  cat("URL:", url, "\n")
  
  tryCatch({
    # Download and read CSV directly from URL
    df <- read_csv(url, show_col_types = FALSE)
    
    cat("✓ Dataset downloaded successfully\n")
    cat("  Rows:", nrow(df), "\n")
    cat("  Columns:", ncol(df), "\n")
    
    return(df)
  }, error = function(e) {
    stop("Failed to download dataset from URL: ", url, "\n",
         "Error: ", e$message, "\n",
         "Check internet connection and URL validity.")
  })
}

#' Validate dataset structure and content
#'
#' @param df Data frame to validate
#' @return Logical TRUE if validation passes (stops execution if fails)
#' @export
validate_dataset <- function(df) {
  cat("\nValidating dataset...\n")
  
  # 1. Check required columns exist
  required_cols <- c("StichtagDatJahr", "AlterV20Lang",
                     "WohnortLeerkuendigungLang_noDM", "AnzBestWir")
  
  missing_cols <- setdiff(required_cols, colnames(df))
  stopifnot(
    "Required columns missing" = length(missing_cols) == 0
  )
  cat("✓ Required columns present:", paste(required_cols, collapse = ", "), "\n")
  
  # 2. Check data types
  stopifnot(
    "Year column must be numeric" = is.numeric(df$StichtagDatJahr)
  )
  stopifnot(
    "Count column must be numeric" = is.numeric(df$AnzBestWir)
  )
  cat("✓ Data types correct\n")
  
  # 3. Check non-negative counts
  stopifnot(
    "Counts must be non-negative" = all(df$AnzBestWir >= 0, na.rm = TRUE)
  )
  cat("✓ All counts non-negative\n")
  
  # 4. Check year range is reasonable
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  stopifnot(
    "Years out of reasonable range" = 
      all(df$StichtagDatJahr >= 2000 & df$StichtagDatJahr <= current_year, na.rm = TRUE)
  )
  cat("✓ Year range valid (2000 to", current_year, ")\n")
  
  # 5. Check sufficient categories
  n_age_groups <- length(unique(df$AlterV20Lang))
  stopifnot(
    "Insufficient age groups" = n_age_groups >= 3
  )
  cat("✓ Sufficient age groups:", n_age_groups, "\n")
  
  n_residence_cats <- length(unique(df$WohnortLeerkuendigungLang_noDM))
  stopifnot(
    "Insufficient residence categories" = n_residence_cats >= 2
  )
  cat("✓ Sufficient residence categories:", n_residence_cats, "\n")
  
  # 6. Check sufficient temporal coverage
  n_years <- length(unique(df$StichtagDatJahr))
  stopifnot(
    "Insufficient years for temporal analysis" = n_years >= 3
  )
  cat("✓ Sufficient temporal coverage:", n_years, "years\n")
  
  # 7. Check dataset is not empty
  stopifnot(
    "Dataset is empty" = nrow(df) >= 10
  )
  cat("✓ Dataset has sufficient rows:", nrow(df), "\n")
  
  # 8. Check for duplicates
  duplicates <- df %>%
    group_by(StichtagDatJahr, AlterV20Lang, WohnortLeerkuendigungLang_noDM) %>%
    filter(n() > 1)
  
  stopifnot(
    "Duplicate rows detected" = nrow(duplicates) == 0
  )
  cat("✓ No duplicate rows\n")
  
  # 9. Check total count is reasonable
  total_count <- sum(df$AnzBestWir, na.rm = TRUE)
  stopifnot(
    "Total count is zero or unreasonably small" = total_count > 0
  )
  cat("✓ Total affected persons:", format(total_count, big.mark = ","), "\n")
  
  cat("\n✓ All validation checks passed\n\n")
  return(TRUE)
}

#' Load and validate dataset in one step
#'
#' @param url Character string with dataset URL (default: official URL)
#' @return Data frame with validated raw dataset
#' @export
load_and_validate <- function(url = DATASET_URL) {
  df <- load_dataset(url)
  validate_dataset(df)
  return(df)
}
