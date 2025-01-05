#' Ultrahigh-Dimensional Multiclass Linear Discriminant Analysis by Pairwise Sure Independence Screening
#'
#' A novel pairwise sure independence screening method for linear discriminant analysis with an
#' ultrahigh-dimensional predictor. This procedure is directly applicable to the situation with many classes.
#'
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by PSIS. The default is n/log(n).
#'
#' @return the labels of first nsis largest active set of all predictors
#' @importFrom utils combn
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
#' A <- PSIS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Pan, R., Wang, H., and Li, R. (2016). Ultrahigh-dimensional multiclass linear discriminant analysis by pairwise sure independence screening. Journal of the American Statistical Association, 111(513):169–179.
PSIS <- function(X, Y, nsis) {
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
  Yr <- unique(Y)
  if (length(Yr) > 15) {
    stop("A supposedly categorical variable was provided with more than 15 levels!")
  }
  n <- dim(X)[1]
  p <- dim(X)[2]
  psis <- matrix(0, p, length(Yr))
  for (k in 1:length(Yr)) {
    for (j in 1:p) {
      psis[j, k] <- t(X[, j]) %*% (1 * (Y[1:n] == k)) / sum(Y == k)
    }
  }
  settn <- combn(length(Yr), 2)
  settna <- settn[1, ]
  settnb <- settn[2, ]
  RR <- length(settna)
  r <- matrix(0, p, RR)
  B <- vector(mode = "numeric", length = p)
  for (j in 1:p) {
    for (i in 1:RR) {
      r[j, i] <- abs(psis[j, settna[i]] - psis[j, settnb[i]])
    }
    B[j] <- max(r[j, ])
  }
  A <- order(B, decreasing = TRUE)
  return(A[1:nsis])
}
