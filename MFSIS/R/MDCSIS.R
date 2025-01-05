#' Martingale Difference Correlation and Its Use in High-Dimensional Variable Screening
#'
#' A new metric, the so-called martingale difference correlation,
#' to measure the departure of conditional mean independence between a scalar response variable V and a vector predictor variable U.
#' Our metric is a natural extension of distance correlation proposed by Szekely, Rizzo, and Bahirov(2007),
#' which is used to measure the dependence between V and U. The martingale difference
#' correlation and its empirical counterpart inherit a number of desirable features of distance correlation and sample distance correlation,
#' such as algebraic simplicity and elegant theoretical properties.
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by MDCSIS. The default is n/log(n).
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
#' A <- MDCSIS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Szekely, G. J., M. L. Rizzo, and N. K. Bakirov (2007). Measuring and testing dependence by correlation of distances. The annals of statistics 35(6), 2769–2794.
#'
#' Shao, X. and J. Zhang (2014). Martingale difference correlation and its use in high-dimensional variable screening. Journal of the American Statistical Association 109(507),1302–1318.
MDCSIS <- function(X, Y, nsis = (dim(X)[1]) / log(dim(X)[1])) {
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
    stop("MDCSIS can not implemented with object  of Surv")
  }
  corr <- c()
  n <- dim(X)[1]
  p <- dim(X)[2]
  Y_ij <- Y %*% t(Y)
  for (k in 1:p) {
    X_matrix <- matrix(X[, k], n, n)
    X_ij <- abs(X_matrix - t(X_matrix))
    covxy <- mean(X_ij * Y_ij)
    covx <- mean(X_ij * X_ij)
    covy <- mean(Y_ij * Y_ij)
    corr[k] <- abs(covxy) / sqrt(covx * covy)
  }
  A <- order(corr, decreasing = TRUE)
  return(A[1:nsis])
}
