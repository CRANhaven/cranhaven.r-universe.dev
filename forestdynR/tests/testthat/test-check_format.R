library(testthat)
library(forestdynR)


test_that("check_format works with correct input", {
  result <- check_format(forest_df_example)
  expect_true(result$status)
  expect_null(result$message)
})

test_that("check_format fails if input is not a dataframe", {
  result <- check_format(list(plot = 1, spp = "species", DBH_1 = 10, DBH_2 = 20))
  expect_false(result$status)
  expect_equal(result$message, "Input is not a dataframe.")
})

test_that("check_format fails if 'plot' column is missing", {
  data("forest_df_example")
  forest_df <- forest_df_example
  forest_df$plot <- NULL

  result <- check_format(forest_df)
  expect_false(result$status)
  expect_equal(result$message, "Dataframe must have a column named 'plot'.")
})

test_that("check_format fails if 'spp' column is missing", {
  data("forest_df_example")
  forest_df <- forest_df_example
  forest_df$spp <- NULL

  result <- check_format(forest_df)
  expect_false(result$status)
  expect_equal(result$message, "Dataframe must have a column named 'spp'.")
})

test_that("check_format fails if 'DBH_1' column is missing", {
  data("forest_df_example")
  forest_df <- forest_df_example
  forest_df$DBH_1 <- NULL

  result <- check_format(forest_df)
  expect_false(result$status)
  expect_equal(result$message, "Dataframe must have a column named 'DBH_1'.")
})

test_that("check_format fails if 'DBH_2' column is missing", {
  data("forest_df_example")
  forest_df <- forest_df_example
  forest_df$DBH_2 <- NULL

  result <- check_format(forest_df)
  expect_false(result$status)
  expect_equal(result$message, "Dataframe must have a column named 'DBH_2'.")
})

test_that("check_format fails if 'DBH_1' or 'DBH_2' are not numeric", {
  data("forest_df_example")
  forest_df <- forest_df_example
  forest_df$DBH_1 <- as.character(forest_df$DBH_1)

  result <- check_format(forest_df)
  expect_false(result$status)
  expect_equal(result$message, "Column: 'DBH_1' must be numeric.")
})

test_that("check_format fails if 'DBH_1' or 'DBH_2' are not numeric", {
  data("forest_df_example")
  forest_df <- forest_df_example
  forest_df$DBH_2 <- as.character(forest_df$DBH_2)

  result <- check_format(forest_df)
  expect_false(result$status)
  expect_equal(result$message, "Column: 'DBH_2' must be numeric.")

})

