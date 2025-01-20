#' Generated example data
#'
#' A generated data set containing three sets of variables: X, Y, Z. The
#' canonical correlation between X and Y depends on some of the Z variables. The
#' sample size is 300. Z1-Z5 are the important variables for the varying
#' correlation between X and Y. Z6-Z7 are the noise variables.
#'
#' @format A list with three elements namely X, Y, Z. Each element has 300 rows.
#'   X has 2 columns, Y has 2 columns and Z has 7 columns.
#'
#' @examples
#' \donttest{
#' ## load generated example data
#' data(data, package = "RFCCA")
#' }
"data"
