#' Generate simulation data (Complete data based on transformation model)
#'
#' This function helps you quickly generate simulation data based on transformation model.
#' You just need to input the sample and dimension of the data
#' you want to generate and the covariance parameter rho.
#' This simulated example comes from Example 3.a introduced by Zhu et al.(2011)
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
#' @param beta A vector with length of n, which are the coefficients that you want to generate
#' about Linear model. The default is beta=(1,1,1,1,1,0,...,0)^T;
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
#' data <- GendataTM(n, p, rho, error = "gaussian")
#'
#' @references
#'
#' Zhu, L.-P., L. Li, R. Li, and L.-X. Zhu (2011). Model-free feature screening for ultrahigh-dimensional data. Journal of the American Statistical Association 106(496), 1464–1475.
GendataTM <- function(n, p, rho,
                      beta = c(rep(1, 5), rep(0, p - 5)),
                      error = c("gaussian", "t", "cauchy")) # n sample size; p dimension size.
{
  sig <- matrix(0, p, p)
  sig <- rho^abs(row(sig) - col(sig))
  diag(sig) <- rep(1, p)
  X <- mvrnorm(n, rep(0, p), sig)
  myrates <- exp(X %*% beta)
  if (error == "gaussian" | is.null(error)) {
    Y <- myrates * exp(rnorm(n))
  } else if (error == "t") {
    Y <- myrates * exp(rt(n, 2))
  } else if (error == "cauchy") {
    Y <- myrates * exp(rcauchy(n))
  } else {
    stop("The author has not implemented this error term yet.")
  }
  return(list(X = X, Y = Y))
}
