#' Optimize MSE of LNC Estimator
#'
#' Gaussian process (GP) optimization is used to minimize the MSE of the LNC estimator with respect to the non-uniformity threshold parameter \code{alpha}. A normal distribution with compound-symmetric covariance is used as a reference distribution to optimize the MSE of LNC with respect to.
#'
#' @param rho Reference correlation.
#' @param N   Sample size.
#' @param M   Number of replications.
#' @param d   Dimension.
#' @param k   Neighborhood order.
#' @param lower Lower bound for optimization.
#' @param upper Upper bound for optimization.
#' @param num_iter Number of iterations of GP optimization.
#' @param init_size Number of initial evaluation to estimating GP.
#' @param cluster A \code{parallel} cluster object.
#' @param verbose If \code{TRUE} then print runtime diagnostic output.
#'
#' @details The package \code{tgp} is used to fit a treed-GP to the MSE estimates of LNC. A treed-GP is used because the MSE of LNC with respect to \code{alpha} exhibits clear non-stationarity. A treed-GP is able to identify the function's different correlation lengths which improves optimization.
#'
#' @export
optimize_mse <- function(rho,
                         N,
                         M,
                         d,
                         k,
                         lower = -10,
                         upper = -1e-10,
                         num_iter = 10,
                         init_size = 20,
                         cluster = NULL,
                         verbose = TRUE) {

  objective_func <- function(alpha) {
    estimate_mse(k=k,alpha=alpha,d=d,rho=rho,N=N,M=M)
  }

  #--- Find Transition Point ---#
  rect      <- rbind(c(lower,upper))
  out       <- NULL
  progress  <- NULL
  threshold <- NULL
  X         <- NULL
  Z         <- NULL
  while (is.null(threshold)) {
    Xcand  <- tgp::lhs(init_size, rect)
    Xnew  <- tgp::dopt.gp(init_size, X = X, Xcand)$XX
    X     <- rbind(X, Xnew)
    new_Z <- NULL
    for (i in seq_along(Xnew)) {
      new_Z[i] <- objective_func(Xnew[i,])
    }
    Z   <- c(Z, new_Z)
    out <- tgp::optim.step.tgp(objective_func, X=X, Z=Z, rect=rect, prev=out)
    threshold <- tryCatch({out$obj$trees[[2]]$val[1]},error=function(e){NULL})
    if (min(Z) > 0.5) {
      rect[1] <- 2*rect[1]
    }
  }

  #--- Improve Design ---#
  rect <- threshold + c(-1,1)
  Xcand  <- tgp::lhs(init_size, rect)
  Xnew  <- tgp::dopt.gp(init_size, X = X, Xcand)$XX
  X     <- rbind(X, Xnew)
  new_Z <- NULL
  for (i in seq_along(Xnew)) {
    new_Z[i] <- objective_func(Xnew[i,])
  }
  Z   <- c(Z, new_Z)

  #--- Adaptive Optimization ---#
  for(j in 1:num_iter) {

    out <- tgp::optim.step.tgp(objective_func, X=X, Z=Z, rect=rect, prev=out)

    ## add in the inputs, and newly sampled outputs
    X <- rbind(X, out$X)
    new_Z <- NULL
    for (i in seq_along(out$X)) {
      new_Z[i] <- objective_func(out$X[i,])
    }
    Z <- c(Z, new_Z)

    ## keep track of progress and best optimum
    progress <- rbind(progress, out$progress)
    if (verbose) {
      print(paste(sprintf("Iteration %d of %d :",j,num_iter),print(out$progress$x1),sep = ""))
    }
  }
  if (verbose) graphics::plot(out$obj)
  return(out$progress$x1)
}

#' Estimate MSE of LNC Estimator
#'
#' Computes the MSE of the Local Non-Uniformity Correct (LNC) KSG estimator for a given value of the tuning parameter \code{alpha}, dimension, neighborhood order, and sample size.
#'
#' @param k Neighborhood order.
#' @param alpha Non-uniformity threshold (see details).
#' @param d Dimension.
#' @param rho Reference correlation (see details).
#' @param N Sample size.
#' @param M Number of replications.
#' @param cluster A \code{parallel} cluster object.
#'
#' @details The parameter \code{alpha} controls the threshold for the application of the non-uniformity correction to a particular point's neighborhood. Roughly, \code{alpha} is the ratio of the PCA aligned neighborhood volume to the rectangular aligned neighborhood volume below which indicates non-uniformity and the correction is applied.
#'
#' If \code{alpha < 0} then a log scale is assumed; otherwise [0,1] scale is used. \code{alpha > 1} are unacceptable values. A value of \code{alpha = 0} forces no correction and LNC reverts to the KSG estimator.
#'
#' The reference distribution that is assumed is a mean-zero multivariate normal distribution with a compound-symmetric covariance. The covariance matrix has a single correlation parameter supplied by \code{rho}.
#'
#' @export
#'
#' @examples
#' estimate_mse(N = 100,M = 2)
estimate_mse <- function(k       = 5,
                         alpha   = 0,
                         d       = 2,
                         rho     = 0.0,
                         N       = 1000,
                         M       = 100,
                         cluster = NULL) {

  inputs <- matrix(c(d,k,alpha,rho,N),ncol=5,nrow=M,byrow=TRUE)

  compute_mi <- function(input) {

    d <- input[1]
    K <- input[2]
    a <- input[3]
    r <- input[4]
    N <- input[5]
    data   <- simulate_mvn(N,d,rho = r)
    return(knn_mi(data,splits = rep(1,d), options = list(method="LNC",k=K,alpha=c(a,rep(0,d)))))
  }

  if (is.null(cluster)) {
    mi_mse_est <- rep(0,M)
    for (i in 1:M) {
      mi_mse_est[i] <- compute_mi(inputs[i,])
    }
  } else {
    mi_mse_est <- parallel::parApply(cluster,inputs,1,compute_mi)
  }

  analytic_mi <- function(d,rho) { #this would be a good function to break off too
    Sigma       <- matrix(rho,d,d)
    diag(Sigma) <- 1
    return(-0.5*log(det(Sigma)))
  }
  my_mse <- mean((mi_mse_est - analytic_mi(d,rho))^2)
  return(my_mse)
}











