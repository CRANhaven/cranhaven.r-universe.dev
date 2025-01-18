#' CovRegRF: A package for estimating covariance matrix of a multivariate
#' response given a set of covariates with random forests
#'
#' Covariance Regression with Random Forests (CovRegRF) is a random forest
#' method for estimating the covariance matrix of a multivariate response given
#' a set of covariates. Random forest trees are built with a new splitting rule
#' which is designed to maximize the distance between the sample covariance
#' matrix estimates of the child nodes. The method is described in Alakus et al.
#' (2023). CovRegRF uses 'randomForestSRC' package (Ishwaran and Kogalur, 2022)
#' by freezing at the version 3.1.0. The custom splitting rule feature is
#' utilised to apply the proposed splitting rule.
#'
#' @section CovRegRF functions:
#'   \code{\link{covregrf}}
#'   \code{\link{predict.covregrf}}
#'   \code{\link{significance.test}}
#'   \code{\link{vimp.covregrf}}
#'   \code{\link{plot.vimp.covregrf}}
#'   \code{\link{print.covregrf}}
#'
#' @references Alakus, C., Larocque, D., and Labbe, A. (2023). Covariance
#'   regression with random forests. BMC Bioinformatics 24, 258.
#' @references Ishwaran H., Kogalur U. (2022). Fast Unified Random Forests for
#'   Survival, Regression, and Classification (RF-SRC). R package version 3.1.0,
#'   \url{https://cran.r-project.org/package=randomForestSRC}.
#'
#' @docType package
#' @name CovRegRF-package
NULL
#> NULL
