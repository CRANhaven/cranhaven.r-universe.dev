#' Model-Free Feature screening Based on Concordance Index Statistic
#'
#' A model-free and data-adaptive feature screening method for
#' ultrahigh-dimensional data and even survival data. The proposed method is based
#' on the concordance index which measures concordance between random vectors even
#' if one of the vectors is a survival object Surv. This rank correlation based
#' method does not require specifying a regression model, and applies robustly to data
#' in the presence of censoring and heavy tails. It enjoys both sure screening and rank
#' consistency properties under weak assumptions.
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1. For survival models,
#' Y should be an object of class Surv, as provided by the function
#' Surv() in the package survival.
#' @param nsis Number of predictors recruited by CSIS. The default is n/log(n).
#'
#' @return the labels of first nsis largest active set of all predictors
#'
#' @importFrom survival concordancefit
#' @importFrom survival Surv
#' @import foreach
#' @import parallel
#' @import doParallel
#'
#' @export
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @examples
#'
#' ## Scenario 1  generate complete data
#' n <- 100
#' p <- 200
#' rho <- 0.5
#' data <- GendataLM(n, p, rho, error = "gaussian")
#' data <- cbind(data[[1]], data[[2]])
#' colnames(data)[1:ncol(data)] <- c(paste0("X", 1:(ncol(data) - 1)), "Y")
#' data <- as.matrix(data)
#' X <- data[, 1:(ncol(data) - 1)]
#' Y <- data[, ncol(data)]
#' A1 <- CSIS(X, Y, n / log(n))
#' A1
#'
#' ## Scenario 2  generate survival data
#' library(survival)
#' n <- 100
#' p <- 200
#' rho <- 0.5
#' data <- GendataCox(n, p, rho)
#' data <- cbind(data[[1]], data[[2]], data[[3]])
#' colnames(data)[ncol(data)] <- c("status")
#' colnames(data)[(ncol(data) - 1)] <- c("time")
#' colnames(data)[(1:(ncol(data) - 2))] <- c(paste0("X", 1:(ncol(data) - 2)))
#' data <- as.matrix(data)
#' X <- data[, 1:(ncol(data) - 2)]
#' Y <- Surv(data[, (ncol(data) - 1)], data[, ncol(data)])
#' A2 <- CSIS(X, Y, n / log(n))
#' A2
#'
#' @references
#'
#' Cheng X, Li G, Wang H. The concordance filter: an adaptive model-free feature screening procedure[J]. Computational Statistics, 2023: 1-24.
CSIS <- function(X, Y, nsis = (dim(X)[1]) / log(dim(X)[1])) {
  if (dim(X)[1] != length(Y)) {
    stop("X and Y should have same number of rows!")
  }
  if (missing(X) | missing(Y)) {
    stop("The data is missing!")
  }
  if (TRUE %in% (is.na(X) | is.na(Y) | is.na(nsis))) {
    stop("The input vector or matrix cannot have NA!")
  }
  n <- dim(X)[1] ## sample size
  p <- dim(X)[2] ## dimension
  B <- vector(mode = "numeric", length = p)
  Cindex <- vector(mode = "numeric", length = p)
  if (n * p <= 2000000) {
    for (i in 1:p) {
      Cindex[i] <- concordancefit(Y, X[, i])$concordance
    }
  } else {
    # Real physical cores in the computer
    cores <- detectCores(logical = FALSE)
    cl <- makeCluster(cores)
    registerDoParallel(cl, cores = cores)
    j <- NULL
    Cindex <- foreach::foreach(
      j = 1:p, .combine = "c",
      .packages = c("survival")
    ) %dopar%
      concordancefit(Y, X[, j])$concordance
    stopImplicitCluster()
    stopCluster(cl)
  }
  num <- which(Cindex < 0.5)
  B[num] <- 1 - Cindex[num]
  B[-num] <- Cindex[-num]
  A <- order(B, decreasing = TRUE)
  return(A[1:nsis])
}
