#' sim_power_indiv.R
#'
#' Simulate power starting from individual-level data for multiple
#' explanatory factor setting.
#'
#' @param B Number of simulations.
#' @param sigSq Variance of outcome.
#' @param xMat Design matrix of non-genetic covariates, n*p.
#' @param gMat Matrix of genotypes, n*J.
#' @param alphaVec p*1 vector of regression coefficients for xMat.
#' @param betaVec J*1 vector of regression coefficients for gMat.
#' @param decompTrue The return value of a call to eigen() on the true covariance matrix. Can be null,
#' in which case estimated covariance will be used.
#' @param checkpoint Boolean, if true then print message every 50 simulations.
#'
#' @return A list with the elements:
#' \item{zMat}{B*J matrix of test statistics Z.}
#' \item{zVecGBJ}{Check on Z statistics, vector should match first row of zMat.}
#' \item{iMat}{Innovated statistics matrix also of dimension B*J.}
#' @importFrom stats glm
#' @importFrom stats gaussian
#' @importFrom stats rnorm
#' @export
#' @examples
#' \donttest{
#' xMat <- cbind(1, rnorm(n = 1000), rbinom(n = 1000, size=1, prob=0.5))
#' gMat <- matrix(data = rbinom(n=10000, size=2, prob=0.3), nrow=1000)
#' alphaVec <- c(1, 1, 1)
#' betaVec <- rep(0, 10)
#' sim_stats_mef(B=10000, sigSq = 1, xMat = xMat, gMat = gMat, alphaVec = alphaVec, betaVec = betaVec)
#' }
sim_stats_mef <- function(B, sigSq, xMat, gMat, alphaVec, betaVec, decompTrue = NULL, checkpoint = FALSE) {

  # true mean vector
  etaVec <- xMat %*% alphaVec + gMat %*% betaVec
  n <- length(etaVec)
  p <- ncol(xMat)
  J <- ncol(gMat)
  # quantities for calculating statistics and correlation matrix
  pMat <- xMat %*% solve(t(xMat) %*% xMat) %*% t(xMat)
  mafVec <- apply(gMat, 2, mean) / 2
  varG <- 2 * mafVec * (1 - mafVec)
  IminusP <- diag(rep(1, n)) - pMat
  GGterm <- t(gMat) %*% IminusP %*% gMat

  # record
  tMat <- matrix(data=NA, nrow=B, ncol=J)
  zMat <- matrix(data=NA, nrow=B, ncol=J)
  for (sim_it in 1:B) {
    # generate outcome
    yVec <- etaVec + rnorm(n=n, mean = 0, sd = sqrt(sigSq))
    # calculate statistics
    residVec <- yVec - pMat %*% yVec
    sigSqHat <- sum(residVec^2) / (n - p)
    tVec <- t(gMat) %*% residVec / sqrt(n)
    zVec <- sqrt(n) * tVec / sqrt(diag(GGterm) * sigSqHat)

    # do GBJ
    if (sim_it == 1) {
      nullMod <- glm(yVec ~ xMat - 1, family=gaussian())
      #packageOutput <- calc_score_stats(null_model = nullMod, factor_matrix = gMat, link_function = "linear")
      packageOutput <- GBJ::calc_score_stats(null_model = nullMod, factor_matrix = gMat, link_function = "linear")
      zVecGBJ <- packageOutput$test_stats
    }

    # record
    zMat[sim_it, ] <- zVec

    # checkpoint
    if (checkpoint) {
      if (sim_it%%500 == 0) {cat(sim_it)}
    }
  }

  # innovate with estimated correlation matrix under the null
  denomVec <- 1 / sqrt(diag(GGterm))
  corMat <- diag(denomVec) %*% GGterm %*% diag(denomVec)
  decomp <- eigen(corMat)
  iMatEst <- zMat %*% decomp$vectors %*% diag(1 / sqrt(decomp$values))

  # innovate with true correlation matrix
  if (!is.null(decompTrue)) {
    iMat <- zMat %*% decompTrue$vectors %*% diag(1 / sqrt(decompTrue$values))
  } else {
    iMat <- NULL
  }

  return(list(zMat = zMat, zVecGBJ = zVecGBJ, iMat = iMat, iMatEst = iMatEst))
}



#' Simulate power starting from individual-level data for multiple
#' outcomes setting.
#'
#' @param B Number of simulations.
#' @param covY Covariance matrix of outcomes.
#' @param xMat Design matrix of non-genetic covariates, n*p.
#' @param gVec n*1 vector of genotypes.
#' @param alphaMat p*K vector of regression coefficients for xMat.
#' @param gammaVec K*1 vector of regression coefficients for each outcome.
#' @param checkpoint Boolean, if true then print message every 50 simulations.
#'
#' @return A list with the elements:
#' \item{zMat}{Matrix of test statistics Z.}
#' \item{zVecGBJ}{Check on Z statistics, vector should match first row of zMat.}
#' \item{iMat}{Innovated statistics using correlation matrix under the null.}
#' @importFrom magrittr %>%
#' @importFrom stats glm
#' @importFrom stats gaussian
#' @export
#' @examples
#' \donttest{
#' covY <- matrix(data=0.3, nrow=10, ncol=10); diag(covY) <- 1
#' xMat <- cbind(1, rnorm(n = 1000), rbinom(n = 1000, size=1, prob=0.5))
#' gVec <- rbinom(n= 1000, size = 2, prob=0.3)
#' alphaMat <-matrix(data = 1, nrow=3, ncol=10)
#' gammaVec <- rep(0, 10)
#' sim_stats_mo(B=10000, covY = covY, xMat = xMat, gVec = gVec,
#' alphaMat = alphaMat, gammaVec = gammaVec)
#' }
sim_stats_mo <- function(B, covY, xMat, gVec, alphaMat, gammaVec, checkpoint = FALSE) {

  # true mean matrix n*K
  etaMat <- xMat %*% alphaMat + gVec %*% t(gammaVec)
  n <- nrow(etaMat)
  K <- length(gammaVec)
  p <- ncol(xMat)

  # quantities for calculating statistics and correlation matrix
  pMat <- xMat %*% solve(t(xMat) %*% xMat) %*% t(xMat)
  IminusP <- diag(rep(1, n)) - pMat
  maf <- mean(gVec) / 2
  varG <- t(gVec) %*% IminusP %*% gVec
  varYvec <- diag(covY)
  corY <- sweep(covY, MARGIN=2, STATS=sqrt(varYvec), FUN="/") %>%
    sweep(MARGIN=1, STATS=sqrt(varYvec), FUN="/")

  # record
  uMat <- matrix(data=NA, nrow=B, ncol=K)
  vMat <- matrix(data=NA, nrow=B, ncol=K)
  for (sim_it in 1:B) {
    # generate outcome
    yMat <- etaMat + mvtnorm::rmvnorm(n=n, mean=rep(0, K), sigma = covY)
    # calculate statistics
    residMat <- yMat - pMat %*% yMat
    sigSqHat <- apply(residMat^2, 2, sum) / (n - p)
    uVec <- t(gVec) %*% residMat / sqrt(n)
    vVec <- sqrt(n) * uVec / sqrt(rep(as.numeric(varG), K) * sigSqHat)

    # do package
    if (sim_it == 1) {
      zVecPackage <- rep(0, K)
      for (k in 1:K) {
        nullMod <- glm(yMat[, k] ~ xMat - 1, family=gaussian())
        packageOutput <- GBJ::calc_score_stats(null_model = nullMod, factor_matrix = matrix(data=rep(gVec, 2), ncol=2), link_function = "linear")
        #packageOutput <- calc_score_stats(null_model = nullMod, factor_matrix = matrix(data=rep(gVec, 2), ncol=2), link_function = "linear", P_mat = sigSqHat[k] * IminusP)
        zVecPackage[k] <- packageOutput$test_stats[1]
      }
    }

    # record
    uMat[sim_it, ] <- uVec
    vMat[sim_it, ] <- vVec

    # checkpoint
    if (checkpoint) {
      if (sim_it%%500 == 0) {cat(sim_it)}
    }
  }

  # innovate with known correlation matrix
  decomp <- eigen(corY)
  iMat <- vMat %*% decomp$vectors %*% diag(1 / sqrt(decomp$values))

  return(list(uMat = uMat, vMat = vMat, zVecPackage = zVecPackage, iMat = iMat))
}





