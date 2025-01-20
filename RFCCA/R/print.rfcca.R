#' Print summary output of a RFCCA analysis
#'
#' Print summary output of a RFCCA analysis. This is the default print method
#'   for the package.
#'
#' @param x An object of class \code{(rfcca,grow)}, \code{(rfcca,predict)} or
#'   \code{(rfcca,globalsignificance)}.
#' @param ... Optional arguments to be passed to other methods.
#'
#' @return No return value, called for side effects.
#'
#' @examples
#' \donttest{
#' ## load generated example data
#' data(data, package = "RFCCA")
#' set.seed(2345)
#'
#' ## train rfcca
#' rfcca.obj <- rfcca(X = data$X, Y = data$Y, Z = data$Z, ntree = 100,
#'   importance = TRUE)
#'
#' ## print the grow object
#' print(rfcca.obj)
#' }
print.rfcca <- function(x, ...) {
  ## default printing
  if (sum(inherits(x, c("rfcca", "forest"), TRUE) == c(1, 2)) == 2) {
    print.default(x)
    return()
  }
  ## check that the object is interpretable
  if (sum(inherits(x, c("rfcca", "grow"), TRUE) == c(1, 2)) != 2 &
      sum(inherits(x, c("rfcca", "predict"), TRUE) == c(1, 2)) != 2 &
      sum(inherits(x, c("rfcca", "globalsignificance"), TRUE) == c(1, 2)) != 2) {
    stop("This function only works for objects of class `(rfcca, grow)' or '(rfcca, predict)' or '(rfcca, globalsignificance)'.")
  }
  ## which mode are we in?
  grow.mode <- FALSE
  predict.mode <- FALSE
  significance.mode <- FALSE
  if (sum(inherits(x, c("rfcca", "grow"), TRUE) == c(1, 2)) == 2) {
    grow.mode <- TRUE
  } else if (sum(inherits(x, c("rfcca", "predict"), TRUE) == c(1, 2)) == 2) {
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
    cat("                         Sample size: ", x$n,                    "\n", sep="")
    cat("                     Number of trees: ", x$ntree,                "\n", sep="")
    cat("           Forest terminal node size: ", x$nodesize,             "\n", sep="")
    cat("         Final CCA estimation method: ", x$finalcca,             "\n", sep="")
    cat("       Average no. of terminal nodes: ", mean(x$leaf.count),     "\n", sep="")
    cat("No. of variables tried at each split: ", x$mtry,                 "\n", sep="")
    cat("            Total no. of X variables: ", length(x$xvar.names),   "\n", sep="")
    cat("            Total no. of Y variables: ", length(x$yvar.names),   "\n", sep="")
    cat("            Total no. of Z variables: ", length(x$zvar.names),   "\n", sep="")
  }
  #################################################################################
  ##
  ## predict mode
  ##
  #################################################################################
  else if (predict.mode) {
    cat("            Sample size of test data: ", x$n,                  "\n", sep="")
    cat("                     Number of trees: ", x$ntree,              "\n", sep="")
    cat("         Final CCA estimation method: ", x$finalcca,             "\n", sep="")
    cat("            Total no. of Z variables: ", length(x$zvar.names), "\n", sep="")
  }
  #################################################################################
  ##
  ## significance mode
  ##
  #################################################################################
  else if (significance.mode) {
    cat("                             p-value: ", x$pvalue,               "\n", sep="")
    cat("                         Sample size: ", x$n,                    "\n", sep="")
    cat("                     Number of trees: ", x$ntree,                "\n", sep="")
    cat("           Forest terminal node size: ", x$nodesize,             "\n", sep="")
    cat("No. of variables tried at each split: ", x$mtry,                 "\n", sep="")
    cat("            Total no. of X variables: ", length(x$xvar.names),   "\n", sep="")
    cat("            Total no. of Y variables: ", length(x$yvar.names),   "\n", sep="")
    cat("            Total no. of Z variables: ", length(x$zvar.names),   "\n", sep="")

  }
}
