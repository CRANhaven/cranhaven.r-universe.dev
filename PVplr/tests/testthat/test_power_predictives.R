context("Test PLR determining functions")
library(PVplr)

test_that("mbm_xbx_model correctly rejects bad '\by'\ values", {
  expect_that(mbm_xbx_model(test_df, var_list, by = "something other than day/month/year"), throws_error())
})

test_that("mbm_pvusa_model correctly rejects bad '\by'\ values", {
  expect_that(mbm_pvusa_model(test_df, var_list, by = "something other than day/month/year"), throws_error())
})

test_that("mbm_6k_model correctly rejects bad '\by'\ values", {
  expect_that(mbm_6k_model(test_df, var_list, by = "something other than day/month/year", nameplate_power = 230), throws_error())
})

test_that("mbm_xbx_utc_model correctly rejects bad '\by'\ values", {
  expect_that(mbm_xbx_utc_model(test_df, var_list, by = "something other than day/month/year"), throws_error())
})