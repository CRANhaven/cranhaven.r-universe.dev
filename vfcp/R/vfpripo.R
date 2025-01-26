#' @export vfpripo
#'
vfpripo <- function(ck, pro){
	if (is.finite(ck) & ck >= 0 & ck <= 1) {
	npro = length(pro)
	k = min(which(pro > 1)) - 1
	# b = numeric(1)
	b = NULL
	b[k] = pro[k] - ck
	for(i in (k + 1):npro)
	{
		b[i] = b[i - 1]/pro[i]
	}
	bb = 0
	a = list()
	for(j in npro:(k+1))
	{
		if (j == npro) a[[j]] = seq(b[j], b[j - 1], b[j]) else {
			a[[j]] = seq(2*b[j], b[j-1], b[j] )
		}
	}
	h = c(1e-14, 1e-09)
	for(i in npro:(k+1))
	{
		h = c(h, as.numeric(a[[i]]))
	}
	return(c(ck + h, pro[(k-1):1]))
	} else {return(NaN)}
}
