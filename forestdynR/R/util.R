#' @title create_din_df
#'
#' @description Creates a dynamic data frame by combining a list of data and rounding numeric values to a specified number of digits.
#' This function takes a list of data, rounds the numeric values, and combines them into a single data frame with custom column names.
#'
#' @param data_list A list of data frames or vectors to be combined into a single data frame.
#' @param col_names A character vector of column names to assign to the resulting data frame.
#' @param round_digits Numeric. The number of decimal places to round numeric values in the data to.
#'
#' @return A data frame with the combined data and rounded numeric values.
#'
#'
#' @export



create_dyn_df <- function(data_list, col_names, round_digits) {
  rounded_data <- lapply(data_list, function(x)
    if (is.numeric(x))
      round(x, round_digits)
    else
      x)
  df <- do.call(cbind, rounded_data)
  colnames(df) <- col_names
  return(df)
}
