fr <- function(x, k=2){
  format_single <- function(x){
    if (is.character(x))
      return(x)
    else if (is.na(x))
      return("")
    else if (is.infinite(x))
      if (x > 0){
        return("$\\infty$")
      } else{
        return("$-\\infty$")
      }
    else return(format(round(x, k), nsmall=k))
  }
  sapply(x, format_single)
}

format_table <- function(tab, k = c(0, 2, 1, 1, 1, 1, rep(0, 6), rep(2, 6), rep(0, 6), 2)){
  fr(tab[-1], k)
}


#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows
make_table <- function(D_list){
  # Map(fr, x=tmp, k=c(1, 1, rep(0, 12), 2))
  table_tib <- tibble(
    `Design`                     = numeric(),
    `$\\alpha$`                  = numeric(),
    `$\\beta$`                   = numeric(),
    `$\\lambda$`                 = numeric(),
    `$\\kappa$`                  = numeric(),
    `$\\eta$`                    = numeric(),
    `$n_{1, T}$`                 = numeric(),
    `$n_{1, P}$`                 = numeric(),
    `$n_{1, C}$`                 = numeric(),
    `$n_{2, T}$`                 = numeric(),
    `$n_{2, P}$`                 = numeric(),
    `$n_{2, C}$`                 = numeric(),
    `$b_{1, TP, f}$`             = numeric(),
    `$b_{1, TP, e}$`             = numeric(),
    `$b_{1, TC, f}$`             = numeric(),
    `$b_{1, TC, e}$`             = numeric(),
    `$b_{2, TP, e}$`             = numeric(),
    `$b_{2, TC, e}$`             = numeric(),
    `$n_{\\max}$`                = numeric(),
    `$N_{H_0}$`                  = numeric(),
    `$N_{H_1}$`                  = numeric(),
    `$N_{H_0}^{P}$`              = numeric(),
    `$N_{H_1}^{P}$`              = numeric(),
    `$g_{\\lambda, \\kappa, \\eta}(D)$` = numeric(),
    `$CP_{\\min}$`               = numeric(),
    .design_object                = list()
  )
  for (i in seq_along(D_list)){
    D <- D_list[[i]]
    if ("OneStageGoldStandardDesign" %in% class(D)){
      tmp <- tibble(
        `Design`                     = if(!is.null(D$nr)) D$nr else NA_real_,
        `$\\alpha$`                  =   D$alpha,
        `$\\beta$`                   =   D$beta,
        `$\\lambda$`                 =   NA_real_,
        `$\\kappa$`                  =   D$kappa,
        `$\\eta$`                    =   NA_real_,
        `$n_{1, T}$`                 =   D$n[[1]][["T"]],
        `$n_{1, P}$`                 =   D$n[[1]][["P"]],
        `$n_{1, C}$`                 =   D$n[[1]][["C"]],
        `$n_{2, T}$`                 =   NA_real_,
        `$n_{2, P}$`                 =   NA_real_,
        `$n_{2, C}$`                 =   NA_real_,
        `$b_{1, TP, f}$` = NA_real_,
        `$b_{1, TP, e}$` = D$b[[1]][["TP"]][["efficacy"]],
        `$b_{1, TC, f}$` = NA_real_,
        `$b_{1, TC, e}$` = D$b[[1]][["TC"]][["efficacy"]],
        `$b_{2, TP, e}$` = NA_real_,
        `$b_{2, TC, e}$` = NA_real_,
        `$n_{\\max}$`                =   sum(round(unlist(D$n))),
        `$N_{H_0}$`                  =   D$ASN[["H0"]],
        `$N_{H_1}$`                  =   D$ASN[["H1"]],
        `$N_{H_0}^{P}$`              =   D$ASNP[["H0"]],
        `$N_{H_1}^{P}$`              =   D$ASNP[["H1"]],
        `$g_{\\lambda, \\kappa, \\eta}(D)$` =   D$objective_val,
        `$CP_{\\min}$`               =   NA_real_,
        .design_object                       = list(D)
      )
      table_tib <- bind_rows(table_tib, tmp)
    } else if ("TwoStageGoldStandardDesign" %in% class(D)){
      tmp <- tibble(
        `Design`                     =  if(!is.null(D$nr)) D$nr else NA_real_,
        `$\\alpha$`                  =  D$alpha,
        `$\\beta$`                   =  D$beta,
        `$\\lambda$`                 =  D$lambda,
        `$\\kappa$`                  =  D$kappa,
        `$\\eta$`                    =  if (!is.null(D$eta)) D$eta else D$nu,
        `$n_{1, T}$`                 =  D$cumn[[1]][["T"]],
        `$n_{1, P}$`                 =  D$cumn[[1]][["P"]],
        `$n_{1, C}$`                 =  D$cumn[[1]][["C"]],
        `$n_{2, T}$`                 =  D$cumn[[2]][["T"]],
        `$n_{2, P}$`                 =  D$cumn[[2]][["P"]],
        `$n_{2, C}$`                 =  D$cumn[[2]][["C"]],
        `$b_{1, TP, f}$` = D$b[[1]][["TP"]][["futility"]],
        `$b_{1, TP, e}$` = D$b[[1]][["TP"]][["efficacy"]],
        `$b_{1, TC, f}$` = D$b[[1]][["TC"]][["futility"]],
        `$b_{1, TC, e}$` = D$b[[1]][["TC"]][["efficacy"]],
        `$b_{2, TP, e}$` = D$b[[2]][["TP"]][["efficacy"]],
        `$b_{2, TC, e}$` = D$b[[2]][["TC"]][["efficacy"]],
        `$n_{\\max}$`                =  sum(round(unlist(D$cumn[[2]]))),
        `$N_{H_0}$`                  =  D$ASN[["H0"]],
        `$N_{H_1}$`                  =  D$ASN[["H1"]],
        `$N_{H_0}^{P}$`              =  D$ASNP[["H0"]],
        `$N_{H_1}^{P}$`              =  D$ASNP[["H1"]],
        `$g_{\\lambda, \\kappa, \\eta}(D)$` =  D$objective_val,
        `$CP_{\\min}$`               =  D$cp_min,
        .design_object               =  list(D)
      )
      table_tib <- bind_rows(table_tib, tmp)
    } else{
      stop("Wrong class.")
    }
  }
  return(table_tib)
}
