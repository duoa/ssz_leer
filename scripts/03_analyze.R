# Analysis Functions for Zurich Leerkündigungen Analysis
# Reviewed: Angelo Duò, 05-02-2026

library(dplyr)
library(tidyr)
library(forcats)

#' Analyze time changes
#' How does the total affected count change over time?
#'
#' @param df Data frame with year and count columns
#' @return List with temporal analysis results
#' @export
analyze_time_change <- function(df) {
  # Aggregate by year
  time_summary <- df %>%
    group_by(year) %>%
    summarise(
      total_affected = sum(count, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(year)
  
  # Identify peak year
  max_count <- max(time_summary$total_affected)
  peak_years <- time_summary %>%
    filter(total_affected == max_count) %>%
    pull(year)
  
  return(list(
    time_summary = time_summary,
    peak_years = peak_years,
    peak_count = max_count
  ))
}

#' Summarise year by residence, compute fractions 
#'
#' @param df Data frame with year, new_residence, and count columns
#' @return List with df with cols: year,new_residence, new_residence_sort, count, share,total_year
#' @export
analyze_composition_shift <- function(df) {
  # Calculate residence fraction by year and total
  composition_summary <- df %>%
    group_by(year, new_residence, new_residence_sort) %>%
    summarise(count = sum(count, na.rm = TRUE), .groups = "drop") %>%
    group_by(year) %>%
    mutate(
      fraction = count / sum(count),
      total_year = sum(count)
    ) %>%
    ungroup()
  
  return(list(
    composition_summary = composition_summary
  ))
}

#' Analyze age groups and differences within city
#'
#' @param df Data frame with age_group, within_city, and count columns
#' @return List with age gradient analysis results
#' @export
analyze_age_groups_within <- function(df) {
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

#' Analyze same-quarter dependence on age
#' If "same city quarter" exists, compare its fraction across age groups
#'
#' @param df Data frame with age_group, new_residence, and count columns
#' @return df Data frame with  age_group, same_quarter_count, total,same_quarter_share
#' @export
analyze_same_quarter <- function(df) {

  # Filter for same quarter category
  same_quarter_data <- df %>%
    filter(grepl("gleiches Stadtquartier",
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
  
  return(same_quarter_summary)
}

#' Summarise the "Unknown" counts
#' If "Unknown" exists, quantify differences across age groups
#' Find min, max and differnces
#' 
#' @param df Data frame with age_group, new_residence, and count columns
#' @return List with "unknown" analysis results or NULL if not applicable
#' @export
summarise_unknow_category <- function(df) {
  # Check if Unknown category exists
  has_unknown <- any(grepl("Unbekannt", df$new_residence, ignore.case = TRUE))
  
  if (!has_unknown) {
    return(list(applicable = FALSE))
  }
  
  # Filter for unknown category
  unknown_data <- df %>%
    filter(grepl("Unbekannt", new_residence, ignore.case = TRUE))
  
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


# bis hier reviewed

#' Analyze age and new residence distributions using Standardized residuals and 
#' calculate the log2(relative risk).
#'
#' This function calculates the contingency table, standardized residuals, and
#' log2(relative risk) for the age * new residence distribution. It ensures
#' correct factor ordering for both age_group (using AlterV20Sort) and
#' new_residence (using new_residence_sort) for visualization readiness.
#'
#' @param df Data frame with age_group, new_residence, count, AlterV20Sort, and new_residence_sort columns.
#' @return List with:
#'         - RR_long: Long-format data frame of standardized residuals.
#'         - log2RR_long: Long-format data frame of log2RR.
#'         - ct: The contingency table (age_group x new_residence).
#' @export
analyze_age_residence_distributions <- function(df) {
  # 1) Prepare sorted residence map
  residence_sort_map <- df %>%
    distinct(new_residence, new_residence_sort) %>%
    arrange(new_residence_sort)
  # Prepare sorted age map
  age_sort_map <- df %>%
    distinct(age_group, AlterV20Sort) %>%
    arrange(AlterV20Sort)
  
  # 2) calculate observed ct long table (age_group × new_residence)
  ct_long <- df %>%
    group_by(age_group, new_residence) %>%
    summarise(observed = sum(count, na.rm = TRUE), .groups = "drop")
  # make table wide
  ct <- ct_long %>%
    pivot_wider(names_from = new_residence, values_from = observed, values_fill = 0)
  
  age_labels <- ct$age_group
  observed <- as.matrix(select(ct, -age_group))
  
  # 3) Calculat the expected frequencies under independence
  row_sum <- rowSums(observed) # how many age obs
  col_sum <- colSums(observed) # how many target obs
  total_counts <- sum(observed)
  # cart. product of row and col normalised by total
  # Eij = (row_sum_i * cols_sum_j) / N
  expected_obs <- outer(row_sum, col_sum) / total_counts 
  
  # 4) calc standaritsed residuals 
  # # R = (O - E) / sqrt(E)
  standardised_residuals <- (observed - expected_obs) / sqrt(expected_obs)
  
  # 5) Calculate log2(RR)
  # compute fraction by  age group
  row_fraction <- observed / row_sum
  # fraction by residence 
  col_fraction <- col_sum / total_counts
  # Relative risk is fraction diveded by respective fraction total
  # RRij = row_fraction_ij / overall_share_j
  RR <- sweep(row_fraction, 2, col_fraction, "/")
  log2RR <- log2(RR)
  
  # 6) Convert RR to longformat
  standardised_residuals_df <- as.data.frame(standardised_residuals )
  standardised_residuals_df$age_group <- age_labels
  
  standardised_residuals_long <- standardised_residuals_df %>%
    pivot_longer(-age_group, names_to = "new_residence", values_to = "resid") %>%
    # Order factors using the sort maps and fct_inorder
    left_join(age_sort_map, by = "age_group") %>%
    left_join(residence_sort_map, by = "new_residence") %>%
    arrange(AlterV20Sort) %>%
    mutate(age_group = fct_inorder(age_group)) %>%
    arrange(new_residence_sort) %>%
    mutate(new_residence = fct_inorder(new_residence)) %>%
    select(-AlterV20Sort, -new_residence_sort)
  
  # 7) Convert log2RR to Long-Format (log2RR_long)
  log2RR_df <- as.data.frame(log2RR)
  log2RR_df$age_group <- age_labels
  
  log2RR_long <- log2RR_df %>%
    pivot_longer(-age_group, names_to = "new_residence", values_to = "log2RR") %>%
    # Order factors using the sort maps and fct_inorder
    left_join(age_sort_map, by = "age_group") %>%
    left_join(residence_sort_map, by = "new_residence") %>%
    arrange(AlterV20Sort) %>%
    mutate(age_group = fct_inorder(age_group)) %>%
    arrange(new_residence_sort) %>%
    mutate(new_residence = fct_inorder(new_residence)) %>%
    select(-AlterV20Sort, -new_residence_sort)
  
  return(list(standardised_residuals_long = standardised_residuals_long, log2RR_long = log2RR_long, ct = ct, O_matrix = observed))
}
