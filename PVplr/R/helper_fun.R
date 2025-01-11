


#' function to convert to character then numeric
#' 
#' @description The function is a shorthand for converting factors to numeric
#' 
#' @param x any factor to convert to numeric
#' 
#' @return Returns supplied parameter as numeric
#' 
#' @examples 
#' num <- nc(test_df$power)
#' 
#' @export
nc <- function(x) {
  return(as.numeric(as.character(x)))
}


#' function to test if an entire column is NA
#' 
#' @description This function tests for completely NA columns
#' 
#' @param x any column in a dataframe
#' 
#' @return Returns boolean TRUE if column is all NA, FALSE if not
#' 
#' @examples 
#' test <- all_na(c(NA, "a", NA))
#' 
#' @export
all_na <- function(x) {
  return(all(is.na(x)))
}

#' function to test is the values in a column should be numeric
#' 
#' @description This function tests a column to see if it should be numeric
#' 
#' @param col any column in a dataframe
#' 
#' @return Returns boolean TRUE if column should be numeric, FALSE if not
#' 
#' @examples
#' test <- num_test(test_df$power)
#' 
#' @export
num_test <- function(col) {
  
  # first eliminate possibility of entire NA column
  if (all_na(col)) {
    
    return(FALSE)
    
  } else {
    
    # remove any NA rows then force convert to numeric
    # converting a non-numeric to numeric creates an NA
    # this is why you have to remove preexisting NAs first
    t <- col[stats::complete.cases(col)]
    # remove NULL values as they appear in hbase
    t <- t[!t == ""]
    t <- t[!t == "-"]
    t <- nc(t)
    
    # if any values are NA the column is not numeric
    # testing if any are catches columns that may have some numbers and some characters
    # columns like that should be character class
    if (any(is.na(t))) {
      
      return(FALSE)
      
      # if it passes the above criteria it is a numeric column
    } else {
      
      return(TRUE)
      
    }
    
  }
  
}


# plr_bootstrap_uncertainty

#' Dataframe resample function
#' @description This function resamples data from a given dataframe.
#' Dataframe must have columns created through plr_cleaning to denote time segments
#' 
#' @param df dataframe 
#' @param fraction fraction of data to resample from dataframe
#' @param by timescale over which to resample, day, week, or month
#' 
#' @return Returns randomly resampled dataframe
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
#' dfc_resampled <- mbm_resample(test_dfc, fraction = 0.65, by = "week")
#' 
#' @export
#' @importFrom rlang .data
mbm_resample <- function(df, fraction, by) {
  
  # Fix global variable binding
  psem <- week <- day <- NULL
  . <- NULL
  
  if (by == "month") {
    
    re <- df %>%
      group_by(psem) %>%
      sample_frac(., size = fraction, replace = TRUE) %>%
      ungroup()
  } else if (by == "week") {
    
    re <- df %>%
      group_by(week) %>%
      sample_frac(., size = fraction, replace = TRUE) %>%
      ungroup()
  } else if (by == "day") {
    
    re <- df %>%
      group_by(day) %>%
      sample_frac(., size = fraction, replace = TRUE) %>%
      ungroup()
  }
  
  return(re)
}


# plr_weighted_regression

#' PLR linear model uncertainty
#' @description This function returns the standard deviation of a PLR calculated from a linear model
#' 
#' @param mod linear model
#' @param per_year number of data points in a given year baesd on which time scale was selected
#' 
#' @return Returns standard deviation of PLR value
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
#' # obain standard deviation from model
#' mod <- lm(power_var ~ time_var, data = test_xbx_wbw_res)
#' plr_sd <- plr_var(mod, per_year = 52)
#' 
#' @export
plr_var <- function(mod, per_year) {
  m <- summary(mod)$coefficients[2, 1]
  y <- summary(mod)$coefficients[1, 1]
  m_var <- stats::vcov(mod)[2, 2]
  y_var <- stats::vcov(mod)[1, 1]
  u <- sqrt( (per_year / y) ^ 2 * m_var + ( (-per_year * m) / y ^ 2) ^ 2 * y_var ^ 2)
  return(u * 100)
}
