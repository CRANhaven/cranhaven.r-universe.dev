context("test bootstrap functions")
library(PVplr)

test_that("bootstrap_uncertainty correctly rejects bad '\by'\ values", {
  expect_that(mbm_bootstrap_uncertainty(test_df, mbm_variable_check(test_df),
                                   model = "xbx", by = "inappropriate value"), throws_error())
})
test_that("bootstrap_output correctly rejects bad '\by'\ values", {
  expect_that(mbm_bootstrap_output(test_df, mbm_variable_check(test_df),
                                   model = "xbx", by = "inappropriate value"), throws_error())
})
test_that("bootstrap_output_from_results correctly rejects bad '\by'\ values", {
  expect_that(mbm_bootstrap_output_from_results(mbm_xbx_model(test_df, mbm_variable_check(test_df)),
                                                mbm_variable_check(test_df),
                                   model = "xbx", by = "inappropriate value"), throws_error())
})