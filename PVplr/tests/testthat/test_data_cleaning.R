context("test data cleaning")
library(PVplr)

# test_that("var_list contains correct variables", {
#  expect_equal(as.character(plr_variable_check(test_df)[1]), "tmst")
#  expect_equal(as.character(plr_variable_check(test_df)[2]), "iacp")
#  expect_equal(as.character(plr_variable_check(test_df)[3]), "poay")
#  expect_equal(as.character(plr_variable_check(test_df)[4]), "temp")
# })
# 
# test_that("var list can be created manually", {
#   expect_equal(as.character(plr_variable_check(test_df)), as.character(plr_build_var_list(time_var = "timestamp", power_var = "power", irrad_var = "g_poa", temp_var = "mod_temp", wind_var = NA)))
# })

var_list <- plr_build_var_list(time_var = "timestamp", power_var = "power", irrad_var = "g_poa", temp_var = "mod_temp", wind_var = NA)

test_that("clean data has numeric columns for important variables", {
  expect_type(plr_cleaning(test_df, var_list)$timestamp, "double")
  expect_type(plr_cleaning(test_df, var_list)$power, "double")
  expect_type(plr_cleaning(test_df, var_list)$g_poa, "double")
  expect_type(plr_cleaning(test_df, var_list)$mod_temp, "double")
})