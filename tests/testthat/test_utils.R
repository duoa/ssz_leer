# Unit tests for utility functions
# moegliches Todo: expand test suite
# run via Rscript -e "testthat::test_dir('tests/testthat')"

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
