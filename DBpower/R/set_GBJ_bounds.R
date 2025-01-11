#' set_GBJ_bounds.R
#'
#' Finds the boundary points of the rejection region for the GBJ statistic.
#'
#' @param alpha Type I error of test.
#' @param J Number of elements in set.
#' @param sig_vec A vector generated from sigma[lower.tri(sigma)] where sigma is the
#' correlation matrix of the test statistics.
#'
#' @return A J*1 vector of bounds on the magnitudes of the test statistics, where
#' the first element is the bound for |Z|_(1) and the last element is the bound for |Z|_(J).
#'
#' @export
#' @examples
#' myCov <- matrix(data=0.3, nrow=5, ncol=5)
#' diag(myCov) <- 1
#' set_GBJ_bounds(alpha = 0.01, J=5, sig_vec = myCov[lower.tri(myCov)])
#'
set_GBJ_bounds <- function(alpha, J, sig_vec) {

  # find the magnitude of the first test statistic that will give p-value of alpha
  firstMag <- stats::uniroot(GBJ_bound1_root, alpha = alpha, d = J, sig_vec = sig_vec, interval=c(0.01, 10))
  # find the observed GBJ value that corresponds to the p-value of alpha.
  gbj <- GBJ::GBJ(test_stats = c(firstMag$root, rep(0, J - 1)), pairwise_cors = sig_vec)$GBJ

  # use uniroot to 'invert' the observed statistic and make the rejection region
  gBJ_z_bounds <- rep(NA, J)
  prev_bound <- 8.2
  # previously this may have been floor, but ceiling is used to conform with GBJ package
  for ( kkk in 1:(ceiling(J/2)) ) {
    temp_gbj <- tryCatch(stats::uniroot(GBJ::GBJ_objective, interval = c(0, prev_bound),
                                 d = J, k_vec = kkk, pairwise_cors = sig_vec,
                                 offset = gbj), error = function(e) e,
                         warning = function(w) w)
    # numerical instability may cause failure
    if (length(class(temp_gbj)) > 1) {
      return(-1)
    }
    else {
      gBJ_z_bounds[kkk] <- temp_gbj$root
    }
    prev_bound <- gBJ_z_bounds[kkk]
  }

  # these bounds are in Z statistics scale, make sure to sort in increasing order for crossprob_cor
  gBJ_z_bounds[(ceiling(J/2)+1):J] <- gBJ_z_bounds[ceiling(J/2)]
  gBJ_z_bounds <- sort(gBJ_z_bounds, decreasing=FALSE)

  # qnorm can't handle more precision than ~1*10^-16
  # Also crossprob_cor can only handle Z up to 8.2
  gBJ_z_bounds[which(gBJ_z_bounds > 8.2)]= 8.2

  return(gBJ_z_bounds)
}

#' Internal function - put this function into uniroot to find the magnitude of the largest test statistic that will
#' give a p-value of alpha.
#'
#' @keywords internal
GBJ_bound1_root <- function(x, alpha, d, sig_vec) {
  tempStats <- c(x, rep(0, d-1))
  GBJ::GBJ(tempStats, pairwise_cors = sig_vec)$GBJ_pvalue - alpha
}
