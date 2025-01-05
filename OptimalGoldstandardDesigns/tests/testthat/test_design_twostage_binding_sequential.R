skip_on_cran()
# skip_if(.skip_slow_test, "Slow test skipped.")
D <- optimize_design_twostage(
  always_both_futility_tests = FALSE,
  binding_futility = TRUE,
  print_progress = FALSE)

test_that(
  "Test that final state probabilities sum to 1.",
  {
    expect_equal(D$final_state_probs |> sapply(\(x)sum(unlist(x))),
                 rep(1, 6),
                 ignore_attr = TRUE, tolerance = 1e-5)
  })

test_that(
  "Local type I error is controlled.",
  {
    set.seed(123)
    p1 <- pnorm(D$b[[1]][["TP"]][["efficacy"]], lower.tail = FALSE)
    p2 <- pmvnorm(
      lower = c(D$b[[1]][["TP"]][["futility"]], D$b[[2]][["TP"]][["efficacy"]]),
      upper = c(D$b[[1]][["TP"]][["efficacy"]], qnorm(.Machine$double.eps, lower.tail = FALSE)),
      mean = c(0,0),
      sigma = D$Sigma[1:2, 1:2]
    )[1]
    expect_lt(p1 + p2, D$type_I_error + 20*.Machine$double.eps)
    p3 <- pnorm(D$b[[1]][["TC"]][["efficacy"]], lower.tail = FALSE)
    p4 <- pmvnorm(
      lower = c(D$b[[1]][["TC"]][["futility"]], D$b[[2]][["TC"]][["efficacy"]]),
      upper = c(D$b[[1]][["TC"]][["efficacy"]], qnorm(.Machine$double.eps, lower.tail = FALSE)),
      mean = c(0,0),
      sigma = D$Sigma[3:4, 3:4]
    )[1]
    expect_lt(p3 + p4, D$type_I_error + 20*.Machine$double.eps)
  })

calc_prob_reject_both_sequential_testing <- function(mu_vec, D) {
  Sigma <- D$Sigma
  b <- D$b
  P <- list()
  P[["TP1E_TC1E"]] <- pmvnorm(
    mean = as.vector(projection[["TP1_TC1"]] %*% mu_vec),
    sigma =  projection[["TP1_TC1"]] %*% Sigma %*% t(projection[["TP1_TC1"]]),
    lower = c(b[[1]][["TP"]][["efficacy"]], b[[1]][["TC"]][["efficacy"]]),
    upper = c(Inf, Inf),
  )[1]
  P[["TP1E_TC12E"]] <- pmvnorm(
    mean = as.vector(projection[["TP1_TC12"]] %*% mu_vec),
    sigma =  projection[["TP1_TC12"]] %*% Sigma %*% t(projection[["TP1_TC12"]]),
    lower = c(b[[1]][["TP"]][["efficacy"]], b[[1]][["TC"]][["futility"]], b[[2]][["TC"]][["efficacy"]]),
    upper = c(Inf, b[[1]][["TC"]][["efficacy"]], Inf)
  )[1]
  P[["TP12E_TC2E"]] <- pmvnorm(
    mean = as.vector(projection[["TP12_TC2"]] %*% mu_vec),
    sigma =  projection[["TP12_TC2"]] %*% Sigma %*% t(projection[["TP12_TC2"]]),
    lower = c(b[[1]][["TP"]][["futility"]], b[[2]][["TP"]][["efficacy"]], b[[2]][["TC"]][["efficacy"]]),
    upper = c(b[[1]][["TP"]][["efficacy"]], Inf, Inf)
  )[1]
  return(sum(unlist(P)))
}

calc_type_I_error_vec <- function(D) {
  sqrt_nT1 <- sqrt(D$n[[1]][["T"]])
  nT1_div_gamma <- sqrt_nT1 / c(D$gamma[[1]][["TP"]], D$gamma[[2]][["TP"]])
  l <- lapply(seq(from = -1, to = 5, by = .001), function(x)x*c(nT1_div_gamma, 0,0))
  return(unlist(lapply(l, calc_prob_reject_both_sequential_testing, D)))
}

test_that(
  "Maximum type I error is controlled.",
  {
    set.seed(123)
    v <- calc_type_I_error_vec(D)
    for (a in v){
     expect_lt(a, D$type_I_error + 1e-5)
    }
  }
  )


D_bad <- optimize_design_twostage(
  bTC1f = 1.5,
  always_both_futility_tests = TRUE,
  binding_futility = TRUE,
  print_progress = FALSE)

test_that(
  "Maximum type I error is inflated if sequential testing is employed in a design optimized under the assumption
that both futility tests are employed.",
  {
    set.seed(123)
    v <- calc_type_I_error_vec(D_bad)
    expect_true(any(v > D_bad$type_I_error + 1e-4))
  })


