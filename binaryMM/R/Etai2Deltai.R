Etai2Deltai <-
function(etai, gamma, sigma, q.points, Z, W){ 
  expit <- function(aa){exp(aa)/(1+exp(aa))}
  n     <- length(etai)
  
  gam   <- gamma
  if (length(gam)==1){ gam<-rep(gamma, n) }
  sig   <- sigma
  if (length(sig)==1){ sig<-rep(sigma, n) }
  
  if (length(sig) != n | length(gam) !=n) { stop("Error in etai.2.deltai") }

  deltai  <- rep(NA, n)
  deltai  <-.Call("DeconvolveGH_CALL", etai, gam, sig, Z, W)
  deltai
}
