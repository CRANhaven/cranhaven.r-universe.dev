#' @export vfalihaq
#'
vfalihaq <- function(C, u, tht){
  # Ali–Mikhail–Haq
	r = (C*(1 - tht*(1 - u))/(u - tht*C*(1 - u)))
	return(ifelse(r > 1, NaN, ifelse(r < 0, NaN, r)))
}

#' @export vfjoe
#'
vfjoe <- function(C, u, tht){
  # tht >= 1
  r = (1 - (((1 - C)^tht - (1 - u)^tht)/(1 - (1 - u)^tht))^(1/tht))
  return(ifelse(r > 1, NaN, ifelse(r < 0, NaN, r)))
}
