#' Printing method for optimal two-stage goldstandard designs
#'
#' @param x An object of class TwoStageGoldStandardDesign
#' @param ... additional parameters
#'
#' @return returns the input x invisibly. This functions is used for its side effects, i.e. printing
#' design characteristics to the screen.
#' @export
#'
#' @inherit optimize_design_twostage examples
print.TwoStageGoldStandardDesign <- function(x, ...){
  if (x$round_n)
    f <- "%i"
  else
    f <- "%.1f"
  sample_sizes_stage1 <- sprintf(paste0("Sample sizes (stage 1): T: ",f,", P: ",f,", C: ",f,"\n"),
                                 x$n[[1]][["T"]], x$n[[1]][["P"]], x$n[[1]][["C"]])
  sample_sizes_stage2 <- sprintf(paste0("Sample sizes (stage 2): T: ",f,", P: ",f,", C: ",f,"\n"),
                                 x$n[[2]][["T"]], x$n[[2]][["P"]], x$n[[2]][["C"]])
  efficacy_boundaries_stage1 <- sprintf("Efficacy boundaries (stage 1): Z_TP_e: %.5f, Z_TC_e: %.5f\n",
                                        x$b[[1]][["TP"]][["efficacy"]], x$b[[1]][["TC"]][["efficacy"]])

  futility_boundaries_stage1 <- sprintf("Futility boundaries (stage 1): Z_TP_f: %.5f, Z_TC_f: %.5f\n",
                                        x$b[[1]][["TP"]][["futility"]], x$b[[1]][["TC"]][["futility"]])

  efficacy_boundaries_stage2 <- sprintf("Efficacy boundaries (stage 2): Z_TP_e: %.5f, Z_TC_e: %.5f\n",
                                        x$b[[2]][["TP"]][["efficacy"]], x$b[[2]][["TC"]][["efficacy"]])
  invnormal_weights_TP <- sprintf("Inverse normal combination test weights (TP): w1: %.5f, w2: %.5f\n",
                                  x$invnormal_weights_TP[[1]], x$invnormal_weights_TP[[2]])
  invnormal_weights_TC <- sprintf("Inverse normal combination test weights (TC): w1: %.5f, w2: %.5f\n",
                                  x$invnormal_weights_TC[[1]], x$invnormal_weights_TC[[2]])
  max_sample_size <- sprintf(paste0("Maximum overall sample size: ",f,"\n"), sum(unlist(x$n)))
  ASN_H1 <- sprintf("Expected sample size (H1): %.1f\n", x$ASN$H1)
  ASN_H0 <- sprintf("Expected sample size (H0): %.1f\n", x$ASN$H0)
  ASNP_H1 <- sprintf("Expected placebo group sample size (H1): %.1f\n", x$ASNP$H1)
  ASNP_H0 <- sprintf("Expected placebo group sample size (H0): %.1f\n", x$ASNP$H0)
  objective_val <- sprintf("Objective function value: %.1f\n", x$objective_val)
  local_alpha_TP <- sprintf("(local) type I error for TP testing: %.2f%%\n", x$local_alphas[["TP"]]*100)
  local_alpha_TC <- sprintf("(local) type I error for TC testing: %.2f%%\n", x$local_alphas[["TC"]]*100)
  if (!x$always_both_futility_tests)
    max_alpha_TC <- sprintf("maximum type I error for TC testing: %.2f%%\n", x$max_alpha_TC*100)
  power <- sprintf("Power: %.2f%%\n", x$power*100)
  cp_min <- sprintf("Minimum conditional power: %.2f%%\n", x$cp_min*100)
  futility_prob_H1 <- sprintf("Probability of futility stop (H1): %.2f%%\n", x$futility_prob[["H1"]]*100)
  futility_prob_H0 <- sprintf("Probability of futility stop (H0): %.2f%%\n", x$futility_prob[["H0"]]*100)
  futility_boundaries_binding <- paste0("Futility boundaries: ", if(x$binding_futility) "binding\n" else "nonbinding\n")
  futility_testing_mode <- paste0("Futility testing method: ",
                                  if(x$always_both_futility_tests) "always both futility tests\n" else "completely sequential testing\n")

  cat(sample_sizes_stage1)
  cat(sample_sizes_stage2)
  cat(efficacy_boundaries_stage1)
  cat(futility_boundaries_stage1)
  cat(efficacy_boundaries_stage2)
  cat(invnormal_weights_TP)
  cat(invnormal_weights_TC)
  cat(max_sample_size)
  cat(ASN_H1)
  cat(ASN_H0)
  cat(ASNP_H1)
  cat(ASNP_H0)
  cat(objective_val)
  cat(local_alpha_TP)
  cat(local_alpha_TC)
  if (!x$always_both_futility_tests && !x$binding_futility)
    cat(max_alpha_TC)
  cat(futility_prob_H1)
  cat(futility_prob_H0)
  cat(cp_min)
  cat(power)
  cat(futility_boundaries_binding)
  if (!x$binding_futility &&
      (is.finite(x$b[[1]][["TP"]][["futility"]]) || is.finite(x$b[[1]][["TC"]][["futility"]]))){
    cat("Note: Results are presented as if futility boundaries were strictly obeyed.\n")
  }
  cat(futility_testing_mode)
  return(invisible(x))
}

#' Printing method for optimal single-stage goldstandard designs
#'
#' @param x An object of class OneStageGoldStandardDesign
#' @param ... additional parameters
#'
#' @return returns the input x invisibly. This functions is used for its side effects, i.e. printing
#' design characteristics to the screen.
#' @export
#'
#' @inherit optimize_design_onestage examples
print.OneStageGoldStandardDesign <- function(x, ...){
  if (x$round_n)
    f <- "%i"
  else
    f <- "%.1f"
  sample_sizes_stage1 <- sprintf(paste0("Sample sizes (stage 1): T: ",f,", P: ",f,", C: ",f,"\n"),
                                 x$n[[1]][["T"]], x$n[[1]][["P"]], x$n[[1]][["C"]])
  efficacy_boundaries_stage1 <- sprintf("Efficacy boundaries (stage 1): Z_TP_e: %.5f, Z_TC_e: %.5f\n",
                                        x$b[[1]][["TP"]][["efficacy"]], x$b[[1]][["TC"]][["efficacy"]])
  max_sample_size <- sprintf(paste0("Maximum overall sample size: ",f,"\n"), sum(unlist(x$n)))
  placebo_penalty <- sprintf("Placebo penalty at optimum (kappa * nP): %.1f\n", x$kappa*x$n[[1]][["P"]])
  objective_val <- sprintf("Objective function value: %.1f\n", x$objective_val)
  alpha_TP <- sprintf("Type I error for TP testing: %.1f%%\n", x$type_I_error*100)
  alpha_TC <- sprintf("Type I error for TC testing: %.1f%%\n", x$type_I_error*100)
  power <- sprintf("Power: %.1f%%\n", x$power*100)

  cat(sample_sizes_stage1)
  cat(efficacy_boundaries_stage1)
  cat(max_sample_size)
  cat(placebo_penalty)
  cat(objective_val)
  cat(alpha_TP)
  cat(alpha_TC)
  cat(power)
  return(invisible(x))
}


#' Add whitespace padding to string
#'
#' @param str a character string
#'
#' @return string with whitespace padding until the full console width
#' @importFrom cli console_width
padd_whitespace <- function(str) {
  paste0(str, paste0(replicate(max(1, console_width()-nchar(str) + 1L) , " "), collapse="") , collapse = "")
}
