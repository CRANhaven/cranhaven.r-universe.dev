#' Compute Gauss-Hermite quadrature rule
#'
#' @import fastGHQuad
#' @param q Order of the Gauss-Hermite quadrature rule to compute
#' @param scale_abscissa Fixed number
#' @param scale_weight Fixed number
#' @keywords internal
#' @return A list with the following components:
#' \describe{
#' \item{z}{Nodes}
#' \item{w}{Quadrature Weights}
#' }
#'
#' @export
#'
get.GH <- function(q, scale_abscissa = sqrt(2), scale_weight=1/sqrt(pi)) {
  rule = gaussHermiteData(q)
  if(scale_abscissa!=1) rule$x = rule$x*scale_abscissa
  if(scale_weight!=1)   rule$w = rule$w*scale_weight
  list(z=rule$x,w=rule$w)
}
