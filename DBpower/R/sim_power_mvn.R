#' sim_power_mvn.R
#'
#' Simulate power of detection boundary tests starting from multivariate normal test statistics.
#'
#' @param n Number of simulations.
#' @param muVec Mean vector of test statistics under the alternative (assuming it's MVN).
#' @param sigMat Covariance matrix of test statistics under the alternative (assuming it's MVN).
#' @param bounds A J*1 vector of bounds on the magnitudes of the test statistics, where
#' the first element is the bound for |Z|_(1) and the last element is the bound for |Z|_(J).
#' @param nullSigMat Assumed correlation matrix of MVN under the null. Only need to specify if specifying test.
#' @param test Either "GHC", "HC", "GBJ", or "BJ" or NULL. If provided, will calculate
#' the p-value using the specified test and calculate power this way.
#' @param alpha Level of the test.
#'
#' @return A list with the elements:
#' \item{boundsPower}{Power from using bounds approach.}
#' \item{testPower}{Power from using specific test p-value approach.}
#'
#' @export
#' @examples
#' myCov <- matrix(data=0.3, nrow=5, ncol=5)
#' diag(myCov) <- 1
#' myBounds <- set_GBJ_bounds(alpha = 0.01, J=5, sig_vec = myCov[lower.tri(myCov)])
#' sim_power_mvn(n=1000, muVec = c(1, 0, 0, 0, 0), sigMat = myCov, alpha=0.01)
#'
sim_power_mvn <- function(n, muVec, sigMat, nullSigMat=NULL, bounds=NULL, test=NULL, alpha) {

  # simulate MVN
  zSample <- mvtnorm::rmvnorm(n=n, mean=muVec, sigma=sigMat)

  # if doing bounds
  if (!is.null(bounds)) {
    crossVec <- apply(zSample, 1, checkBoundsCross, bounds = bounds)
    boundsPower <- mean(crossVec)
  } else {
    boundsPower <- NA
  }

  # if choosing a test, apply this function over zSample
  applyTest <- function(x, test, nullSigMat) {
    if (test == "GBJ") {
      return(GBJ::GBJ(test_stats = x, cor_mat = nullSigMat, pairwise_cors = NULL)$GBJ_pvalue)
    } else if (test == "BJ") {
      return(GBJ::BJ(test_stats = x, cor_mat = nullSigMat, pairwise_cors = NULL)$BJ_pvalue)
    } else if (test == "HC") {
      return(GBJ::HC(test_stats = x, cor_mat = nullSigMat, pairwise_cors = NULL)$HC_pvalue)
    } else if (test == "GHC") {
      return(GBJ::GHC(test_stats = x, cor_mat = nullSigMat, pairwise_cors = NULL)$GHC_pvalue)
    } else {
      return(NA)
    }
  }

  # power using pvalue
  if (!is.null(test)) {
    pvalueVec <- apply(zSample, 1, applyTest, test = test, nullSigMat = nullSigMat)
    testPower <- length(which(pvalueVec < alpha)) / n
  } else {
    testPower <- NA
  }

  # return
  return(list(testPower = testPower, boundsPower = boundsPower))
}


#' Internal function to check if bounds are violated.
#' Bounds should be smallest to largest.
#'
#' @keywords internal
checkBoundsCross <- function(x, bounds) {
  sortedX <- sort(abs(x))
  numCross <- length(which(sortedX > bounds))
  if (numCross == 0) {
    return(0)
  } else {
    return(1)
  }
}
