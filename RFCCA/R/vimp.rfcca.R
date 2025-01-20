#' Variable importance for rfcca objects
#'
#' Calculates variable importance measures (VIMP) for subject-related
#'   z-variables for training data.
#'
#' @param object An object of class (rfcca,grow).
#' @param ... Optional arguments to be passed to other methods.
#'
#' @return An object of class \code{(rfcca,predict)} which is a list with the
#'   following components:
#'
#'   \item{call}{The original grow call to \code{rfcca}.}
#'   \item{n}{Sample size of the data (\code{NA}'s are omitted).}
#'   \item{ntree}{Number of trees grown.}
#'   \item{zvar}{Data frame of z-variables.}
#'   \item{zvar.names}{A character vector of the z-variable names.}
#'   \item{predicted.oob}{OOB predicted canonical correlations for training
#'     observations based on the selected final canonical correlation estimation
#'     method.}
#'   \item{finalcca}{The selected CCA used for final canonical correlation
#'     estimations.}
#'   \item{importance}{Variable importance measures (VIMP) for each z-variable.}
#'
#' @examples
#' \donttest{
#' ## load generated example data
#' data(data, package = "RFCCA")
#' set.seed(2345)
#'
#' ## train rfcca
#' rfcca.obj <- rfcca(X = data$X, Y = data$Y, Z = data$Z, ntree = 100)
#'
#' ## get variable importance measures
#' vimp.obj <- vimp(rfcca.obj)
#' vimp.z <- vimp.obj$importance
#' }
#' @method vimp rfcca
#' @aliases vimp.rfcca vimp
#'
#' @seealso
#'   \code{\link{plot.vimp.rfcca}}

vimp.rfcca <- function(object,
                       ...)
{
  result.vimp <- generic.vimp.rfcca (object,
                                     ...)

  return(result.vimp)
}
vimp <- vimp.rfcca
