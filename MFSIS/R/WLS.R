#' A Model-free Variable Screening Method Based on Leverage Score
#'
#' An innovative and effective sampling scheme based on leverage scores via singular value decompositions
#' has been proposed to select rows of a design matrix as a surrogate of the full data in linear regression.
#' Analogously, variable screening can be viewed as selecting rows of the design matrix. However, effective
#' variable selection along this line of thinking remains elusive. This method propose a
#' weighted leverage variable screening method by using both the left and right singular vectors of the design matrix.
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by WLS. The default is n/log(n).
#'
#' @return the labels of first nsis largest active set of all predictors.
#' @import dr
#'
#'
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
#' A <- WLS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Zhong, W., Liu, Y., & Zeng, P. (2021). A Model-free Variable Screening Method Based on Leverage Score. Journal of the American Statistical Association, (just-accepted), 1-36.
WLS <- function(X, Y, nsis = (dim(X)[1]) / log(dim(X)[1])) {
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
    stop("WLS can not implemented with object  of Surv")
  }
  nslice <- 10
  cn1 <- 0.1
  cn2 <- 1
  ## basic information about X and Y
  n <- dim(X)[1]
  p <- dim(X)[2]
  h <- nslice

  ## judge whether Y is discrete
  if (length(table(Y) <= 10)) {
    Y <- as.factor(Y)
  }

  ## slice
  if (is.factor(Y) == 1) {
    index <- as.numeric(factor(Y))
    nh <- summary(factor(Y))
    h <- length(nh)
  }
  if (is.factor(Y) != 1) {
    slice <- dr.slices.arc(Y, h)
    index <- slice$slice.indicator # Slice Index
    nh <- slice$slice.sizes # Observations per Slice
  }
  ph <- nh / n

  ####################################
  ## calculate wls
  ####################################
  wls <- c() # Weighted Leverage Score
  svdx <- svd(X)
  u <- svdx$u
  d <- svdx$d
  v <- svdx$v
  dir <- min(n, p)

  ## calculate WLS
  w <- matrix(ncol = dir, nrow = length(nh))
  for (j in 1:dir) {
    for (i in 1:length(nh)) w[i, j] <- sum(u[, j] * (index == i)) / nh[i]
  }

  uut <- array(dim = c(length(nh), dir, dir)) # UUT Array
  for (i in 1:length(nh)) uut[i, , ] <- (nh[i]) * (w[i, ] %*% t(w[i, ]))

  ## LEVERAGE SCORES
  for (j in 1:p) wls[j] <- t(v[j, 1:dir]) %*% colSums(uut) %*% v[j, 1:dir]
  A <- order(wls, decreasing = T)
  return(A[1:nsis])
}
