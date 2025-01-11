#' calc_b2.R
#'
#' Calculate lower bound or upper bound on power when considering only the two largest
#' test statistic in magnitude, i.e. only |Z|_(J) and |Z|_(J-1).
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
#' @importFrom magrittr %>%
#' @export
#' @examples
#' myCov <- matrix(data=0.3, nrow=5, ncol=5)
#' diag(myCov) <- 1
#' myBounds <- set_GBJ_bounds(alpha = 0.01, J=5, sig_vec = myCov[lower.tri(myCov)])
#' calcb2(muVec = c(1, 0, 0, 0, 0), sigMat = myCov, bounds=myBounds)
#'
calcb2 <- function(lower = TRUE, upper = FALSE, muVec, sigMat, bounds) {

  # size of set
  J <- length(muVec)
  muVec <- as.numeric(muVec)

  # lower and upper bounds on integration. See Sun, Shi, & Lin for expressions used.
  lowerBounds1 <- rep(0, 2*J - 1)
  upperBounds1 <- c(bounds[J], bounds[J - 1], rep(Inf, 2*J - 3))
  lowerBounds2 <- c(0, -bounds[J - 1], 0, rep(-Inf, 2*J - 4))
  upperBounds2 <- c(bounds[J], 0, Inf, rep(0, 2*J - 4))
  lowerBounds3 <- c(-bounds[J], 0, -Inf, rep(0, 2*J - 4))
  upperBounds3 <- c(0, bounds[J - 1], 0, rep(Inf, 2*J - 4))
  lowerBounds4 <- c(-bounds[J], -bounds[J - 1], rep(-Inf, 2*J - 3))
  upperBounds4 <- rep(0, 2*J - 1)

  # if you don't have this, R CMD CHECK throws an error
  Var1 <- Var2 <- NULL
  # create the indices for the partitions we care about
  allCombs <- expand.grid(1:J, 1:J) %>%
    as.data.frame() %>%
    dplyr::filter(Var1 != Var2) %>%
    as.matrix()

  # if calculating lower bound
  if (lower) {
    # calculate the probability/integral for each partition of the subspace we care about
    allProbsLower <- apply(allCombs, 1, performIntegralLower2, muVec = muVec, sigMat = sigMat,
                            lBounds1 = lowerBounds1, uBounds1 = upperBounds1, lBounds2 = lowerBounds2,
                            uBounds2 = upperBounds2, lBounds3 = lowerBounds3, uBounds3 = upperBounds3,
                            lBounds4 = lowerBounds4, uBounds4 = upperBounds4)
    # only take the positive probabilities
    lowerProb <- 1 - sum(allProbsLower[which(allProbsLower > 0)])
    lowerDF <- allCombs %>% as.data.frame() %>% dplyr::mutate(Probs = allProbsLower)
  } else {
    lowerProb <- NA
    lowerDF <- NA
  }

  # if calculating upper bound
  if (upper) {
    # add to the bounds the -b1 \leq x \leq b1 part
    lowerExt <- rep(-bounds[1], J - 2)
    upperExt <- rep(bounds[1], J - 2)
    # calculate the probability/integral for each partition of the subspace we care about
    allProbsUpper <- apply(allCombs, 1, FUN = performIntegralUpper2, muVec = muVec, sigMat = sigMat,
                            lBounds1 = c(lowerBounds1, lowerExt), uBounds1 = c(upperBounds1, upperExt),
                            lBounds2 = c(lowerBounds2, lowerExt), uBounds2 = c(upperBounds2, upperExt),
                            lBounds3 = c(lowerBounds3, lowerExt), uBounds3 = c(upperBounds3, upperExt),
                            lBounds4 = c(lowerBounds4, lowerExt), uBounds4 = c(upperBounds4, upperExt))
    # only take the positive probabilities
    upperProb <- 1 - sum(allProbsUpper[which(allProbsUpper > 0)])
    upperDF <- allCombs %>% as.data.frame() %>% dplyr::mutate(Probs = allProbsUpper)
  } else {
    upperProb <- NA
    upperDF <- NA
  }

  # return
  return(list(lowerDF = lowerDF, lowerProb = lowerProb,
              upperDF = upperDF, upperProb = upperProb))
}

#' Create the matrix that linearly transforms the vector of test statistics
#' into a quantity amenable for pmvnorm.
#'
#' @param j The element of the vector that is the largest.
#' @param k The element of the vector that is the second largest.
#' @param size The length of the set.
#'
#' @return The transformation matrix of dimension (2J-1)*(2J-1)
#'
#' @export
#' @examples
#' createMjk(j=3, k=4, size=5)
createMjk <- function(j, k, size) {
  # the Zk - Zl part (referred to as Zj - Zl in paper)
  topHalf <- diag(rep(-1, size))[-c(j, k), ]
  topHalf[, k] <- 1
  # the Zk + Zl part (referred to as Zj - Zl in paper)
  bottomHalf <- abs(topHalf)

  # put it together
  Mjk <- rbind(matrix(data=0, nrow=3, ncol=size), topHalf, bottomHalf)
  # the Zj, Zk, Zj - Zk parts (referred to as Zm, Zj, Zm - Zj in paper)
  Mjk[1, j] <- 1
  Mjk[2, k] <- 1
  Mjk[3, j] <- 1
  Mjk[3, k] <- -1
  return(Mjk)
}


#' Apply this function over all m, j not equal (order matters) to calculate each portion of the integral
#' we need for the lower bound for calc_b2.
#'
#' @param x Apply over this 2*1 vector, the element that will be the largest in magnitude.
#' @param muVec Mean vector of test statistics under the alternative (assuming it's MVN).
#' @param sigMat Covariance matrix of test statistics under the alternative (assuming it's MVN).
#' @param lBounds1 A 2J-1 vector of lower bounds for the first integral (see paper).
#' @param uBounds1 A 2J-1 vector of upper bounds for the second integral (see paper).
#' @param lBounds2 A 2J-1 vector of lower bounds for the first integral (see paper).
#' @param uBounds2 A 2J-1 vector of upper bounds for the second integral (see paper).
#' @param lBounds3 A 2J-1 vector of lower bounds for the third integral (see paper).
#' @param uBounds3 A 2J-1 vector of upper bounds for the third integral (see paper).
#' @param lBounds4 A 2J-1 vector of lower bounds for the fourth integral (see paper).
#' @param uBounds4 A 2J-1 vector of upper bounds for the fourth integral (see paper).
#'
#' @return The value of the integration.
#'
#' @export
performIntegralLower2 <- function(x, muVec, sigMat, lBounds1, uBounds1, lBounds2, uBounds2,
                                  lBounds3, uBounds3, lBounds4, uBounds4) {
  j <- x[1]
  k <- x[2]
  # two transform matrices, use the Opp one when Zj and Zk have different signs
  transformMat <- createMjk(j = j, k = k, size = length(muVec))
  transformMatOpp <- transformMat
  # the opp substitutes Zm - Zj for Zm + Zj when they are assumed to have opposite signs
  transformMatOpp[3, k] <- 1
  newMu <- as.numeric(transformMat %*% muVec)
  newSig <- transformMat %*% sigMat %*% t(transformMat)
  newMuOpp <- as.numeric(transformMatOpp %*% muVec)
  newSigOpp <- transformMatOpp %*% sigMat %*% t(transformMatOpp)
  # do the integrals
  intOut1 <- mvtnorm::pmvnorm(lower = lBounds1, upper = uBounds1, mean = newMu, sigma = newSig)
  intOut2 <- mvtnorm::pmvnorm(lower = lBounds2, upper = uBounds2, mean = newMuOpp, sigma = newSigOpp)
  intOut3 <- mvtnorm::pmvnorm(lower = lBounds3, upper = uBounds3, mean = newMuOpp, sigma = newSigOpp)
  intOut4 <- mvtnorm::pmvnorm(lower = lBounds4, upper = uBounds4, mean = newMu, sigma = newSig)

  # return
  return(intOut1[1] + intOut2[1] + intOut3[1] + intOut4[1])
}


#' Apply this function over all m, j not equal (order matters) to calculate each portion of the integral
#' we need for the lower bound for calc_b2.
#'
#' @param x Apply over this 2*1 vector, the elements that will be the largest and second largest in magnitude.
#' @param muVec Mean vector of test statistics under the alternative (assuming it's MVN).
#' @param sigMat Covariance matrix of test statistics under the alternative (assuming it's MVN).
#' @param lBounds1 A 3J-2 vector of lower bounds for the first integral (see paper).
#' @param uBounds1 A 3J-2 vector of upper bounds for the second integral (see paper).
#' @param lBounds2 A 3J-2 vector of lower bounds for the first integral (see paper).
#' @param uBounds2 A J3J-2 vector of upper bounds for the second integral (see paper).
#' @param lBounds3 A 3J-2 vector of lower bounds for the third integral (see paper).
#' @param uBounds3 A 3J-2 vector of upper bounds for the third integral (see paper).
#' @param lBounds4 A 3J-2 vector of lower bounds for the fourth integral (see paper).
#' @param uBounds4 A 3J-2 vector of upper bounds for the fourth integral (see paper).
#'
#' @return The value of the integration.
#'
#' @export
performIntegralUpper2 <- function(x, muVec, sigMat, lBounds1, uBounds1, lBounds2, uBounds2,
                                  lBounds3, uBounds3, lBounds4, uBounds4) {
  j <- x[1]
  k <- x[2]
  # need to add to the transform mat
  transformMatTop <- createMjk(j = j, k = k, size = length(muVec))
  transformMatOppTop <- transformMatTop
  transformMatOppTop[3, k] <- 1
  # botom part is for -b1 \leq Zl \leq b1
  bottomPart <- diag(rep(1, length(muVec)))[-c(j, k), ]
  transformMat <- rbind(transformMatTop, bottomPart)
  transformMatOpp <- rbind(transformMatOppTop, bottomPart)
  # transform
  newMu <- as.numeric(transformMat %*% muVec)
  newSig <- transformMat %*% sigMat %*% t(transformMat)
  newMuOpp <- as.numeric(transformMatOpp %*% muVec)
  newSigOpp <- transformMatOpp %*% sigMat %*% t(transformMatOpp)

  # do integral, bounds will be larger
  intOut1 <- mvtnorm::pmvnorm(lower = lBounds1, upper = uBounds1, mean = newMu, sigma = newSig)
  intOut2 <- mvtnorm::pmvnorm(lower = lBounds2, upper = uBounds2, mean = newMuOpp, sigma = newSigOpp)
  intOut3 <- mvtnorm::pmvnorm(lower = lBounds3, upper = uBounds3, mean = newMuOpp, sigma = newSigOpp)
  intOut4 <- mvtnorm::pmvnorm(lower = lBounds4, upper = uBounds4, mean = newMu, sigma = newSig)
  return(intOut1[1] + intOut2[1] + intOut3[1] + intOut4[1])
}
