#' Random Multivariate Normal MVN Generator
#'
#' @param n number of observations
#' @param mu d dimensional mean vector
#' @param cov_mat d x d covariance matrix
#'
#' @return Matrix (n x d) of random MVN draws
#'
#' @keywords internal
rmvn <- function(n,mu = rep(0,d),cov_mat) {
  if (n <= 0) stop("n must be 1 or larger")
  S <- chol(cov_mat)
  d <- ncol(S)
  Y <- (matrix(stats::rnorm(n*d),n,d) %*% S) + mu
  return(Y)
}

#' Calibration Random Multivariate Normal
#'
#' @param n number of observations
#' @param d number of dimension
#' @param rho correlation of compound-symmetric covariance
#'
#' @return Matrix (n x d) of random MVN draws
#'
#' @keywords internal
simulate_mvn  <- function(n,d,rho) {
  Sigma       <- matrix(rho,d,d)
  diag(Sigma) <- 1
  return(rmvn(n,mean(0,d),Sigma))
}
