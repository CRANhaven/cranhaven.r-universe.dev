#' Generate simulation data (Complete data with group predictors)
#'
#' In many regression problems, some predictors may be naturally grouped.
#' The most common example that contains group variables is the multifactor
#' analysis of variance (ANOVA) problem, where each factor may have several
#' levels and can be expressed through a group of dummy variables.
#' This function helps you quickly generate simulation data with group predictors.
#' You just need to input the sample and dimension of the data
#' you want to generate and the covariance parameter rho.
#' This simulated example comes from Example 2 introduced by Li et al.(2012)
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
#' @param error The distribution of error term.
#'
#' @return the list of your simulation data
#' @import MASS
#' @importFrom MASS mvrnorm
#' @importFrom stats rnorm
#' @importFrom stats rt
#' @importFrom stats rcauchy
#' @export
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @examples
#' n <- 100
#' p <- 200
#' rho <- 0.5
#' data <- GendataGP(n, p, rho, "gaussian")
#'
#' @references
#'
#' Li, R., W. Zhong, and L. Zhu (2012). Feature screening via distance correlation learning. Journal of the American Statistical Association 107(499), 1129–1139.
GendataGP <- function(n, p, rho,
                      error = c("gaussian", "t", "cauchy")) # n sample size; p dimension size.
{
  sig <- matrix(0, p, p)
  sig <- rho^abs(row(sig) - col(sig))
  diag(sig) <- rep(1, p)
  X <- mvrnorm(n, rep(0, p), sig)
  q1 <- quantile(X[, 10], 0.25)
  q2 <- quantile(X[, 10], 0.5)
  q3 <- quantile(X[, 10], 0.75)
  y <- 2 * X[, 1] + 2 * X[, 5] + 2 * X[, 15] + 2 * X[, 20]
  +1 * as.numeric(X[, 10] < q1) + 2 * as.numeric(X[, 10] > q1 & X[, 10] <= q2)
  +3 * as.numeric(X[, 10] >= q3)
  if (error == "gaussian" | is.null(error)) {
    Y <- y + rnorm(n)
  } else if (error == "t") {
    Y <- y + rt(n, 2)
  } else if (error == "cauchy") {
    Y <- y + rcauchy(n)
  } else {
    stop("The author has not implemented this error term yet.")
  }
  return(list(X = X, Y = Y))
}
