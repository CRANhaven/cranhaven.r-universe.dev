#' set_BJ_bounds.R
#'
#' Finds the boundary points of the rejection region for the BJ statistic when
#' all elements in a set are independent.
#'
#' @param alpha Type I error of test.
#' @param J Number of elements in set.
#'
#' @return A J*1 vector of bounds on the magnitudes of the test statistics, where
#' the first element is the bound for |Z|_(1) and the last element is the bound for |Z|_(J).
#'
#' @export
#' @examples
#' set_BJ_bounds(alpha = 0.01, J=5)
#'
set_BJ_bounds <- function(alpha, J) {

  # find the magnitude of the first test statistic that will give p-value of alpha
  firstMag <- stats::uniroot(BJ_bound1_root, alpha = alpha, d = J, interval=c(0.01, 50))
  # find the observed BJ value that corresponds to the p-value of alpha.
  b <- GBJ::BJ(test_stats = c(firstMag$root, rep(0, J - 1)), pairwise_cors = rep(0, J*(J-1)/2))$BJ

  # will return this vector of bounds
  BJ_p_bounds <- rep(NA, J)

  # Then use uniroot to 'invert' the observed test statistic and find the bounds for p-value calculation.
  # Bounds here are in terms of p-values.
  for ( jjj in 1:(ceiling(J/2)) ) {
    BJ_p_bounds[jjj] <- stats::uniroot(BJ_func, k=jjj, d=J, b=b, lower=0, upper=jjj/J, tol=(10^(-12)))$root
  }
  # The last half of the order statistic bounds are the same
  BJ_p_bounds[(ceiling(J/2)+1):J] <- BJ_p_bounds[ceiling(J/2)]

  # Now put the bounds in terms of the Z statistics
  BJ_z_bounds <- stats::qnorm(1 - BJ_p_bounds/2)
  BJ_z_bounds <- sort(BJ_z_bounds, decreasing=F)

  # qnorm can't handle more precision than ~1*10^-15
  if(length(which(BJ_z_bounds==Inf))>0) {
    BJ_z_bounds[which(BJ_z_bounds==Inf)]= 8.209536
  }

  return(BJ_z_bounds)
}

#' Internal function - the BJ objective function minus the observed value, put it into uniroot to find the
#' test statistic magnitude bound at order statistic k of d that will give the observed BJ value.
#'
#' @keywords internal
BJ_func <- function(x, k, d, b) {
  k*log(k/(d*x)) + (d-k)*log((1-k/d)/(1-x)) - b
}

# put this function into uniroot to find the magnitude of the largest test statistic that will
# give a p-value of alpha.
BJ_bound1_root <- function(x, alpha, d) {
  tempStats <- c(x, rep(0, d-1))
  GBJ::BJ(tempStats, pairwise_cors = rep(0, d*(d-1) / 2))$BJ_pvalue - alpha
}
