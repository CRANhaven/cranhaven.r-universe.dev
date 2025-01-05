#' Generate simulation data (Complete data for intersection variables)
#'
#' This function helps you quickly generate simulation data based on transformation model.
#' You just need to input the sample and dimension of the data
#' you want to generate and the covariance parameter rho.
#' This simulated example comes from Section 4.2 introduced by Pan et al.(2019)
#'
#' @param n Number of subjects in the dataset to be simulated. It will also equal to the
#' number of rows in the dataset to be simulated, because it is assumed that each
#' row represents a different independent and identically distributed subject.
#' @param p Number of predictor variables (covariates) in the simulated dataset.
#' These covariates will be the features screened by model-free procedures.
#' @param rho The correlation between adjacent covariates in the simulated matrix X.
#' The within-subject covariance matrix of X is assumed to has the same form as an
#' AR(1) auto-regressive covariance matrix, although this is not meant to imply
#' that the X covariates for each subject are in fact a time series. Instead, it is just
#' used as an example of a parsimonious but nontrivial covariance structure. If
#' rho is left at the default of zero, the X covariates will be independent and the
#' simulation will run faster.
#' @param order The number of interactive variables and the default is 2.
#'
#' @return the list of your simulation data
#' @import MASS
#' @importFrom MASS mvrnorm
#' @importFrom stats rnorm
#' @export
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @examples
#' n <- 100
#' p <- 200
#' rho <- 0.5
#' data <- GendataIM(n, p, rho)
#'
#' @references
#'
#' Pan, W., X. Wang, W. Xiao, and H. Zhu (2019). A generic sure independence screening procedure. Journal of the American Statistical Association 114(526), 928–937.
GendataIM <- function(n, p, rho,
                      order = 2) # n sample size; p dimension size.
{
  sig <- matrix(0, p, p)
  sig <- rho^abs(row(sig) - col(sig))
  diag(sig) <- rep(1, p)
  X <- mvrnorm(n, rep(0, p), sig)
  if (p < 21) {
    stop("The dimension p must be greater than 20")
  }
  if (order < 2 | order > 5) {
    stop("The parameter order can be implemented between 2 to 5")
  }
  if (order == 2) {
    Y <- 2 * X[, 1] * X[, 5] + 2 * X[, 10] + 2 * X[, 15] + 2 * X[, 20] + rnorm(n)
  } else if (order == 3) {
    Y <- 2 * X[, 1] * X[, 5] * X[, 10] + 2 * X[, 15] + 2 * X[, 20] + rnorm(n)
  } else if (order == 4) {
    Y <- 2 * X[, 1] * X[, 5] * X[, 10] * X[, 15] + 2 * X[, 20] + rnorm(n)
  } else if (order == 5) {
    Y <- 2 * X[, 1] * X[, 5] * X[, 10] * X[, 15] * X[, 20] + rnorm(n)
  }
  return(list(X = X, Y = Y))
}
