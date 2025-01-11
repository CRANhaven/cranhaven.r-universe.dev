#' calc_b1.R
#'
#' Calculate lower bound or upper bound on power when considering only the largest
#' test statistic in magnitude, i.e. only |Z|_(J) and not |Z|_(J-1).
#'
#' @param lower Boolean, whether to calculate lower bound.
#' @param upper Boolean, whether to calculate upper bound.
#' @param muVec Mean vector of test statistics under the alternative (assuming it's MVN).
#' @param sigMat Covariance matrix of test statistics under the alternative (assuming it's MVN).
#' @param bounds A J*1 vector of bounds on the magnitudes of the test statistics, where
#' the first element is the bound for |Z|_(1) and the last element is the bound for |Z|_(J).
#'
#' @return A list with the elements:
#' \item{allProbsLower}{J*1 vector of all components summed to calculate lower bound.}
#' \item{lowerProb}{Lower bound.}
#' \item{allProbsUpper}{J*1 vector of all components summed to calculate upper bound.}
#' \item{upperProb}{Upper bound.}
#'
#' @export
#' @examples
#' myCov <- matrix(data=0.3, nrow=5, ncol=5)
#' diag(myCov) <- 1
#' myBounds <- set_GBJ_bounds(alpha = 0.01, J=5, sig_vec = myCov[lower.tri(myCov)])
#' calcb1(muVec = c(1, 0, 0, 0, 0), sigMat = myCov, bounds=myBounds)
#'
calcb1 <- function(lower = TRUE, upper = FALSE, muVec, sigMat, bounds) {

  # size of set
  J <- length(muVec)

  # lower and upper bounds on integration. See Sun, Shi, & Lin for expressions used.
  lowerBounds1 <- rep(0, 2*J - 1)
  upperBounds1 <- c(bounds[J], rep(Inf, 2*J - 2))
  lowerBounds2 <- c(-bounds[J], rep(-Inf, 2*J - 2))
  upperBounds2 <- rep(0, 2*J - 1)

  # if calculating lower bound
  if (lower) {
    # calculate the probability/integral for each partition of the subspace we care about
    allProbsLower <- sapply(X = 1:J, FUN = performIntegralLower1, muVec = muVec, sigMat = sigMat,
                       lBounds1 = lowerBounds1, uBounds1 = upperBounds1, lBounds2 = lowerBounds2,
                       uBounds2 = upperBounds2)
    # only take the positive probabilities
    lowerProb <- 1 - sum(allProbsLower[which(allProbsLower > 0)])
  } else {
    allProbsLower <- NA
    lowerProb <- NA
  }

  # if calculating upper bound
  if (upper) {
    # add to the bounds the -b1 \leq x \leq b1 part
    lowerExt <- rep(-bounds[1], J - 1)
    upperExt <- rep(bounds[1], J - 1)
    # calculate the probability/integral for each partition of the subspace we care about
    allProbsUpper <- sapply(X = 1:J, FUN = performIntegralUpper1, muVec = muVec, sigMat = sigMat,
                            lBounds1 = c(lowerBounds1, lowerExt), uBounds1 = c(upperBounds1, upperExt),
                            lBounds2 = c(lowerBounds2, lowerExt), uBounds2 = c(upperBounds2, upperExt))
    # only take the positive probabilities
    upperProb <- 1 - sum(allProbsUpper[which(allProbsUpper > 0)])
  } else {
    allProbsUpper <- NA
    upperProb <- NA
  }

  # return
  return(list(allProbsLower = allProbsLower, lowerProb = lowerProb,
              allProbsUpper = allProbsUpper, upperProb = upperProb))
}


#' Create the matrix that linearly transforms the vector of test statistics
#' into a quantity amenable for pmvnorm.
#'
#' @param j The element of the vector that is the largest.
#' @param size The length of the set.
#'
#' @return The transformation matrix of dimension (2J-1)*(2J-1)
#'
#' @export
#' @examples
#' createMj(j=3, size=5)
createMj <- function(j, size) {
  # the Zj - Zk part (referred to as Zm - Zj in paper)
  topHalf <- diag(rep(-1, size))[-j, ]
  topHalf[, j] <- 1
  # the Zj + Zk part (referred to as Zm + Zj in paper)
  bottomHalf <- abs(topHalf)

  # put it together
  Mj <- rbind(0, topHalf, bottomHalf)
  # for bound on Zm
  Mj[1, j] <- 1
  return(Mj)
}


#' Apply this function over 1:J to calculate each portion of the integral
#' we need for the lower bound.
#'
#' @param j Apply over this integer, the element that will be the largest in magnitude.
#' @param muVec Mean vector of test statistics under the alternative (assuming it's MVN).
#' @param sigMat Covariance matrix of test statistics under the alternative (assuming it's MVN).
#' @param lBounds1 A 2J-1 vector of lower bounds for the first integral (see paper).
#' @param uBounds1 A 2J-1 vector of upper bounds for the second integral (see paper).
#' @param lBounds2 A 2J-1 vector of lower bounds for the first integral (see paper).
#' @param uBounds2 A 2J-1 vector of upper bounds for the second integral (see paper).
#'
#' @return The value of the integration.
#'
#' @export
performIntegralLower1 <- function(j, muVec, sigMat, lBounds1, uBounds1, lBounds2, uBounds2) {
  # transform the mean and variance using the transformMat created above
  transformMat <- createMj(j = j, size = length(muVec))
  newMu <- as.numeric(transformMat %*% muVec)
  newSig <- transformMat %*% sigMat %*% t(transformMat)
  # calculate integral
  intOut1 <- mvtnorm::pmvnorm(lower = lBounds1, upper = uBounds1, mean = newMu, sigma = newSig)
  intOut2 <- mvtnorm::pmvnorm(lower = lBounds2, upper = uBounds2, mean = newMu, sigma = newSig)
  return(intOut1[1] + intOut2[1])
}



#' Apply this function over 1:J to calculate each portion of the integral
#' we need for the upper bound.
#'
#' @param j Apply over this integer, the element that will be the largest in magnitude.
#' @param muVec Mean vector of test statistics under the alternative (assuming it's MVN).
#' @param sigMat Covariance matrix of test statistics under the alternative (assuming it's MVN).
#' @param lBounds1 A 3J-2 vector of lower bounds for the first integral (see paper), bounds will be longer than for performIntegralLower1.
#' @param uBounds1 A 3J-2 vector of upper bounds for the second integral (see paper).
#' @param lBounds2 A 3J-2 vector of lower bounds for the first integral (see paper).
#' @param uBounds2 A 3J-2 vector of upper bounds for the second integral (see paper).
#'
#' @return The value of the integration.
#'
#' @export
performIntegralUpper1 <- function(j, muVec, sigMat, lBounds1, uBounds1, lBounds2, uBounds2) {
  # transform the mean and variance using the transformMat created above
  transformMatTop <- createMj(j = j, size = length(muVec))
  addBottom <- diag(rep(1, length(muVec)))[-j, ]
  # for the upper bound, we need to add J-1 of the -b1 \leq Zj \leq b1 parts
  transformMat <- rbind(transformMatTop, addBottom)

  newMu <- as.numeric(transformMat %*% muVec)
  newSig <- transformMat %*% sigMat  %*% t(transformMat)

  # bounds will be larger than for performIntegralLower1
  intOut1 <- mvtnorm::pmvnorm(lower = lBounds1, upper = uBounds1, mean = newMu, sigma = newSig)
  intOut2 <- mvtnorm::pmvnorm(lower = lBounds2, upper = uBounds2, mean = newMu, sigma = newSig)
  return(intOut1[1] + intOut2[1])
}
