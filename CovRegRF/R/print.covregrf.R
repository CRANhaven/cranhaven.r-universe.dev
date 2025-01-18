#' Print summary output of a CovRegRF analysis
#'
#' Print summary output of a CovRegRF analysis. This is the default print method
#'   for the package.
#'
#' @param x An object of class \code{(covregrf, grow)}, \code{(covregrf, predict)}
#'   or \code{(covregrf, significancetest)}.
#' @param ... Optional arguments to be passed to other methods.
#'
#' @return Returns a \code{character} string for the summary of CovRegRF
#'   analysis.
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
#' covregrf.obj <- covregrf(formula, traindata, params.rfsrc = list(ntree = 50))
#'
#' ## print the grow object
#' print(covregrf.obj)
#'
#' ## predict with new test data
#' pred.obj <- predict(covregrf.obj, newdata = testdata)
#'
#' ## print the predict object
#' print(pred.obj)
#'
print.covregrf <- function(x, ...) {
  ## check that the object is interpretable
  if (sum(inherits(x, c("covregrf", "grow"), TRUE) == c(1, 2)) != 2 &
      sum(inherits(x, c("covregrf", "predict"), TRUE) == c(1, 2)) != 2 &
      sum(inherits(x, c("covregrf", "significancetest"), TRUE) == c(1, 2)) != 2) {
    stop("This function only works for objects of class `(covregrf, grow)' or '(covregrf, predict)' or '(covregrf, significancetest)'.")
  }
  ## which mode are we in?
  grow.mode <- FALSE
  predict.mode <- FALSE
  significance.mode <- FALSE
  if (sum(inherits(x, c("covregrf", "grow"), TRUE) == c(1, 2)) == 2) {
    grow.mode <- TRUE
  } else if (sum(inherits(x, c("covregrf", "predict"), TRUE) == c(1, 2)) == 2) {
    predict.mode <- TRUE
  } else {
    significance.mode <- TRUE
  }
  #################################################################################
  ##
  ## grow mode
  ##
  #################################################################################
  if (grow.mode) {
    cat("            Sample size: ", x$n,                    "\n", sep="")
    cat("  Number of X variables: ", length(x$xvar.names),   "\n", sep="")
    cat("  Number of Y variables: ", length(x$yvar.names),   "\n", sep="")
    cat("Best terminal node size: ", x$best.nodesize,        "\n", sep="")
  }
  #################################################################################
  ##
  ## predict mode
  ##
  #################################################################################
  else if (predict.mode) {
    cat("Sample size of test data: ", x$n,                  "\n", sep="")
    cat("   Number of X variables: ", length(x$xvar.names), "\n", sep="")
  }
  #################################################################################
  ##
  ## significance mode
  ##
  #################################################################################
  else if (significance.mode) {
    cat("                                                p-value: ", x$pvalue,                     "\n", sep="")
    cat("               Best terminal node size (all covariates): ", x$best.nodesize,              "\n", sep="")
    cat("Best terminal node size (controlling set of covariates): ", x$best.nodesize.control,      "\n", sep="")
    cat("                                 Testing set covariates: ", x$test.vars,                  "\n", sep="")
    cat("                          Controlling set of covariates: ", x$control.vars,               "\n", sep="")
  }
}
