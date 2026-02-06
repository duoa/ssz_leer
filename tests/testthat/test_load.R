# Unit tests for data loading functions
# run via Rscript -e "testthat::test_dir('tests/testthat')"
# Moegliches Todo: expand
library(testthat)
library(dplyr)

# Source the load file
source("../../scripts/01_load.R")

test_that("DATASET_URL is defined", {
  expect_true(exists("DATASET_URL"))
  expect_type(DATASET_URL, "character")
  expect_match(DATASET_URL, "^https://")
})
