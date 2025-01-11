#' sim_R1.R
#'
#' Simulate the probability of falling in the region used for the b1 lower
#' bound or the b1 upper bound.
#'
#' @param lower Boolean, if true sim lower bound.
#' @param upper Boolean, if true sim upper bound.
#' @param n Number of simulations.
#' @param muVec Mean vector of test statistics under the alternative (assuming it's MVN).
#' @param sigMat Covariance matrix of test statistics under the alternative (assuming it's MVN).
#' @param bounds A J*1 vector of bounds on the magnitudes of the test statistics, where
#' the first element is the bound for |Z|_(1) and the last element is the bound for |Z|_(J).
#'
#' @return A list with the elements:
#' \item{lowerBound}{Lower bound on power.}
#' \item{upperBound}{Upper bound on power.}
#'
#' @export
#' @examples
#' myCov <- matrix(data=0.3, nrow=5, ncol=5)
#' diag(myCov) <- 1
#' myBounds <- set_GBJ_bounds(alpha = 0.01, J=5, sig_vec = myCov[lower.tri(myCov)])
#' sim_b1(n=5000, muVec = c(1, 0, 0, 0, 0), sigMat = myCov, bounds=myBounds)
#'
sim_b1<- function(lower=TRUE, upper=TRUE, n, muVec, sigMat, bounds) {

  # simulate MVN
  zSample <- mvtnorm::rmvnorm(n=n, mean=muVec, sigma=sigMat)

  # upper or lower
  if (lower) {
    lowerNonCross <- apply(zSample, 1, checkBoundsLower1, bounds=bounds)
    lowerBound <- 1 - mean(lowerNonCross)
  } else {
    lowerBound <- NA
  }
  if (upper) {
    upperNonCross <- apply(zSample, 1, checkBoundsUpper1, J=length(bounds), bounds=bounds)
    upperBound <- 1 - mean(upperNonCross)
  } else {
    upperBound <- NA
  }

  # return
  return( list(lowerBound = lowerBound, upperBound = upperBound) )
}


#' Internal function to check if test statistics fall within the region
#' used for b1 lower bound, 1 minus the result of this is the lower bound on the power..
#'
#' @keywords internal
checkBoundsLower1 <- function(x, bounds) {
  # this is calculating the same region as in the calc_b1() function for lower bound,
  # does |Z|_(M) fall under b_M.
  maxX <- max(abs(x))
  maxBound <- max(bounds)
  return(as.numeric(maxX < maxBound))
}

#' Internal function to check if test statistics fall within the region
#' used for b1 uupper bound, 1 minus the result of this is the upper bound on the power.
#'
#' @keywords internal
checkBoundsUpper1 <- function(x, J, bounds) {
  # this is calculating the same region as in the calc_b1() function for lower bound,
  # does |Z|_(M) fall under b_M and the rest of the magnitudes fall under b_1.
  newBounds <- bounds
  newBounds[1:(J-1)] <- bounds[1]
  sortedX <- sort(abs(x), decreasing = FALSE)
  if (sum(as.numeric(sortedX > newBounds)) == 0) {
    return(1)
  } else {
    return(0)
  }
}
