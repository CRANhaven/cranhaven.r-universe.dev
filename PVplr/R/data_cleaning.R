#' Define Standard Variable Names
#' @description The method determines the variable names used by the input dataframe.
#'  It looks for the following labels:
#'  \itemize{
#'    \item power_var <- iacp; if not, sets to idcp
#'    \item time_var <- tmst; if not ,sets to tutc
#'    \item irrad_var <- poay; if not, sets to ghir
#'    \item temp_var <- temp; if not, sets to modt
#'    \item wind_var <- wspa; if applicable, else NULL
#' }
#'  This function assumes data is in a standard HBase format. If you are using other data
#'  (as you most likely are) you should use the companion function, \code{\link{plr_build_var_list}}.
#' 
#' @param df A dataframe containing pv data.
#' 
#' @return Returns a dataframe containing standard variable names (no data). It will not include
#'   windspeed if the variable was not already included. This is frequently an input
#'   of other functions.
#'   
#' @examples 
#' var_list <- plr_variable_check(test_df)
#'  
#' @export
plr_variable_check <- function(df) {
  names <- colnames(df)
  power_var <- dplyr::if_else("iacp" %in% names, "iacp", "idcp")
  time_var <- dplyr::if_else("tmst" %in% names, "tmst", "tutc")
  irrad_var <- dplyr::if_else("poay" %in% names, "poay", "ghir")
  temp_var <- dplyr::if_else("temp" %in% names, "temp", "modt")
  
  if ("wspa" %in% names) {
    wind_var <- "wspa"
    
    final <- data.frame(time_var, power_var, irrad_var, temp_var, wind_var,
                        stringsAsFactors = FALSE)
  } else {
    
    final <- data.frame(time_var, power_var, irrad_var, temp_var, 
                        stringsAsFactors = FALSE)
  }
  
  return(final)
}

#' Build a Custom Variable List
#' 
#' The default var_list generator, plr_variable_check, assumes data comes from
#' SDLE's sources. If you are using this package with your own data, the format
#' may not line up appropriately. Use this function to create a variable list to
#' be passed to other functions so they can keep track of what column names mean.
#' 
#' @param time_var The variable representing time. Typically, a timestamp.
#' @param power_var The variable representing time. Typically, in watts.
#' @param irrad_var The variable representing irradiance. Typically, either poa or
#' ghi irradiance.
#' @param temp_var The variable representing temperature. Package functions assume 
#' Celcius.
#' @param wind_var optional; The variable representing wind speed.
#' 
#' @return Returns dataframe of variable names for the given photovoltaic data for use with later functions
#' 
#' @examples 
#' var_list <- plr_build_var_list(time_var = "timestamp",
#'                                power_var = "power",
#'                                irrad_var = "g_poa",
#'                                temp_var = "mod_temp",
#'                                wind_var = NA)
#' 
#' @export
plr_build_var_list <- function(time_var, power_var, irrad_var, temp_var, wind_var) {
  
  final <- data.frame(time_var, power_var, irrad_var, temp_var, wind_var,
                      stringsAsFactors = FALSE)
  if (is.null(final$wind_var)) {
    final <- dplyr::select(time_var, power_var, irrad_var, temp_var)
  }
  
  return(final)
}

#' Fix Column Typings
#'
#' @description Converts appropriate columns to numeric without specifying
#'  the name of the column. All columns from hbase are read as factors.
#'  Columns are tested to see if they should be numeric by forcing conversion
#'  to numeric. Columns that subsequently contain NA's are not numeric; if not,
#'  they are set to numeric.
#'
#'@param df A dataframe containing pv data.
#'
#'@return Returns original dataframe with columns corrected to proper classes
#'
#' @examples 
#' df <- PVplr::plr_convert_columns(test_df)
#'
#'@export
plr_convert_columns <- function(df) {
  
  start_time <- Sys.time()
  # function to convert to character then numeric
  nc <- function(x) {
    return(as.numeric(as.character(x)))
  }
  # function to test if an entire column is NA
  all_na <- function(x) {
    return(all(is.na(x)))
  }
  # function to test is the values in a column should be numeric
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
  
  # turn off warnings (removed for package)
  # old <- getOption("warn")
  # options(warn = -1)
  
  # test every column for numeric class
  # see helper_fun.R for the num_test and nc functions
  cols <- suppressWarnings(sapply(df, num_test))
  
  # only convert the passed columns to numeric, keep the others as they were
  # this should prevent any loss of data during the conversion
  df[, cols] <- sapply(df[cols], nc)
  
  # turn warnings back on
  # options(warn = old)
  
  print(Sys.time() - start_time)
  return(df)
  
}

#' Basic Data Cleaning
#'
#' @description Removes entries with irradiance and power readings outside cutoffs,
#'   fixes timestamps to your specified format, and converts columns to numeric
#'   when appropriate - see \code{\link{plr_convert_columns}}. 
#'   Also, adds columns for days/weeks/years of operation that are used by
#'   other functions.
#'   
#' @param df A dataframe containing pv data.
#' @param var_list A list of the dataframe's standard variable names, obtained from
#'  the output of \code{\link{plr_variable_check}}.
#' @param irrad_thresh The lowest meaningful irradiance value.
#' Values below are filtered.
#' @param low_power_thresh The lowest meaningful power output.
#' Values below are filtered.
#' @param high_power_cutoff The highest meaningful power output.
#' Values above are filtered.
#' @param tmst_format The desired timestamp format.
#' 
#' @return Returns dataframe with rows filtered out based on passed cleaning parameters
#' 
#' @examples 
#' var_list <- plr_build_var_list(time_var = "timestamp",
#'                                power_var = "power",
#'                                irrad_var = "g_poa",
#'                                temp_var = "mod_temp",
#'                                wind_var = NA)
#'                                
#' test_dfc <- plr_cleaning(test_df, var_list, irrad_thresh = 100,
#'                          low_power_thresh = 0.01, high_power_cutoff = NA)
#' 
#' @importFrom magrittr %>%
#'
#' @export
plr_cleaning <- function(df, var_list, irrad_thresh = 100, low_power_thresh = 0.05,
                         high_power_cutoff = NA, tmst_format = "%Y-%m-%d %H:%M:%S") {
  
  #requires dplyr, lazyeval
  
  # removed to speed up cleaning function. Function can be run prior to cleaning if necessary
  # df <- PVplr::plr_convert_columns(df)
  
  # format timestamp as POSIXct object
  # add days of operation column, useful for clear sky identification
  df[, var_list$time_var] <- as.POSIXct(df[, var_list$time_var], format = tmst_format)
  df$day <- sapply( (as.Date(df[, var_list$time_var]) - as.Date(df[, var_list$time_var][1])) + 1,
                    as.character)
  df$week <- ceiling(as.numeric(df$day) / 7)
  df$date <- as.character(as.Date(df[, var_list$time_var]))
  df$psem <- ceiling(as.numeric(df$day) / 30)
  
  
  # # convert select columns to numeric class
  # df <- data.frame(dplyr::select(df, tmst, row_key, date),
  #                    lapply(dplyr::select(df, -c(tmst, row_key, date)),
  #                           function(x) as.numeric(as.character(x))))
  
  # define filter functions for irradiance and power
  # 200 < irradiance < 1500
  # power > 5% max power
  
  irrad_filter <- paste(var_list$irrad_var, ">=", irrad_thresh, "&", var_list$irrad_var, "<=", 1500)
  
  if (!is.na(high_power_cutoff)) {

    power_filter1 <- paste(var_list$power_var, "<", high_power_cutoff)
    
    # apply power and irradiance filters
    dfc <- df[stats::complete.cases(df), ] %>%
      dplyr::filter(eval(str2expression(irrad_filter))) %>%
      dplyr::filter(eval(str2expression(power_filter1)))
    
  } else {

    # apply only irradiance filters
    dfc <- df[stats::complete.cases(df), ] %>%
      dplyr::filter(eval(str2expression(irrad_filter)))
    
  }
  
  power_filter2 <- paste(var_list$power_var, ">=", low_power_thresh * max(dfc[, var_list$power_var], 
                                                                          na.rm = TRUE))
  
  dfc <- dplyr::filter(dfc, eval(str2expression(power_filter2)))
  
  
  
  return(dfc)
}

#' Filter outliers from Power Predicted Data
#' 
#' This function is used to remove outliers (if desired) after putting data 
#' through a power predictive model, e.g. \code{\link{plr_xbx_model}}. 
#' 
#' @param data A resulting dataframe from a power predictive model.
#' 
#' @return Returns dataframe with outliers flagged by other functions removed
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
#' # Remove outliers from the modeled data
#' test_xbx_wbw_res_no_outliers <- plr_remove_outliers(test_xbx_wbw_res)
#' 
#' @importFrom magrittr %>%
#' 
#' @export
plr_remove_outliers <- function(data) {
  res <- data %>%
    dplyr::filter(data$outlier == FALSE)
  
  return(res)
}
