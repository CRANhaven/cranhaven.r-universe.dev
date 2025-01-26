#' @export vfgumbel
#'
vfgumbel <- function(C, u, tht) {
  r = exp(-((-log(C))^tht - (-log(u))^tht)^(1/tht))
  return(ifelse(r > 1, NaN, ifelse(r < 0, NaN, r)))
}

#' @export vfclayton
#'
vfclayton <- function(C, u, tht) {
  r = (C^(-tht) - u^(-tht) + 1)^(-1/tht)
  return(ifelse(r > 1, NaN, ifelse(r < 0, NaN, r)))
}

#' @export vffrank
#'
vffrank <- function(C, u, tht) {
  r = -log(((exp(-C * tht) - 1) * (exp(-tht) - 1))/
  				 	(exp(-u * tht) - 1) + 1)/tht
  return(ifelse(r > 1, NaN, ifelse(r < 0, NaN, r)))
}
