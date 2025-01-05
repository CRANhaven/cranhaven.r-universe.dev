test_that(
  "calc_cumn works.",
  {
    n <- list(list("T" = 10, "P" = 20, "C" = 30),
              list("T" = 40, "P" = 50, "C" = 60))
    D <- list(n = n)
    reference <- list(list("T" = 10, "P" = 20, "C" = 30),
                      list("T" = 50, "P" = 70, "C" = 90))
    expect_identical(calc_cumn(D), reference)
  })
test_that(
  "calc_cumc works.",
  {
    stagec <- list(list("T" = 1, "P" = 2, "C" = 3),
              list("T" = 4, "P" = 5, "C" = 6))
    D <- list(stagec = stagec)
    reference <- list(list("T" = 1, "P" = 2, "C" = 3),
                      list("T" = 5, "P" = 7, "C" = 9))
    expect_identical(calc_cumc(D), reference)
  })
test_that(
  "calc_n_from_c works.",
  {
    nT1 <- 10
    stagec <- list(list("T" = 1, "P" = 2, "C" = 3),
                   list("T" = 4, "P" = 5, "C" = 6))
    D <- list(stagec = stagec)
    reference <- list(list("T" = 10, "P" = 20, "C" = 30),
                      list("T" = 40, "P" = 50, "C" = 60))
    expect_identical(calc_n_from_c(nT1, D), reference)
  })
test_that(
  "calc_c works.",
  {
    n <- list(list("T" = 10, "P" = 20, "C" = 30),
              list("T" = 40, "P" = 50, "C" = 60))
    D <- list(n = n)
    reference <- list(list("T" = 1, "P" = 2, "C" = 3),
                      list("T" = 4, "P" = 5, "C" = 6))
    expect_identical(calc_c(D), reference)
  })
test_that(
  "calc_gamma works.",
  {
    var <- list("T" = 1, "P" = 2, "C" = 3)
    cumc <- list(list("T" = 1, "P" = 2, "C" = 3),
                   list("T" = 4, "P" = 5, "C" = 6))
    D <- list(var = var, cumc = cumc)
    reference <- list(list("TP" = sqrt(2), "TC" = sqrt(2)),
                      list("TP" = sqrt(1/4 + 2/5), "TC" = sqrt(1/4 + 3/6)))
    expect_identical(calc_gamma(D), reference)
  })

test_that(
  "Covariance matrix calculation is correct and works as expected.",
  {
    skip_on_cran()
    # skip_if(.skip_slow_test, "Slow test skipped.")
    set.seed(123)
    D <- list()
    D$n <- list()
    D$n[[2]] <- list()
    D$n[[1]][["T"]] <- rpois(1, 7)
    D$n[[1]][["P"]] <- rpois(1, 7)
    D$n[[1]][["C"]] <- rpois(1, 7)
    D$n[[2]][["T"]] <- rpois(1, 7)
    D$n[[2]][["P"]] <- rpois(1, 7)
    D$n[[2]][["C"]] <- rpois(1, 7)
    D$var[["T"]] <- runif(1)
    D$var[["P"]] <- runif(1)
    D$var[["C"]] <- runif(1)

    # Calculate covariance matrix Sigma
    D$stagec <- calc_c(D)
    D$cumc <- calc_cumc(D)
    D$cumn <- calc_cumn(D)
    D$gamma <- calc_gamma(D)
    D$Sigma <- calc_Sigma(D)
    D$alternative_TP <- 3
    D$alternative_TC <- 2
    D$Delta <- 1

    nsim <- 10000000
    sd_TP1 <- sqrt(D$var[["T"]] / D$n[[1]][["T"]]  + D$var[["P"]] / D$n[[1]][["P"]])
    sd_TP2 <- sqrt(D$var[["T"]] / D$n[[2]][["T"]]  + D$var[["P"]] / D$n[[2]][["P"]])
    sd_TC1 <- sqrt(D$var[["T"]] / D$n[[1]][["T"]]  + D$var[["C"]] / D$n[[1]][["C"]])
    sd_TC2 <- sqrt(D$var[["T"]] / D$n[[2]][["T"]]  + D$var[["C"]] / D$n[[2]][["C"]])

    sample1_T1 <- rnorm(nsim, 0, sqrt(D$var[["T"]] / D$n[[1]][["T"]]))
    sample1_T2 <- rnorm(nsim, 0, sqrt(D$var[["T"]] / D$n[[2]][["T"]]))
    sample1_P1 <- rnorm(nsim, 0, sqrt(D$var[["P"]] / D$n[[1]][["P"]]))
    sample1_P2 <- rnorm(nsim, 0, sqrt(D$var[["P"]] / D$n[[2]][["P"]]))
    sample1_C1 <- rnorm(nsim, 0, sqrt(D$var[["C"]] / D$n[[1]][["C"]]))
    sample1_C2 <- rnorm(nsim, 0, sqrt(D$var[["C"]] / D$n[[2]][["C"]]))

    sample1_TP1 <-  sample1_T1 - sample1_P1
    sample1_TP2 <-
      sample1_T1 * D$n[[1]][["T"]]/D$cumn[[2]][["T"]] +
      sample1_T2 * D$n[[2]][["T"]]/D$cumn[[2]][["T"]] -
      sample1_P1 * D$n[[1]][["P"]]/D$cumn[[2]][["P"]] -
      sample1_P2 * D$n[[2]][["P"]]/D$cumn[[2]][["P"]]
    sample1_TC1 <-  sample1_T1 - sample1_C1
    sample1_TC2 <-
      sample1_T1 * D$n[[1]][["T"]]/D$cumn[[2]][["T"]] +
      sample1_T2 * D$n[[2]][["T"]]/D$cumn[[2]][["T"]] -
      sample1_C1 * D$n[[1]][["C"]]/D$cumn[[2]][["C"]] -
      sample1_C2 * D$n[[2]][["C"]]/D$cumn[[2]][["C"]]

    sample1_Z_TP1 <- sample1_TP1 / sd_TP1
    sample1_Z_TP2 <- sample1_TP2 / sqrt(
     D$var[["T"]] / D$n[[1]][["T"]] * (D$n[[1]][["T"]]/D$cumn[[2]][["T"]])^2 +
     D$var[["T"]] / D$n[[2]][["T"]] * (D$n[[2]][["T"]]/D$cumn[[2]][["T"]])^2 +
     D$var[["P"]] / D$n[[1]][["P"]] * (D$n[[1]][["P"]]/D$cumn[[2]][["P"]])^2 +
     D$var[["P"]] / D$n[[2]][["P"]] * (D$n[[2]][["P"]]/D$cumn[[2]][["P"]])^2
      )
    sample1_Z_TC1 <- sample1_TC1 / sd_TC1
    sample1_Z_TC2 <- sample1_TC2 / sqrt(
      D$var[["T"]] / D$n[[1]][["T"]] * (D$n[[1]][["T"]]/D$cumn[[2]][["T"]])^2 +
        D$var[["T"]] / D$n[[2]][["T"]] * (D$n[[2]][["T"]]/D$cumn[[2]][["T"]])^2 +
        D$var[["C"]] / D$n[[1]][["C"]] * (D$n[[1]][["C"]]/D$cumn[[2]][["C"]])^2 +
        D$var[["C"]] / D$n[[2]][["C"]] * (D$n[[2]][["C"]]/D$cumn[[2]][["C"]])^2
    )

    expect_equal(cov(data.frame(sample1_Z_TP1, sample1_Z_TP2, sample1_Z_TC1, sample1_Z_TC2)),
      D$Sigma, ignore_attr = TRUE, tolerance = 1e-3)

    nsim <- 100000
    sample2_Z_TP1 <- numeric(nsim)
    sample2_Z_TP2 <- numeric(nsim)
    sample2_Z_TC1 <- numeric(nsim)
    sample2_Z_TC2 <- numeric(nsim)
    for (i in seq_len(nsim)) {
      sample2_T1 <- rnorm(D$n[[1]][["T"]], mean = D$alternative_TP, sd = sqrt(D$var[["T"]]))
      sample2_T2 <- c(sample2_T1, rnorm(D$n[[2]][["T"]], mean = D$alternative_TP, sd = sqrt(D$var[["T"]])))
      sample2_P1 <- rnorm(D$n[[1]][["P"]], mean = 0, sd = sqrt(D$var[["P"]]))
      sample2_P2 <- c(sample2_P1, rnorm(D$n[[2]][["P"]], mean = 0, sd = sqrt(D$var[["P"]])))
      sample2_C1 <- rnorm(D$n[[1]][["C"]], mean = D$alternative_TP - D$alternative_TC, sd = sqrt(D$var[["C"]]))
      sample2_C2 <- c(sample2_C1, rnorm(D$n[[2]][["C"]], mean = D$alternative_TC, sd = sqrt(D$var[["C"]])))
      sample2_Z_TP1[i] <- (mean(sample2_T1) - mean(sample2_P1))  / sqrt(D$var[["T"]] / D$cumn[[1]][["T"]] + D$var[["P"]] / D$cumn[[1]][["P"]])
      sample2_Z_TP2[i] <- (mean(sample2_T2) - mean(sample2_P2))  / sqrt(D$var[["T"]] / D$cumn[[2]][["T"]] + D$var[["P"]] / D$cumn[[2]][["P"]])
      sample2_Z_TC1[i] <- (mean(sample2_T1) - mean(sample2_C1) + D$Delta)  / sqrt(D$var[["T"]] / D$cumn[[1]][["T"]] + D$var[["C"]] / D$cumn[[1]][["C"]])
      sample2_Z_TC2[i] <- (mean(sample2_T2) - mean(sample2_C2) + D$Delta) / sqrt(D$var[["T"]] / D$cumn[[2]][["T"]] + D$var[["C"]] / D$cumn[[2]][["C"]])
    }
    expect_equal(cov(data.frame(sample2_Z_TP1, sample2_Z_TP2, sample2_Z_TC1, sample2_Z_TC2)),
    D$Sigma, ignore_attr = TRUE, tolerance = 1e-2)

  }
)





