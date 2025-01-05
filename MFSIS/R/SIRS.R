#' Model-Free Feature Screening for Ultrahigh Dimensional Data
#'
#' A novel feature screening procedure under a unified model framework,
#' which covers a wide variety of commonly used parametric and semi-parametric models.
#' This method does not require imposing a specific model structure on regression functions,
#' and thus is particularly appealing to ultrahigh-dimensional regressions, where there are a
#' huge number of candidate predictors but little information about the actual model forms.
#'
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by SIRS. The default is n/log(n).
#'
#' @return the labels of first nsis largest active set of all predictors
#' @importFrom stats sd
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
#' A <- SIRS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Zhu, L.-P., L. Li, R. Li, and L.-X. Zhu (2011). Model-free feature screening for ultrahigh-dimensional data. Journal of the American Statistical Association 106(496), 1464–1475.
#'
SIRS <- function(X, Y, nsis = (dim(X)[1]) / log(dim(X)[1])) {
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
  n <- dim(X)[1] ## sample size
  posit <- order(Y, decreasing = FALSE)
  Y <- Y[posit]
  X <- X[posit, ]
  xx <- (X - as.matrix(rep(1, n)) %*% apply(X, 2, mean)) / (as.matrix(rep(1, n)) %*% apply(X, 2, sd))
  B <- matrix(1, n, n)
  B[!upper.tri(B, diag = TRUE)] <- 0
  USIRS <- apply((t(xx) %*% B / n)^2, 1, mean)
  A <- order(USIRS, decreasing = TRUE)
  B <- A[1:nsis]
  return(B)
}
