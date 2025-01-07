#' Mutual Information Estimators
#'
#' The \code{rmi} package offers a collection of mutual information estimators based on k-Nearest Neighbor and local density estimators. Currently, \code{rmi} provides the Kraskov et al. algorithm (KSG) 1 and 2, Local Non-uniformity Corrected (LNC) KSG, and the Local Nearest Neighbor (LNN) estimator. More estimators and examples will be incorporated in the future.
#'
#' @section References:
#' Gao, S., Ver Steeg G., & Galstyan A. (2015). Efficient estimation of mutual information for strongly dependent variables. Artificial Intelligence and Statistics: 277-286.
#'
#' Gao, W., Oh, S., & Viswanath, P. (2017). Density functional estimators with k-nearest neighbor bandwidths. IEEE International Symposium on Information Theory - Proceedings, 1, 1351–1355.
#'
#' Kraskov, A., Stogbauer, H., & Grassberger, P. (2004). Estimating mutual information. Physical review E 69(6): 066138.
#'
#' @docType package
#' @author Isaac Michaud
#' @import Rcpp
#' @useDynLib rmi
#' @name rmi
NULL
