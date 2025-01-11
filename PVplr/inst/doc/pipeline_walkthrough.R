## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

options(rmarkdown.html_vignette.check_title = FALSE)


## -----------------------------------------------------------------------------

library(PVplr)
library(knitr)
library(dplyr)
library(ggplot2)
library(broom)
library(purrr)
library(tidyr)

# build variable list based on column names in example data
var_list <- plr_build_var_list(time_var = "timestamp",
                               power_var = "power",
                               irrad_var = "g_poa",
                               temp_var = "mod_temp",
                               wind_var = NA)


## -----------------------------------------------------------------------------
test_dfc <- plr_cleaning(test_df, var_list, irrad_thresh = 100, low_power_thresh = 0.01, high_power_cutoff = NA)

## ----eval = TRUE, warning = TRUE----------------------------------------------
# an example
a <- c(1,"two","three","four")
b <- c(1,2,NA,4)
c <- c(1,2,3,4)

# force numeric
d <- as.numeric(as.character(a))
e <- as.numeric(as.character(b))
f <- as.numeric(as.character(c))

# printed results show introduction of NA's, which would indicate non-numeric columns
print(d)
print(e)
print(f)

## -----------------------------------------------------------------------------
test_xbx_wbw_res <- plr_xbx_model(test_dfc, var_list, by = "week", data_cutoff = 30, predict_data = NULL)

# Generate Table
knitr::kable(test_xbx_wbw_res[1:5, ], caption = "XbX Model: Week-by-Week Implementation")

## -----------------------------------------------------------------------------
test_xbx_wbw_res_no_outliers <- plr_remove_outliers(test_xbx_wbw_res)

rows_before <- nrow(test_xbx_wbw_res)
rows_after <- nrow(test_xbx_wbw_res_no_outliers)
number_outliers <- rows_before - rows_after

## -----------------------------------------------------------------------------
# example weighted regression
xbx_wbw_plr <- plr_weighted_regression(test_xbx_wbw_res_no_outliers, power_var = 'power_var', time_var = 'time_var', model = "xbx", per_year = 52, weight_var = 'sigma')

xbx_wbw_plr

## -----------------------------------------------------------------------------
# example unweighted regression
xbx_wbw_plr_unweighted <- plr_weighted_regression(test_xbx_wbw_res_no_outliers, power_var = 'power_var', time_var = 'time_var', model = "xbx", per_year = 52, weight_var = NA)

xbx_wbw_plr

## -----------------------------------------------------------------------------
mod <- lm(power_var ~ time_var, data = test_xbx_wbw_res_no_outliers)

plr_sd <- plr_var(mod, per_year = 52)

## -----------------------------------------------------------------------------
# example YoY regression
xbx_wbw_yoy_plr <- plr_yoy_regression(test_xbx_wbw_res_no_outliers, power_var = 'power_var', time_var = 'time_var', model = "xbx", per_year = 52, return_PLR = TRUE)

xbx_wbw_yoy_plr

## ---- warning=FALSE-----------------------------------------------------------
# samples data before applying PLR regression
xbx_wbw_plr_uncertainty <- plr_bootstrap_uncertainty(test_dfc, n = 2, fraction = 0.65, by = 'week', power_var = 'power_var', time_var = 'time_var', var_list = var_list, model = "xbx", data_cutoff = 10, np = NA, pred = NULL)

knitr::kable(xbx_wbw_plr_uncertainty, caption = "XbX Week-by-Week Bootstrapped Uncertainty")

## -----------------------------------------------------------------------------
dfc_resampled <- mbm_resample(test_dfc, fraction = 0.65, by = "week")

## ---- warning=FALSE-----------------------------------------------------------
xbx_wbw_plr_output_uncertainty <- plr_bootstrap_output(test_dfc, var_list, model = "xbx", fraction = 0.65, n = 10, power_var = 'power_var', time_var = 'time_var', ref_irrad = 900, irrad_range = 10, by = "week", np = NA, pred = NULL)

knitr::kable(xbx_wbw_plr_output_uncertainty, caption = "XbX Week-by-Week Bootstrapped Output Uncertainty")

## ---- warning=FALSE-----------------------------------------------------------
xbx_wbw_plr_result_uncertainty <- plr_bootstrap_output_from_results(test_xbx_wbw_res_no_outliers, power_var = 'power_var', time_var = 'time_var', weight_var = 'sigma', by = "week", model = 'xbx', fraction = 0.65, n = 10)

knitr::kable(xbx_wbw_plr_result_uncertainty, caption = "XbX Week-by-Week Bootstrapped Output Uncertainty From Results")

