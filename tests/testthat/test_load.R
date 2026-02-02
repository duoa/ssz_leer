# Unit tests for data loading functions

library(testthat)
library(dplyr)

# Source the load file
source("../../scripts/01_load.R")

test_that("DATASET_URL is defined", {
  expect_true(exists("DATASET_URL"))
  expect_type(DATASET_URL, "character")
  expect_match(DATASET_URL, "^https://")
})

test_that("validate_dataset checks required columns", {
  # Valid data frame
  valid_df <- data.frame(
    StichtagDatJahr = c(2020, 2021),
    AlterV20Lang = c("20-39 Jahre", "40-59 Jahre"),
    WohnortLeerkuendigungLang_noDM = c("gleiches Stadtquartier", "Ausland"),
    AnzBestWir = c(10, 20)
  )
  
  expect_true(validate_dataset(valid_df))
  
  # Invalid data frame (missing column)
  invalid_df <- data.frame(
    StichtagDatJahr = c(2020, 2021),
    AlterV20Lang = c("20-39 Jahre", "40-59 Jahre")
  )
  
  expect_error(validate_dataset(invalid_df), "Required columns missing")
})

test_that("validate_dataset checks data types", {
  # Invalid year type
  invalid_df <- data.frame(
    StichtagDatJahr = c("2020", "2021"),  # Character instead of numeric
    AlterV20Lang = c("20-39 Jahre", "40-59 Jahre"),
    WohnortLeerkuendigungLang_noDM = c("gleiches Stadtquartier", "Ausland"),
    AnzBestWir = c(10, 20)
  )
  
  expect_error(validate_dataset(invalid_df), "Year column must be numeric")
})

test_that("validate_dataset checks non-negative counts", {
  # Negative count
  invalid_df <- data.frame(
    StichtagDatJahr = c(2020, 2021),
    AlterV20Lang = c("20-39 Jahre", "40-59 Jahre"),
    WohnortLeerkuendigungLang_noDM = c("gleiches Stadtquartier", "Ausland"),
    AnzBestWir = c(10, -5)  # Negative count
  )
  
  expect_error(validate_dataset(invalid_df), "Counts must be non-negative")
})

test_that("validate_dataset checks year range", {
  # Year out of range
  invalid_df <- data.frame(
    StichtagDatJahr = c(1990, 2021),  # 1990 is before 2000
    AlterV20Lang = c("20-39 Jahre", "40-59 Jahre"),
    WohnortLeerkuendigungLang_noDM = c("gleiches Stadtquartier", "Ausland"),
    AnzBestWir = c(10, 20)
  )
  
  expect_error(validate_dataset(invalid_df), "Years out of reasonable range")
})

test_that("validate_dataset checks sufficient categories", {
  # Insufficient age groups (only 2)
  invalid_df <- data.frame(
    StichtagDatJahr = c(2020, 2021),
    AlterV20Lang = c("20-39 Jahre", "20-39 Jahre"),  # Only 1 unique
    WohnortLeerkuendigungLang_noDM = c("gleiches Stadtquartier", "Ausland"),
    AnzBestWir = c(10, 20)
  )
  
  expect_error(validate_dataset(invalid_df), "Insufficient age groups")
})

test_that("validate_dataset checks for duplicates", {
  # Duplicate rows
  invalid_df <- data.frame(
    StichtagDatJahr = c(2020, 2020, 2021),
    AlterV20Lang = c("20-39 Jahre", "20-39 Jahre", "40-59 Jahre"),
    WohnortLeerkuendigungLang_noDM = c("gleiches Stadtquartier", "gleiches Stadtquartier", "Ausland"),
    AnzBestWir = c(10, 15, 20)  # Same year/age/residence combination
  )
  
  expect_error(validate_dataset(invalid_df), "Duplicate rows detected")
})

test_that("validate_dataset checks minimum dataset size", {
  # Too few rows
  invalid_df <- data.frame(
    StichtagDatJahr = c(2020),
    AlterV20Lang = c("20-39 Jahre"),
    WohnortLeerkuendigungLang_noDM = c("gleiches Stadtquartier"),
    AnzBestWir = c(10)
  )
  
  expect_error(validate_dataset(invalid_df), "Dataset too small")
})
