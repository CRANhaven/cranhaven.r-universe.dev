#' Variable importance for covregrf objects
#'
#' Calculates variable importance measures (VIMP) for covariates for training
#'   data.
#'
#' @param object An object of class (covregrf, grow).
#' @param ... Optional arguments to be passed to other methods.
#'
#' @return An object of class \code{(covregrf, vimp)} which is a list with the
#'   following component:
#'
#'   \item{importance}{Variable importance measures (VIMP) for covariates.}
#'
#' @examples
#' options(rf.cores=2, mc.cores=2)
#'
#' ## load generated example data
#' data(data, package = "CovRegRF")
#' xvar.names <- colnames(data$X)
#' yvar.names <- colnames(data$Y)
#' data1 <- data.frame(data$X, data$Y)
#'
#' ## define train/test split
#' set.seed(2345)
#' smp <- sample(1:nrow(data1), size = round(nrow(data1)*0.6), replace = FALSE)
#' traindata <- data1[smp,,drop=FALSE]
#' testdata <- data1[-smp, xvar.names, drop=FALSE]
#'
#' ## formula object
#' formula <- as.formula(paste(paste(yvar.names, collapse="+"), ".", sep=" ~ "))
#'
#' ## train covregrf
#' covregrf.obj <- covregrf(formula, traindata, params.rfsrc = list(ntree = 50),
#'   importance = TRUE)
#'
#' ## get the variable importance measures
#' vimp <- covregrf.obj$importance
#' vimp2 <- vimp(covregrf.obj)$importance
#'
#'
#' @method vimp covregrf
#' @aliases vimp.covregrf vimp
#'
#' @seealso
#'   \code{\link{plot.vimp.covregrf}}

vimp.covregrf <- function(object,
                        ...)
{
  ## get any hidden options
  user.option <- list(...)

  ## object cannot be missing
  if (missing(object)) {stop("object is missing!")}

  ## incoming object must be a grow forest object
  if (sum(inherits(object, c("covregrf", "grow"), TRUE) == c(1, 2)) != 2)
    stop("this function only works for objects of class `(covregrf, grow)'")

  ## pull the xvar and yvar from the grow object
  xvar <- object$xvar
  xvar.names <- object$xvar.names
  yvar.names <- object$yvar.names
  py <- length(yvar.names)

  ## form multivariate response data with vectorizing covariance matrix elements
  covmat.names <- matrix(NA, py, py)
  for (j in 1:py) {
    for (k in j:py) {
      if (j==k) {
        covmat.names[j,k] <- yvar.names[j]
      } else {
        covmat.names[j,k] <- paste(yvar.names[j], yvar.names[k], sep = "_")
      }
    }
  }
  covmat.names <- covmat.names[upper.tri(covmat.names, diag=TRUE)]
  vimpdata <- t(sapply(object$predicted.oob, function(x) x[upper.tri(x, diag=TRUE)]))
  colnames(vimpdata) <- covmat.names

  params.rfsrc.vimp <- object$params.rfsrc
  params.rfsrc.vimp[["membership"]] <- FALSE
  params.rfsrc.vimp[["forest"]] <- FALSE
  params.rfsrc.vimp[["importance"]] <- TRUE
  params.rfsrc.vimp[["formula"]] <- get.mv.formula(colnames(vimpdata))
  params.rfsrc.vimp[["data"]] <- data.frame(xvar, vimpdata)
  params.rfsrc.vimp[["splitrule"]] <- "mahalanobis"

  ## train multivariate rf with Mahalanobis distance
  vimprf <- do.call(rfsrc, params.rfsrc.vimp)

  ## get vimp output
  vimp.out <- rowMeans(get.mv.vimp(vimprf,  standardize = TRUE))

  ## make the output object
  covregrf.output <- list(
    importance = vimp.out
  )

  class(covregrf.output) <- c("covregrf", "vimp")

  return(covregrf.output)
}
vimp <- vimp.covregrf
