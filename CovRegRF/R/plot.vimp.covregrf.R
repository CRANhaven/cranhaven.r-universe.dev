#' Plot variable importance measures for covregrf objects
#'
#' Plots variable importance measures (VIMP) for covariates for training data.
#'
#' @param x An object of class (covregrf, grow) or (covregrf, vimp).
#' @param sort Should the covariates be sorted according to their variable
#'   importance measures in the plot? The default is \code{TRUE}.
#' @param ndisp Number of covariates to display in the plot. If \code{sort}=
#'   \code{TRUE}, the most important \code{ndisp} covariates will be plotted.
#'   Otherwise, the first \code{ndisp} covariates in the original call will be
#'   plotted. The default value is \code{NULL} which will plot all covariates.
#' @param ...  Optional arguments to be passed to other methods.
#'
#' @return Invisibly, the variable importance measures that were plotted.
#'
#' @export
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
#' ## plot vimp
#' plot.vimp(covregrf.obj)
#'
#'
#' @method plot.vimp covregrf
#' @aliases plot.vimp.covregrf plot.vimp
#'
#' @seealso
#'   \code{\link{vimp.covregrf}}

plot.vimp.covregrf <- function(x,
                             sort = TRUE,
                             ndisp = NULL,
                             ...)
{
  object <- x
  remove(x)
  ## object cannot be missing
  if (missing(object)) {stop("object is missing!")}
  ## incoming object must be a grow forest object
  if (sum(inherits(object, c("covregrf", "grow"), TRUE) == c(1, 2)) != 2 &&
      sum(inherits(object, c("covregrf", "vimp"), TRUE) == c(1, 2)) != 2)
    stop("this function only works for objects of class '(covregrf, grow)' or
         '(covregrf, vimp)'")
  if (is.null(object$importance))
    stop("Variable importance information is missing. Re-run covregrf with
           importance=TRUE or call vimp() for the covregrf grow object.")
  ## verify key options
  sort <- match.arg(as.character(sort), c(TRUE,FALSE))
  ## get the vimp
  vimp.out <- object$importance
  ## coherence checks on option parameters
  if (!is.null(ndisp)) {
    ndisp <- round(ndisp)
  } else{
    ndisp <- length(vimp.out)
  }
  ## sort if sort=TRUE
  if (sort) {
    vimp.out <- rev(sort(vimp.out, decreasing = TRUE)[1:ndisp])
  } else {
    vimp.out <- rev(vimp.out[1:ndisp])
  }
  ## save par settings
  old.par <- par(no.readonly = TRUE)
  on.exit(par(old.par))
  par(mfrow=c(1,1))
  ## draw a horizontal barplot
  barplot(vimp.out,
          horiz = TRUE,
          border = NA,
          main = "Variable importance measures: covregrf",
          xlab = "vimp",
          col = "lightskyblue3",
          las = 1,
          font.lab = 1,
          cex.main = 1.1,
          xlim=range(pretty(c(0, vimp.out))))

  ## Return the plot.variable object for reuse
  invisible(vimp.out)
}
plot.vimp <- plot.vimp.covregrf
