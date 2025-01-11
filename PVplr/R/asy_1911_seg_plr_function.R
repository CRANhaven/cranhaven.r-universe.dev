#' Segmented linear PLR extraction function
#'
#' @param df data frame of corrected power measurements, typically the output of a weather correction model
#' @param per_year number of data point defining one seasonal year (365 for days, 52 for weeks etc.)
#' @param psi vector of 1 or more breakpoint estimates for the model. If not given will evenly space breakpoints across time series
#' @param n_breakpoints number of desired breakpoints. Determines number of linear models
#' @param power_var character name of the power variable
#' @param time_var character name of the time variable
#' @param return_model logical to return model object. If FALSE returns PLR results from model
#'
#' @return if return_model is FALSE it returns PLR results from model, otherwise returns segmented linear model object
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
#' #' # Perform power modeling step
#' test_xbx_wbw_res <- plr_xbx_model(test_dfc, var_list, by = "week",
#'                                   data_cutoff = 30, predict_data = NULL)
#'                                   
#' decomp <- plr_decomposition(test_xbx_wbw_res, freq = 4,
#'                                          power_var = 'power_var', time_var = 'time_var',
#'                                          plot = FALSE, plot_file = NULL, title = NULL, 
#'                                          data_file = NULL)
#' 
#' # evaluate segmented PLR results
#' seg_plr_result <- PVplr::plr_seg_extract(df = decomp, per_year = 365,
#'                                          n_breakpoints = 1, power_var = "trend",
#'                                          time_var = "age")
#' 
#' # return segmented model instead of PLR result
#' model <- PVplr::plr_seg_extract(df = decomp, per_year = 365, n_breakpoints = 1,
#'                                 power_var = "trend", time_var = "age", return_model = TRUE)
#' 
#' # predict data along time-series with piecewise model for plotting
#' pred <- data.frame(age = seq(1, max(decomp$age, na.rm = TRUE), length.out = 10000))
#' pred$seg <- predict(model, newdata = pred)
#' 
#' @export
#'
plr_seg_extract <- function(df, per_year, psi = NA, n_breakpoints, power_var, time_var, return_model = FALSE) {
  
  # segmented package used to create segmented linear models
  # require(segmented)
  
  # # function to extract model standard deviation based on coefficient variance
  # plr_var <- function(mod, per_year) {
  #   m <- summary(mod)$coefficients[2,1]
  #   y <- summary(mod)$coefficients[1,1]
  #   m_var <- vcov(mod)[2,2]
  #   y_var <- vcov(mod)[1,1]
  #   u <- sqrt((per_year/y)^2 * m_var + ((-per_year * m)/y^2)^2 * y_var^2)
  #   return(u*100)
  # }
  
  # build linear model
  fun.lm <- stats::as.formula(paste(power_var, "~", time_var))
  mod.lm <- lm(fun.lm, data = df)
  
  # if psi imputs are not passed determine their values 
  # by spacing them evenly along the time series
  # based on the number of breakpoints
  if (is.na(psi)) {
    iter <- max(df[,time_var], na.rm = TRUE)/(n_breakpoints + 1)
    psi <- NULL
    psi <- seq(iter, iter*n_breakpoints, by = iter)
    
    # for loop replqced with sequence
    # for (i in c(1:n_breakpoints)) {
    #   v <- iter*i
    #   psi <- c(psi, v)
    # }
  }
  
  # define segmented model
  fun.sg <- stats::as.formula(paste0("~", time_var))
  mod.sg <- segmented::segmented(mod.lm, seg.Z = fun.sg, psi = psi)
  
  yint <- as.numeric(mod.sg$coefficients[1])
  
  
  # loop over breakpoints to extract results
  res.sg <- NULL
  for (i in c(1:(n_breakpoints + 1))) {
    
    
    # extract previous breakpoint 
    # so the start and end of each segment in known
    seg.start <- 0
    
    if (i > 1) {
      seg.start <- segmented::summary.segmented(mod.sg)$psi[i - 1, 2]
    }
    
    if (i == (n_breakpoints + 1)) {
      seg.end <- max(df[time_var])
    } else {
      seg.end <- segmented::summary.segmented(mod.sg)$psi[i, 2]
    }
    
    
    # CONSIDERATION - SHOULD THE Y-INT USED BE FROM THE SEGMENT OR THE WHOLE MODEL
    # SO FAR IT IS THE WHOLE MODEL TO KEEP EVERYTHING RELATIVE TO INITIAL CONDITIONS
    plr <- data.frame(segmented::slope(mod.sg))[i,1]/yint*100*per_year
    
    # filter data to range of current segment
    df.sg <- df[df[time_var] > seg.start & df[time_var] < seg.end,]
    
    # calculate standard deviation of segment
    sd <- plr_var(mod = lm(fun.lm, data = df.sg), per_year = per_year)
    
    # combine results
    r <- data.frame(plr = plr, 
                    seg_start = seg.start,
                    seg_end = seg.end,
                    plr_sd = sd, 
                    segment = i)
    
    res.sg <- rbind(res.sg, r)
    
  }
  
  # add y-intercept and adj-R2 model results
  res.sg$yint <- yint
  res.sg$Adj_R2 <- segmented::summary.segmented(mod.sg)$adj.r.squared
  
  # return model results or model object based on function inputs
  if (return_model) {
    return(mod.sg)
  } else {
    return(res.sg)
  }
  
}