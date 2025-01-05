skip_on_cran()
# skip_if(.skip_slow_test, "Slow test skipped.")
D <- optimize_design_twostage(print_progress = FALSE,
                              binding_futility = TRUE)
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

