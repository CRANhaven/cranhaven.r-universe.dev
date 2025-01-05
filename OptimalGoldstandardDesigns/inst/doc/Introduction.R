## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(Sys.getenv("NOT_CRAN"), "true")
)

## ----setup--------------------------------------------------------------------
library(OptimalGoldstandardDesigns)

## ---- eval=FALSE--------------------------------------------------------------
#    mvnorm_algorithm = mvtnorm::Miwa(
#      # steps = 128,
#      steps = 4097,
#      checkCorr = FALSE,
#      maxval = 1000),
#    nloptr_opts = list(algorithm = "NLOPT_LN_SBPLX",
#                       # xtol_abs = 1e-3,
#                       # xtol_rel = 1e-2,
#                       # maxeval = 2000,
#                       xtol_abs = 1e-10,
#                       xtol_rel = 1e-9,
#                       maxeval = 2000,
#                       print_level = 0)

## ---- eval=FALSE--------------------------------------------------------------
#  print_progress = TRUE

## -----------------------------------------------------------------------------
tab1_D1 <- optimize_design_onestage(
  alpha = .025,
  beta = .2,
  alternative_TP = .4,
  alternative_TC = 0,
  Delta = .2,
  print_progress = FALSE
)
tab1_D1

## -----------------------------------------------------------------------------
optimize_design_twostage(
  cP1 = tab1_D1$stagec[[1]]$P, # The allocation ratios are enforced to be
  cC1 = tab1_D1$stagec[[1]]$C, # the same as in the optimal single-stage design.
  cT2 = 1,          
  cP2 = tab1_D1$stagec[[1]]$P, 
  cC2 = tab1_D1$stagec[[1]]$C, 
  
  bTP1f = -Inf,     # These two boundary conditions enforce no futility stops.
  bTC1f = -Inf,
  
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  bTP1f = -Inf,     # These two boundary conditions enforce no futility stops.
  bTC1f = -Inf,
  
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE,
  binding_futility = FALSE
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE,
  binding_futility = TRUE
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE,
  binding_futility = TRUE,
  lambda = 0.9
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE,
  binding_futility = TRUE,
  kappa = 0.5
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE,
  binding_futility = TRUE,
  lambda = .9,
  kappa = 1 
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE,
  eta = 1
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  cT2 = 1,           # These three boundary conditions enforce a
  cP2 = quote(cP1),  # between-stage allocation ratio of one.
  cC2 = quote(cC1),  # The quote() command is necessary for this to work.
  
  bTP1f = -Inf,      # These two boundary conditions enforce no futility stops.
  bTC1f = -Inf,
  
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE
)

## -----------------------------------------------------------------------------
optimize_design_twostage(
  beta = 0.2,
  alternative_TP = 0.4,
  alternative_TC = 0,
  Delta = 0.2,
  print_progress = FALSE,
  objective = quote((final_state_probs[["H1"]][["TP1E_TC1E"]] + final_state_probs[["H1"]][["TP1F_TC1F"]]) *
                      (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]])^2 +
                      (final_state_probs[["H1"]][["TP1E_TC12E"]] + final_state_probs[["H1"]][["TP1E_TC12F"]]) *
                      (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]] + n[[2]][["T"]] + n[[2]][["C"]])^2 +
                      (final_state_probs[["H1"]][["TP12F_TC1"]] + final_state_probs[["H1"]][["TP12E_TC12E"]] +
                         final_state_probs[["H1"]][["TP12E_TC12F"]]) *
                      (n[[1]][["T"]] + n[[1]][["P"]] + n[[1]][["C"]] + n[[2]][["T"]] + n[[2]][["P"]] + n[[2]][["C"]])^2)
)

