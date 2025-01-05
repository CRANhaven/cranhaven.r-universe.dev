skip_on_cran()
# skip_if(.skip_slow_test, "Slow test skipped.")
# Compare results with work from Patrick Schloemer
library(mvtnorm)
library(mnormt)

schloemer_reference_optimal_singlestage <- function(D) {
  opt <- ThreeArmSingleStageOptDesign(
    thetaTP = D$alternative_TP,
    thetaTC = D$alternative_TC,
    sigma = D$var[["T"]],
    DeltaNI = D$Delta,
    alpha = D$type_I_error,
    beta = D$type_II_error,
    FALSE
  )
  stagec <- list()
  stagec[[1]] <- list(
    "T" = 1,
    "P" = opt$par[2],
    "C" = opt$par[1]
  )
  objective_val <- opt$value
  return(list(stagec = stagec, objective_val = objective_val))
}

test_that("Optimal single stage designs from Patrick Schloemer Dissertation agrees with our computation", {
  D <- optimize_design_onestage(print_progress = FALSE, round_n = FALSE)
  D_compare <- schloemer_reference_optimal_singlestage(D)

  expect_equal(D$objective_val, D_compare$objective_val, tolerance = 1e-4)
  expect_equal(D$stagec, D_compare$stagec, tolerance = 1e-4)
})

schloemer_reference_ASN <- function(D) {
  ThreeArmGroupSeqASN(
    K = 2,
    nT = c(D$cumn[[1]][["T"]], D$cumn[[2]][["T"]]),
    nC = c(D$cumn[[1]][["C"]], D$cumn[[2]][["C"]]),
    nP = c(D$cumn[[1]][["P"]], D$cumn[[2]][["P"]]),
    thetaTP = D$alternative_TP,
    thetaTC = D$alternative_TC,
    sigma = D$var[["T"]],
    DeltaNI = D$Delta,
    bTP = c(D$b[[1]]$TP$efficacy, D$b[[2]]$TP$efficacy),
    bTC = c(D$b[[1]]$TC$efficacy, D$b[[2]]$TC$efficacy)
  )$ASN
}

test_that("ASN from Patrick Schloemer Dissertation agrees with our computation", {
  D <- optimize_design_twostage(bTP1f = -Inf, bTC1f = -Inf, round_n = FALSE, print_progress = FALSE)
  expect_equal(
    D$ASN[["H1"]], schloemer_reference_ASN(D)
  )
})


schloemer_ASN_wrt_WangDelta <- function(WangDeltas, D) {
  WangDeltaTP <- WangDeltas[1]
  WangDeltaTC <- WangDeltas[2]
  WDTP <- WangTsiatis(2, D$type_I_error, WangDeltaTP)
  WDTC <- WangTsiatis(2, D$type_I_error, WangDeltaTC)

  req_samplesize<- ThreeArmGroupSeqDesign(
    K = 2,
    thetaTP = D$alternative_TP,
    thetaTC = 0,
    sigma = D$var[["T"]],
    DeltaNI = D$Delta,
    alpha = D$type_I_error,
    beta = D$type_II_error,
    cC = D$stagec[[1]]$C,
    cP = D$stagec[[1]]$P,
    type = "WT",
    WangDeltaTP,WangDeltaTC
  )

  ThreeArmGroupSeqASN(
    K = 2,
    nT = req_samplesize$nT,
    nC = req_samplesize$nC,
    nP = req_samplesize$nP,
    thetaTP = D$alternative_TP,
    thetaTC = D$alternative_TC,
    sigma = D$var[["T"]],
    DeltaNI = D$Delta,
    bTP = c(WDTP[1], WDTP[2]),
    bTC = c(WDTC[1], WDTC[2])
  )$ASN
}

optimal_schloemer <- function(D){
  opt <- optim(c(.5, .5),
               schloemer_ASN_wrt_WangDelta,
               # method="L-BFGS-B",
               # lower=c(.01, .01),
               # upper=c(5,5),
               D=D
  )

  bTP <- WangTsiatis(2, D$type_I_error,  opt$par[1])
  bTC <- WangTsiatis(2, D$type_I_error,  opt$par[2])
  return(c(bTP1 = bTP[1], bTP2 = bTP[2], bTC1 = bTC[1], bTC2 = bTC[2], ASN = opt$value))
}

compare_design2_with_schloemer <- function(D){
  bvec_schloemer <- optimal_schloemer(D)
  bvec_design2 <- c(D$b[[1]]$TP$efficacy,
                    D$b[[2]]$TP$efficacy,
                    D$b[[1]]$TC$efficacy,
                    D$b[[2]]$TC$efficacy,
                    D$ASN$H1)
  bvec_design2 - bvec_schloemer
}

test_that(
  "Optimal Schloemer design is similar to our design",
  {
    D_s <- optimize_design_onestage(round_n = FALSE, print_progress = FALSE)
    D <- optimize_design_twostage(bTP1f = -Inf, bTC1f = -Inf,
                                  cP1 = D_s$stagec[[1]]$P, cC1 = D_s$stagec[[1]]$P,
                                  cT2 = 1, cP2 = quote(cP1), cC2 = quote(cC1),
                                  round_n = FALSE,
                                  print_progress = FALSE
    )
    D_compare <- optimal_schloemer(D)
    expect_equal(
      c(D$b[[1]]$TP$efficacy, D$b[[2]]$TP$efficacy,
        D$b[[1]]$TC$efficacy, D$b[[2]]$TC$efficacy,
        D$ASN$H1),
      D_compare,
      ignore_attr = TRUE, tolerance = 1e-4
      )
  }
  )



