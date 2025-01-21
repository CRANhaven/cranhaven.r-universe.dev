#' @title check_format()
#'
#' @description Verify if the database is correctly formatted
#'
#' @param forest_df Dataset to be validated
#' @param verbose Logical. If \code{TRUE}, messages about errors and warnings will be printed to the console.
#'
#' @return A list containing:
#' \item{status}{Logical, \code{TRUE} if the format is correct, \code{FALSE} if not.}
#' \item{message}{A message providing details about any format issues.}
#'
#'
#' @export
#'

check_format <- function(forest_df, verbose = TRUE) {
  result <- list(status = TRUE, message = NULL)

  tryCatch({
    if (!is.data.frame(forest_df))
      stop("Input is not a dataframe.")
    if (!"plot" %in% names(forest_df))
      stop("Dataframe must have a column named 'plot'.")
    if (!"spp" %in% names(forest_df))
      stop("Dataframe must have a column named 'spp'.")
    if (!"DBH_1" %in% names(forest_df))
      stop("Dataframe must have a column named 'DBH_1'.")
    if (!"DBH_2" %in% names(forest_df))
      stop("Dataframe must have a column named 'DBH_2'.")
    if (!is.numeric(forest_df$DBH_1) == TRUE)
      stop("Column: 'DBH_1' must be numeric.")
    if (!is.numeric(forest_df$DBH_2) == TRUE)
      stop("Column: 'DBH_2' must be numeric.")

    return(result)

  }, error = function(e) {
    result$status <- FALSE
    result$message <- e$message
    if (verbose)
      message("An error occurred: ", e$message)
    return(result)

  }, warning = function(w) {
    result$status <- NA
    result$message <- w$message
    if (verbose)
      message("A warning occurred: ", w$message)
    return(result)
  })
}
