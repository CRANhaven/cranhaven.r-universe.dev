#' mvtnorm::pmvnorm, but returns 0 if any lower boundary is larger than
#' any upper boundary
#'
#' @param upper the vector of upper limits of length n.
#' @param lower the vector of lower limits of length n.
#' @param ... additional parameters passed to \code{\link[mvtnorm]{pmvnorm}}.
#'
#' @return
#' The evaluated distribution function is returned, if \code{keepAttr} is true, with attributes
#' \item{error}{estimated absolute error}
#' \item{msg}{status message(s).}
#' \item{algorithm}{a \code{\link{character}} string with \code{class(algorithm)}.}
#'
#' @seealso \code{\link[mvtnorm]{pmvnorm}}
#'
#' @importFrom mvtnorm pmvnorm
pmvnorm_ <- function(upper, lower, ...) {
  if (any(lower >= upper)) {
    return(0)
  } else {
    pmvnorm(upper = upper, lower = lower, ...)
  }
}

#' mvtnorm::pmvt, but returns 0 if any lower boundary is larger than
#' any upper boundary
#'
#' @param upper the vector of upper limits of length n.
#' @param lower the vector of lower limits of length n.
#' @param ... additional parameters passed to \code{\link[mvtnorm]{pmvt}}.
#'
#' @return
#' The evaluated distribution function is returned, if \code{keepAttr} is true, with attributes
#' \item{error}{estimated absolute error}
#' \item{msg}{status message(s).}
#' \item{algorithm}{a \code{\link{character}} string with \code{class(algorithm)}.}
#'
#' @seealso \code{\link[mvtnorm]{pmvt}}
#'
#' @importFrom mvtnorm pmvt
pmvt_ <- function(upper, lower, ...) {
  if (any(lower >= upper)) {
    return(0)
  } else {
    pmvt(upper = upper, lower = lower, ...)
  }
}
