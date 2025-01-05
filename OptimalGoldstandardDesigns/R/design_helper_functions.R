#' Helper function to calculate cumulative sample sizes from stagewise sample sizes
#'
#' @template D
#' @include global_constants.R
#' @include pmv_upper_smaller_slower_fix.R
calc_cumn <- function(D) {
  n <- D$n
  cumn <- D$n
  cumn[[2]][["T"]] <- n[[1]][["T"]] + n[[2]][["T"]]
  cumn[[2]][["P"]] <- n[[1]][["P"]] + n[[2]][["P"]]
  cumn[[2]][["C"]] <- n[[1]][["C"]] + n[[2]][["C"]]
  return(cumn)
}

#' Helper function to calculate "cumulative allocation ratio" from stagewise allocation ratios
#'
#' @template D
calc_cumc <- function(D) {
  stagec <- D$stagec
  cumc <- D$stagec
  cumc[[2]][["T"]] <- stagec[[1]][["T"]] + stagec[[2]][["T"]]
  cumc[[2]][["P"]] <- stagec[[1]][["P"]] + stagec[[2]][["P"]]
  cumc[[2]][["C"]] <- stagec[[1]][["C"]] + stagec[[2]][["C"]]
  return(cumc)
}

#' Helper function to calculate other n's given n_{1,T} and allocation ratios
#'
#' @template D
#' @template nT1
calc_n_from_c <- function(nT1, D) {
  stagec <- D$stagec
  n <- list()
  n[[2]] <- list()
  n[[1]][["T"]] <- nT1
  n[[1]][["P"]] <- stagec[[1]][["P"]] * n[[1]][["T"]]
  n[[1]][["C"]] <- stagec[[1]][["C"]] * n[[1]][["T"]]
  n[[2]][["T"]] <- stagec[[2]][["T"]] * n[[1]][["T"]]
  n[[2]][["P"]] <- stagec[[2]][["P"]] * n[[1]][["T"]]
  n[[2]][["C"]] <- stagec[[2]][["C"]] * n[[1]][["T"]]
  return(n)
}

#' Helper function to calculate allocation ratios from stagewise sample sizes
#'
#' @template D
calc_c <- function(D) {
  n <- D$n
  stagec <- list()
  stagec[[2]] <- list()
  stagec[[1]][["T"]] <- 1
  stagec[[1]][["P"]] <- n[[1]][["P"]] / n[[1]][["T"]]
  stagec[[1]][["C"]] <- n[[1]][["C"]] / n[[1]][["T"]]
  stagec[[2]][["T"]] <- n[[2]][["T"]] / n[[1]][["T"]]
  stagec[[2]][["P"]] <- n[[2]][["P"]] / n[[1]][["T"]]
  stagec[[2]][["C"]] <- n[[2]][["C"]] / n[[1]][["T"]]
  return(stagec)
}

#' Helper function to calculate gamma factors from group variances and cumulative allocation ratios
#'
#' @template D
calc_gamma <- function(D) {
  var <- D$var
  cumc <- D$cumc
  gamma <- list()
  gamma[[1]] <- list()
  gamma[[2]] <- list()
  for (g in c("P", "C")) {
    for (s in 1:(length(cumc))) {
      gamma[[s]][[paste0("T", g)]] <- sqrt(var[["T"]] / cumc[[s]][["T"]] + var[[g]] / cumc[[s]][[g]])
    }
  }
  return(gamma)
}

#' Helper function to calculate the covariance matrix from the group variances, cumulative allocation ratios
#' and gamma factors
#'
#' @template D
calc_Sigma <- function(D) {
  var <- D$var
  cumc <- D$cumc
  gamma <- D$gamma

  Sigma <- matrix(0, ncol = 4, nrow = 4)
  Sigma[1, ] <-
    c(
      1,
      gamma[[2]][["TP"]] / gamma[[1]][["TP"]],
      var[["T"]] / (cumc[[1]][["T"]] * gamma[[1]][["TP"]] * gamma[[1]][["TC"]]),
      var[["T"]] / (cumc[[2]][["T"]] * gamma[[1]][["TP"]] * gamma[[2]][["TC"]])
    )
  Sigma[2, c(2, 3, 4)] <-
    c(
      1,
      var[["T"]] / (cumc[[2]][["T"]] * gamma[[2]][["TP"]] * gamma[[1]][["TC"]]),
      var[["T"]] / (cumc[[2]][["T"]] * gamma[[2]][["TP"]] * gamma[[2]][["TC"]])
    )
  Sigma[3, c(3, 4)] <-
    c(
      1,
      gamma[[2]][["TC"]] / gamma[[1]][["TC"]]
    )
  Sigma[4, c(4)] <-
    c(1)
  Sigma[lower.tri(Sigma, diag = T)] <-
    t(Sigma)[lower.tri(Sigma, diag = T)]
  return(Sigma)
}

#' Helper function to calculate expected value of normal test statistic vector c(Z_TP1, Z_TP2, Z_TC1, Z_TP2)
#' under the null and alternative hypothesis given nT1=1, gamma and mu.
#'
#' This quantity is helpful when solving for the smallest n which fulfills a certain power constraint.
#'
#' @template D
calc_mu_wo_nT1 <- function(D) {
  gamma <- D$gamma
  mu <- D$mu
  mu_wo_nT1 <- list()
  mu_wo_nT1[["H0"]] <-
    c(
      mu[["H0"]][["TP"]] / gamma[[1]][["TP"]],
      mu[["H0"]][["TP"]] / gamma[[2]][["TP"]],
      mu[["H0"]][["TC"]] / gamma[[1]][["TC"]],
      mu[["H0"]][["TC"]] / gamma[[2]][["TC"]]
    )
  mu_wo_nT1[["H1"]] <-
    c(
      mu[["H1"]][["TP"]] / gamma[[1]][["TP"]],
      mu[["H1"]][["TP"]] / gamma[[2]][["TP"]],
      mu[["H1"]][["TC"]] / gamma[[1]][["TC"]],
      mu[["H1"]][["TC"]] / gamma[[2]][["TC"]]
    )
  return(mu_wo_nT1)
}

#' Helper function to calculate expected value of normal test statistic vector c(Z_TP1, Z_TP2, Z_TC1, Z_TP2)
#' under the null and alternative hypothesis given nT1, gamma and mu.
#'
#' @template D
calc_mu_vec <- function(D) {
  sqrt_nT1 <- sqrt(D$n[[1]][["T"]])
  gamma <- D$gamma
  mu <- D$mu

  mu_vec <- list()
  mu_vec[["H0"]] <-
    sqrt_nT1 * c(
      mu[["H0"]][["TP"]] / gamma[[1]][["TP"]],
      mu[["H0"]][["TP"]] / gamma[[2]][["TP"]],
      mu[["H0"]][["TC"]] / gamma[[1]][["TC"]],
      mu[["H0"]][["TC"]] / gamma[[2]][["TC"]]
    )
  mu_vec[["H1"]] <-
    sqrt_nT1 * c(
      mu[["H1"]][["TP"]] / gamma[[1]][["TP"]],
      mu[["H1"]][["TP"]] / gamma[[2]][["TP"]],
      mu[["H1"]][["TC"]] / gamma[[1]][["TC"]],
      mu[["H1"]][["TC"]] / gamma[[2]][["TC"]]
    )

  mu_vec[["H00"]] <- mu_vec[["H0"]]
  mu_vec[["H11"]] <- mu_vec[["H1"]]

  mu_vec[["H01"]] <-
    sqrt_nT1 * c(
      mu[["H0"]][["TP"]] / gamma[[1]][["TP"]],
      mu[["H0"]][["TP"]] / gamma[[2]][["TP"]],
      mu[["H1"]][["TC"]] / gamma[[1]][["TC"]],
      mu[["H1"]][["TC"]] / gamma[[2]][["TC"]]
    )
  mu_vec[["H10"]] <-
    sqrt_nT1 * c(
      mu[["H1"]][["TP"]] / gamma[[1]][["TP"]],
      mu[["H1"]][["TP"]] / gamma[[2]][["TP"]],
      mu[["H0"]][["TC"]] / gamma[[1]][["TC"]],
      mu[["H0"]][["TC"]] / gamma[[2]][["TC"]]
    )
  return(mu_vec)
}


#' Helper function to calculate the final state probabilities
#'
#' @template hypothesis
#' @template D
#' @importFrom stats qnorm
calc_final_state_probs <- function(hypothesis = "H0", D) {
  mu_ <- D$mu_vec[[hypothesis]]
  Sigma <- D$Sigma
  b <- D$b
  always_both_futility_tests <- D$always_both_futility_tests

  # Hack to get MiWa algorithm to work with infinite boundaries and reasonable accuracy
  pInf <- qnorm(.Machine$double.eps, mean = mu_, lower.tail = FALSE)
  pInf <- list(list("TP" = pInf[1], "TC" = pInf[3]), list("TP" = pInf[2], "TC" = pInf[4]))
  nInf <- qnorm(.Machine$double.eps, mean = mu_, lower.tail = TRUE)
  nInf <- list(list("TP" = nInf[1], "TC" = nInf[3]), list("TP" = nInf[2], "TC" = nInf[4]))

  for (i in seq_len(length(b))){
    for (j in names(b[[i]])){
      for (k in names(b[[i]][[j]])){
        if (b[[i]][[j]][[k]]==Inf)
          b[[i]][[j]][[k]] <- pInf[[i]][[j]]
        if (b[[i]][[j]][[k]]==-Inf)
          b[[i]][[j]][[k]] <- nInf[[i]][[j]]
      }
    }
  }

  toladjust <- 8

  P <- list()
  P[["TP1E_TC1E"]] <- pmvnorm_(
    mean = as.vector(projection[["TP1_TC1"]] %*% mu_),
    sigma =  projection[["TP1_TC1"]] %*% Sigma %*% t(projection[["TP1_TC1"]]),
    lower = c(b[[1]][["TP"]][["efficacy"]], b[[1]][["TC"]][["efficacy"]]),
    upper = c(pInf[[1]][["TP"]], pInf[[1]][["TC"]]),
    algorithm = D$mvnorm_algorithm
  )[1]

  P[["TP1E_TC12E"]] <- pmvnorm_(
    mean = as.vector(projection[["TP1_TC12"]] %*% mu_),
    sigma =  projection[["TP1_TC12"]] %*% Sigma %*% t(projection[["TP1_TC12"]]),
    lower = c(b[[1]][["TP"]][["efficacy"]], b[[1]][["TC"]][["futility"]], b[[2]][["TC"]][["efficacy"]]),
    upper = c(pInf[[1]][["TP"]], b[[1]][["TC"]][["efficacy"]], pInf[[2]][["TC"]]),
    algorithm = D$mvnorm_algorithm
  )[1]

  P[["TP1E_TC12F"]] <- pmvnorm_(
    mean = as.vector(projection[["TP1_TC12"]] %*% mu_),
    sigma =  projection[["TP1_TC12"]] %*% Sigma %*% t(projection[["TP1_TC12"]]),
    lower = c(b[[1]][["TP"]][["efficacy"]], b[[1]][["TC"]][["futility"]], nInf[[2]][["TC"]]),
    upper = c(pInf[[1]][["TP"]], b[[1]][["TC"]][["efficacy"]], b[[2]][["TC"]][["efficacy"]]),
    algorithm = D$mvnorm_algorithm
  )[1]

  if (isTRUE(always_both_futility_tests)) {
    P[["TP1F_TC1F"]] <- 1 - pmvnorm_(
      mean = as.vector(projection[["TP1_TC1"]] %*% mu_),
      sigma =  projection[["TP1_TC1"]] %*% Sigma %*% t(projection[["TP1_TC1"]]),
      lower = c(b[[1]][["TP"]][["futility"]], b[[1]][["TC"]][["futility"]]),
      upper = c(pInf[[1]][["TP"]], pInf[[1]][["TC"]]),
      algorithm = D$mvnorm_algorithm
    )[1]

    P[["TP12F_TC1"]] <- pmvnorm_(
      mean = as.vector(projection[["TP12_TC1"]] %*% mu_),
      sigma =  projection[["TP12_TC1"]] %*% Sigma %*% t(projection[["TP12_TC1"]]),
      lower = c(b[[1]][["TP"]][["futility"]], nInf[[2]][["TP"]], b[[1]][["TC"]][["futility"]]),
      upper = c(b[[1]][["TP"]][["efficacy"]], b[[2]][["TP"]][["efficacy"]], pInf[[1]][["TC"]]),
      algorithm = D$mvnorm_algorithm
    )[1]

    P[["TP12E_TC12E"]] <- pmvnorm_(
      mean = as.vector(projection[["TP12_TC12"]] %*% mu_),
      sigma =  projection[["TP12_TC12"]] %*% Sigma %*% t(projection[["TP12_TC12"]]),
      lower = c(b[[1]][["TP"]][["futility"]], b[[2]][["TP"]][["efficacy"]], b[[1]][["TC"]][["futility"]], b[[2]][["TC"]][["efficacy"]]),
      upper = c(b[[1]][["TP"]][["efficacy"]], pInf[[2]][["TP"]], pInf[[1]][["TC"]], pInf[[2]][["TC"]]),
      algorithm = D$mvnorm_algorithm
    )[1]

    P[["TP12E_TC12F"]] <- pmvnorm_(
      mean = as.vector(projection[["TP12_TC12"]] %*% mu_),
      sigma =  projection[["TP12_TC12"]] %*% Sigma %*% t(projection[["TP12_TC12"]]),
      lower = c(b[[1]][["TP"]][["futility"]], b[[2]][["TP"]][["efficacy"]], b[[1]][["TC"]][["futility"]], nInf[[2]][["TC"]]),
      upper = c(b[[1]][["TP"]][["efficacy"]], pInf[[2]][["TP"]], pInf[[1]][["TC"]], b[[2]][["TC"]][["efficacy"]]),
      algorithm = D$mvnorm_algorithm
    )[1]
  } else {
    P[["TP1F"]] <- pmvnorm_(
      mean = as.vector(projection[["TP1"]] %*% mu_),
      sigma =  projection[["TP1"]] %*% Sigma %*% t(projection[["TP1"]]),
      lower = c(nInf[[1]][["TP"]]),
      upper = c(b[[1]][["TP"]][["futility"]]),
      algorithm = D$mvnorm_algorithm
    )[1]

    P[["TP1E_TC1F"]] <- pmvnorm_(
      mean = as.vector(projection[["TP1_TC1"]] %*% mu_),
      sigma =  projection[["TP1_TC1"]] %*% Sigma %*% t(projection[["TP1_TC1"]]),
      lower = c(b[[1]][["TP"]][["efficacy"]], nInf[[1]][["TC"]]),
      upper = c(pInf[[1]][["TP"]], b[[1]][["TC"]][["futility"]]),
      algorithm = D$mvnorm_algorithm
    )[1]

    P[["TP12F"]] <- pmvnorm_(
      mean = as.vector(projection[["TP12"]] %*% mu_),
      sigma =  projection[["TP12"]] %*% Sigma %*% t(projection[["TP12"]]),
      lower = c(b[[1]][["TP"]][["futility"]], nInf[[2]][["TP"]]),
      upper = c(b[[1]][["TP"]][["efficacy"]], b[[2]][["TP"]][["efficacy"]]),
      algorithm = D$mvnorm_algorithm
    )[1]

    P[["TP12E_TC2E"]] <- pmvnorm_(
      mean = as.vector(projection[["TP12_TC2"]] %*% mu_),
      sigma =  projection[["TP12_TC2"]] %*% Sigma %*% t(projection[["TP12_TC2"]]),
      lower = c(b[[1]][["TP"]][["futility"]], b[[2]][["TP"]][["efficacy"]], b[[2]][["TC"]][["efficacy"]]),
      upper = c(b[[1]][["TP"]][["efficacy"]], pInf[[2]][["TP"]], pInf[[2]][["TC"]]),
      algorithm = D$mvnorm_algorithm
    )[1]

    P[["TP12E_TC2F"]] <- pmvnorm_(
      mean = as.vector(projection[["TP12_TC2"]] %*% mu_),
      sigma =  projection[["TP12_TC2"]] %*% Sigma %*% t(projection[["TP12_TC2"]]),
      lower = c(b[[1]][["TP"]][["futility"]], b[[2]][["TP"]][["efficacy"]], nInf[[2]][["TC"]]),
      upper = c(b[[1]][["TP"]][["efficacy"]], pInf[[2]][["TP"]], b[[2]][["TC"]][["efficacy"]]),
      algorithm = D$mvnorm_algorithm
    )[1]
  }
  return(P)
}


#' Helper function to calculate the probability to reject both hypotheses
#' given the mean of the normal test statistic vector c(Z_TP1, Z_TP2, Z_TC1, Z_TC2).
#'
#' @template D
#' @template mu_vec
calc_prob_reject_both <- function(mu_vec, D) {
  Sigma <- D$Sigma
  b <- D$b
  always_both_futility_tests <- D$always_both_futility_tests

  pInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = FALSE)
  pInf <- list(list("TP" = pInf[1], "TC" = pInf[3]), list("TP" = pInf[2], "TC" = pInf[4]))
  nInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = TRUE)
  nInf <- list(list("TP" = nInf[1], "TC" = nInf[3]), list("TP" = nInf[2], "TC" = nInf[4]))

  for (i in seq_len(length(b))){
    for (j in names(b[[i]])){
      for (k in names(b[[i]][[j]])){
        if (b[[i]][[j]][[k]]==Inf)
          b[[i]][[j]][[k]] <- pInf[[i]][[j]]
        if (b[[i]][[j]][[k]]==-Inf)
          b[[i]][[j]][[k]] <- nInf[[i]][[j]]
      }
    }
  }

  P <- list()
  P[["TP1E_TC1E"]] <- pmvnorm_(
    mean = as.vector(projection[["TP1_TC1"]] %*% mu_vec),
    sigma =  projection[["TP1_TC1"]] %*% Sigma %*% t(projection[["TP1_TC1"]]),
    lower = c(b[[1]][["TP"]][["efficacy"]], b[[1]][["TC"]][["efficacy"]]),
    upper = c(pInf[[1]][["TP"]], pInf[[1]][["TC"]]),
    algorithm = D$mvnorm_algorithm
  )[1]

  P[["TP1E_TC12E"]] <- pmvnorm_(
    mean = as.vector(projection[["TP1_TC12"]] %*% mu_vec),
    sigma =  projection[["TP1_TC12"]] %*% Sigma %*% t(projection[["TP1_TC12"]]),
    lower = c(b[[1]][["TP"]][["efficacy"]], b[[1]][["TC"]][["futility"]], b[[2]][["TC"]][["efficacy"]]),
    upper = c(pInf[[1]][["TP"]], b[[1]][["TC"]][["efficacy"]], pInf[[2]][["TC"]]),
    algorithm = D$mvnorm_algorithm
  )[1]

  if (isTRUE(always_both_futility_tests)) {
    P[["TP12E_TC12E"]] <- pmvnorm_(
      mean = as.vector(projection[["TP12_TC12"]] %*% mu_vec),
      sigma =  projection[["TP12_TC12"]] %*% Sigma %*% t(projection[["TP12_TC12"]]),
      lower = c(b[[1]][["TP"]][["futility"]], b[[2]][["TP"]][["efficacy"]], b[[1]][["TC"]][["futility"]], b[[2]][["TC"]][["efficacy"]]),
      upper = c(b[[1]][["TP"]][["efficacy"]], pInf[[2]][["TP"]], pInf[[1]][["TC"]], pInf[[2]][["TC"]]),
      algorithm = D$mvnorm_algorithm
    )[1]
  } else {
    P[["TP12E_TC2E"]] <- pmvnorm_(
      mean = as.vector(projection[["TP12_TC2"]] %*% mu_vec),
      sigma =  projection[["TP12_TC2"]] %*% Sigma %*% t(projection[["TP12_TC2"]]),
      lower = c(b[[1]][["TP"]][["futility"]], b[[2]][["TP"]][["efficacy"]], b[[2]][["TC"]][["efficacy"]]),
      upper = c(b[[1]][["TP"]][["efficacy"]], pInf[[2]][["TP"]], pInf[[2]][["TC"]]),
      algorithm = D$mvnorm_algorithm
    )[1]
  }
  return(sum(unlist(P)))
}

#' Helper function to calculate the probability to reject both hypotheses
#' given the mean of the normal test statistic vector c(Z_TP1, Z_TC1).
#'
#' @template D
#' @template mu_vec
calc_prob_reject_both_singlestage <- function(mu_vec, D) {
  pInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail =  FALSE)
  pInf <- list(list("TP" = pInf[1], "TC" = pInf[2]))
  nInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = TRUE)
  nInf <- list(list("TP" = nInf[1], "TC" = nInf[2]))
  pmvnorm_(
    mean = as.vector(mu_vec),
    sigma = D$Sigma,
    lower = c(D$b[[1]][["TP"]][["efficacy"]], D$b[[1]][["TC"]][["efficacy"]]),
    upper = c(pInf[[1]][["TP"]], pInf[[1]][["TC"]]),
    algorithm = D$mvnorm_algorithm
  )[1]
}


#' Helper function to calculate the local type I error rates of a Design
#'
#' @template D
#' @importFrom stats qnorm
calc_local_alphas <- function(D){
  mu_vec <- c(0,0,0,0)
  b <- D$b
  Sigma <- D$Sigma
  pInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = FALSE)
  pInf <- list(list("TP" = pInf[1], "TC" = pInf[3]), list("TP" = pInf[2], "TC" = pInf[4]))
  nInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = TRUE)
  nInf <- list(list("TP" = nInf[1], "TC" = nInf[3]), list("TP" = nInf[2], "TC" = nInf[4]))
  for (i in seq_len(length(b))){
    for (j in names(b[[i]])){
      for (k in names(b[[i]][[j]])){
        if (!is.na(b[[i]][[j]][[k]])){
          if (b[[i]][[j]][[k]]==Inf)
            b[[i]][[j]][[k]] <- pInf[[i]][[j]]
          if (b[[i]][[j]][[k]]==-Inf)
            b[[i]][[j]][[k]] <- nInf[[i]][[j]]
        }
      }
    }
  }
  P <- list()
  for (groups in c("TP", "TC")){
    P[[paste0(groups, "1E")]] <- pmvnorm_(
      mean = as.vector(projection[[paste0(groups, "1")]] %*% mu_vec),
      sigma = projection[[paste0(groups, "1")]] %*% Sigma %*% t(projection[[paste0(groups, "1")]]),
      lower = b[[1]][[groups]][["efficacy"]],
      upper = pInf[[1]][[groups]],
      algorithm = D$mvnorm_algorithm
    )[1]
    P[[paste0(groups, "12E")]] <- pmvnorm_(
      mean = as.vector(projection[[paste0(groups, "12")]] %*% mu_vec),
      sigma =  projection[[paste0(groups, "12")]] %*% Sigma %*% t(projection[[paste0(groups, "12")]]),
      lower = c(b[[1]][[groups]][["futility"]], b[[2]][[groups]][["efficacy"]]),
      upper = c(b[[1]][[groups]][["efficacy"]], pInf[[1]][[groups]]),
      algorithm = D$mvnorm_algorithm
    )[1]
  }
  alphas <- numeric(2)
  names(alphas) <- c("TP", "TC")
  alphas[[1]] <- P[["TP1E"]] + P[["TP12E"]]
  alphas[[2]] <- P[["TC1E"]] + P[["TC12E"]]
  return(alphas)
}

#' Helper function to calculate the local rejection boundaries of group sequential testing
#' procedure associated with the hypothesis belong to the groups argument
#'
#' @template groups
#' @template D
#' @importFrom stats qnorm
calc_local_rejection_boundaries <- function(groups = "TP", D) {
  mu_vec <- c(0, 0, 0, 0)
  b <- D$b
  if (!D$binding_futility){
    b[[1]][["TP"]][["futility"]] <- -Inf
    b[[1]][["TC"]][["futility"]] <- -Inf
  }

  pInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = FALSE)
  pInf <- list(list("TP" = pInf[1], "TC" = pInf[3]), list("TP" = pInf[2], "TC" = pInf[4]))
  nInf <- qnorm(.Machine$double.eps, mean = mu_vec, lower.tail = TRUE)
  nInf <- list(list("TP" = nInf[1], "TC" = nInf[3]), list("TP" = nInf[2], "TC" = nInf[4]))

  for (i in seq_len(length(b))){
    for (j in names(b[[i]])){
      for (k in names(b[[i]][[j]])){
        if (!is.na(b[[i]][[j]][[k]])){
          if (b[[i]][[j]][[k]]==Inf)
            b[[i]][[j]][[k]] <- pInf[[i]][[j]]
          if (b[[i]][[j]][[k]]==-Inf)
            b[[i]][[j]][[k]] <- nInf[[i]][[j]]
        }
      }
    }
  }

  P <- list()
  P[[paste0(groups, "1E")]] <- pmvnorm_(
    mean = as.vector(projection[[paste0(groups, "1")]] %*% mu_vec),
    sigma = projection[[paste0(groups, "1")]] %*% D$Sigma %*% t(projection[[paste0(groups, "1")]]),
    lower = b[[1]][[groups]][["efficacy"]],
    upper = pInf[[1]][[groups]],
    algorithm = D$mvnorm_algorithm
  )[1]
  sgn_low <- sign(pmvnorm_(
    mean = as.vector(projection[[paste0(groups, "12")]] %*% mu_vec),
    sigma =  projection[[paste0(groups, "12")]] %*% D$Sigma %*% t(projection[[paste0(groups, "12")]]),
    lower = c(b[[1]][[groups]][["futility"]], qnorm(1 - D$type_I_error)),
    upper = c(b[[1]][[groups]][["efficacy"]], pInf[[1]][[groups]]),
    algorithm = D$mvnorm_algorithm
  )[1] + P[[paste0(groups, "1E")]] - D$type_I_error)
  sgn_high <- sign(pmvnorm_(
    mean = as.vector(projection[[paste0(groups, "12")]] %*% mu_vec),
    sigma =  projection[[paste0(groups, "12")]] %*% D$Sigma %*% t(projection[[paste0(groups, "12")]]),
    lower = c(b[[1]][[groups]][["futility"]], qnorm(.Machine$double.eps, lower.tail = FALSE)),
    upper = c(b[[1]][[groups]][["efficacy"]], pInf[[1]][[groups]]),
    algorithm = D$mvnorm_algorithm
  )[1] + P[[paste0(groups, "1E")]] - D$type_I_error)

  if (sgn_high >= -D$inner_tol_objective / 3) {
    b2 <- list()
    b2$root <- Inf
  } else if (sgn_low <= D$inner_tol_objective / 3) {
    b2 <- list()
    b2$root <- qnorm(1 - D$type_I_error)
  } else {
    b2 <- uniroot(
      function(x) {
        pmvnorm_(
          mean = as.vector(projection[[paste0(groups, "12")]] %*% mu_vec),
          sigma =  projection[[paste0(groups, "12")]] %*% D$Sigma %*% t(projection[[paste0(groups, "12")]]),
          lower = c(b[[1]][[groups]][["futility"]], x),
          upper = c(b[[1]][[groups]][["efficacy"]], pInf[[1]][[groups]]),
          algorithm = D$mvnorm_algorithm
        )[1] + P[[paste0(groups, "1E")]] - D$type_I_error
      },
      c(qnorm(1 - D$type_I_error), qnorm(.Machine$double.eps, lower.tail = FALSE)),
      tol = D$inner_tol_objective / 3, extendInt = "downX"
    )
  }
  b[[2]][[groups]][["efficacy"]] <- b2$root
  P[[paste0(groups, "12E")]] <- pmvnorm_(
    mean = as.vector(projection[[paste0(groups, "12")]] %*% mu_vec),
    sigma =  projection[[paste0(groups, "12")]] %*% D$Sigma %*% t(projection[[paste0(groups, "12")]]),
    lower = c(b[[1]][[groups]][["futility"]], b[[2]][[groups]][["efficacy"]]),
    upper = c(b[[1]][[groups]][["efficacy"]], pInf[[1]][[groups]]),
    algorithm = D$mvnorm_algorithm
  )[1]

  return(list(
    root = b2$root,
    alpha = sum(c(P[[paste0(groups, "1E")]], P[[paste0(groups, "12E")]]))
  ))
}

#' Helper function to calculate the required sample size (of the stage 1 treatment group)
#' to achieve the target power given the bTC2e
#'
#' @template bTC2e
#' @template D
#' @importFrom mvtnorm qmvnorm
#' @importFrom stats uniroot
calc_nT1_wrt_bTC2e <- function(bTC2e, D) {
  D$b[[2]][["TC"]][["efficacy"]] <- bTC2e
  D$inner_tol_objective <- D$inner_tol_objective * 3 / 4

  if (1 - calc_prob_reject_both(D$mu_wo_nT1[["H1"]] * 1, D) - D$type_II_error <= D$inner_tol_objective / 3) {
    return(1)
  } else {
    # This trick calculates (-) the sqrt of the sample size required for a power of 1-D$type_II_error to reject in the first stage.
    # This gives an upper bound on the total sample size required for a power of 1-D$type_II_error.
    sqrtn <- qmvnorm(1 - D$type_II_error,
                     mean = -as.vector(diag(1 / D$mu_wo_nT1[["H1"]][c(1, 3)]) %*% c(D$b[[1]][["TP"]][["efficacy"]], D$b[[1]][["TC"]][["efficacy"]])),
                     var = diag(1 / D$mu_wo_nT1[["H1"]][c(1, 3)]) %*%
                       (projection[["TP1_TC1"]] %*% D$Sigma %*% t(projection[["TP1_TC1"]])) %*% diag(1 / D$mu_wo_nT1[["H1"]][c(1, 3)]),
                     tail = "upper.tail"
    )$quantile

    return(uniroot(function(nT1, D) 1 - calc_prob_reject_both(D$mu_wo_nT1[["H1"]] * sqrt(nT1), D) - D$type_II_error,
                   c(1, sqrtn^2),
                   tol = D$inner_tol_objective / 3,
                   extendInt = "downX",
                   D = D
    )$root)
  }
}

#' Helper function to calculate the maximal probability of rejecting the non-inferiority hypothesis
#' in the testing procedure featuring nonsequential futility, given a point hypothesis for
#' the superiority hypothesis.
#'
#' This is required in designs with nonsequential futility testing, as choosing locally valid designs
#' is insufficient to gurantee type I error control.
#'
#' @template bTC2e
#' @template D
#' @importFrom stats optimize
calc_worst_type_I_error <- function(bTC2e, D) {
  sqrt_nT1 <- sqrt(calc_nT1_wrt_bTC2e(bTC2e, D))
  nT1_div_gamma <- sqrt_nT1 / c(D$gamma[[1]][["TP"]], D$gamma[[2]][["TP"]])
  D$b[[2]][["TC"]]["efficacy"] <- bTC2e

  calc_alpha_wrt_muH0T <- function(muH0TP, D) {
    return(vapply(muH0TP, function(x, D){
      mu_vec <- c(x * nT1_div_gamma, 0, 0)
      calc_prob_reject_both(mu_vec, D)
    }, numeric(1), D = D))
  }

  D$inner_tol_objective <- D$inner_tol_objective * 3 / 5
  optimum <- optimize(calc_alpha_wrt_muH0T, c(0, qnorm(.Machine$double.eps, lower.tail = FALSE) / min(nT1_div_gamma)),
                      maximum = TRUE, D = D,
                      tol = D$inner_tol_objective / 3
  )
  return(optimum$objective)
}

#' Helper function to calculate the average sample size
#'
#' @template D
calc_ASN <- function(D) {
  n <- D$n
  always_both_futility_tests <- D$always_both_futility_tests
  ASN <- list()
  for (hyp in c("H00", "H11", "H10", "H01")){
    P <- D$final_state_probs[[hyp]]

    if (isTRUE(always_both_futility_tests)) {
      ASN[[hyp]] <- (P[["TP1E_TC1E"]] + P[["TP1F_TC1F"]]) * (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]]) +
        (P[["TP1E_TC12E"]] + P[["TP1E_TC12F"]]) * (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]] + n[[2]][["T"]] + n[[2]][["C"]]) +
        (P[["TP12F_TC1"]] + P[["TP12E_TC12E"]] + P[["TP12E_TC12F"]]) *
        (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]] + n[[2]][["T"]] + n[[2]][["P"]] + n[[2]][["C"]])
    } else {
      ASN[[hyp]] <- (P[["TP1E_TC1E"]] + P[["TP1E_TC1F"]] + P[["TP1F"]]) * (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]]) +
        (P[["TP1E_TC12E"]] + P[["TP1E_TC12F"]]) * (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]] + n[[2]][["T"]] + n[[2]][["C"]]) +
        (P[["TP12F"]] + P[["TP12E_TC2E"]] + P[["TP12E_TC2F"]]) *
        (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]] + n[[2]][["T"]] + n[[2]][["P"]] + n[[2]][["C"]])
    }
  }
  ASN[["H0"]] <- ASN[["H00"]]
  ASN[["H1"]] <- ASN[["H11"]]
  return(ASN)
}

#' Calculate the average placebo group sample size
#'
#' @template D
calc_ASNP <- function(D) {
  n <- D$n
  always_both_futility_tests <- D$always_both_futility_tests
  ASNP <- list()
  for (hyp in c("H00", "H11", "H10", "H01")){
    P <- D$final_state_probs[[hyp]]
    if (isTRUE(always_both_futility_tests)) {
      ASNP[[hyp]] <- (P[["TP1E_TC1E"]] + P[["TP1F_TC1F"]]) * (n[[1]][["P"]]) +
        (P[["TP1E_TC12E"]] + P[["TP1E_TC12F"]]) * (n[[1]][["P"]]) +
        (P[["TP12F_TC1"]] + P[["TP12E_TC12E"]] + P[["TP12E_TC12F"]]) * (n[[1]][["P"]] + n[[2]][["P"]])
    } else {
      ASNP[[hyp]] <- (P[["TP1E_TC1E"]] + P[["TP1E_TC1F"]] + P[["TP1F"]]) * (n[[1]][["P"]]) +
        (P[["TP1E_TC12E"]] + P[["TP1E_TC12F"]]) * (n[[1]][["P"]]) +
        (P[["TP12F"]] + P[["TP12E_TC2E"]] + P[["TP12E_TC2F"]]) * (n[[1]][["P"]] + n[[2]][["P"]])
    }
  }
  ASNP[["H0"]] <- ASNP[["H00"]]
  ASNP[["H1"]] <- ASNP[["H11"]]
  return(ASNP)
}
