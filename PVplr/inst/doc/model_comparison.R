## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----include = FALSE----------------------------------------------------------
library(PVplr)
library(knitr)
library(broom)
library(purrr)
library(tidyr)

# using the package's example data
var_list <- PVplr::plr_build_var_list(time_var = "timestamp", 
                               power_var = "power", 
                               irrad_var = "g_poa", 
                               temp_var = "mod_temp", 
                               wind_var = NA)

test_dfc <- plr_cleaning(test_df, var_list)

## -----------------------------------------------------------------------------
test_xbx_wbw_res <- plr_xbx_model(test_dfc, var_list, by = "week", data_cutoff = 30, predict_data = NULL)

knitr::kable(test_xbx_wbw_res[1:5, ], caption = "XbX Model: Week-by-Week Implementation")

## -----------------------------------------------------------------------------
test_xbxutc_wbw_res <- plr_xbx_utc_model(test_dfc, var_list, by = "week", data_cutoff = 30, predict_data = NULL, ref_irrad = 900, irrad_range = 10)

knitr::kable(test_xbxutc_wbw_res[1:5, ], caption = "XbX + UTC: Week-by-Week Implementation")

## -----------------------------------------------------------------------------
test_pvusa_wbw_res <- plr_pvusa_model(test_dfc, var_list, by = "week", data_cutoff = 30, predict_data = NULL)

knitr::kable(test_pvusa_wbw_res[1:5, ], caption = "PVUSA: Week-by-Week Implementation")

## -----------------------------------------------------------------------------
test_6k_wbw_res <- plr_6k_model(test_dfc, var_list, nameplate_power = 230, by = "week", data_cutoff = 30, predict_data = NULL)

knitr::kable(test_6k_wbw_res[1:5, ], caption = "6k: Week-by-Week Implementation")

## ---- error = TRUE, warning = FALSE-------------------------------------------
# This code should create an error
test6k_dbd_res <- plr_6k_model(test_dfc, var_list, nameplate_power = 230, by = "day", data_cutoff = 30, predict_data = NULL)

