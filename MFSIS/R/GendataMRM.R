#' Generate simulation data (Multivariate response models)
#'
#' This function helps you quickly generate simulation data based on transformation model.
#' You just need to input the sample and dimension of the data
#' you want to generate and the covariance parameter rho.
#' This simulated example comes from Example 3 introduced by Li et al.(2020)
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
#' @param type The type of multivariate response models, which use different mean and covariance
#' structure to generate data. Specially, type="a" is following the Model 3.a and
#' type="b" is following the Model 3.b by Li et al.(2020).
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
#' data <- GendataMRM(n, p, rho, type = "a")
#'
#' @references
#'
#' Liu, W., Y. Ke, J. Liu, and R. Li (2020). Model-free feature screening and FDR control with knockoff features. Journal of the American Statistical Association, 1–16.
GendataMRM <- function(n, p, rho,
                       type = c("a", "b")) # n sample size; p dimension size.
{
  sig1 <- matrix(0, p, p)
  sig1 <- rho^abs(row(sig1) - col(sig1))
  diag(sig1) <- rep(1, p)
  X <- mvrnorm(n, rep(0, p), sig1)
  if (type != "a" & type != "b") {
    stop("The type can be implemented both a and b ")
  }
  if (type == "a") {
    Y <- matrix(0, n, 2)
    for (i in 1:n) {
      mu1 <- exp(2 * (X[i, 1] + X[i, 2]))
      mu2 <- X[i, 3] + X[i, 4] + X[i, 5]
      sig2 <- matrix(0, 2, 2)
      cita <- 2 * X[i, 1] + 2 * X[i, 2] + 2 * X[i, 3] + 2 * X[i, 4] + 2 * X[i, 5]
      sig2[1, 2] <- sin(cita)
      sig2[2, 1] <- sig2[1, 2]
      diag(sig2) <- rep(1, 2)
      Y[i, ] <- mvrnorm(1, c(mu1, mu2), sig2)
    }
  } else {
    Y <- matrix(0, n, 2)
    for (i in 1:n) {
      mu1 <- 2 * sin(pi * X[i, 1] / 2) + X[i, 3] + exp(1 + X[i, 5])
      mu2 <- 1 / X[i, 2] + X[i, 4]
      sig2 <- matrix(0, 2, 2)
      cita <- 2 * X[i, 1] + 2 * X[i, 2] + 2 * X[i, 3] + 2 * X[i, 4] + 2 * X[i, 5]
      sig2[1, 2] <- (exp(cita) - 1) / (exp(cita) + 1)
      sig2[2, 1] <- sig2[1, 2]
      diag(sig2) <- rep(1, 2)
      Y[i, ] <- mvrnorm(1, c(mu1, mu2), sig2)
    }
  }
  return(list(X = X, Y = Y))
}
