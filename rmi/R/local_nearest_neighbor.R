#' Local Nearest Neighbor (LNN) Entropy Estimator
#'
#' Local Nearest Neighbor entropy estimator using Gaussian kernel and kNN selected bandwidth. Entropy is estimated by taking a Monte Carlo estimate using local kernel density estimate of the negative-log density.
#'
#' @param data Matrix of sample observations, each row is an observation.
#' @param k  Order of the local kNN bandwidth selection.
#' @param tr Order of truncation (number of neighbors to include in entropy).
#' @param bw Bandwidth (optional) manually fix bandwidth instead of using local kNN bandwidth selection.
#'
#' @section References:
#'
#' Loader, C. (1999). Local regression and likelihood. Springer Science & Business Media.
#'
#' Gao, W., Oh, S., & Viswanath, P. (2017). Density functional estimators with k-nearest neighbor bandwidths. IEEE International Symposium on Information Theory - Proceedings, 1, 1351–1355.
#'
#' @examples
#' set.seed(123)
#' x <- rnorm(1000)
#' print(lnn_entropy(x))
#' #analytic entropy
#' print(0.5*log(2*pi*exp(1)))
#'
#' @export
lnn_entropy <- function(data, k = 5, tr = 30, bw=NULL) {

    #bandwidth selection is k, number of points used in the calculation is tr
    if (k > tr) {
      stop("Unaccaptable Inputs, k is larger than tr")
    }

    if (!is.matrix(data)) {
      data <- matrix(data,ncol=1)
    }

    nn <- nearest_neighbors(data,tr)
    N  <- dim(data)[1]
    d  <- dim(data)[2]

    local_estimate <- rep(0,N)

    if(is.null(bw)) {
      bw = nn$nn_dist[,k+1]
    } else {
      bw = rep(bw,N)
    }

    for (i in 1:N) {
      S0 = 0
      S1 = rep(0,d)
      S2 = matrix(0,d,d)
      for (j in 1:(tr+1)) {
        dis = t(data[nn$nn_inds[i,j],] - data[i,])
        w   = as.numeric(exp(-(dis%*%t(dis))/(2*bw[i]^2)))
        S0 = S0 + w
        S1 = S1 + w*(dis/bw[i])
        S2 = S2 + w*((t(dis)%*%dis)/(bw[i]^2))
      }
      Sigma = S2/S0 - (t(S1)%*%S1)/(S0^2)

      if (is.nan(det(Sigma))) {
        stop("Local covariance matrix was singular")
      }

      if (d == 1) {
        det_Sigma = as.numeric(Sigma)
      } else {
        det_Sigma = det(Sigma)
      }

      if (det_Sigma < (1e-4)^d) {
        local_estimate[i] = 0
      } else {
        if (d == 1) {
          offset = (S1/S0)%*%(1/as.numeric(Sigma)*(S1/S0))
        } else {
          offset = t((S1/S0))%*%t(solve(Sigma)%*%t((S1/S0)))
        }
        local_estimate[i] = -log(S0) + log(N-1) + 0.5*d*log(2*pi) + d*log(bw[i]) + 0.5*log(det_Sigma) + 0.5*offset[1]
      }
    }

    if (sum(local_estimate > 0) == 0) {
      return(0)
    } else {
      return(mean(local_estimate[local_estimate != 0]))
    }
    warning("Bad returned value")
    return(NA)
}

#' Local Nearest Neighbor (LNN) MI Estimator
#'
#' Local Nearest Neighbor (LNN) mutual information estimator by Gao et al. 2017. This estimator uses the LNN entropy (\code{lnn_entropy}) estimator into the mutual information identity.
#'
#' @param  data Matrix of sample observations, each row is an observation.
#' @param  splits A vector that describes which sets of columns in \code{data} to compute the mutual information between. For example, to compute mutual information between two variables use \code{splits = c(1,1)}. To compute \emph{redundancy} among multiple random variables use \code{splits = rep(1,ncol(data))}. To compute the mutual information between two random vector list the dimensions of each vector.
#' @param k  Order of the local kNN bandwidth selection.
#' @param tr Order of truncation (number of neighbors to include in the local density estimation).
#'
#' @section References:
#'
#' Gao, W., Oh, S., & Viswanath, P. (2017). Density functional estimators with k-nearest neighbor bandwidths. IEEE International Symposium on Information Theory - Proceedings, 1, 1351–1355.
#'
#' @examples
#' set.seed(123)
#' x <- rnorm(1000)
#' y <- x + rnorm(1000)
#' lnn_mi(cbind(x,y),c(1,1))
#'
#' @export
lnn_mi <- function(data, splits, k = 5, tr = 30) {

  if (length(splits) != 2) {
    stop("splits must have length 2, multivariate redundency not implimented yet")
  }

  joint_E    <- lnn_entropy(data,k=k,tr=tr)
  marginal_E <- 0*splits

  marg_1 <- as.matrix(data[,1:splits[1]],ncol=splits[1])
  marg_2 <- as.matrix(data[,-(1:splits[1])],ncol=splits[1])

  marginal_E[1] <- lnn_entropy(marg_1,k=k,tr=tr)
  marginal_E[2] <- lnn_entropy(marg_2,k=k,tr=tr)

  mi_result <- sum(marginal_E) - joint_E
  return(mi_result)
}
