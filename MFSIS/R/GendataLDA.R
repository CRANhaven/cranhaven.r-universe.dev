#' Generate simulation data (Categorial based on linear discriminant analysis model)
#'
#' @description Simulates a dataset that can be used to filter out features for ultrahigh-dimensional discriminant analysis.
#' The simulation is based on the balanced scenarios in Example 3.1 of Cui et al.(2015).
#' The simulated dataset has p numerical X-predictors and a categorical Y-response.
#'
#' @param n Number of subjects in the dataset to be simulated. It will also equal to the
#' number of rows in the dataset to be simulated, because it is assumed that each
#' row represents a different independent and identically distributed subject.
#' @param p Number of predictor variables (covariates) in the simulated dataset.
#' These covariates will be the features screened by model-free procedures.
#' @param R A positive integer, number of outcome categories for multinomial (categorical) outcome Y.
#' @param error The distribution of error term, you can choose "gaussian" to generate a normal
#' distribution of error or you choose "t" to generate a t distribution of error with degree=2.
#' "cauchy" is represent the error term with cauchy distribution.
#' @param style The balance among categories in categorial data .
#'
#' @return the list of your simulation data
#' @importFrom stats rt
#' @importFrom stats rnorm
#' @importFrom stats rcauchy
#' @export
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @examples
#' n <- 100
#' p <- 200
#' R <- 3
#' data <- GendataLDA(n, p, R, error = "gaussian", style = "balanced")
#' @references
#'
#' Cui, H., Li, R., & Zhong, W. (2015). Model-free feature screening for ultrahigh dimensional discriminant analysis. Journal of the American Statistical Association, 110(510), 630-641.
GendataLDA <- function(n, # number of subjects to be generated
                       p, # number of covariates to be generated
                       R = 3, # number of outcome categories for multinomial (categorical) outcome Y
                       error = c("gaussian", "t", "cauchy"), # The error distribution
                       style = c("balanced", "unbalanced")) { # Simulates multinomial Y for demonstrating MVSIS discriminant analysis.
  #  The p columns of X are each generated as independent;  most have
  #  means of zero, but the active covariates have different means depending on the level of Y.
  mu <- 3 # mu = signal strength
  if ((p < 30) | (p > 100000)) {
    stop("Please select a number p of predictors between 30 and 100000.")
  }
  if (style == "balanced") {
    Y <- sample(1:R, n, replace = T, prob = rep(1 / R, R))
  } else {
    P <- c()
    for (r in 1:R) {
      P[r] <- 2 * (1 + (r - 1) / (R - 1)) / (3 * R)
    }
    Y <- sample(1:R, n, replace = T, prob = P)
  }
  X <- matrix(0, n, p)
  for (r in 1:R) {
    ind <- (Y == r)
    A <- matrix(0, sum(ind), p)
    for (i in 1:sum(ind)) {
      # That is, for each subject having Y=r...
      if (error == "gaussian" | is.null(error)) {
        A[i, ] <- c(seq(0, 0, length = r - 1), mu, seq(0, 0, length = p - r)) + rnorm(p)
        # If heavyTailedCovariates = TRUE, then covariates will be generated as a mean
        # plus an independent error following a t distribution with 2 degrees of freedom.
      } else if (error == "t") {
        A[i, ] <- c(seq(0, 0, length = r - 1), mu, seq(0, 0, length = p - r)) + rt(p, 2)
        # If heavyTailedCovariates = TRUE, then covariates will be generated as a mean
        # plus a standard normal distribution, i.e., they will be independently normally
        # distributed with variance 1.
      } else if (error == "cauchy") {
        A[i, ] <- c(seq(0, 0, length = r - 1), mu, seq(0, 0, length = p - r)) + rcauchy(p)
      } else {
        stop("The author has not implemented this error term yet.")
      }
    }
    X[ind, ] <- A
  }
  #  The p columns of X are each generated as independent normals with variance one;  most have
  #  means of zero, but the active covariates have different means depending on the level of Y.
  #  Specifically, mu has been added to the rth predictor for r=1,...,R, so that the probability
  #  that Y equals r will be higher if the rth predictor is higher.  It is assumed that p>>r
  #  so that most predictors will be inactive.  In real data there is no reason why, say, the
  #  first two columns in the matrix should be the important ones, but this is convenient in a
  #  simulation and the choice of permutation of the columns involves no loss of generality.
  return(list(X = X, Y = Y))
}
