#' @export prunikus
#'
prunikus <- function(x, y){
	a1 = x[1]*y[2] - x[2]*y[1]
	a2 = x[3] - x[4]
	a3 = x[1] - x[2]
	a4 = x[3]*y[4] - x[4]*y[3]
	hp = a1*a2 - a3*a4
	a5 = y[3] - y[4]
	a6 = y[1] - y[2]
	dp = a3*a5 - a6*a2
	px = hp/dp
	#=========
	hd = a1*a5 - a6*a4
	dd = a3*a5 - a6*a2
	py = hd/dd
  return(c(px, py))
}