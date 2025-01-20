#' Plot variable importance measures for rfcca objects
#'
#' Plots variable importance measures (VIMP) for subject-related z-variables for
#'   training data.
#'
#' @param x An object of class (rfcca,grow) or (rfcca,predict).
#' @param sort Should the z-variables be sorted according to their variable
#'   importance measures in the plot? The default is \code{TRUE}.
#' @param ndisp Number of z-variables to display in the plot. If \code{sort}=
#'   \code{TRUE}, the most important \code{ndisp} z-variables will be plotted.
#'   Otherwise, the first \code{ndisp} z-variables in the original call will be
#'   plotted. The default value is \code{NULL} which will plot all of the
#'   z-variables.
#' @param ...  Optional arguments to be passed to other methods.
#'
#' @return Invisibly, the variable importance measures that were plotted.
#'
#' @export
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
#' ## plot vimp
#' plot.vimp(rfcca.obj)
#' }
#' @method plot.vimp rfcca
#' @aliases plot.vimp.rfcca plot.vimp
#'
#' @seealso
#'   \code{\link{vimp.rfcca}}

plot.vimp.rfcca <- function(x,
                            sort = TRUE,
                            ndisp = NULL,
                            ...)
{
  object <- x
  ## object cannot be missing
  if (missing(object)) {stop("object is missing!")}
  ## incoming object must be a grow forest object
  if (sum(inherits(object, c("rfcca", "grow"), TRUE) == c(1, 2)) != 2 &&
      sum(inherits(object, c("rfcca", "predict"), TRUE) == c(1, 2)) != 2)
    stop("this function only works for objects of class '(rfcca, grow)' or
         '(rfcca, predict)'")
    if (is.null(object$importance))
      stop("Variable importance information is missing. Re-run rfcca with
           importance=TRUE or call vimp() for the rfcca grow object.")
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
          main = "Variable importance measures: RFCCA",
          xlab = "vimp",
          col = "lightskyblue3",
          las = 1,
          font.lab = 1,
          cex.main = 1.1,
          xlim=range(pretty(c(0, vimp.out))))

  ## Return the plot.variable object for reuse
  invisible(vimp.out)
}
plot.vimp <- plot.vimp.rfcca
