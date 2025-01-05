#' Objective function for two-stage gold-standard designs
#'
#' @template D
#' @include design_helper_functions.R
objective_twostage <- function(D)
{
  # this make cran check shut up.
  alpha_TC <- NA_real_

  # Quote this because might need reevaluation when D$round_n == TRUE
  # Sets D$cumc, D$gamma, D$Sigma, D$mu_wo_nT1, D$b
  get_boundaries <- quote({

  # Calculate covariance matrix Sigma
  D$cumc <- calc_cumc(D)
  D$gamma <- calc_gamma(D)
  D$Sigma <- calc_Sigma(D)
  D$mu_wo_nT1 <- calc_mu_wo_nT1(D)

  # calculate b2TPefficacy boundary using the other predefined parameters
  # (This is the first implicit parameter)
  TP_local <- calc_local_rejection_boundaries("TP", D)
  alpha_TP <- TP_local$alpha
  D$b[[2]][["TP"]][["efficacy"]] <- TP_local$root

  # calculate bTC2e boundary using the other predefined parameters
  # (This is the second implicit parameter)
  TC_local_lower <- calc_local_rejection_boundaries("TC", D)

  if (D$always_both_futility_tests || !D$binding_futility){
    alpha_TC <- TC_local_lower$alpha
    D$b[[2]][["TC"]][["efficacy"]] <- TC_local_lower$root
  } else{
    b2TC_lower_bound <- TC_local_lower$root
    max_ss_lb <- sum(unlist(
      calc_n_from_c(
        calc_nT1_wrt_bTC2e(b2TC_lower_bound, D), D
      )
    ))

    D_upper_bound <- D
    D_upper_bound$b[[1]][["TC"]][["futility"]] <- -Inf
    TC_local_upper <- calc_local_rejection_boundaries("TC", D_upper_bound)
    b2TC_upper_bound <- TC_local_upper$root
    max_ss_ub <- sum(unlist(
      calc_n_from_c(
        calc_nT1_wrt_bTC2e(b2TC_upper_bound, D), D
      )
    ))

    b2TC_boundary_description <- ""
    if (max_ss_ub - max_ss_lb < 1) {
      best_boundary <- list(root = b2TC_upper_bound, f.root = calc_worst_type_I_error(b2TC_upper_bound, D) - D$type_I_error)
      b2TC_boundary_description <- "boundary reduction not worth it"
    } else
      if ((lb_val <- calc_worst_type_I_error(b2TC_lower_bound, D)) - D$type_I_error <= D$inner_tol_objective / 5) {
        b2TC_boundary_description <- "lower boundary used"
        best_boundary <- list(root = b2TC_lower_bound, f.root = lb_val - D$type_I_error)
      } else if ((ub_val <- calc_worst_type_I_error(b2TC_upper_bound, D)) - D$type_I_error >= -D$inner_tol_objective / 5) {
        b2TC_boundary_description <- "upper boundary used"
        best_boundary <- list(root = b2TC_upper_bound, f.root = ub_val - D$type_I_error)
      } else {
        b2TC_boundary_description <- "optimal boundary used"
        best_boundary <- uniroot(function(x) calc_worst_type_I_error(x, D) - D$type_I_error,
                                 c(b2TC_lower_bound, b2TC_upper_bound),
                                 f.lower = lb_val, f.upper = ub_val,
                                 extendInt = "yes", tol = D$inner_tol_objective / 5
        )
      }

    D$b2TC_boundary_description <- b2TC_boundary_description
    D$b[[2]][["TC"]][["efficacy"]] <- best_boundary$root
    alpha_TC <- sum(best_boundary$f.root + D$type_I_error)
  }
  })
  eval(get_boundaries)

  # Calculate Design parameters, now that the implicit parameters are fixed
  nT1 <- calc_nT1_wrt_bTC2e(D$b[[2]][["TC"]][["efficacy"]], D)
  D$n <- calc_n_from_c(nT1, D)

  # Recalculate design parameters if rounding is requested
  if (D$round_n){
    D$n[[1]] <- lapply(D$n[[1]], ceiling)
    D$n[[2]] <- lapply(D$n[[2]], ceiling)
    D$c <- calc_c(D)
    eval(get_boundaries)
  }
  n <- D$n

  D$cumn <- cumn <- calc_cumn(D)
  D$mu_vec <- calc_mu_vec(D)

  final_state_probs <- list()
  for (hyp in c("H00", "H11", "H10", "H01")) {
    final_state_probs[[hyp]] <- calc_final_state_probs(hyp, D)
  }
  final_state_probs[["H0"]] <- final_state_probs[["H00"]]
  final_state_probs[["H1"]] <- final_state_probs[["H11"]]
  D$final_state_probs <- final_state_probs
  D$ASN <- ASN <- calc_ASN(D)
  D$ASNP <- ASNP <- calc_ASNP(D)
  lambda <- D$lambda
  kappa <- D$kappa
  eta <- D$eta

  D$objective_val <- eval(D$objective)

  if (D$return_everything) {
    D$invnormal_weights_TP <- c(D$Sigma[1,2], sqrt(1-D$Sigma[1,2]^2))
    D$invnormal_weights_TC <- c(D$Sigma[3,4], sqrt(1-D$Sigma[3,4]^2))
    D$power <- calc_prob_reject_both(D$mu_vec[["H1"]], D)
    D$futility_prob <- list()
    if (D$always_both_futility_tests){
      for (hyp in c("H0", "H1")){
        D$futility_prob[[hyp]] <- D$final_state_probs[[hyp]][["TP1F_TC1F"]]
      }
    } else{
      D$max_alpha_TC <- alpha_TC
      for (hyp in c("H0", "H1")){
        D$futility_prob[[hyp]] <- D$final_state_probs[[hyp]][["TP1F"]] + D$final_state_probs[[hyp]][["TP1E_TC1F"]]
      }
    }
    D$local_alphas <- calc_local_alphas(D)
    D$cp_min <-
      calc_conditional_power(D$b[[1]][["TP"]][["futility"]] + .Machine$double.eps,
                             D$b[[1]][["TC"]][["futility"]] + .Machine$double.eps,
                             D)
    return(D)
  } else {
    return(D$objective_val)
  }
}

#' Objective function for single-stage gold-standard designs
#'
#' @template D
#' @importFrom stats qnorm uniroot
objective_onestage <-
  function(D) {
    calc_params <- quote({
    # Calculate covariance matrix Sigma
    gamma <- list()
    gamma[[1]] <- list()
    for (g in c("P", "C")) {
      for (s in 1:(length(D$stagec))) {
        gamma[[s]][[paste0("T", g)]] <- sqrt(D$var[["T"]] / D$stagec[[s]][["T"]] + D$var[[g]] / D$stagec[[s]][[g]])
      }
    }
    D$gamma <- gamma

    Sigma <- matrix(0, ncol = 2, nrow = 2)
    Sigma[1, ] <-
      c(
        1,
        D$var[["T"]] / (D$stagec[[1]][["T"]] * gamma[[1]][["TP"]] * gamma[[1]][["TC"]])
      )
    Sigma[2, 2] <- 1
    Sigma[lower.tri(Sigma, diag = T)] <-
      t(Sigma)[lower.tri(Sigma, diag = T)]
    D$Sigma <- Sigma

    D$mu_wo_nT1 <- list()
    for (hyp in c("H0", "H1")){
      D$mu_wo_nT1[[hyp]] <- c(
        D$mu[[hyp]][["TP"]] / D$gamma[[1]][["TP"]],
        D$mu[[hyp]][["TC"]] / D$gamma[[1]][["TC"]]
      )
    }
    })
    eval(calc_params)

    if (1 - calc_prob_reject_both_singlestage(D$mu_wo_nT1[["H1"]] * 1, D) - D$type_II_error <= D$inner_tol_objective / 2) {
      beta_sol <- (list(root = 1, f.root = calc_prob_reject_both_singlestage(D$mu_wo_nT1[["H1"]] * 1, D) - D$type_II_error))
    } else {
      beta_sol <- (uniroot(
        function(nT1, D)
          1 - calc_prob_reject_both_singlestage(D$mu_wo_nT1[["H1"]] * sqrt(nT1), D) - D$type_II_error,
        c(1, 10000),
        tol = D$inner_tol_objective / 2,
        extendInt = "downX",
        D = D
      ))
    }

    if(D$round_n){
      nT <- ceiling(beta_sol$root)
      n <- list()
      n[[1]] <- list()
      n[[1]][["T"]] <- nT
      n[[1]][["P"]] <- ceiling(nT * D$stagec[[1]][["P"]])
      n[[1]][["C"]] <- ceiling(nT * D$stagec[[1]][["C"]])
      D$stagec[[1]][["P"]] <-  n[[1]][["P"]] / n[[1]][["T"]]
      D$stagec[[1]][["C"]] <-  n[[1]][["C"]] / n[[1]][["T"]]
      eval(calc_params)
    } else {
      nT <- beta_sol$root
      n <- list()
      n[[1]] <- list()
      n[[1]][["T"]] <- nT
      n[[1]][["P"]] <- nT * D$stagec[[1]][["P"]]
      n[[1]][["C"]] <- nT * D$stagec[[1]][["C"]]
    }

    D$n <- n
    sqrt_nT <- sqrt(nT)
    D$mu_vec <- list()
    for (hyp in c("H0", "H1")){
      D$mu_vec[[hyp]] <- sqrt_nT * D$mu_wo_nT1[[hyp]]
    }

    final_state_probs <- list()
    ASN <- list()
    ASNP <- list()

    for (hyp in c("H0", "H1")) {
      pInf <- qnorm(.Machine$double.eps, mean = D$mu_vec[[hyp]], lower.tail = FALSE)
      pInf <- list(list("TP" = pInf[1], "TC" = pInf[2]))
      nInf <- qnorm(.Machine$double.eps, mean = D$mu_vec[[hyp]], lower.tail = TRUE)
      nInf <- list(list("TP" = nInf[1], "TC" = nInf[2]))

      P <- list()
      P[["TP1E_TC1E"]] <- pmvnorm_(
        mean = as.vector(D$mu_vec[[hyp]]),
        sigma = D$Sigma,
        lower = c(D$b[[1]][["TP"]][["efficacy"]], D$b[[1]][["TC"]][["efficacy"]]),
        upper = c(pInf[[1]][["TP"]], pInf[[1]][["TC"]]),
        algorithm = D$mvnorm_algorithm
      )[1]

      P[["TP1F"]] <- pmvnorm_(
        mean = as.vector(D$mu_vec[[hyp]])[1],
        sigma = D$Sigma[1, 1],
        lower = c(nInf[[1]][["TP"]]),
        upper = c(D$b[[1]][["TP"]][["efficacy"]]),
        algorithm = D$mvnorm_algorithm
      )[1]

      P[["TP1E_TC1F"]] <- pmvnorm_(
        mean = as.vector(D$mu_vec[[hyp]]),
        sigma = D$Sigma,
        lower = c(D$b[[1]][["TP"]][["efficacy"]], nInf[[1]][["TC"]]),
        upper = c(pInf[[1]][["TP"]], D$b[[1]][["TC"]][["efficacy"]]),
        algorithm = D$mvnorm_algorithm
      )[1]
      final_state_probs[[hyp]] <- P
      ASN[[hyp]] <- sum(unlist(D$n))
      ASNP[[hyp]] <- D$n[[1]][["P"]]
    }
    D$ASN <- ASN
    D$ASNP <- ASNP
    D$final_state_probs <- final_state_probs
    kappa <- D$kappa

    D$objective_val <- eval(D$objective)

    if (D$return_everything) {
      D$power <- calc_prob_reject_both_singlestage(D$mu_wo_nT1[["H1"]] * sqrt(nT), D)
      return(D)
    } else {
      return(D$objective_val)
    }
  }
