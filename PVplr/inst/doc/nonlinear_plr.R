## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----include = FALSE----------------------------------------------------------
library(PVplr)
library(knitr)
library(dplyr)
library(ggplot2)
library(broom)
library(purrr)
library(tidyr)

# using the package's example data
var_list <- PVplr::plr_build_var_list(time_var = "timestamp",
                                        power_var = "power",
                                        irrad_var = "g_poa",
                                        temp_var = "mod_temp",
                                        wind_var = NA)

test_dfc <- PVplr::plr_cleaning(test_df, var_list)

## ---- warning=FALSE-----------------------------------------------------------

predict_data <- data.frame(irrad_var = 800, temp_var = 40)

weather_cor_utc <- PVplr::plr_xbx_utc_model(test_dfc, var_list, by = "day", data_cutoff = 10, ref_irrad = 800, irrad_range  = 20, predict_data = predict_data)

decomp <- PVplr::plr_decomposition(data = weather_cor_utc, freq = 365, power_var = "power_var", time_var = "time_var")

ggplot() +
  geom_point(data = decomp, aes(x = age, y = raw, color = "Raw"), alpha = 0.5, size = 1) +
  geom_point(data = decomp, aes(x = age, y = trend, color = "Decomposed"), size = 1, alpha = 0.5) +
  scale_color_manual(values = c("orange", "blue")) +
  labs(x = "Time (days)", y = "Predicted Power (W)", color = "") +
  theme_bw(base_size = 8) +
  theme(legend.position = c(0.3, 0.3))


## -----------------------------------------------------------------------------
# multiple assumed linear methods of calculating PLR
PVplr::plr_weighted_regression(decomp, power_var = "trend", time_var = "age", per_year = 365, weight_var = "weights", model = "utc")
PVplr::plr_yoy_regression(decomp, power_var = "trend", time_var = "age", per_year = 365, model = "utc")

## -----------------------------------------------------------------------------
# evaluate segmented PLR results
seg_plr_result <- PVplr::plr_seg_extract(df = decomp, per_year = 365, n_breakpoints = 1, power_var = "trend", time_var = "age")

seg_plr_result

# return segmented model instead of PLR result
model <- PVplr::plr_seg_extract(df = decomp, per_year = 365, n_breakpoints = 1, power_var = "trend", time_var = "age", return_model = TRUE)

# predict data along time-series with piecewise model for plotting
pred <- data.frame(age = seq(1, max(decomp$age, na.rm = TRUE), length.out = 10000))
pred$seg <- predict(model, newdata = pred)

# plot segmented model along decomposed time series
# add initial PLR trend as well
ggplot() +
  geom_point(data = decomp, aes(x = age, y = trend, color = "STL Decompose"), size = 2) +
  geom_line(data = pred, aes(x = age, y = seg, color = "Piecewise Model"), size = 1) +
  geom_abline(slope = seg_plr_result$plr[1]/(100*365)*seg_plr_result$yint[1], intercept = seg_plr_result$yint[1], linetype = "dotted") +
  scale_color_manual(values = c("blue", "orange")) +
  geom_vline(xintercept = seg_plr_result$seg_end[1], linetype = "dashed") +
  labs(x = "Time (days)", y = "Predicted Power (W)", color = "") +
  theme_bw(base_size = 8) +
  theme(legend.position = c(0.7, 0.7))


