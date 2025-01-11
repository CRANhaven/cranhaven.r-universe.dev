
#' XbX Method for PLR Determination
#' 
#' @description This function groups data by the specified time interval
#' and performs a linear regression using the formula:
#' \eqn{P_{pred.} = \beta_0 + \beta_1 G + \beta_2 T + \epsilon}.
#' This is the simplest of the PLR determining methods.
#' Predicted values of irradiance, temperature, and wind speed (if applicable)
#' are added to the output for reference. These values are the lowest daily high
#' irradiance reading (over 300), the average temperature over all data, and
#' the average wind speed over all data.
#' Outliers are detected and labeled in a column as TRUE or FALSE.
#' 
#' @param df A dataframe containing pv data.
#' @param var_list  A list of the dataframe's standard variable names, obtained from
#'  the plr_variable_check output.
#' @param by String, either "day", "week", or "month". The time periods over which
#' to group data for regression.
#' @param data_cutoff The number of data points needed to keep a value in the
#' final table. Regressions over less than this number and their data will be discarded.
#' @param predict_data optional; Dataframe; If you have preferred estimations of irradiance,
#' temperature, and wind speed, include them here to skip automatic generation. Format:
#' Irradiance, Temperature, Wind (optional).
#' 
#' @return Returns dataframe of results per passed time scale from XbX modeling
#' 
#' @examples 
#' # build var_list
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
#' @importFrom stats sigma
#' @importFrom rlang .data
#' @importFrom broom augment
#' @importFrom broom tidy
#' @importFrom broom glance
#' 
#' @export
plr_xbx_model <- function(df, var_list, by = "month", data_cutoff = 30,
                          predict_data = NULL) {
  
  # define global variables for use in pipes
  mod <- NULL
  mod_temp <- NULL
  . <- NULL
  tvar <- NULL
  data <- NULL
  fit <- NULL
  prediction <- NULL
  time_var <- NULL
  power_var <- NULL
  std_error <- NULL
  outlier <- NULL
  .fitted <- NULL

  
  # define representative conditions
  
  #remove wind column is NA
  if (is.na(var_list$wind_var)) {
    var_list$wind_var <- NULL
    }
  
  
  model_df <- dplyr::select(df, as.character(var_list)) %>%
    magrittr::set_colnames(names(var_list))
  
  model_df$tvar <- if (by == "month") {
    df$psem
  } else if (by == "week") {
    df$week
  } else if (by == "day") {
    df$day
  } else {
    stop("Error: 'By' set to something other than \'month\', \'week\', or \'day\'.
         Try again with one of these values")
  }
  
  # if set parameters are given use those, otherwise create them from the data set
  if (is.null(predict_data)) {
    
    # smallest daily max irradiance, over 300
    irrad_var <- model_df %>%
      dplyr::group_by(tvar) %>%
      dplyr::summarise(max = max(irrad_var)) %>%
      dplyr::ungroup() %>%
      dplyr::filter(max > 300) %>%
      dplyr::summarise(irrad_var = min(max))
    
    # average temperature over all data points
    temp_var <- model_df %>%
      dplyr::summarise(temp_var = mean(temp_var))
    
    # average wind speed over all data points
    if ("wind_var" %in% names(model_df)) {
      wind_var <- model_df %>%
        dplyr::summarise(wind_var = mean(wind_var))
    } else {
      wind <- NULL
    }
    
    # build pred
    if ("wind_var" %in% names(model_df)) {
      pred <- data.frame(irrad_var, temp_var, wind_var)
    } else {
      pred <- data.frame(irrad_var, temp_var)
    }
    
  } else {
    
    pred <- predict_data
    
  }
  
  
  
  if ("wind_var" %in% names(model_df)) {
    
    # determine number of data points for each month
    n <- model_df %>%
      dplyr::group_by(tvar) %>%
      dplyr::summarise(n = dplyr::n())
    
    # suppress warnings of misleading model fits, some time segments will have low data count
    suppressWarnings(res <- model_df %>%
      tidyr::nest(data = -tvar) %>% 
      dplyr::mutate(
        fit = purrr::map(data, ~ lm(power_var ~ irrad_var + temp_var + wind_var, data = .)),
        prediction = purrr::map(fit, augment, newdata = pred),
        tidy = purrr::map(fit, tidy),
        glance  = purrr::map(fit, glance)
      ) 
    )
    
  } else {
    
    # determine number of data points for each month
    n <- model_df %>%
      dplyr::group_by(tvar) %>%
      dplyr::summarise(n = dplyr::n())
    
    # suppress warnings of misleading fits, some time segments will have low data count
    suppressWarnings(res <- model_df %>%
      tidyr::nest(data = -tvar) %>% 
      dplyr::mutate(
        fit = purrr::map(data, ~ lm(power_var ~ irrad_var + temp_var, data = .)),
        prediction = purrr::map(fit, augment, newdata = pred),
        tidy = purrr::map(fit, tidy),
        glance  = purrr::map(fit, glance)
      ) 
    )
    
  }
  
  # merge data count onto results and add standard deviation
  res <- merge(res, n, by = "tvar")
  res <- dplyr::filter(res, n >= data_cutoff)
  #res$sigma <- res$.se.fit * sqrt(res$n)
  res$tvar <- as.numeric(res$tvar)
  res <- res %>% 
    tidyr::unnest(prediction) %>% 
    tidyr::unnest(glance)

  # detect outliers by inter quartile range and create a column indicating if a point is an outlier
  # allows manual removal if desired
  iqr <- stats::IQR(res$.fitted)
  lower <- stats::quantile(res$.fitted)[2] - 1.5 * iqr
  upper <- stats::quantile(res$.fitted)[4] + 1.5 * iqr
  
  res$outlier <- (res$.fitted > upper|res$.fitted < lower)
  
  # reduce to necessary columns for output
  res <- res %>%
    dplyr::mutate(time_var = tvar, power_var = .fitted, std_error = sigma/sqrt(n)) %>%
    dplyr::select(time_var, power_var, std_error, sigma, outlier) 
    
  
  return(as.data.frame(res))
  
}

#' PVUSA Method for PLR Determination
#' 
#' @description  This function groups data by the specified time interval
#' and performs a linear regression using the formula: 
#' \eqn{P = G_{POA} * (\beta_{0} + \beta_{1} G + \beta_{2} T_{amb} + \beta_{3} W)}.
#' Predicted values of irradiance, temperature, and wind speed (if applicable)
#' are added for reference. These values are the lowest daily high
#' irradiance reading (over 300), the average temperature over all data, and
#' the average wind speed over all data.
#'  
#' @param df A dataframe containing pv data.
#' @param var_list  A list of the dataframe's standard variable names, obtained from
#'  the output of \code{\link{plr_variable_check}}.
#' @param by String, either "day", "week", or "month". The time periods over which
#' to group data for regression.
#' @param data_cutoff The number of data points needed to keep a value in the 
#' final table. Regressions over less than this number and their data will be discarded.
#' @param predict_data optional; Dataframe; If you have preferred estimations of irradiance,
#' temperature, and wind speed, include them here to skip automatic generation. Format:
#' Irradiance, Temperature, Wind (optional).
#' 
#' @return Returns dataframe of results per passed time scale from PVUSA modeling
#' 
#' @examples 
#' # build var_list
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
#' test_xbx_wbw_res <- plr_pvusa_model(test_dfc, var_list, by = "week",
#'                                   data_cutoff = 30, predict_data = NULL)
#' 
#' @importFrom rlang .data
#' @importFrom broom augment
#' @importFrom broom tidy
#' @importFrom broom glance
#' 
#' @export
plr_pvusa_model <- function(df, var_list, by = "month", data_cutoff = 30,
                            predict_data = NULL) {
  
  # define global variables for use in pipes
  mod <- NULL
  mod_temp <- NULL
  . <- NULL
  tvar <- NULL
  data <- NULL
  fit <- NULL
  prediction <- NULL
  time_var <- NULL
  power_var <- NULL
  std_error <- NULL
  outlier <- NULL
  .fitted <- NULL
  
  # define representative conditions
  
  #remove wind column is NA
  if (is.na(var_list$wind_var)) {
    var_list$wind_var <- NULL
    }
  
  model_df <- dplyr::select(df, as.character(var_list)) %>%
    magrittr::set_colnames(names(var_list))
  # mutate(psem = df$psem)
  
  model_df$tvar <- if (by == "month") {
    df$psem
  } else if (by == "week") {
    df$week
  } else if (by == "day") {
    df$day
  } else {
    stop("Error: By set to something other than \'month\', \'week\', or \'day\'")
  }
  
  # if set parameters are given use those, otherwise create them from the data set
  if (is.null(predict_data)) {
    
    irrad_var <- model_df %>%
      dplyr::group_by(tvar) %>%
      dplyr::summarise(max = max(irrad_var)) %>%
      dplyr::ungroup() %>%
      dplyr::filter(max > 300) %>%
      dplyr::summarise(irrad_var = min(max))
    
    temp_var <- model_df %>%
      dplyr::summarise(temp_var = mean(temp_var))
    
    if ("wind_var" %in% names(model_df)) {
      wind_var <- model_df %>%
        dplyr::summarise(wind_var = mean(wind_var))
    } else {
      wind <- NULL
    }
    
    if ("wind_var" %in% names(model_df)) {
      pred <- data.frame(irrad_var, temp_var, wind_var)
    } else {
      pred <- data.frame(irrad_var, temp_var)
    }
    
  } else {
    
    pred <- predict_data
    
  }
  
  
  
  if ("wind_var" %in% names(model_df)) {
    
    # suppress warnings of misleading fits, some time segments will have low data count
    suppressWarnings(
      res <- model_df %>%
        tidyr::nest(data = -tvar) %>% 
        dplyr::mutate(
          fit = purrr::map(data, ~ lm(power_var ~ irrad_var + irrad_var ^ 2 + irrad_var * temp_var + irrad_var * wind_var, data = .)),
          prediction = purrr::map(fit, augment, newdata = pred),
          tidy = purrr::map(fit, tidy),
          glance  = purrr::map(fit, glance)
        ) 
    )
  } else {
    
    # suppress warnings of misleading fits, some time segments will have low data count
    suppressWarnings(
    res <- model_df %>%
      tidyr::nest(data = -tvar) %>% 
      dplyr::mutate(
        fit = purrr::map(data, ~ lm(power_var ~ irrad_var + irrad_var ^ 2 + irrad_var * temp_var, data = .)),
        prediction = purrr::map(fit, augment, newdata = pred),
        tidy = purrr::map(fit, tidy),
        glance  = purrr::map(fit, glance)
      ) 
    )
  }
  
  # determine number of data points for each month
  n <- model_df %>%
    dplyr::group_by(tvar) %>%
    dplyr::summarise(n = dplyr::n())
  
  
  res <- res %>% 
    tidyr::unnest(prediction) %>% 
    tidyr::unnest(glance)
  
  # merge data count onto results and add standard deviation
  res <- merge(res, n, by = "tvar")
  res <- dplyr::filter(res, n >= data_cutoff)
  #res$sigma <- res$.se.fit * sqrt(res$n)
  res$tvar <- as.numeric(res$tvar)
  
  # detect outliers and create a column indicating if a point is an outlier
  # allows manual removal if desired
  iqr <- stats::IQR(res$.fitted)
  lower <- stats::quantile(res$.fitted)[2] - 1.5 * iqr
  upper <- stats::quantile(res$.fitted)[4] + 1.5 * iqr
  
  res$outlier <- (res$.fitted > upper|res$.fitted < lower)
  
  res <- res %>%
    dplyr::mutate(time_var = tvar, power_var = .fitted, std_error = sigma/sqrt(n)) %>%
    dplyr::select(time_var, power_var, std_error, sigma, outlier) 
  
  return(as.data.frame(res))
  
}


#' 6k Method for PLR Determination
#' 
#' @description  This function groups data by the specified time interval
#' and performs a linear regression using the formula: 
#'  power_var ~ irrad_var/istc * 
#'  (nameplate_power + 
#'  a*log(irrad_var/istc) + 
#'  b*log(irrad_var/istc)^2 +
#'   c*(temp_var - tref) + 
#'  d*(temp_var - tref)*log(irrad_var/istc) + 
#'  e*(temp_var - tref)*log(irrad_var/istc)^2 + 
#'  f*(temp_var - tref)^2).
#' Predicted values of irradiance, temperature, and wind speed (if applicable)
#'  are added for reference. These values are the lowest daily high
#' irradiance reading (over 300W/m^2), the average temperature over all data, and
#' the average wind speed over all data.
#'  
#' @param df A dataframe containing pv data.
#' @param var_list  A list of the dataframe's standard variable names, obtained from
#'  the output of \code{\link{plr_variable_check}}.
#' @param nameplate_power The rated power capability of the system, in watts.
#' @param by String, either "day", "week", or "month". The time periods over which
#' to group data for regression.
#' @param data_cutoff The number of data points needed to keep a value in the 
#' final table. Regressions over less than this number and their data will be discarded.
#' @param predict_data optional; Dataframe; If you have preferred estimations of irradiance,
#' temperature, and wind speed, include them here to skip automatic generation. Format:
#' Irradiance, Temperature, Wind (optional).
#' 
#' @return Returns dataframe of results per passed time scale from 6K modeling
#' 
#' @importFrom rlang .data
#' @importFrom broom augment
#' @importFrom broom tidy
#' @importFrom broom glance
#' 
#' @export
plr_6k_model <- function(df, var_list, nameplate_power, by = "month", data_cutoff = 30,
                        predict_data = NULL) {
  
  # define global variables for use in pipes
  mod <- NULL
  mod_temp <- NULL
  . <- NULL
  tvar <- NULL
  data <- NULL
  fit <- NULL
  prediction <- NULL
  time_var <- NULL
  power_var <- NULL
  std_error <- NULL
  outlier <- NULL
  .fitted <- NULL
  
  # define representative conditions
  
  #remove wind column is NA
  if (is.na(var_list$wind_var)) {
    var_list$wind_var <- NULL
    }
  
  
  model_df <- dplyr::select(df, as.character(var_list)) %>%
    magrittr::set_colnames(names(var_list))
  # mutate(psem = df$psem)
  
  model_df$tvar <- if (by == "month") {
    df$psem
  } else if (by == "week") {
    df$week
  } else if (by == "day") {
    df$day
  } else {
    stop("Error: By set to something other than \'month\', \'week\', or \'day\'")
  }
  
  # if set parameters are given use those, otherwise create them from the data set
  if (is.null(predict_data)) {
    
    irrad_var <- model_df %>%
      dplyr::group_by(tvar) %>%
      dplyr::summarise(max = max(irrad_var)) %>%
      dplyr::ungroup() %>%
      dplyr::filter(max > 300) %>%
      dplyr::summarise(irrad_var = min(max))
    
    temp_var <- model_df %>%
      dplyr::summarise(temp_var = mean(temp_var))
    
    if ("wind_var" %in% names(model_df)) {
      wind_var <- model_df %>%
        dplyr::summarise(wind_var = mean(wind_var))
    } else {
      wind <- NULL
    }
    
    if ("wind_var" %in% names(model_df)) {
      pred <- data.frame(irrad_var, temp_var, wind_var)
    } else {
      pred <- data.frame(irrad_var, temp_var)
    }
    
  } else {
    
    pred <- predict_data
    
  }
  
  istc <- 1000 # standard irradiance
  tref <- pred$temp_var # reference temperature
  
  # suppress warnings of misleading NLS fits, some time segments will have low data count\
  suppressWarnings(res <- model_df %>%
    tidyr::nest(data = -tvar) %>% 
    dplyr::mutate(
      fit = purrr::map(data, ~ minpack.lm::nlsLM(power_var ~ irrad_var / istc * (nameplate_power +
                                                             a * log(irrad_var / istc) +
                                                             b * log(irrad_var / istc) ^ 2 +
                                                             c * (temp_var - tref) +
                                                             d * (temp_var - tref) * log(irrad_var / istc) +
                                                             e * (temp_var - tref) * log(irrad_var / istc) ^ 2 +
                                                             f * (temp_var - tref) ^ 2),
                                                 data = .,
                                                 start = list(a = 0.6, b = 0.1, c = -0.05, d = -0.05, e = -0.005, f = 0.001),
                                                 control = list(maxiter = 200))),
      prediction = purrr::map(fit, augment, newdata = pred),
      tidy = purrr::map(fit, tidy),
      glance  = purrr::map(fit, glance)
    ) 
  )
  
  # determine number of data points for each month
  n <- model_df %>%
    dplyr::group_by(tvar) %>%
    dplyr::summarise(n = dplyr::n())

  res <- res %>% 
    tidyr::unnest(prediction) %>% 
    tidyr::unnest(glance)
  
  # merge data count onto results and add standard deviation
  res <- merge(res, n, by = "tvar")
  res <- dplyr::filter(res, n >= data_cutoff)
  res$tvar <- as.numeric(res$tvar)
  
  # detect outliers and create a column indicating if a point is an outlier
  # allows manual removal if desired
  iqr <- stats::IQR(res$.fitted)
  lower <- stats::quantile(res$.fitted)[2] - 1.5 * iqr
  upper <- stats::quantile(res$.fitted)[4] + 1.5 * iqr
  
  res$outlier <- (res$.fitted > upper|res$.fitted < lower)
  
  res <- res %>%
    dplyr::mutate(time_var = tvar, power_var = .fitted, std_error = sigma/sqrt(n)) %>%
    dplyr::select(time_var, power_var, std_error, sigma, outlier) 
  
  
  return(as.data.frame(res))
  
}

# function using a universal temperature correction instead of a monthly regression one
# updated code for improved modeling performance
# for use with clear sky or total data
# mbm_predictve_model_temperature_coeff() is now depreciated

#' UTC Method for PLR Determination
#' 
#' @description  This function groups data by the specified time interval
#' and performs a linear regression using the formula: 
#' power_corr ~ irrad_var - 1.
#' Predicted values of irradiance, temperature, and wind speed (if applicable)
#' are added for reference. The function uses a universal temperature correction,
#' rather than the monthly regression correction done in other PLR determining methods.
#'  
#' @param df A dataframe containing pv data.
#' @param var_list  A list of the dataframe's standard variable names, obtained from
#'  the output of \code{\link{plr_variable_check}}.
#' @param by String, either "day", "week", or "month". The time periods over which
#' to group data for regression.
#' @param data_cutoff The number of data points needed to keep a value in the 
#' final table. Regressions over less than this number and their data will be discarded.
#' @param predict_data optional; Dataframe; If you have preferred estimations of irradiance,
#' temperature, and wind speed, include them here to skip automatic generation. Format:
#' Irradiance, Temperature, Wind (optional).
#' @param ref_irrad The irradiance value at which to calculate the universal
#' temperature coefficient. Since irradiance is a much stronger influencer on power generation
#' than temperature, it is important to specify a small range of irradiance data 
#' from which to estimate the effect of temperature.
#' @param irrad_range The range of the subset used to calculate the universal
#' temperature coefficient. See above.
#' 
#' @return Returns dataframe of results per passed time scale from XbX with 
#' universal temperature correction modeling
#' 
#' @examples 
#' # build var_list
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
#' test_xbx_wbw_res <- plr_xbx_utc_model(test_dfc, var_list, by = "week",
#'                                   data_cutoff = 30, predict_data = NULL,
#'                                   ref_irrad = 900, irrad_range = 10)
#' 
#' @importFrom rlang .data
#' @importFrom broom augment
#' @importFrom broom tidy
#' @importFrom broom glance
#' 
#' @export
plr_xbx_utc_model <- function(df, var_list, by = "month", 
                                               data_cutoff = 30, predict_data = NULL, 
                                               ref_irrad = 900, irrad_range = 10) {
  # define global variables for use in pipes
  mod <- NULL
  mod_temp <- NULL
  . <- NULL
  tvar <- NULL
  data <- NULL
  fit <- NULL
  prediction <- NULL
  time_var <- NULL
  power_var <- NULL
  std_error <- NULL
  outlier <- NULL
  .fitted <- NULL
  
  # define representative conditions
  
  #remove wind column is NA
  if (is.na(var_list$wind_var)) {
    var_list$wind_var <- NULL
    }
  
  
  model_df <- dplyr::select(df, as.character(var_list)) %>%
    magrittr::set_colnames(names(var_list))

  
  model_df$tvar <- if (by == "month") {
    df$psem
  } else if (by == "week") {
    df$week
  } else if (by == "day") {
    df$day
  } else {
    stop("Error: By set to something other than \'month\', \'week\', or \'day\'")
  }
  
  if (is.null(predict_data)) {
    
    irrad_var <- model_df %>%
      dplyr::group_by(tvar) %>%
      dplyr::summarise(max = max(irrad_var)) %>% #find max irrad per tvar
      dplyr::ungroup() %>%
      dplyr::filter(max > 300) %>% #only interested in maxes over 300
      dplyr::summarise(irrad_var = min(max)) #find smallest maximum
    
    temp_var <- model_df %>%
      dplyr::summarise(temp_var = mean(temp_var)) #avg temp
    
    if ("wind_var" %in% names(model_df)) {
      wind_var <- model_df %>%
        dplyr::summarise(wind_var = mean(wind_var)) #avg wind
    } else {
      wind <- NULL
    }
    
    if ("wind_var" %in% names(model_df)) {
      pred <- data.frame(irrad_var, temp_var, wind_var)
    } else {
      pred <- data.frame(irrad_var, temp_var)
    }
    
  } else {
    
    pred <- predict_data #makes it possible to give method specific values
    
  }
  
  # establish universal temperature coefficient
  
  # select high irradiance subset
  utc <- model_df %>%
    dplyr::filter(irrad_var < (ref_irrad + irrad_range),
                  irrad_var > (ref_irrad - irrad_range), 
                  power_var > 0.05 * max(power_var)) %>%
    dplyr::mutate(frac = power_var * (temp_var + 273.15)) #kelvin
  
  # filter outliers that may influence coefficient
  iqr <- stats::IQR(utc$frac)
  lower <- stats::quantile(utc$frac)[2] - 1.5 * iqr
  upper <- stats::quantile(utc$frac)[4] + 1.5 * iqr
  
  utc <- utc[!utc$frac < lower, ]
  utc <- utc[!utc$frac > upper, ]
  
  utc_mod <- lm(power_var ~ temp_var, data = utc)
  utc <- as.numeric(utc_mod$coefficients[2])/ref_irrad
  
  res <- model_df %>%
    dplyr::mutate(power_corr = power_var + utc * (pred$temp_var - temp_var) * irrad_var) %>%
    tidyr::nest(data = -tvar) %>% 
    dplyr::mutate(
      fit = purrr::map(data, ~ lm(power_corr ~ irrad_var -1, data = .)),
      prediction = purrr::map(fit, augment, newdata = pred),
      tidy = purrr::map(fit, tidy),
      glance  = purrr::map(fit, glance)
    ) 
  
  
  # determine number of data points for each month
  n <- model_df %>%
    dplyr::group_by(tvar) %>%
    dplyr::summarise(n = dplyr::n())
  
  res <- res %>% 
    tidyr::unnest(prediction) %>% 
    tidyr::unnest(glance)
  
  # merge data count onto results and add standard deviation
  res <- merge(res, n, by = "tvar")
  res <- dplyr::filter(res, n >= data_cutoff)
  res$tvar <- as.numeric(res$tvar)
  
  # detect outliers and create a column indicating if a point is an outlier
  # allows manual removal if desired
  iqr <- stats::IQR(res$.fitted)
  lower <- stats::quantile(res$.fitted)[2] - 1.5 * iqr
  upper <- stats::quantile(res$.fitted)[4] + 1.5 * iqr
  
  res$outlier <- (res$.fitted > upper|res$.fitted < lower)
  

  res <- res %>%
    dplyr::mutate(time_var = tvar, power_var = .fitted, std_error = sigma/sqrt(n)) %>%
    dplyr::select(time_var, power_var, std_error, sigma, outlier) 
  
  return(as.data.frame(res))
  
}
