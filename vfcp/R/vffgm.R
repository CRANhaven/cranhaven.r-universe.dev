#' @export vffgm
#'
vffgm <- function(C, u, tht){
	a = -(1 - u)*tht
	b = 1 + (1 - u)*tht
	c = -C/u
	r = ((-b + sqrt(b*b - 4*a*c))/(2*a))
	return(ifelse(r > 1, NaN, ifelse(r < 0, NaN, r)))
}
