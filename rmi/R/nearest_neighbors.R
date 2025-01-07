#' Compute Nearest Neighbors
#'
#' Computes the nearest neighbor distances and indices of a sample using the infinite norm.
#'
#' @param data Matrix of sample observations, each row is an observation.
#' @param k Neighborhood order.
#' @return List of distances and indices of the k-nearest neighbors of each point in \code{data}.
#' @details Nearest neighbors are computed using the brute-force method.
#' @examples
#' X <- cbind(1:10)
#' nearest_neighbors(X,3)
#'
#' set.seed(123)
#' X <- cbind(runif(100),runif(100))
#' plot(X,pch=20)
#' points(X[3,1],X[3,2],col='blue',pch=19, cex=1.5)
#' nn <- nearest_neighbors(X,5)
#' a = X[nn$nn_inds[3,-1],1]
#' b = X[nn$nn_inds[3,-1],2]
#' points(a,b,col='red',pch=19, cex=1.5)
#' @export
#'
nearest_neighbors <- function(data, k) {
  results = .Call('_rmi_nearest_neighbors', PACKAGE = 'rmi', data, k)
  results$nn_inds = results$nn_inds + 1
  return(results)
}


