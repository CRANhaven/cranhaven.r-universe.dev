#' Model-Free Feature screening Based on Concordance Index for Ultra-High Dimensional Categorical Data
#'
#' The proposed method is based on the concordance index which measures concordance between random vectors.
#' A model-free and robust feature screening method for ultrahigh-dimensional categorical data.
#' The performance is quite robust in the presence of heavy-tailed distributions, extremely unbalance responses, and category-adaptive data.
#'
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by CISIS. The default is n/log(n).
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
#' A <- CISIS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Cheng X, Wang H. A generic model-free feature screening procedure for ultra-high dimensional data with categorical response[J]. Computer Methods and Programs in Biomedicine, 2023, 229: 107269.
CISIS <- function(X, Y, nsis) {
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
  p <- dim(X)[2] ## dimension
  B <- vector(mode = "numeric", length = p)
  Yc <- vector(mode = "numeric", length = n)
  Yr <- unique(Y)
  if (length(Yr) > 15) {
    stop("A supposedly categorical variable was provided with more than 15 levels!")
  }
  Cindex <- matrix(0, length(Yr), p)
  for (r in 1:length(Yr)) {
    index <- which(Y == Yr[r])
    len <- length(index) * (n - length(index))
    # P=sum(Y==Yr[r])/length(Y)
    for (j in 1:p) {
      sum <- 0
      for (i in index) {
        sum <- sum + length(which(X[-index, j] < X[i, j]))
      }
      Cindex[r, j] <- abs(sum / len - 0.5)
    }
  }
  B <- apply(Cindex, 2, max)
  A <- order(B, decreasing = TRUE)
  return(A[1:nsis])
}
