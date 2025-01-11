#' Title Heatmap generation for PV data
#'
#' @param df dataframe containing at least the timestamp column and the variable to be plotted with the heatmap
#' @param col the character name of the column to be ploted
#' @param timestamp_col the character name of the timestamp column
#' @param timestamp_format the POSIXct format of the timestamp if conversion is needed
#' @param upper_threshold the fraction of upper data to include, 1 removes no data, 0.9 remove the top 1 percent etc.
#' @param lower_threshold the fraction of lower data to remove, 0 removes no data, 0.01 remove the bottom 1 percent etc.
#' @param font_size font size of the output plot
#'
#' @return returns a ggplot object heatmap of the specified column
#' @export
#'
#' @examples
#' # build heatmap
#' heat <- plr_pvheatmap(test_df, col = "g_poa", timestamp_col = "timestamp", 
#'                       upper_threshold = 0.99, lower_threshold = 0)
#' # display heatmap
#' plot(heat)
#' 
plr_pvheatmap <- function(df, col, timestamp_col, timestamp_format = "%Y-%m-%d %H:%M:%S",  upper_threshold = 1, lower_threshold = 0, font_size = 12){
  
  hms <- NA
  # remove NA timestamps
  df <- df[stats::complete.cases(df[[timestamp_col]]),]
  
  # check timestamp class, covert to posixct if necessary
  if(class(df[[timestamp_col]][1])[1] == 'POSIXct'){
    df$timestamp <- df[[timestamp_col]]
  }else{
    df$timestamp <- as.POSIXct(strptime(df[[timestamp_col]], format = timestamp_format, tz = "Ugrade_pv(df, 'iacp', meta$row_key[i], 'tmst')TC"))
  }
  
  # Determine the number of minutes between observations.
  c_time <- rev(df$timestamp)
  N <- difftime(c_time[1:(length(c_time) - 1)], c_time[2:length(c_time)], units = "mins")
  N <- round(N)
  n <- sort(table(N), decreasing = TRUE)[1]
  time_freq <- as.integer(names(n))
  
  # define time format for x and y axes
  df$date <- as.Date(strptime(df$timestamp, '%Y-%m-%d'))
  df$hms <- format(df$timestamp, '%H:%M')
  
  # labels of y
  timesequence <-seq(from =as.POSIXct('2020-01-02 00:00:00'), to = as.POSIXct('2020-01-03 00:00:00'), by = paste(time_freq,'min'))
  timesequence <- timesequence[-length(timesequence)]
  ylimits <- format(timesequence, '%H:%M')
  
  lab <- c( "01:00", "03:00", "05:00",
            "07:00", "09:00", 
            "11:00", "13:00",  "15:00",
            "17:00","19:00",
            "21:00",  "23:00")
  
  # plot color range
  bottom <- as.numeric(stats::quantile(df[[col]], lower_threshold, na.rm = TRUE))
  top <- as.numeric(stats::quantile(df[[col]], upper_threshold, na.rm = TRUE))
  
  # ggplot output
  hmpl <- ggplot2::ggplot(data = df, ggplot2::aes(y= hms, x = date, fill = .data[[col]])) +
    ggplot2::geom_tile() +
    ggplot2::labs(caption = NULL, title = NULL) +
    ggplot2::theme_bw(font_size) +
    ggplot2::scale_fill_viridis_c(values = c(0, 0.12, 0.6, 1), limits = c(bottom, top), oob = scales::squish) +
    ggplot2::scale_y_discrete(breaks = lab, limits = ylimits) +
    ggplot2::scale_x_date(expand = c(0, 0)) +
    ggplot2::labs(fill = col) + ggplot2::ylab('Time') + ggplot2::xlab('Date')
  
  return(hmpl)
  
}

#' returns quality information of time series data of PV
#'
#' @param df the PV time series data. It can be the direct output of read.csv(file_name, stringsAsFactors = F)
#' @param col column of the grading, default 'poay'
#' @param timestamp_col the character name of the timestamp column
#' @param timestamp_format the POSIXct format of the timestamp if conversion is needed
#' @param id The name of the pv data
#' @param batch_days the batch of data that the anomaly detection is applied. Since time series decomposition is used,
#' one seasonality will be applied for whole data which is inefficeint, if NA, will pass whole
#'
#' @author Arash Khalilnejad
#' @export

grade_pv <- function(df, col = 'poay', id = 'pv_id', timestamp_col = 'tmst', timestamp_format = "%Y-%m-%d %H:%M:%S", batch_days = 90){
  
  # timestamp to posixct
  df$timestamp <- as.POSIXct(strptime(df[[timestamp_col]], format = timestamp_format, tz = "UTC"))
  
  # structure the building with input column name
  df_structured <- data_structure(df, col = col, timestamp_col = timestamp_col)
  
  # return the quality information of the data
  quality_grade <- data_quality_check(df_structured, id = id, batch_days = batch_days)
  
  return(quality_grade)
}

#' Reads jci files gotten in budget period 2
#'
#' Reads the jci file and modifies the timestamp intevals and
#' based on location modifies the timezone using googleapi and
#' then generates the useful columns
#'
#' @param df dataframe containing at least the timestamp column and the variable to be plotted with the heatmap
#' @param col the character name of the column to be ploted
#' @param timestamp_col the character name of the timestamp column
#' which i is the number of file in the list
#'
#' @return a dataframe with fixed timestamps and useful cooumns
#' @author Arash
#' @export


data_structure <- function(df, col = 'elec_cons', timestamp_col = 'timestamp') {
  
  df$elec_cons <- df[[col]]
  df$timestamp <- df[[timestamp_col]]
  df_struct <- df[,c('timestamp', 'elec_cons')]
  df_struct <- df_struct[!duplicated(df_struct$timestamp), ]
  freq <- time_frequency(df_struct)
  df_struct <- as.data.frame(df_struct)
  df_struct <- ts_inflate(df_struct, 'timestamp', 'elec_cons', freq)
  
  if (length(df_struct[which(is.na(df_struct$elec_cons)), ]$elec_cons_imp) > 0) {
    df_struct[which(is.na(df_struct$elec_cons)), ]$elec_cons_imp <- 1
  }
  
  df_struct <- ip_num_time(df_struct)
  
  return(df_struct)
}

#' Determines the minutes between data points in a time-series
#'
#' @param data A time-series dataframe containing a column named 'timestamp'.
#'
#' @return a numeric value of the minutes between data points
#' @author Arash Khalilnejad
#' @export

time_frequency <- function(data) {
  
  # Determine the number of minutes between observations.
  c_time <- rev(data$timestamp)
  N <- difftime(c_time[1:(length(c_time) - 1)], c_time[2:length(c_time)], units = "mins")
  N <- round(N)
  n <- sort(table(N), decreasing = TRUE)[1]
  n <- as.integer(names(n))
  
  return(n)
}

#' Inflate a time series data set.
#'
#' Shifts known values to the nearest equidistant timestamp and fills in any
#' missing timestamps with NA values. An additional binary column named
#' \code{<column to impute>_imp} is added where 1 represents an unknown value
#' and zero represents a known value.
#'
#' @param data A data frame containing columns \code{ts_col} and
#' \code{col_to_imp}.
#'
#' @param ts_col The name of the timestamp column.
#'
#' @param col_to_imp The name of the column to impute.
#'
#' @param dt The expected time between consecutive timestamps, in minutes.
ts_inflate <- function(data, ts_col, col_to_imp, dt) {
  
  # Shift existing timestamps using a spline.
  start_ts <- round.POSIXt(data$timestamp[1], units = c("mins"))
  end_ts <- round.POSIXt(data$timestamp[length(data$timestamp)], units = c("mins"))
  dates <- data.frame(timestamp = seq(start_ts, end_ts, by = paste(dt, "min")))
  
  # Create an array of row indices that should not be imputed but rather keep their 'adjusted' value resulting from
  # a spline.
  data <- data[stats::complete.cases(data), ]
  time_diffs <- diff(data[[ts_col]])
  units(time_diffs) <- "mins"
  org_rows <- c(0, cumsum(as.numeric(round(time_diffs/dt)))) + 1
  
  imp <- suppressWarnings(spline_timestamp_sync(dates, merge_data = data[, c(ts_col, col_to_imp)]))
  
  # Set the values to be imputed to NA.
  imp[-org_rows, col_to_imp] <- NA
  
  # Add a binary column with name <column to impute>_imp representing whether or not the value for the corresponding
  # row has been imputed.
  imp_col <- paste0(col_to_imp, "_imp")
  imp[, imp_col] <- 0
  imp[-org_rows, imp_col] <- 1
  
  return(imp)
}

#' Spline columns to match timestamps.
#'
#' Often timestamps of two data frames will be mismatched. To
#' produced matching timestamps, columns that may be splined
#' will be and then corresponding values at the 'correct'
#' timestamp are used.
#'
#' Any value that can not be linearly interpolated such as a
#' string will remain the same.
#'
#' @param data A data frame with a correct timestamp column.
#'
#' @param data_ts The column name for the \code{data}
#' timestamp. Defaults to 'timestamp'
#'
#' @param merge_data A data frame that will be linearly
#' interpolated and merged with \code{data}.
#'
#' @param merge_ts The column name for the
#' \code{merge_data} timestamp. Defaults to 'timestamp'.
#'
#' @return The resulting merged data frame.
#' @author Arash Khalilnejad
#' @export

spline_timestamp_sync <- function(data, data_ts = "timestamp", merge_data, merge_ts = "timestamp") {
  timestamps <- data[, data_ts]
  timestamps_to_inter <- merge_data[, merge_ts]
  
  ncores <- parallel::detectCores()
  cluster <- parallel::makeCluster(ncores)
  dates <- data[, data_ts]
  parallel_cluster_export(cluster, c("timestamps", "timestamps_to_inter"), envir = environment())
  
  spline_col <- function(col) {
    col <- stats::spline(timestamps_to_inter, col, xout = timestamps)$y
    return(round(col, digits = 3))
  }
  
  num_cols <- sapply(merge_data, is.numeric)
  num_cols <- names(merge_data)[which(num_cols)]
  
  splined <- parallel::parSapply(cluster, merge_data[num_cols], spline_col)
  data <- cbind(data, splined)
  
  # FIXME: find a way to merge non numeric cols w/ diff lengths
  if (length(data[, data_ts]) == length(merge_data[, merge_ts])) {
    non_num_cols <- !sapply(merge_data, is.numeric)
    non_num_cols <- names(merge_data)[which(non_num_cols)]
    non_num_cols <- setdiff(non_num_cols, merge_ts)
    
    data <- cbind(data, merge_data[non_num_cols])
  } else {
    warning("Non-numeric columns dropped b/c data
                frames have different lengths")
  }
  
  parallel::stopCluster(cluster)
  
  return(data)
}


#' Numerical time interim predictor.
#'
#' Convert the hour and minute component of each timestamp to a numerical
#' representation.
#'
#' @param data A dataframe with a timestamp column.
#'
#' @param ts_col The timestamp column name in \code{data}. Default value is
#' 'timestamp'.
#' @author Arash Khalilnejad
#'
#' @return \code{data} with a num_time column added.
ip_num_time <- function(data, ts_col = "timestamp") {
  timestamps <- data[[ts_col]]
  hours <- as.numeric(substr(timestamps, 12, 13))
  minutes <- as.numeric(substr(timestamps, 15, 16))
  times <- hours + minutes/60
  
  data$num_time <- round(times, digits = 3)
  
  return(data)
}

#' checks the quality of the data after and before cleaning
#'
#'
#' calculates the percentage of anomalies, missings + zeros, gaps, and length of
#' the data and reports the quality of data before and after cleaning.
#'
#' The quality grading criteria is as following:
#' anomalies A: less than 10%, B: 10 to 20%, C: 20 to 30%, D: more than 30%
#' missing percentage: A: less than 10%, B: 10 to 15%, C: 15 to 20% and D: more than 20%
#' largest gap: A: less than 120 hours, B: 120 to 164 hours, C: 164 to 240 hours
#' D: more than 240 hours
#' length P: more than 2 years, F: less than 2 years
#'
#'@param energy_data structured energy dataframe
#'@param col Input column
#'@param id PV system ID
#'@param batch_days the batch of data that the anomaly detection is applied. Since time series decomposition is used,
#'one seasonality will be applied for whole data which is inefficient, if NA, will pass whole
#'
#'@return a table with grading of the quality after and before cleaning
#'
#'@author Arash Khalilnejad
#'
#'@export

data_quality_check <- function(energy_data, col = 'elec_cons', id = 'pv_df',
                               batch_days = 90){
  
  # require(tidyverse)
  # # 
  # # 
  # energy_data$timestamp <- as.POSIXct(energy_data$tmst)
  # energy_data$elec_cons <- energy_data[[col]]
  # 
  
  # zero or negative points are replaced with NA in electricty and treated as missing points
  # (the corresponding elec_cons_imp = 1)
  
  elec_cons <- NA
  
  #observations per hour
  freq <- 60/time_frequency(energy_data[1:2000,])
  
  # passing through anom fix function to find anomaly rate, and adds two columns
  # of anom_flag and cleaned_energy, it just puts NA in anomalous cleaned_energy col
  en_anom <- anomaly_detector(energy_data, batch_days = batch_days)
  
  # the quality parameters for dataset before cleaning
  raw <- c()
  raw$id <- id
  raw$start <- energy_data$timestamp[1]
  raw$end <- energy_data$timestamp[nrow(energy_data)]
  
  raw$anom_percentage <- round(sum(en_anom$anom_flag)/length(en_anom$elec_cons),
                               3)*100
  
  
  en_anom_on_time <- en_anom[which(en_anom$on_time == 1), ]
  
  # missings
  
  raw$missing_percentage <- round(sum(en_anom_on_time$elec_cons_imp)/length(en_anom$elec_cons),
                                  3)*100
  
  # gets the two largest chunks using Int function
  chunks <- Int(en_anom)
  
  # gets the largest one in hours
  raw$largest_gap_hour <- max(chunks$length)/freq
  
  if (is.na(raw$largest_gap_hour)) {
    raw$largest_gap_hour = 0
  }
  
  raw$length_day <- floor(as.numeric(difftime(energy_data$timestamp[nrow(energy_data)],
                                              energy_data$timestamp[1],
                                              units ='days')))
  
  ## number_of_gaps Calc
  res <- rle(en_anom_on_time$elec_cons_imp == 1)
  gaps_calc <- which(res$lengths > 4 & res$values == TRUE)
  ##
  raw$number_of_gaps <- length(gaps_calc)
  
  # standard deviation of remainders
  raw$remainder_sd <- sd(en_anom$decompose_remainders, na.rm = TRUE)
  
  # all days peak values  (0.98 quantile to exclude outliers)
  daily_max <- en_anom %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(max_power = as.numeric(stats::quantile(elec_cons, 0.98, na.rm = TRUE)))
  
  # standard deviation of remainders in kW
  raw$trend_mean <- sd(en_anom$decompose_trend, na.rm = TRUE)
  raw$seasonality_mean <- sd(en_anom$decompose_seasonality, na.rm = TRUE)
  raw$median_noon_peak <- median(daily_max$max_power, na.rm = TRUE)
  raw$quantile_98_noon <- as.numeric(stats::quantile(en_anom[which(en_anom$num_time > 11 & en_anom$num_time < 13), ]$elec_cons, 0.98, na.rm = TRUE))
  
  ## first 30 days
  # first 30 days with available data
  days = unique(en_anom[which(en_anom$elec_cons_imp == 0), ]$date)[1:30]
  
  
  # data with first 30 days
  en_anom_30days <- en_anom[which(en_anom$date %in% days), ]
  
  # first 30 days peak values  (0.98 quantile to exclude outliers)
  daily_max_30 <- en_anom_30days %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(max_power = as.numeric(stats::quantile(elec_cons, 0.98, na.rm = TRUE)))
  
  # mean of seasonality and trend in first 30 days
  raw$trend_mean_30days <- sd(en_anom_30days$decompose_trend, na.rm = TRUE)
  raw$seasonality_mean_30days <- sd(en_anom_30days$decompose_seasonality, na.rm = TRUE)
  raw$median_noon_peak_30days <- median(daily_max_30$max_power, na.rm = TRUE)
  raw$quantile_98_noon_30days <- as.numeric(stats::quantile(en_anom_30days[which(en_anom_30days$num_time > 11 & en_anom_30days$num_time < 13), ]$elec_cons, 0.98, na.rm = TRUE))
  
  quality <- as.data.frame(raw)
  
  
  quality$grade_anom <- NA
  quality$grade_missing <- NA
  quality$grade_gap <- NA
  quality$grade_length <- NA
  quality$grade <- NA
  
  
  # quality statement
  
  i = 1
  # anomaly percentage grading
  
  if (quality$anom_percentage[i] <= 10) {
    
    quality$grade_anom[i] <- "A"
    
  } else if (quality$anom_percentage[i] > 10 & quality$anom_percentage[i] <= 20) {
    
    quality$grade_anom[i] <- "B"
    
  }else if (quality$anom_percentage[i] > 20 & quality$anom_percentage[i] <= 30) {
    
    quality$grade_anom[i] <- "C"
    
  }else if (quality$anom_percentage[i] > 30) {
    
    quality$grade_anom[i] <- "D"
    
  }
  
  
  # missing percentage grading
  
  if (quality$missing_percentage[i] <= 10) {
    
    quality$grade_missing[i] <- "A"
    
  } else if (quality$missing_percentage[i] > 10 & quality$missing_percentage[i] <= 25) {
    
    quality$grade_missing[i] <- "B"
    
  }else if (quality$missing_percentage[i] > 25 & quality$missing_percentage[i] <= 40) {
    
    quality$grade_missing[i] <- "C"
    
  }else if (quality$missing_percentage[i] > 40) {
    
    quality$grade_missing[i] <- "D"
    
  }
  
  
  # gap grading (120 hour as 5 days)
  
  if (quality$largest_gap_hour[i] <= 360) {
    
    quality$grade_gap[i] <- "A"
    
  } else if (quality$largest_gap_hour[i] > 360 & quality$largest_gap_hour[i] <= 720) {
    
    quality$grade_gap[i] <- "B"
    
  }else if (quality$largest_gap_hour[i] > 720 & quality$largest_gap_hour[i] <= 2160) {
    
    quality$grade_gap[i] <- "C"
    
  }else if (quality$largest_gap_hour[i] > 2160) {
    
    quality$grade_gap[i] <- "D"
    
  }
  
  # length grading
  
  if (quality$length_day[i] >= 730) {
    
    quality$grade_length[i] <- "P"
    
  } else if (quality$length_day[i] < 730) {
    
    quality$grade_length[i] <- "F"
    
  }
  
  
  # merge the grades into one column
  
  quality$grade <- paste0(quality$grade_anom,
                          quality$grade_missing,
                          quality$grade_gap,
                          quality$grade_length)
  
  
  quality <- quality[, -c( 18:21)]
  
  return(quality)
  
}

#' detects rhw anomalies and returns a dataframw with cleaned and anom_flag column
#'
#' @param df the strucutred data
#'
#' @param batch_days the batch of data that the anomaly detection is applied. Since time series decomposition is used,
#' one seasonality will be applied for whole data which is inefficeint, if NA, will pass whole
#'
#' @return  data with anomalies
#' @author Arash Khalilnejad
#'
#' @export


anomaly_detector <- function(df, batch_days = 90){
  
  # date
  df$date <- substr(df$timestamp, 1, 10)
  
  # if no batch, pass the whole data through anomaly
  if(is.na(batch_days)){
    
    return(anomalies(df))
    
  }
  
  # separating the batches
  i = 0
  df_anomaly <- c()
  while(TRUE){
    
    
    start_date = as.Date(unique(df$date)[batch_days*i+1])
    
    end_date = as.Date(unique(df$date)[batch_days*i+batch_days])
    
    # in the last batch
    if(is.na(end_date)){
      end_date = df$date[nrow(df)]
    }
    
    # A batch of less than 10 days doesn't have enough seasonality
    if(as.numeric(difftime(end_date, start_date, units = 'days')) < 10){
      
      break
      
    }
    
    # batch subset
    
    df_batch <- df %>%
      dplyr::filter(date >= start_date, date <= end_date)
    
    # anomaly detection
    df_batch_anomaly <- anomalies(df_batch)
    
    df_batch_anomaly <- df_With_on_time(df_batch_anomaly)
    
    # bind
    df_anomaly <- rbind(df_anomaly, df_batch_anomaly)
    
    i=i+1
    if(end_date == df$date[nrow(df)]){
      
      break
    }
    
  }
  
  return(df_anomaly)
  
}


#'Fixes the anomlies
#'
#'
#'This function gets the data and finds the anomlies in weekends and
#'weekdays and gives a dataframe with anomalies and anomaly columns
#'
#'@param df structured dataframe
#'@author Arash Khalilnejad
#'
#'@return df with two columns of cleaned_energy and anom_flag
#'
anomalies <- function(df) {
  
  daildaata <- NA
  
  ## assign the row names to a new column
  df$row <- as.numeric(rownames(df))
  inputdf <- df
  
  # if all is missing, put zero nd proceed
  if(nrow(df[!is.na(df$elec_cons),]) < 2){
    df$elec_cons <- 0
  }
  ## linear interpolation of missings
  df$elec_cons <- forecast::na.interp(df$elec_cons)
  
  ## ts class of elec cons on weekdays
  en_ts_wd <- stats::as.ts(df$elec_cons)
  
  ## find frequncy of data
  #freq <- 24 * 60/time_frequency(df)
  freq <- df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(daildaata = dplyr::n()) %>%
    dplyr::summarise(median_value = as.numeric(median(daildaata, na.rm = TRUE))) %>%
    as.data.frame()
  
  ## apply time series decompostion using "stl", and extract the residuals
  ts_decompose <- stats::stl(stats::ts(en_ts_wd, frequency = freq$median_value),
                      s.window = "periodic",
                      robust = TRUE)$time.series
  
  
  ## apply the tsoutliers function to find the outliers in residuals
  residout <- forecast::tsoutliers(ts_decompose[, 3], lambda = 'auto', iterate = 1)
  
  
  df[, c(3)] <- stats::ts(rep(NA, length(en_ts_wd)))
  
  ## assign the outliers on that column
  df[, c(3)][residout$index] <- en_ts_wd[residout$index]
  
  # convert the the classes of elec_cons imp which is the third column to numeric
  df$elec_cons_imp <- as.numeric(df$elec_cons_imp)
  
  ## df as dataframe
  en_bind <- as.data.frame(df)
  
  ## reoder based on the order of orginal data
  en_bind <- en_bind[order(en_bind$row), ]
  
  ## anom flag column
  en_bind$anom_flag <- 0
  
  ## if th elec_cons_imp is not empty (we have outlier in that row), then mark the anom_flag to 1
  if(nrow( en_bind[which(!is.na(en_bind$elec_cons_imp)), ]) > 1){
    en_bind[which(!is.na(en_bind$elec_cons_imp)), ]$anom_flag <- 1
  }
  
  ## generate the cleaned energy column
  en_bind$cleaned_energy <- NA
  
  ## assign the non anomaly datapoints to cleaned energy column
  en_bind[which(en_bind$anom_flag == 0), ]$cleaned_energy <- en_bind[which(en_bind$anom_flag == 0), ]$elec_cons
  
  ## assign those two new columns to original dataset
  inputdf$cleaned_energy <- en_bind$cleaned_energy
  inputdf$anom_flag <- en_bind$anom_flag
  
  ## remove the row column
  inputdf <- within(inputdf, rm(row))
  
  
  ## append time series decompose components
  inputdf$decompose_trend <- round(as.numeric(ts_decompose[,2]), 2)
  inputdf$decompose_seasonality <- round(as.numeric(ts_decompose[,1]), 2)
  inputdf$decompose_remainders <- round(as.numeric(ts_decompose[,3]), 2)
  
  ## remove time series decompose infromation on missing points,
  # since, the missings are linearly interpolated and are not real data, so, decomposition is not real
  if(nrow(inputdf[which(inputdf$elec_cons_imp == 1),])> 0){
    inputdf[which(inputdf$elec_cons_imp == 1),]$anom_flag <- 0
    inputdf[which(inputdf$elec_cons_imp == 1),]$elec_cons <- NA
    inputdf[which(inputdf$elec_cons_imp == 1),]$decompose_trend <- NA
    inputdf[which(inputdf$elec_cons_imp == 1),]$decompose_seasonality <- NA
    inputdf[which(inputdf$elec_cons_imp == 1),]$decompose_remainders <- NA
  }
  
  
  return(inputdf)
  
}

#' data with PV on time flag.
#'
#' returns dataframe of PV with approximate operating period, baed on median of start and end time.
#' @param df df with num_time
#' @return input data with one more column of on_time
#'
#' @author Arash Khalilnejad

df_With_on_time <- function(df){
  
  df$on_time <- NA
  start_end <- day_time_start_end(df)
  
  if (length(df[which(df$num_time >= start_end$start_median & df$num_time <= start_end$end_median), ]$on_time) > 0){
    df[which(df$num_time >= start_end$start_median & df$num_time <= start_end$end_median), ]$on_time <- 1
  }
  
  return(df)
  
}

#' finds median start and end time of PV operation
#'
#' @param df with num_time Column
#'
#' @return dataframe with start and end time
#' @author Arash Khalilnejad

day_time_start_end <- function(df){
  
  num_time <- NA
  start <- NA
  end <- NA
  
  # if the elec_cons is positive for at least 10 datapoints.
  if(length(df[which(df$elec_cons > 0), ]$timestamp) > 10){
    
    en_subset <- df[which(df$elec_cons > 0), ]
    
    # median start and end time
    start_end <-  en_subset %>%
      group_by(date) %>%
      dplyr::summarise(start = num_time[1], end = num_time[dplyr::n()]) %>%
      dplyr::summarize(start_median = median(start, na.rm = TRUE),
                end_median = median(end, na.rm = TRUE)) %>%
      as.data.frame()
    
    
    # if cannot detected full day
    if (is.na(start_end$start_median)){
      start_end$start_median <- 0
    }
    if(is.na(start_end$end_median)){
      start_end$end_median <- 24
    }
    if((start_end$end_median - start_end$start_median) < 5){
      start_end$start_median <- 0
      start_end$end_median <- 24
    }
  }
  
  else{
    
    start_end <- data.frame(start_median = 0, end_median = 24)
    
  }
  
  
  return(start_end)
}

#' Largest Intervals
#'
#' @param df Dataframe
#'
#' @return Intervals
#' @author Arash Khalilnejad
#' @export

Int <- function(df) {
  res <- rle(df$elec_cons_imp == 1)
  
  # AA<-which(res$lengths>=96 & res$values==TRUE )
  
  Res <- data.frame(unclass(res))
  Res$Row <- as.numeric(rownames(Res))
  
  Res_Order <- Res[order(Res$lengths, decreasing = TRUE), ]
  Interval1 <- Res_Order[which(Res_Order$values == TRUE), ][1, ]
  if (is.na(Interval1$lengths)) {
    Interval1$lengths <- 0
    Intervals <- c()
    Intervals$lengths <- 0
  } else {
    Interval2 <- Res_Order[which(Res_Order$values == TRUE), ][2, ]
    Interval1$Start <- sum(Res$lengths[1:Interval1$Row - 1])
    Interval1$End <- sum(Res$lengths[1:Interval1$Row])
    if (is.na(Interval2$Row)) {
      
      Interval2$Start <- 3
      Interval2$End <- 5
    } else {
      Interval2$Start <- sum(Res$lengths[1:Interval2$Row - 1])
      Interval2$End <- sum(Res$lengths[1:Interval2$Row])
      Interval2$lengths <- 1
      
    }
    Intervals <- rbind(Interval1, Interval2)
    Intervals <- Intervals[order(Intervals$Row, decreasing = FALSE), ]
    Intervals$Date.s <- df$timestamp[Intervals$Start[1]]
    Intervals$Date.s[2] <- df$timestamp[Intervals$Start[2]]
    Intervals$Date.e <- df$timestamp[Intervals$End[1]]
    Intervals$Date.e[2] <- df$timestamp[Intervals$End[2]]
  }
  return(Intervals)
}


#' Linearly interpolate missing energy values.
#'
#' If there exist lest than four missing values, represented by
#' NA values, fill with linearly interpolated values.
#'
#' @param data A data frame with an 'elec_cons' column.
#'
#' @param threshold The maximum number of consective values
#' that may be filled with interpolated values. By default
#' four.
#'
#' @return The data frame with 'missing values' filled in.
#'
#' @examples
#' \dontrun{
#' lin_inter_missing_energy(data)
#' }
lin_inter_missing_energy <- function(data, threshold = 4) {
  data_length <- length(data$elec_cons)
  missing_energy_rows <- which(is.na(data$elec_cons))
  
  if (length(missing_energy_rows) == 0) {
    return(data)
  }
  
  row = missing_energy_rows[1]
  
  # If the data starts missing, fill with zeros no matter what
  if (row == 1) {
    while (row %in% missing_energy_rows) {
      row <- row + 1
    }
    
    data$elec_cons[1:(row - 1)] <- 0
  }
  
  while (row < missing_energy_rows[length(missing_energy_rows)]) {
    # Get the next row from list
    row <- missing_energy_rows[which(missing_energy_rows >= row)[1]]
    
    # The row before the NAs
    front_row <- row - 1
    front_val <- data$elec_cons[front_row]
    
    consecutive_nas <- 0
    while (row %in% missing_energy_rows) {
      row <- row + 1
      consecutive_nas <- consecutive_nas + 1
    }
    
    # If there is no last value in the last row, fill with zeroes
    if (row == data_length + 1) {
      # Exclude 'front' and 'back' vals
      data$elec_cons[(front_row + 1):(row - 1)] <- 0
    } else {
      if (consecutive_nas <= threshold) {
        # The value after the NAs
        back_val <- data$elec_cons[row]
        
        step <- (back_val - front_val)/(consecutive_nas + 1)
        vals <- seq(from = front_val, to = back_val, by = step)
        
        data$elec_cons[front_row:row] <- vals
      } else {
        # Exclude 'front' and 'back' vals
        data$elec_cons[(front_row + 1):(row - 1)] <- 0
      }
    }
  }
  
  return(data)
}

#' Linearly interpolate hourly data to 15 min data.
#'
#' Many weather data sets are hourly and we need values for
#' every 15 minutes.
#'
#' Any value that can not be linearly interpolated such as a
#' string will remain the same.
#'
#' @param data A data frame with hourly data.
#' @param data_ts The column name for the \code{data}
#' timestamp.
#' @author Arash Khalilnejad
#'
#' @return The resulting fifteen minute data frame.
lin_inter_hrly_to_fifteen <- function(data, data_ts) {
  original <- data
  original[, -which(names(data) == data_ts)] <- NA
  
  for (i in (1:3)) {
    mins <- i * 15 * 60
    inter_ts_data <- original
    inter_ts_data[, data_ts] <- original[, data_ts] + mins
    data <- rbind(data, inter_ts_data)
  }
  
  data <- data[order(data[, data_ts]), ]
  row.names(data) <- 1:length(data[, data_ts])
  
  num_cols <- sapply(data, is.numeric)
  non_num_cols <- !sapply(data, is.numeric)
  
  inter <- zoo::na.approx(data[, num_cols])
  inter_len <- length(inter[, 1])
  
  data[1:inter_len, num_cols] <- inter
  res <- data[1:inter_len, ]
  
  return(res)
}




#' Export variables to a cluster.
#'
#' Ghost cluster export call to make sure
#' testCoverage's trace function and environment
#' are available.
#' @param cluster Cluster
#' @param varlist Character vector of names of objects to export.
#' @param envir Environment from which t export variables
#'
#' @export

parallel_cluster_export <- function(cluster, varlist, envir = .GlobalEnv) {
  if ("package:testCoverage" %in% search() & exists(".g")) {
    parallel::clusterExport(cluster, c("_trace"), as.environment("package:testCoverage"))
    parallel::clusterExport(cluster, c(varlist, ".g"), envir)
  } else {
    parallel::clusterExport(cluster, varlist, envir)
  }
}