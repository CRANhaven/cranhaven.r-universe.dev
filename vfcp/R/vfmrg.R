#' @export vfmrg
#' @importFrom extraDistr qbetapr
#' @importFrom stats qbeta qweibull qgamma qlnorm qnorm
#'
vfmrg <- function(rdj, i, cosi, yo, cdf)
{
	if (!cdf) posi = 1 - cosi else posi = cosi
	if (rdj[i] == "weibull"){
		ha = qweibull(posi, scale = yo[2*i - 1], shape = yo[2*i])
	} else {
		if (rdj[i] == "gamma"){
			ha = qgamma(posi, scale = yo[2*i - 1], shape = yo[2*i])
		} else {
			if (rdj[i] == "lnorm"){
				ha = qlnorm(posi, meanlog = yo[2*i - 1], sdlog = yo[2*i])
			} else {
				if (rdj[i] == "norm"){
					ha = qnorm(posi, mean = yo[2*i - 1], sd = yo[2*i])
				} else {
					if (rdj[i] == "betapr"){
						ha = qbetapr(posi, shape1 = yo[2*i - 1], shape2 = yo[2*i])
					} else {
						ha = qbeta(posi, shape1 = yo[2*i - 1], shape2 = yo[2*i])
					}
				}
			}
		}
	}
	return(ha)
}