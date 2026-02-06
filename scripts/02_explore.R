# Exploratory Analysis Functions for Zurich Leerkündigungen Analysis
# This file contains functions for data exploration and sanity checks
# Reviewed: Angelo Duò, 03-02-2026

library(dplyr)

#' Get time range from dataset
#'
#' @param df Data frame with year column
#' @param na_rm default is TRUE

#' @return List with earliest and latest year
#' @export
get_time_range <- function(df, na_rm = TRUE) {
  list(
    earliest = min(df$year, na.rm = na_rm),
    latest = max(df$year, na.rm = na_rm),
    span = max(df$year, na.rm = na_rm) - min(df$year, na.rm = na_rm) + 1
  )
}

#' Get total affected count across all years
#'
#' @param df Data frame with count column
#' @return Numeric total count
#' @export
get_total_count <- function(df) {
  sum(df$count, na.rm = TRUE)
}

#' Get all age group categories
#'
#' @param df Data frame with age_group column
#' @return Character vector of unique age groups
#' @export
get_age_groups <- function(df) {
  sort(unique(df$age_group))
}

#' Get all new residence categories
#'
#' @param df Data frame with new_residence column
#' @return Character vector of unique residence categories
#' @export
get_residence_categories <- function(df) {
  sort(unique(df$new_residence))
}

#' Check if Unknown category exists and calculate its share
#'
#' @param df Data frame with new_residence and count columns
#' @return List with exists flag and share (if exists)
#' @export
check_unknown_category <- function(df) {
  # todo just simplify and make a table or similar
  has_unknown <- any(grepl("Unbekannt|Unknown", df$new_residence, ignore.case = TRUE))
  
  if (has_unknown) {
    unknown_count <- df %>%
      filter(grepl("Unbekannt|Unknown", new_residence, ignore.case = TRUE)) %>%
      summarise(total = sum(count, na.rm = TRUE)) %>%
      pull(total)
    
    total_count <- sum(df$count, na.rm = TRUE)
    unknown_share <- unknown_count / total_count
    
    return(list(
      exists = TRUE,
      count = unknown_count,
      share = unknown_share
    ))
  } else {
    return(list(
      exists = FALSE,
      count = 0,
      share = 0
    ))
  }
}

#' Detect anomalies in the dataset
#'
#' @param df Data frame with year, age_group, new_residence, count columns
#' @return List of detected anomalies
#' @export
detect_anomalies <- function(df) {
  anomalies <- list()
  
  # Check for missing years (gaps in time series)
  time_range <- get_time_range(df)
  all_years <- seq(time_range$earliest, time_range$latest)
  present_years <- unique(df$year)
  missing_years <- setdiff(all_years, present_years)
  
  if (length(missing_years) > 0) {
    anomalies$missing_years <- missing_years
  }
  
  # Check for empty categories (combinations with zero count)
  zero_count_rows <- df %>%
    filter(count == 0) %>%
    nrow()
  
  if (zero_count_rows > 0) {
    anomalies$zero_count_rows <- zero_count_rows
  }
  
  # Check for years with very low total counts (potential data quality issues)
  yearly_totals <- df %>%
    group_by(year) %>%
    summarise(total = sum(count, na.rm = TRUE), .groups = "drop")
  
  median_total <- median(yearly_totals$total)
  low_count_years <- yearly_totals %>%
    filter(total < median_total * 0.25) %>%  # Less than 25% of median
    pull(year)
  
  if (length(low_count_years) > 0) {
    anomalies$low_count_years <- low_count_years
  }
  
  # Check for age groups or residence categories that appear only in some years
  age_year_coverage <- df %>%
    group_by(age_group) %>%
    summarise(n_years = n_distinct(year), .groups = "drop")
  
  incomplete_age_groups <- age_year_coverage %>%
    filter(n_years < time_range$span) %>%
    pull(age_group)
  
  if (length(incomplete_age_groups) > 0) {
    anomalies$incomplete_age_groups <- incomplete_age_groups
  }
  
  return(anomalies)
}

#' Generate comprehensive exploration summary
#'
#' @param df Data frame with mapped fields
#' @return List with all exploration results
#' @export
explore_dataset <- function(df) {
  # Time range
  time_range <- get_time_range(df)
  # Total count
  total_count <- get_total_count(df)
  # Age groups
  age_groups <- get_age_groups(df)
  # Residence categories
  residence_cats <- get_residence_categories(df)
  # Unknown category check
  unknown_info <- check_unknown_category(df)
    # Anomalies
  anomalies <- detect_anomalies(df)
  # Return structured results
  return(list(
    time_range = time_range,
    total_count = total_count,
    age_groups = age_groups,
    residence_categories = residence_cats,
    unknown_info = unknown_info,
    anomalies = anomalies
  ))
}
