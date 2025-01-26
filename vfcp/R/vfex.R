#' @export vfex
#'
vfex <- function(C, u, th, fm)
{
	if (fm == "clayton"){
		v = vfclayton(C, u, th)
	} else {
		if (fm == "frank"){
			v = vffrank(C, u, th)
		} else {
			if (fm == "gumbel"){
				v = vfgumbel(C, u, th)
			} else {
				if (fm == "fgm"){
					v = vffgm(C, u, th)
				} else {
					if (fm == "amh"){
						v = vfalihaq(C, u, th)
					} else {
						if (fm == "joe"){
							v = vfjoe(C, u, th)
						}
					}
				}
			}
		}
	}
	return(v)
}
