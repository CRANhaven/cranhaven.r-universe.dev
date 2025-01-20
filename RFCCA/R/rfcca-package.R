#' RFCCA: A package for computing canonical correlations depending on
#' subject-related covariates with random forests
#'
#' RFCCA is a random forest method for estimating the canonical correlations
#' between two sets of variables depending on the subject-related covariates.
#' The trees are built with a splitting rule specifically designed to partition
#' the data to maximize the canonical correlation heterogeneity between child
#' nodes. RFCCA uses 'randomForestSRC' package (Ishwaran and Kogalur, 2020) by
#' freezing at the version 2.9.3. The custom splitting rule feature is utilised
#' to apply the proposed splitting rule. The method is described in Alakus et
#' al. (2021).
#'
#' @section RFCCA functions:
#'   \code{\link{rfcca}}
#'   \code{\link{predict.rfcca}}
#'   \code{\link{global.significance}}
#'   \code{\link{vimp.rfcca}}
#'   \code{\link{plot.vimp.rfcca}}
#'   \code{\link{print.rfcca}}
#'
#' @references Alakus, C., Larocque, D., Jacquemont, S., Barlaam, F., Martin,
#'   C.-O., Agbogba, K., Lippe, S., and Labbe, A. (2021). Conditional canonical
#'   correlation estimation based on covariates with random forests.
#'   Bioinformatics, 37(17), 2714-2721.
#' @references Ishwaran, H., Kogalur, U. (2020). Fast Unified Random Forests for
#'   Survival, Regression, and Classification (RF-SRC). R package version 2.9.3,
#'   \url{https://cran.r-project.org/package=randomForestSRC}.
#' @docType package
#' @name RFCCA-package
NULL
#> NULL
