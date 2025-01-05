#' Sure Independent Screening
#'
#' To overcome challenges caused by ultra-high dimensionality,
#' Fan and Lv (2008) proposed a sure independence screening (SIS)
#' method, which aims to screen out the redundant features by
#' ranking their marginal Pearson correlations. The SIS method
#' is named after the SIS property, which states the selected subset
#' of features contains all the active ones with probability
#' approaching one.
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by SIS. The default is n/log(n).
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
#' A <- SIS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Fan, J. and J. Lv (2008). Sure independence screening for ultrahigh dimensional feature space. Journal of the Royal Statistical Society: Series B (Statistical Methodology) 70(5),849–911.
SIS <- function(X, Y, nsis = (dim(X)[1]) / log(dim(X)[1])) {
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
    stop("SIS can not implemented with object  of Surv")
  }
  A <- order(abs(t(X) %*% Y), decreasing = TRUE)
  return(A[1:nsis])
}
