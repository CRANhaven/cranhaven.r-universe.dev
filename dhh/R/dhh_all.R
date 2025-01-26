dhh = function (x, a=0, b=1, alpha=0.1)
{
  if (a >= b) stop("Error: a should be less than b.")
  if (alpha <= 0) stop("Error: alpha should be larger than 0.")
  
  
  f=ifelse(x <= a | x >=b, 0, alpha*(b-a)^(-alpha)*(x-a)^(alpha-1))
  
  return (f)
}

phh = function (x, a=0, b=1, alpha=0.1){
  if (a >= b) stop("Error: a should be less than b.")
  if (alpha <= 0) stop("Error: alpha should be larger than 0.")
  
  f = rep(NA, length(x))
  
  f = ifelse (x <= a, 0, f)
  f = ifelse (x >= b, 1, f)
  f = ifelse (x > a & x < b, ((x-a)/(b-a))^alpha, f)
  
  return (f)
}

qhh = function (p, a=0, b=1, alpha=0.1) {
  if (a >= b) stop("Error: a should be less than b.")
  if (alpha <= 0) stop("Error: alpha should be larger than 0.")
  
  if (min(p)<0) stop("Error: p should not be negative.")
  if (max(p)<0) stop("Error: p should not be greater than 1.")
  
  f = rep(NA, length(p))
  
  f = ifelse (p==0, a, f)
  f = ifelse (p==1, b, f)
  f = ifelse (p>0 | p<1, a + (b-a)*p^(1/alpha))
  
  return (f)
}

rhh = function(n, a=0, b=1, alpha=0.1){
  if (a >= b) stop("Error: a should be less than b.")
  if (alpha <= 0) stop("Error: alpha should be larger than 0.")
  
  u = runif(n)
  
  f = rep(NA, n)
  
  f = ifelse (u==0, a, f)
  f = ifelse (u==1, b, f)
  f = ifelse (u>0 | u<1, a + (b-a)*u^(1/alpha))
  
  return(f)
}