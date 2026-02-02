# Unit tests for utility functions

library(testthat)
library(dplyr)

# Source the utils file
source("../../scripts/utils.R")

test_that("FIELD_MAPPINGS contains all required fields", {
  expect_true("year" %in% names(FIELD_MAPPINGS))
  expect_true("age_group" %in% names(FIELD_MAPPINGS))
  expect_true("new_residence" %in% names(FIELD_MAPPINGS))
  expect_true("count" %in% names(FIELD_MAPPINGS))
})

test_that("WITHIN_CITY_CATEGORIES is defined correctly", {
  expect_length(WITHIN_CITY_CATEGORIES, 2)
  expect_true("gleiches Stadtquartier" %in% WITHIN_CITY_CATEGORIES)
  expect_true("anderes Stadtquartier" %in% WITHIN_CITY_CATEGORIES)
})

test_that("map_fields renames columns correctly", {
  # Create test data with original column names
  test_df <- data.frame(
    StichtagDatJahr = c(2020, 2021),
    AlterV20Lang = c("20-39 Jahre", "40-59 Jahre"),
    WohnortLeerkuendigungLang_noDM = c("gleiches Stadtquartier", "Ausland"),
    AnzBestWir = c(10, 20)
  )
  
  # Apply mapping
  result <- map_fields(test_df)
  
  # Check renamed columns exist
  expect_true("year" %in% colnames(result))
  expect_true("age_group" %in% colnames(result))
  expect_true("new_residence" %in% colnames(result))
  expect_true("count" %in% colnames(result))
  expect_true("within_city" %in% colnames(result))
  
  # Check within_city derivation
  expect_equal(result$within_city[1], TRUE)
  expect_equal(result$within_city[2], FALSE)
})

test_that("cramers_v calculates correctly", {
  # Create a simple contingency table
  test_table <- matrix(c(10, 20, 30, 40), nrow = 2)
  chi_result <- chisq.test(test_table)
  n <- sum(test_table)
  
  v <- cramers_v(chi_result, n)
  
  # Cramér's V should be between 0 and 1
  expect_gte(v, 0)
  expect_lte(v, 1)
  expect_type(v, "double")
})

test_that("interpret_cramers_v returns correct interpretations", {
  expect_equal(interpret_cramers_v(0.05), "negligible")
  expect_equal(interpret_cramers_v(0.15), "small")
  expect_equal(interpret_cramers_v(0.35), "medium")
  expect_equal(interpret_cramers_v(0.55), "large")
})

test_that("has_unknown_category detects unknown correctly", {
  test_df1 <- data.frame(new_residence = c("gleiches Stadtquartier", "Unbekannt"))
  test_df2 <- data.frame(new_residence = c("gleiches Stadtquartier", "Ausland"))
  
  expect_true(has_unknown_category(test_df1))
  expect_false(has_unknown_category(test_df2))
})

test_that("filter_unknown removes unknown category", {
  test_df <- data.frame(
    new_residence = c("gleiches Stadtquartier", "Unbekannt", "Ausland"),
    count = c(10, 5, 15)
  )
  
  result <- filter_unknown(test_df)
  
  expect_equal(nrow(result), 2)
  expect_false(any(grepl("Unbekannt", result$new_residence, ignore.case = TRUE)))
})

test_that("format_pct formats percentages correctly", {
  expect_equal(format_pct(0.1234, 1), "12.3%")
  expect_equal(format_pct(0.5, 0), "50%")
  expect_equal(format_pct(0.9876, 2), "98.76%")
})

test_that("format_number formats numbers with thousands separator", {
  expect_match(format_number(1000), "1,000")
  expect_match(format_number(1234567), "1,234,567")
})
