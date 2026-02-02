# Core Analysis Functions for Zurich Leerkündigungen Analysis
# This file contains functions to answer the 5 core analytical questions (Q1-Q5)

library(dplyr)
library(tidyr)

#' Q1: Analyze time dynamics
#' How does the total affected count change over time?
#'
#' @param df Data frame with year and count columns
#' @return List with temporal analysis results
#' @export
analyze_time_dynamics <- function(df) {
  # Aggregate by year
  temporal_summary <- df %>%
    group_by(year) %>%
    summarise(
      total_affected = sum(count, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(year)
  
  # Identify peak year(s)
  max_count <- max(temporal_summary$total_affected)
  peak_years <- temporal_summary %>%
    filter(total_affected == max_count) %>%
    pull(year)
  
  # Describe temporal pattern
  # Calculate year-over-year changes
  temporal_summary <- temporal_summary %>%
    mutate(
      yoy_change = total_affected - lag(total_affected),
      yoy_pct_change = (total_affected - lag(total_affected)) / lag(total_affected)
    )
  
  # Determine pattern type
  avg_change <- mean(abs(temporal_summary$yoy_change), na.rm = TRUE)
  sd_change <- sd(temporal_summary$yoy_change, na.rm = TRUE)
  
  if (sd_change / avg_change > 0.5) {
    pattern <- "wave-like (high variability)"
  } else {
    pattern <- "relatively stable"
  }
  
  return(list(
    temporal_summary = temporal_summary,
    peak_years = peak_years,
    peak_count = max_count,
    pattern = pattern
  ))
}

#' Q2: Analyze composition shift
#' Is the distribution of new residence outcomes stable over time?
#'
#' @param df Data frame with year, new_residence, and count columns
#' @return List with composition analysis results
#' @export
analyze_composition_shift <- function(df) {
  # Calculate residence shares by year
  composition_summary <- df %>%
    group_by(year, new_residence) %>%
    summarise(count = sum(count, na.rm = TRUE), .groups = "drop") %>%
    group_by(year) %>%
    mutate(
      share = count / sum(count),
      total_year = sum(count)
    ) %>%
    ungroup()
  
  # Calculate baseline composition (average across all years)
  baseline_composition <- composition_summary %>%
    group_by(new_residence) %>%
    summarise(
      baseline_share = mean(share, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Calculate deviation from baseline for each year
  composition_with_deviation <- composition_summary %>%
    left_join(baseline_composition, by = "new_residence") %>%
    mutate(
      deviation = abs(share - baseline_share)
    )
  
  # Identify deviant years (years with large deviations)
  year_deviations <- composition_with_deviation %>%
    group_by(year) %>%
    summarise(
      max_deviation = max(deviation),
      total_deviation = sum(deviation),
      .groups = "drop"
    ) %>%
    arrange(desc(max_deviation))
  
  # Flag years with deviation > 10 percentage points
  deviant_years <- year_deviations %>%
    filter(max_deviation > 0.10) %>%
    pull(year)
  
  # Get details for most deviant year
  if (length(deviant_years) > 0) {
    most_deviant_year <- deviant_years[1]
    deviant_details <- composition_with_deviation %>%
      filter(year == most_deviant_year) %>%
      arrange(desc(deviation)) %>%
      select(year, new_residence, share, baseline_share, deviation)
  } else {
    most_deviant_year <- NULL
    deviant_details <- NULL
  }
  
  return(list(
    composition_summary = composition_summary,
    baseline_composition = baseline_composition,
    year_deviations = year_deviations,
    deviant_years = deviant_years,
    most_deviant_year = most_deviant_year,
    deviant_details = deviant_details
  ))
}

#' Q3: Analyze age gradient
#' Do age groups differ in likelihood of remaining within Zurich city?
#'
#' @param df Data frame with age_group, within_city, and count columns
#' @return List with age gradient analysis results
#' @export
analyze_age_gradient <- function(df) {
  # Calculate within-city share by age group
  age_summary <- df %>%
    group_by(age_group, within_city) %>%
    summarise(count = sum(count, na.rm = TRUE), .groups = "drop") %>%
    group_by(age_group) %>%
    mutate(
      share = count / sum(count),
      total_age = sum(count)
    ) %>%
    filter(within_city == TRUE) %>%
    select(age_group, within_city_share = share, total_count = total_age)
  
  # Find strongest contrast
  if (nrow(age_summary) >= 2) {
    max_share <- max(age_summary$within_city_share)
    min_share <- min(age_summary$within_city_share)
    contrast <- max_share - min_share
    
    max_age_group <- age_summary %>%
      filter(within_city_share == max_share) %>%
      pull(age_group) %>%
      first()
    
    min_age_group <- age_summary %>%
      filter(within_city_share == min_share) %>%
      pull(age_group) %>%
      first()
  } else {
    contrast <- NA
    max_age_group <- NA
    min_age_group <- NA
  }
  
  return(list(
    age_summary = age_summary,
    contrast = contrast,
    max_age_group = max_age_group,
    max_share = max_share,
    min_age_group = min_age_group,
    min_share = min_share
  ))
}

#' Q4: Analyze same-quarter dependence on age
#' If "same city quarter" exists, compare its share across age groups
#'
#' @param df Data frame with age_group, new_residence, and count columns
#' @return List with same-quarter analysis results or NULL if not applicable
#' @export
analyze_same_quarter <- function(df) {
  # Check if "same city quarter" category exists
  has_same_quarter <- any(grepl("gleiches Stadtquartier|Same.*quarter",
                                 df$new_residence, ignore.case = TRUE))
  
  if (!has_same_quarter) {
    return(list(applicable = FALSE))
  }
  
  # Filter for same quarter category
  same_quarter_data <- df %>%
    filter(grepl("gleiches Stadtquartier|Same.*quarter",
                 new_residence, ignore.case = TRUE))
  
  # Calculate same-quarter share by age group
  age_totals <- df %>%
    group_by(age_group) %>%
    summarise(total = sum(count, na.rm = TRUE), .groups = "drop")
  
  same_quarter_summary <- same_quarter_data %>%
    group_by(age_group) %>%
    summarise(same_quarter_count = sum(count, na.rm = TRUE), .groups = "drop") %>%
    left_join(age_totals, by = "age_group") %>%
    mutate(same_quarter_share = same_quarter_count / total) %>%
    arrange(desc(same_quarter_share))
  
  # Find strongest contrast
  if (nrow(same_quarter_summary) >= 2) {
    max_share <- max(same_quarter_summary$same_quarter_share)
    min_share <- min(same_quarter_summary$same_quarter_share)
    contrast <- max_share - min_share
    
    max_age_group <- same_quarter_summary %>%
      filter(same_quarter_share == max_share) %>%
      pull(age_group) %>%
      first()
    
    min_age_group <- same_quarter_summary %>%
      filter(same_quarter_share == min_share) %>%
      pull(age_group) %>%
      first()
  } else {
    contrast <- NA
    max_age_group <- NA
    min_age_group <- NA
  }
  
  return(list(
    applicable = TRUE,
    same_quarter_summary = same_quarter_summary,
    contrast = contrast,
    max_age_group = max_age_group,
    max_share = max_share,
    min_age_group = min_age_group,
    min_share = min_share
  ))
}

#' Q5: Analyze unknown concentration
#' If "Unknown" exists, quantify differences across age groups
#'
#' @param df Data frame with age_group, new_residence, and count columns
#' @return List with unknown concentration analysis results or NULL if not applicable
#' @export
analyze_unknown_concentration <- function(df) {
  # Check if Unknown category exists
  has_unknown <- any(grepl("Unbekannt|Unknown", df$new_residence, ignore.case = TRUE))
  
  if (!has_unknown) {
    return(list(applicable = FALSE))
  }
  
  # Filter for unknown category
  unknown_data <- df %>%
    filter(grepl("Unbekannt|Unknown", new_residence, ignore.case = TRUE))
  
  # Calculate unknown share by age group
  age_totals <- df %>%
    group_by(age_group) %>%
    summarise(total = sum(count, na.rm = TRUE), .groups = "drop")
  
  unknown_summary <- unknown_data %>%
    group_by(age_group) %>%
    summarise(unknown_count = sum(count, na.rm = TRUE), .groups = "drop") %>%
    right_join(age_totals, by = "age_group") %>%
    mutate(
      unknown_count = ifelse(is.na(unknown_count), 0, unknown_count),
      unknown_share = unknown_count / total
    ) %>%
    arrange(desc(unknown_share))
  
  # Find strongest contrast
  if (nrow(unknown_summary) >= 2) {
    max_share <- max(unknown_summary$unknown_share)
    min_share <- min(unknown_summary$unknown_share)
    contrast <- max_share - min_share
    
    max_age_group <- unknown_summary %>%
      filter(unknown_share == max_share) %>%
      pull(age_group) %>%
      first()
    
    min_age_group <- unknown_summary %>%
      filter(unknown_share == min_share) %>%
      pull(age_group) %>%
      first()
  } else {
    contrast <- NA
    max_age_group <- NA
    min_age_group <- NA
  }
  
  return(list(
    applicable = TRUE,
    unknown_summary = unknown_summary,
    contrast = contrast,
    max_age_group = max_age_group,
    max_share = max_share,
    min_age_group = min_age_group,
    min_share = min_share
  ))
}
