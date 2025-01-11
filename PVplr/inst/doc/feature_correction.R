## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

options(rmarkdown.html_vignette.check_title = FALSE)


## ---- include = FALSE---------------------------------------------------------

library(PVplr)
library(knitr)
library(dplyr)
library(ggplot2)
library(broom)
library(purrr)
library(tidyr)

var_list <- plr_build_var_list(time_var = "timestamp", 
                               power_var = "power", 
                               irrad_var = "g_poa", 
                               temp_var = "mod_temp", 
                               wind_var = NA)

test_dfc <- plr_cleaning(test_df, 
                         var_list, 
                         irrad_thresh = 100, 
                         low_power_thresh = 0.01, 
                         high_power_cutoff = NA)

test_xbx_wbw_res <- plr_xbx_model(test_dfc, var_list = var_list, by = "week", data_cutoff = 30, predict_data = NULL)

## -----------------------------------------------------------------------------
test_dfc_removed_saturation <- plr_saturation_removal(test_dfc, var_list, sat_limit = 3000, power_thresh = 0.99)

# fraction of data kept
nrow(test_dfc_removed_saturation)/nrow(test_dfc)

## -----------------------------------------------------------------------------
# default values inserted for reference
#df_failure <- plr_failure_test(test_dfc, var_list, corr_thresh = 0.95, plot = FALSE, by_month = FALSE)

# fraction of data kept
#nrow(df_failure)/nrow(test_dfc)

## -----------------------------------------------------------------------------
test_xbx_wbw_decomp <- plr_decomposition(test_xbx_wbw_res, freq = 52, power_var = 'power_var', time_var = 'time_var', plot = FALSE, plot_file = NULL, title = NULL, data_file = NULL)

# generate a pretty table
knitr::kable(test_xbx_wbw_decomp[1:5, ], caption = "XbX Week-by-Week Decomposition: Resulting Data")

## -----------------------------------------------------------------------------
# make plots of the decomposed data
raw_plot <- ggplot2::ggplot(test_xbx_wbw_decomp, aes(age, raw)) +
  geom_point() +
  geom_smooth( method = "lm") +
  theme_bw()

trend_plot <- ggplot2::ggplot(test_xbx_wbw_decomp, aes(age, trend)) +
  geom_point() +
  geom_smooth( method = "lm") +
  theme_bw()

seasonal_plot <- ggplot2::ggplot(test_xbx_wbw_decomp, aes(age, seasonal)) +
  geom_point() +
  geom_smooth( method = "lm") +
  theme_bw()

raw_plot
trend_plot
seasonal_plot

