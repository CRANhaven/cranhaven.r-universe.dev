

# a method to determine the uncertainty of an ROC through resampling data for each model
# 65%
# model is desired modeling method
# xbx, 6k, pvusa, correction

#' Bootstrap: Resampling data going into each Model
#' 
#' @description This function determines the uncertainty of a PLR measurement
#' through resampling data for each model, prior to putting the data through the
#' model.
#' 
#' @param df A dataframe containing pv data.
#' @param n (numeric) Number of samples to take. The higher the n value, the longer it 
#' takes to complete, but the results become more accurate as well.
#' @param fraction The fraction of data that constitutes a resample for the bootstrap.
#' @param var_list A list of variables obtained through \code{\link{plr_variable_check}}.
#' @param model the String name of the model to bootstrap. Select from: \itemize{
#' \item "xbx" (\code{\link{plr_xbx_model}}),
#' \item "correction" (\code{\link{plr_xbx_utc_model}}),
#' \item "pvusa" (\code{\link{plr_pvusa_model}}),
#'  \item or "6k" (\code{\link{plr_6k_model}}).
#' }
#' @param by String, either "day", "week", or "month". Time over which to perform
#' \code{\link{plr_yoy_regression}}.
#' @param power_var Variable name of power in the dataframe. This must be the
#' variable's name after being put through your selected model. Typically power_var
#' @param time_var Variable name of time in the dataframe. This must be the
#' variable's name after being put through your selected model. Typically time_var
#' @param data_cutoff The number of data points needed to keep a value in the
#' final table. Regressions over less than this number and their data will be discarded.
#' @param np The system's reported name plate power. See \code{\link{plr_6k_model}}.
#' @param pred passed to predict_data in model call. See \code{\link{plr_xbx_model}}
#' for an example.
#' 
#' @return Returns PLR value and uncertainty calculated with bootstrap of data going into power correction models
#' 
#' @examples 
#' # build var_list
#' 
#' \donttest{
#' var_list <- plr_build_var_list(time_var = "timestamp",
#'                                power_var = "power",
#'                                irrad_var = "g_poa",
#'                                temp_var = "mod_temp",
#'                                wind_var = NA)
#' # Clean Data
#' test_dfc <- plr_cleaning(test_df, var_list, irrad_thresh = 100,
#'                          low_power_thresh = 0.01, high_power_cutoff = NA)
#'                          
#' xbx_mbm_plr_uncertainty <- plr_bootstrap_uncertainty(test_dfc, n = 2, 
#'                                                      fraction = 0.65, by = 'month',
#'                                                      power_var = 'power_var', time_var = 'time_var',
#'                                                      var_list = var_list, model = "xbx",
#'                                                      data_cutoff = 10, np = NA,
#'                                                      pred = NULL)
#' }
#' 
#' @importFrom stats sd
#' @importFrom stats median
#' @importFrom stats qt
#' @importFrom dplyr group_by
#' @importFrom dplyr ungroup
#' @importFrom dplyr sample_frac
#' @importFrom rlang .data
#' 
#' @export
plr_bootstrap_uncertainty <- function(df, n, fraction = 0.65, var_list, model, by = "month",
                                      power_var = 'power_var', time_var = 'time_var',
                                      data_cutoff = 100, np = NA, pred = NULL) {

  . <- NULL
  
  # requires tidyr, dplyr

  # define groups per year for YoY regression
  per_year <- dplyr::case_when(by == "day" ~ 365,
                               by == "week" ~ 52,
                               by == "month" ~ 12,
                               by != "month|week|day" ~ 0) # arbitrary double for error catching
  if (per_year == 0) {
    stop("Error: By set to something other than \'month\', \'week\', or \'day\'")
  }
  
  roc_df <- NULL
  for (i in 1:n) {
    
    df_sub <- mbm_resample(df, fraction = fraction, by = by)
    
    if (model == "xbx") {
      res <- plr_xbx_model(df_sub, var_list = var_list, by = by,
                           data_cutoff = data_cutoff)
      res$weight <- 1 / (res$sigma) ^ 2
    } else if (model == "correction") {
      res <- plr_xbx_utc_model(df_sub, var_list = var_list,
                                                by = by,
                                                data_cutoff = data_cutoff,
                                                predict_data = pred)
      res$weight <- 1 / (res$sigma) ^ 2
    } else if (model == "pvusa") {
      res <- plr_pvusa_model(df_sub, var_list = var_list, by = by,
                             data_cutoff = data_cutoff, predict_data = pred)
      res$weight <- 1 / (res$sigma) ^ 2
    } else if (model == "6k") {
      res <- plr_6k_model(df_sub, var_list = var_list, by = by,
                          data_cutoff = data_cutoff, nameplate_power = np,
                          predict_data = pred)
      res$weight <- 1
    }
    else {
      stop("Error: model not recognized. See method documentation via ?plr_bootstrap_uncertainty")
    }
    
    roc_reg <- plr_weighted_regression(data = res, power_var = power_var,
                                       time_var = time_var, model = model, per_year = per_year,
                                       weight_var = "weight")
    roc_yoy <- plr_yoy_regression(data = res, power_var = power_var,
                                           time_var = time_var, model = model, per_year = per_year)
    
    rr <- data.frame(roc_reg$plr, roc_yoy$plr, rows = nrow(df_sub))
    roc_df <- rbind(roc_df, rr)
  }
  
  # result <- data.frame(reg_mean = mean(roc_df$roc_reg, na.rm = TRUE),
  #                     reg_median = median(roc_df$roc_reg, na.rm = TRUE),
  #                     reg_sd = sd(roc_df$roc_reg, na.rm = TRUE),
  #                     reg_se = sd(roc_df$roc_reg, na.rm = TRUE) / sqrt(roc_df$rows[1]),
  #                     yoy_mean = mean(roc_df$roc_yoy, na.rm = TRUE),
  #                     yoy_median = median(roc_df$roc_yoy, na.rm = TRUE),
  #                     yoy_sd = sd(roc_df$roc_yoy, na.rm = TRUE),
  #                     yoy_se = sd(roc_df$roc_yoy, na.rm = TRUE) / sqrt(roc_df$rows[1]))
  
  result <- data.frame(plr = c(mean(roc_df$roc_reg, na.rm = T),
                               mean(roc_df$roc_yoy, na.rm = T)),
                       error_95_conf = c(qt(0.975, n - 1) * sd(roc_df$roc_reg, na.rm = TRUE) / sqrt(nrow(roc_df)),
                                qt(0.975, n - 1) * sd(roc_df$roc_yoy, na.rm = TRUE) / sqrt(nrow(roc_df))),
                       error_std_dev = c(sd(roc_df$roc_reg, na.rm = TRUE),
                                         sd(roc_df$roc_yoy, na.rm = TRUE)),
                       method = c("regression", "YoY"),
                       model = c(model, model))
  
  return(result)
  
}

# different bootstrap from previous
# bootstraps by sampling results from individual models
# other function samples data going into each model
# i.e. other model samples data going into each mdoel, this one samples from all models
# model is which model to use, xbx, correction, pvusa, m6k

#' Bootstrap: Resampling from individual Models
#' 
#' @description This function determines uncertainty of a PLR measurement
#' by sampling results from invididual models. Specify the model you would like
#' to find the uncertainty of, and the function will put the dataframe through the
#' selected model and return the uncertainties of the model's results.
#' 
#' @param df  A dataframe containing pv data.
#' @param var_list  A list of the dataframe's standard variable names, obtained from
#'  the plr_variable_check output.
#' @param model The model you would like to calculate the uncertainty of. Use
#' "xbx", "xbx+utc", "pvusa", or "6k".
#' @param by String indicating time step count per year for the regression. 
#' Use "day", "month", or "year". See \code{\link{plr_weighted_regression}}.
#' @param fraction The size of each sample relative to the total dataset.
#' @param n Number of samples to take.
#' @param predict_data passed to predict_data in model call. See \code{\link{plr_xbx_model}}
#' for example.
#' @param np The system's reported name plate power. See \code{\link{plr_6k_model}}.
#' @param power_var The name of the power variable after being put through a Performance
#' Loss Rate (PLR) determining test. Typically "power_var".
#' @param time_var The name of the time variable after being put through a PLR
#' determining test. Typically "time_var".
#' @param ref_irrad The irradiance value at which to calculate the universal
#' temperature coefficient. Since irradiance is a much stronger influencer on power generation
#' than temperature, it is important to specify a small range of irradiance data 
#' from which to estimate the effect of temperature.
#' @param irrad_range The range of the subset used to calculate the universal
#' temperature coefficient. See above.
#' 
#' @return Returns PLR value and uncertainty calculated with bootstrap of data from power correction models
#' 
#' @examples
#' # build var_list
#' \donttest{
#' var_list <- plr_build_var_list(time_var = "timestamp",
#'                                power_var = "power",
#'                                irrad_var = "g_poa",
#'                                temp_var = "mod_temp",
#'                                wind_var = NA)
#' # Clean Data
#' test_dfc <- plr_cleaning(test_df, var_list, irrad_thresh = 100,
#'                          low_power_thresh = 0.01, high_power_cutoff = NA)
#' 
#' xbx_mbm_plr_output_uncertainty <- plr_bootstrap_output(test_dfc, var_list,
#'                                                        model = "xbx", fraction = 0.65,
#'                                                        n = 10, power_var = 'power_var',
#'                                                        time_var = 'time_var', ref_irrad = 900,
#'                                                        irrad_range = 10, by = "month",
#'                                                        np = NA, pred = NULL)
#' }
#' 
#' @export
plr_bootstrap_output <- function(df, var_list, model, by = "month", fraction = 0.65, n = 1000,
                                 predict_data = NULL, np = NA, power_var = "power_var",
                                 time_var = "time_var", ref_irrad = 900, irrad_range = 10) {
  
  . <- NULL
  
  if (model == "xbx") {
    mod_res <- plr_xbx_model(df = df, var_list = var_list, by = by, 
                             predict_data = predict_data)
  } else if (model == "xbx+utc") {
    mod_res <- plr_xbx_utc_model(df = df, 
                                 var_list = var_list, by = by, 
                                 predict_data = predict_data, 
                                 ref_irrad = ref_irrad, 
                                 irrad_range = irrad_range)
  } else if (model == "pvusa") {
    mod_res <- plr_pvusa_model(df = df, 
                               var_list = var_list, by = by, 
                               predict_data = predict_data)
  } else if (model == "6k") {
    mod_res <- plr_6k_model(df = df,
                            var_list = var_list, by = by,
                            predict_data = predict_data,
                            nameplate_power = np)
    mod_res$sigma <- 1
  }
  else {
    stop("Model not recognized. Refer to method documentation via ?plr_bootstrap_output")
  }
  
  mod_res$weight <- 1 / mod_res$sigma
  
  # define groups per year for YoY regression
  per_year <- dplyr::case_when(by == "day" ~ 365,
                        by == "week" ~ 52,
                        by == "month" ~ 12,
                        by != "month|week|day" ~ 0) # arbitrary double for error catching
  if (per_year == 0) {
    stop("Error: By set to something other than \'month\', \'week\', or \'day\'")
  }
  
  res <- NULL
  for (i in c(1:n)) {
    
    re <- mod_res %>%
      sample_frac(., size = fraction, replace = TRUE)
    
    reg <- plr_weighted_regression(data = re, power_var = power_var, 
                                   time_var = time_var, model = model, per_year = per_year,
                                   weight_var = "weight")
    yoy <- plr_yoy_regression(data = re, power_var = power_var, 
                                       time_var = time_var, model = model, per_year = per_year)
    
    iter <- data.frame(reg$plr, yoy$plr, i)
    
    res <- rbind(res, iter)
    
  }
  
  # calculate mean error
  
  fin <- data.frame(plr = c(mean(res$reg, na.rm = TRUE), 
                            yoy_mean = mean(res$yoy, na.rm = TRUE)),
                    error_95_conf = c(reg_error = qt(0.975, n - 1) * sd(res$reg, na.rm = TRUE) / sqrt(n), 
                              yoy_error = qt(0.975, n - 1) * sd(res$yoy, na.rm = TRUE) / sqrt(n)),
                    error_std_dev = c(sd(res$reg, na.rm = TRUE),
                                      sd(res$yoy, na.rm = TRUE)),
                    method = c("regression", "YoY"),
                    model = c(model, model))
  rownames(fin) <- NULL
  
  
  # fin <- data.frame(reg_mean = mean(res$reg, na.rm = TRUE),
  #                   reg_error = stats::qt(0.975, n - 1) * stats::sd(res$reg, na.rm = TRUE)/sqrt(n),
  #                   yoy_mean = mean(res$yoy, na.rm = TRUE),
  #                   yoy_error = stats::qt(0.975, n - 1) * stats::sd(res$yoy, na.rm = TRUE)/sqrt(n),
  #                   model = model)
  
  return(fin)
  
}

#' Bootstrap: Resample from individual Models
#' 
#' @description The function samples and bootstraps data that has already been
#' put through a power predictive model. The PLR and Uncertainty are returned in
#' a dataframe. 
#' 
#' @param data Result of modeling data with a PLR determining model, i.e.
#' plr_xbx_model, plr_6k_model, etc.
#' @param power_var Variable name of power in the dataframe. Typically power_var
#' @param time_var Variable name of time in the dataframe. Typically time_var
#' @param weight_var Variable name of weightings in the dataframe. Typically sigma
#' @param by String, either "day", "month", or "year". Time over which to perform
#' \code{\link{plr_yoy_regression}} and \code{\link{plr_weighted_regression}}.
#' @param model The name of the model the data has been put through. This
#' option is only included for the user's benefit in keeping bootstrap outputs
#' consistent.
#' @param fraction The fractional size of the data to be sampled each time.
#' @param n The number of resamples to take.
#' 
#' @return Returns PLR value and uncertainty calculated with bootstrap of data going into power correction models
#' 
#' @examples 
#' # build var_list
#' 
#' \donttest{
#' var_list <- plr_build_var_list(time_var = "timestamp",
#'                                power_var = "power",
#'                                irrad_var = "g_poa",
#'                                temp_var = "mod_temp",
#'                                wind_var = NA)
#' # Clean Data
#' test_dfc <- plr_cleaning(test_df, var_list, irrad_thresh = 100,
#'                          low_power_thresh = 0.01, high_power_cutoff = NA)
#'                          
#' # Perform the power predictive modeling step
#' test_xbx_wbw_res <- plr_xbx_model(test_dfc, var_list, by = "week",
#'                                   data_cutoff = 30, predict_data = NULL)
#'                                   
#' xbx_mbm_plr_result_uncertainty <- plr_bootstrap_output_from_results(test_xbx_wbw_res, 
#'                                                                     power_var = 'power_var',
#'                                                                     time_var = 'time_var',
#'                                                                     weight_var = 'sigma',
#'                                                                     by = "month", model = 'xbx',
#'                                                                     fraction = 0.65, n = 10)
#' }
#' 
#' @export
plr_bootstrap_output_from_results <- function(data, power_var, time_var, weight_var,
                                              by = "month", model, fraction = .65,
                                              n = 1000){
  
  . <- NULL
  
  # define groups per year for YoY regression
  per_year <- dplyr::case_when(by == "day" ~ 365,
                               by == "week" ~ 52,
                               by == "month" ~ 12,
                               by != "month|week|day" ~ 0) # arbitrary double for error catching
  if (per_year == 0) {
    stop("Error: By set to something other than \'month\', \'week\', or \'day\'")
  }
  
  model <- model #string to standardise output
  res <- NULL
  for (i in c(1:n)) {
    
    re <- data %>%
      sample_frac(., size = fraction, replace = TRUE)
    
    
    
    reg <- plr_weighted_regression(data = re, power_var = power_var, 
                                   time_var = time_var, model = model, per_year = per_year, 
                                   weight_var = weight_var)
    yoy <- plr_yoy_regression(data = re, power_var = power_var, 
                                       time_var = time_var, model = model, per_year = per_year)
    
    iter <- data.frame(reg$plr, yoy$plr, i)
    
    res <- rbind(res, iter)
  }
  
  fin <- data.frame(plr = c(mean(res$reg, na.rm = TRUE), yoy_mean = mean(res$yoy, na.rm = TRUE)),
                    error = c(reg_error = qt(0.975, n - 1) * sd(res$reg, na.rm = TRUE) / sqrt(n), 
                                yoy_error = qt(0.975, n - 1) * sd(res$yoy, na.rm = TRUE) / sqrt(n),
                              sd(res$reg, na.rm = TRUE), sd(res$yoy, na.rm = TRUE)),
                   # std_dev = c(sd(res$reg, na.rm = TRUE), sd(res$yoy, na.rm = TRUE)),
                    method = c("regression", "YoY", "regression", "YoY"),
                    error_method = c("bootstrap 95 conf", "bootstrap 95 conf", "bootstrap std dev", "bootstrap std dev"),
                    model = c(model, model, model, model))
  
  fin2 <- data.frame(plr = c(mean(res$reg, na.rm = TRUE), yoy_mean = mean(res$yoy, na.rm = TRUE)),
                     error_95_conf = c(reg_error = qt(0.975, n - 1) * sd(res$reg, na.rm = TRUE) / sqrt(n), 
                               yoy_error = qt(0.975, n - 1) * sd(res$yoy, na.rm = TRUE) / sqrt(n)),
                     error_std_dev = c(sd(res$reg, na.rm = TRUE), sd(res$yoy, na.rm = TRUE)),
                     method = c("regression", "YoY"),
                     model = c(model, model))
  
  rownames(fin) <- NULL
  rownames(fin2) <- NULL
  
  return(fin2)
  
}
