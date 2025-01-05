#' Model-Free Feature Screening for Ultrahigh Dimensional Discriminant Analysis
#'
#' A marginal feature screening procedure based on empirical conditional distribution function.
#' The response variable is categorical in discriminant analysis.
#' This enables us to use the conditional distribution function to construct a new index for feature screening.
#'
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by MVSIS. The default is n/log(n).
#'
#' @return the labels of first nsis largest active set of all predictors
#' @export
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @examples
#'
#' n <- 100
#' p <- 200
#' rho <- 0.5
#' data <- GendataLGM(n, p, rho)
#' data <- cbind(data[[1]], data[[2]])
#' colnames(data)[1:ncol(data)] <- c(paste0("X", 1:(ncol(data) - 1)), "Y")
#' data <- as.matrix(data)
#' X <- data[, 1:(ncol(data) - 1)]
#' Y <- data[, ncol(data)]
#' A <- MVSIS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Cui, H., Li, R., & Zhong, W. (2015). Model-free feature screening for ultrahigh dimensional discriminant analysis. Journal of the American Statistical Association, 110(510), 630-641.
MVSIS <- function(X, Y, nsis) {
  if (dim(X)[1] != length(Y)) {
    stop("X and Y should have same number of rows!")
  }
  if (missing(X) | missing(Y)) {
    stop("The data is missing!")
  }
  if (TRUE %in% (is.na(X) | is.na(Y) | is.na(nsis))) {
    stop("The input vector or matrix cannot have NA!")
  }
  if (inherits(Y, "Surv")) {
    stop("SIRS can not implemented with object of Surv")
  }
  Fk <- function(X0, x) {
    # Returns the estimated value of F(X0) = P(X <= X0), specifically the proportion
    # of values in x that are less than a constant X0, where x is a numerical vector
    # representing the observed values of the kth covariate x.  This is the estimated
    # unconditional cumulative distribution function of X.
    Fk <- c()
    for (i in 1:length(x))
    {
      Fk[i] <- sum(X0 <= x[i]) / length(X0)
    }
    return(Fk)
  }
  Fkr <- function(X0, Y, yr, x) {
    # Returns the estimated value of Fr(X0) = P(X <= X0| Y=yr),
    # for variables (actually vectors) x and Y and for constants X0 and yr.
    # This is the estimated cumulative distribution function of X conditional
    # on the rth value of Y.
    Fkr <- c()
    ind_yr <- (Y == yr)
    for (i in 1:length(x))
    {
      Fkr[i] <- sum((X0 <= x[i]) * ind_yr) / sum(ind_yr)
    }
    return(Fkr)
  }
  MV <- function(X, Y) {
    # Calculates the MV nonparametric association measure between numerical variable X
    # and categorical variable Y, defined as expression (2.2) in Cui, H., Li, R., & Zhong, W. (2015).
    Fk0 <- Fk(X, X)
    # It is not a mistake that X is used twice here.  For each value of this covariate, we want
    # to know what quantile it represents.  The MV  is the Expectation in X of the variance in Y
    # of the conditional cumulative distribution function F(x|Y)=P(X<=x|Y).
    # Note that like the correlation or distance correlation, this is zero if X and Y are
    # independent because F(x) does not depend on Y in that case.
    Yr <- unique(Y)
    if (length(Yr) > 15) {
      stop("A supposedly categorical variable was provided with more than 15 levels.  Did you mean to treat it as numeric?")
    }
    MVr <- c()
    for (r in 1:length(Yr)) {
      MVr[r] <- (sum(Y == Yr[r]) / length(Y)) * mean((Fkr(X, Y, Yr[r], X) - Fk0)^2)
    }
    MV <- sum(MVr)
    return(MV)
  }
  MVy <- function(Xk) {
    MV(Xk, Y)
  }
  v <- abs(apply(X, 2, MVy))
  MWord <- order(v, decreasing = T) # rank order of estimated association strengths;
  A <- match(v, v[MWord])
  return(A[1:nsis])
}
