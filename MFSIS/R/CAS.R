#' Category-Adaptive Variable Screening for Ultra-High Dimensional Heterogeneous Categorical Data
#'
#' A category-adaptive screening procedure with high-dimensional heterogeneous data, which is to detect category-specific important covariates.
#' This proposal is a model-free approach without any specification of a regression model and an adaptive procedure
#' in the sense that the set of active variables is allowed to vary across different categories, thus making it more
#' flexible to accommodate heterogeneity.
#'
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by CAS. The default is n/log(n).
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
#' A <- CAS(X, Y, n / log(n))
#' A
#'
#' @references
#'
#' Pan, R., Wang, H., and Li, R. (2016). Ultrahigh-dimensional multiclass linear discriminant analysis by pairwise sure independence screening. Journal of the American Statistical Association, 111(513):169–179.
CAS <- function(X, Y, nsis) {
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
  cas <- matrix(0, p, length(Yr))
  for (r in 1:length(Yr)) {
    index <- which(Y == Yr[r])
    tau <- 0
    for (i in index) {
      for (k in 1:n) {
        tau <- tau + (X[i, ] <= X[k, ])
      }
    }
    cas[, r] <- abs(tau / (n + 1) / sum(Y == Yr[r]) - 1 / 2)
  }
  B <- apply(cas, 1, max)
  A <- order(B, decreasing = TRUE)
  return(A[1:nsis])
}
