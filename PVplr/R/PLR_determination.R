
#' Weighted Regression
#' 
#' @description Automatically calculates Performance Loss Rate (PLR)
#' using weighted linear regression. Note that it needs data from 
#' a power predictive model.
#' 
#' @param data The result of a power predictive model
#' @param power_var String name of the variable used as power
#' @param time_var String name of the variable used as time
#' @param model String name of the model that the data was passed through
#' @param per_year the time step count per year based on the model - 
#' 12 for month-by-month, 52 for week-by-week, and 365 for day-by-day
#' @param weight_var Used to weight regression, typically sigma.
#' 
#' @return Returns PLR value and error evaluated with linear regression
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
#' # Calculate Performance Loss Rate
#' xbx_wbw_plr <- plr_weighted_regression(test_xbx_wbw_res, 
#'                                        power_var = 'power_var', 
#'                                        time_var = 'time_var',
#'                                        model = "xbx", 
#'                                        per_year = 52, 
#'                                        weight_var = 'sigma')
#' 
#' @export
plr_weighted_regression <- function(data, power_var, time_var, model, per_year = 12,
                                    weight_var = NA) {
  
  # Fix global variable binding
  wvar <- NULL
  
  # name variables for regression
  data$pvar <- data[, power_var]
  data$tvar <- data[, time_var]
  
  if (is.na(weight_var)) {
    lm.power <- lm(pvar ~ tvar, data = data)
  }
  
  else {
    data$wvar <- data[, weight_var]
    
    # regression model weighted to the given variable
    # this will need to be changed i for a different weight variable
    # as the 1/wvar^2 assumes sigma is the weight
    lm.power <- lm(pvar ~ tvar, data  = data, weights = wvar)
  }
  
  # Rate of Change is slope/intercept converted to %/year
  roc <- (lm.power$coefficients[2] / lm.power$coefficients[1]) * per_year * 100
  
  # make roc into a dataframe
  roc <- data.frame(plr = roc, error = plr_var(lm.power, per_year), model = model)
  
  if(!is.na(weight_var)) {
    roc <- dplyr::mutate(roc, method = "weighted")
  }
  else {
    roc <- dplyr::mutate(roc, method = "unweighted")
  }
  
  # calculate PLR uncertainty
  #if (return_uncert) {
  #  
  #  u <- plr_var(lm.power, per_year)
  #  roc <- data.frame(plr = roc, error = u)
    
  #}
  
  return(roc)
}


#' Year-on-Year Regression
#' 
#' @description Automatically calculates Performance Loss Rate (PLR)
#' using year on year regression. Note that it needs data from a 
#' power predictive model.
#' 
#' @param data Result of a power predictive model
#' @param power_var String name of the variable used as power
#' @param time_var String name of the variable used as time
#' @param model String name of the model the data was passed through
#' @param per_year Time step count per year based on model. 
#' Typically 12 for MbM, 365 for DbD.
#' @param return_PLR boolean; option to return PLR value, rather than
#' the raw regression data.
#' 
#' @return Returns PLR value and error evaluated with YoY regression, if return_PLR is false
#'  it will return the individual YoY calculations
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
#' # Calculate Performance Loss Rate
#' xbx_wbw_plr <- plr_yoy_regression(test_xbx_wbw_res, 
#'                                        power_var = 'power_var', 
#'                                        time_var = 'time_var',
#'                                        model = "xbx", 
#'                                        per_year = 52, 
#'                                        return_PLR = TRUE)
#' 
#' 
#' @importFrom rlang .data
#' 
#' @export
plr_yoy_regression <- function(data, power_var, time_var, model, per_year = 12, 
                                        return_PLR = TRUE) {
  
  # Fix global variable binding
  pvar <- tvar <- NULL
  
  #requires dplyr
  
  # name variables for regression
  # consider changing to line up with function parameter names
  data$pvar <- data[, power_var]
  data$tvar <- data[, time_var]
  
  data <- data[order(data$tvar), ]
  
  # loop over points separated by 1 year
  b <- NULL
  slope <- NULL
  for (j in 1:(nrow(data) - per_year)) {
    
    # select rows separated by 1 year
    p1 <- data[j, ]
    p2 <- data[data$tvar == p1$tvar + per_year, ]
    df <- rbind(p1, p2) %>% dplyr::select(pvar, tvar)
    
    # only measure difference if both points exist
    if (!any(is.na(df))) {
      if (nrow(df) == 2) {
        # lm model between the 2 selected data points
        # this regression is perfect, with only 2 data points
        mod <- lm(pvar ~ tvar, data = df)
        
        # pull out the slope and intercept of the model
        m <- mod$coefficients[2]
        b <- mod$coefficients[1]
        
        # yy <- (p2$pvar - p1$pvar)/(p2$tvar - p1$tvar)
        
        # collect results for every point pair
        res <- data.frame(slope = m, yint = b, start = p1$tvar)
        rownames(res) <- c()
        slope <- rbind(slope, res)
      }
    }
  }
  
  # check if there wasn't enough data, return NA
  if (is.null(slope)) {
    roc <- NA
    return(roc)
  } else {
    
    # NA rows must be removed because an NA data point will give an NA slope but not an NA intercept
    # these intercepts with NA slopes must be removed as they are not based off of regression
    res <- slope[stats::complete.cases(slope), ]
    
    # add in a group matching points that match up across multiple years and which year they are in
    res$group <- res$start - per_year * floor(res$start / (per_year))
    res$group[res$group == 0] <- per_year
    
    res$year <- floor(res$start / (per_year)) + 1
    
    # medians of the slopes and y-ints for each point pair are taken as representative of the whole system
    # median reduces the influence of outliers, which are expected with only 2 data points per model
    ss <- median(res$slope, na.rm = TRUE)
    yy <- median(res$yint, na.rm = TRUE)
    
    # ROC calculated the same way, slope over intercept converted to %/year
    roc <- (ss / yy) * 100 * per_year
    
    # make roc into a dataframe
    roc <- data.frame(plr = roc, plr_sd = sd( (res$slope / median(res$yint, na.rm = TRUE)) * 100 * per_year),
                      model = model, method = "year-on-year")
    
    #if (return_sd) {
    #  roc <- data.frame(plr = roc, 
    #                    plr_sd = sd( (res$slope / median(res$yint, na.rm = TRUE)) * 100 * per_year))
    #}
    
    ifelse(return_PLR == TRUE, return(roc), return(res))
  }
}

