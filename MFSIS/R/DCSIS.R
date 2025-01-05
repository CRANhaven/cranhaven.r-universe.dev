#' Feature Screening via Distance Correlation Learning
#'
#' A sure independence screening procedure based on the distance correlation (DC-SIS).
#' The DC-SIS can be implemented as easily as the sure independence screening (SIS) procedure based on the Pearson correlation proposed by Fan and Lv(2008).
#' DC-SIS can be used directly to screen grouped predictor variables and multivariate response variables.
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by DCSIS. The default is n/log(n).
#'
#' @return the labels of first nsis largest active set of all predictors
#' @export
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @examples
#'
#' n <- 100
#' p <- 200
#' rho <- 0.5
#' data <- GendataLM(n, p, rho, error = "gaussian")
#' data <- cbind(data[[1]], data[[2]])
#' colnames(data)[1:ncol(data)] <- c(paste0("X", 1:(ncol(data) - 1)), "Y")
#' data <- as.matrix(data)
#' X <- data[, 1:(ncol(data) - 1)]
#' Y <- data[, ncol(data)]
#' A <- DCSIS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Fan, J. and J. Lv (2008). Sure independence screening for ultrahigh dimensional feature space. Journal of the Royal Statistical Society: Series B (Statistical Methodology) 70(5),849–911.
#'
#' Li, R., W. Zhong, and L. Zhu (2012). Feature screening via distance correlation learning. Journal of the American Statistical Association 107(499), 1129–1139.
DCSIS <- function(X, Y, nsis = (dim(X)[1]) / log(dim(X)[1])) {
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
    stop("DCSIS can not implemented with object  of Surv")
  }
  n <- dim(X)[1] ## sample size
  p <- dim(X)[2] ## dimension
  B <- matrix(1, n, 1)
  C <- matrix(1, 1, p)
  sxy1 <- matrix(0, n, p)
  sxy2 <- matrix(0, n, p)
  sxy3 <- matrix(0, n, 1)
  sxx1 <- matrix(0, n, p)
  syy1 <- matrix(0, n, 1)
  for (i in 1:n) {
    XX1 <- abs(X - B %*% X[i, ])
    YY1 <- sqrt(apply((Y - B %*% Y[i])^2, 1, sum))
    sxy1[i, ] <- apply(XX1 * (YY1 %*% C), 2, mean)
    sxy2[i, ] <- apply(XX1, 2, mean)
    sxy3[i, ] <- mean(YY1)
    XX2 <- XX1^2
    sxx1[i, ] <- apply(XX2, 2, mean)
    YY2 <- YY1^2
    syy1[i, ] <- mean(YY2)
  }
  SXY1 <- apply(sxy1, 2, mean)
  SXY2 <- apply(sxy2, 2, mean) * apply(sxy3, 2, mean)
  SXY3 <- apply(sxy2 * (sxy3 %*% C), 2, mean)
  SXX1 <- apply(sxx1, 2, mean)
  SXX2 <- apply(sxy2, 2, mean)^2
  SXX3 <- apply(sxy2^2, 2, mean)
  SYY1 <- apply(syy1, 2, mean)
  SYY2 <- apply(sxy3, 2, mean)^2
  SYY3 <- apply(sxy3^2, 2, mean)
  dcovXY <- sqrt(SXY1 + SXY2 - 2 * SXY3)
  dvarXX <- sqrt(SXX1 + SXX2 - 2 * SXX3)
  dvarYY <- sqrt(SYY1 + SYY2 - 2 * SYY3)
  dcorrXY <- dcovXY / sqrt(dvarXX * dvarYY)
  A <- order(dcorrXY, decreasing = TRUE)
  return(A[1:nsis])
}
