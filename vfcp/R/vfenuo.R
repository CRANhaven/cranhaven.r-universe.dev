#' @export vfenuo
#'
vfenuo <- function(marg, xo)
{
  nuo = length(marg)
	k = 0
  e = numeric(nuo)
  for(i in 1:nuo){
    if (marg[i] == "weibull"){
      e[i] = xo[i + k] * gamma(1 + 1/xo[i + k + 1])
    } else {
      if (marg[i] == "gamma"){
        e[i] = xo[i + k] * xo[i + k + 1]
      } else {
        if (marg[i] == "lnorm"){
          e[i] = exp(xo[i + k] + xo[i + k + 1]*xo[i + k + 1]/2)
        } else {
          if (marg[i] == "norm"){
            e[i] = xo[i + k]
          } else {
            if (marg[i] == "betapr"){
              e[i] = xo[i + k]/(xo[i + k + 1] - 1)
            } else {
              if (marg[i] == "beta"){
                e[i] = xo[i + k]/(xo[i + k] + xo[i + k + 1])
              }
            }
          }
        }
      }
    }
    k = k + 1
  }
  return(e)
}