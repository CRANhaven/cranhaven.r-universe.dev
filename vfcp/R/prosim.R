#' @export prosim
#' @importFrom copula rCopula pCopula
#'
prosim <- function(C, fam, tht, dm, no){
  kop3 = kopula(fam, tht, dm)
  u3 = rCopula(no, kop3)
  C3 = pCopula(u3, kop3)
  S3 = pCopula(1 - u3, kop3)
  S = C
  p = numeric(length(C))
  for (i in 1:length(C)){
    m = C3 >= C[i] & S3 >= S[i]
    p[i] = sum(m)/no
  }
  return(p)
}
