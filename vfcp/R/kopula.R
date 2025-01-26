#' @export kopula
#' @importFrom copula archmCopula fgmCopula
#'
kopula <- function(fam, tht, dm){
	# print(paste("fam =", fam))
	if (fam == "amh"){
		if (dm == 2){
			kop3 = archmCopula(family = fam, param = tht, dim = dm)
		} else {
			stop("'dm' must be 2 for 'amh'")
		}
  } else {
  	if (fam == "fgm"){
  	if (dm == 2){
  		kop3 = fgmCopula(tht)
  	} else {
  		stop("bad 'dm'")
  	}
  } else {
		kop3 = archmCopula(family = fam, param = tht, dim = dm)
  }}
  return(kop3)
}