#' @export gentruk
#' @importFrom stringr str_to_lower
#'
gentruk <- function(tht, fm, C, pro){
    ux = vfpripo(C, pro)
    uy = vfex(C, ux, tht, str_to_lower(fm))
    nux = length(ux)
    if (round(uy[1], 7) >= 1) uy[1] = 0.9999999
    if (uy[1] < ux[nux]) uy[1] = ux[nux]
    gt3 = trimeze(ux, uy)
  return(gt3)
}
