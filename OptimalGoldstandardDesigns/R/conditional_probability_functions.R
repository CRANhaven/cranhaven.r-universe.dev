#' Calculate the conditional mean of a multivariate normal distribution
#'
#' See e.g. Chapter 8.1.2 in [The Matrix Cookbook](https://www.math.uwaterloo.ca/~hwolkowi/matrixcookbook.pdf).
#'
#' @template x_a
#' @template mu_a
#' @template mu_b
#' @template Sigma
#'
#' @return numeric vector with the conditional mean
#'
#' @references Petersen, K. B., & Pedersen, M. S. (2008). The matrix cookbook. Technical University of Denmark, 7(15), 510.
#'
#' @include pmv_upper_smaller_slower_fix.R
conditional_mean <- function(x_a, mu_a, mu_b, Sigma) {
  Sigma_a <- Sigma[seq_len(length(mu_a)), seq_len(length(mu_a))]
  # Sigma_b <- Sigma[(length(mu_a) + 1):(length(mu_a) + length(mu_b)), (length(mu_a) + 1):(length(mu_a) + length(mu_b))]
  Sigma_c <- Sigma[seq_len(length(mu_a)), (length(mu_a) + 1):(length(mu_a) + length(mu_b))]
  return(mu_b + t(Sigma_c) %*% solve(Sigma_a) %*% (x_a - mu_a))
}

#' Calculate the conditional mean of a multivariate normal distribution
#'
#' See e.g. Chapter 8.1.2 in [The Matrix Cookbook](https://www.math.uwaterloo.ca/~hwolkowi/matrixcookbook.pdf).
#'
#' @template x_a
#' @template mu_a
#' @template mu_b
#' @template Sigma
#'
#' @return numeric vector with the conditional covariance matrix
#'
#' @references Petersen, K. B., & Pedersen, M. S. (2008). The matrix cookbook. Technical University of Denmark, 7(15), 510.
#'
conditional_Sigma <- function(x_a, mu_a, mu_b, Sigma) {
  Sigma_a <- Sigma[seq_len(length(mu_a)), seq_len(length(mu_a))]
  Sigma_b <- Sigma[(length(mu_a) + 1):(length(mu_a) + length(mu_b)), (length(mu_a) + 1):(length(mu_a) + length(mu_b))]
  Sigma_c <- Sigma[seq_len(length(mu_a)), (length(mu_a) + 1):(length(mu_a) + length(mu_b))]
  return(Sigma_b - t(Sigma_c) %*% solve(Sigma_a) %*% Sigma_c)
}


#' Calculate the conditional power to reject both hypothesis given both interim test statistics.
#'
#' @template Z_TP1
#' @template Z_TC1
#' @template D
#'
#' @return numeric value of the conditional power.
#' @importFrom stats qnorm
#'
calc_conditional_power <- function(Z_TP1, Z_TC1, D) {
  b <- D$b
  mu <- D$mu_vec[["H1"]]
  Sigma <- D$Sigma
  always_both_futility_tests <- D$always_both_futility_tests

  pInf <- qnorm(.Machine$double.eps, mean = mu, lower.tail = FALSE)
  pInf <- list(list("TP" = pInf[1], "TC" = pInf[3]), list("TP" = pInf[2], "TC" = pInf[4]))
  nInf <- qnorm(.Machine$double.eps, mean = mu, lower.tail = TRUE)
  nInf <- list(list("TP" = nInf[1], "TC" = nInf[3]), list("TP" = nInf[2], "TC" = nInf[4]))

  for (i in seq_len(length(b))){
    for (j in names(b[[i]])){
      for (k in names(b[[i]][[j]])){
        if (b[[i]][[j]][[k]]==Inf)
          b[[i]][[j]][[k]] <- pInf[[i]][[j]]
      }
    }
  }

  if (Z_TP1 <= b[[1]][["TP"]][["futility"]]) {
    return(0)
  } else if (b[[1]][["TP"]][["efficacy"]] < Z_TP1) {
    if (Z_TC1 <= b[[1]][["TC"]][["futility"]]) {
      return(0)
    } else if (b[[1]][["TC"]][["efficacy"]] < Z_TC1) {
      return(1)
    } else {
      permutation <- diag(4)[c(1, 3, 2, 4), ]
      cmean <- as.vector(conditional_mean(
        c(Z_TP1, Z_TC1),
        (permutation %*% mu)[1:2],
        (permutation %*% mu)[3:4],
        permutation %*% Sigma %*% t(permutation)
      ))
      csigma <- conditional_Sigma(
        c(Z_TP1, Z_TC1),
        (permutation %*% mu)[1:2], (permutation %*% mu)[3:4],
        permutation %*% Sigma %*% t(permutation)
      )
      return(pmvnorm_(
        mean = cmean[[2]],
        sigma = csigma[2, 2],
        lower = c(b[[2]][["TC"]][["efficacy"]]),
        upper = c(pInf[[2]][["TC"]]),
        algorithm = D$mvnorm_algorithm
      )[1])
    }
  } else {
    if (isTRUE(always_both_futility_tests)) {
      if (Z_TC1 <= b[[1]][["TC"]][["futility"]]) {
        return(0)
      }
    }
    permutation <- diag(4)[c(1, 3, 2, 4), ]
    cmean <- as.vector(conditional_mean(
      c(Z_TP1, Z_TC1),
      (permutation %*% mu)[1:2],
      (permutation %*% mu)[3:4], permutation %*% Sigma %*% t(permutation)
    ))
    csigma <- conditional_Sigma(
      c(Z_TP1, Z_TC1), (permutation %*% mu)[1:2],
      (permutation %*% mu)[3:4],
      permutation %*% Sigma %*% t(permutation)
    )
    return(pmvnorm_(
      mean = cmean,
      sigma = csigma,
      lower = c(b[[2]][["TP"]][["efficacy"]], b[[2]][["TC"]][["efficacy"]]),
      upper = c(pInf[[2]][["TP"]], pInf[[2]][["TC"]]),
      algorithm = D$mvnorm_algorithm
    )[1])
  }
}

#' Calculate the (local) conditional type I errors of both hypothesis given both interim test statistics.
#'
#' @template Z_TP1
#' @template Z_TC1
#' @template D
#' @template mu_vec
#'
#' @return named numeric vector with both conditional type I errors.
#' @importFrom stats qnorm
#'
calc_conditional_local_rejection_probs <- function(Z_TP1, Z_TC1, D, mu_vec = D$mu_vec$H0) {
  if (!D$always_both_futility_tests){
    warning("Testing procedure not closed. Changing design characteristics at interim based on the conditional rejection probability princple may lead to inflated family-wise type I error if only local type I error rates are considered.")
  }
  b <- D$b
  Sigma <- D$Sigma

  pInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = FALSE)
  pInf <- list(list("TP" = pInf[1], "TC" = pInf[3]), list("TP" = pInf[2], "TC" = pInf[4]))
  nInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = TRUE)
  nInf <- list(list("TP" = nInf[1], "TC" = nInf[3]), list("TP" = nInf[2], "TC" = nInf[4]))

  for (i in seq_len(length(b))){
    for (j in names(b[[i]])){
      for (k in names(b[[i]][[j]])){
        if (b[[i]][[j]][[k]]==Inf)
          b[[i]][[j]][[k]] <- pInf[[i]][[j]]
      }
    }
  }

  alphas <- c(NA_real_, NA_real_)
  names(alphas) <- c("TP", "TC")
  for (groups in c("TP", "TC")){
    if (groups == "TP") {
      permutation <- diag(4)[c(1, 2, 3, 4), ]
      Z <- Z_TP1
    } else {
      permutation <- diag(4)[c(3, 4, 1, 2), ]
      Z <- Z_TC1
    }
    if (Z <= b[[1]][[groups]][["futility"]]) {
      alphas[[groups]] <- 0
    } else if (b[[1]][[groups]][["efficacy"]] < Z) {
      alphas[[groups]] <- 1
    } else {
      cmean <- as.vector(conditional_mean(c(Z), (permutation %*% mu_vec)[1], (permutation %*% mu_vec)[2], permutation %*% Sigma %*% t(permutation)))
      csigma <- conditional_Sigma(c(Z), (permutation %*% mu_vec)[1], (permutation %*% mu_vec)[2], permutation %*% Sigma %*% t(permutation))
      alphas[[groups]] <- pmvnorm_(
        mean = cmean[[1]],
        sigma = csigma[1, 1],
        lower = c(b[[2]][[groups]][["efficacy"]]),
        upper = c(pInf[[2]][["TC"]]),
        algorithm = D$mvnorm_algorithm
      )[1]
    }
  }
  return(alphas)
}


