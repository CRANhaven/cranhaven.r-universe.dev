#' Print summary output
#'
#' Print summary output from \code{pibf()}, \code{rfpi()}, or \code{piall()}
#' functions. This is the default print method for the package.
#'
#' @param x An object of class \code{('rfpredinterval', 'piall')},
#' \code{('rfpredinterval', 'pibf')}, or \code{('rfpredinterval', 'rfpi')}.
#' @param ...  Optional arguments to be passed to other methods.
#'
#' @examples
#' \donttest{
#' ## load example data
#' data(BostonHousing, package = "RFpredInterval")
#' set.seed(2345)
#'
#' ## define train/test split
#' testindex <- 1:10
#' trainindex <- sample(11:nrow(BostonHousing), size = 100, replace = FALSE)
#' traindata <- BostonHousing[trainindex, ]
#' testdata <- BostonHousing[testindex, ]
#' px <- ncol(BostonHousing) - 1
#'
#' ## construct 95% PI with "cv" calibration using 5-folds
#' out <- pibf(formula = medv ~ ., traindata = traindata,
#'   testdata = testdata, calibration =  "oob",
#'   params_ranger = list(num.trees = 40))
#'
#' ## print summary output
#' print(out)
#'
#' ## contruct 95% PI with "ls" split rule, "lm", "quant" and "spi" PI methods
#' ## with calibration and use "ranger" package for RF training
#' out2 <- rfpi(formula = medv ~ ., traindata = traindata,
#'   testdata = testdata, split_rule = "ls", pi_method = c("lm", "quant", "spi"),
#'   rf_package = "ranger", params_ranger = list(num.trees = 50))
#'
#' ## print summary output
#' print(out2)
#' }
#' @seealso \code{\link{pibf}} \code{\link{piall}} \code{\link{rfpi}}

print.rfpredinterval <- function(x, ...) {

  ## pibf
  if (sum(inherits(x, c("rfpredinterval", "pibf"), TRUE) == c(1, 2)) == 2) {

    if (!is.null(x$alphaw)) {
      cat("                      alpha_w: ", format(round(x$alphaw, digits=3), digits=3, nsmall=3),  "\n", sep="")
    }
    ml <- mean(x$pred_interval$upper - x$pred_interval$lower)
    cat("               Mean PI length: ", format(round(ml, digits=3), digits=3, nsmall=3),  "\n", sep="")

    if (!is.null(x$test_response)) {
      coverage <- mean((x$pred_interval$lower <= x$test_response) * (x$test_response <= x$pred_interval$upper))
      cat("                     Coverage: ", format(round(coverage*100, digits=1), digits=1, nsmall=1), "%",  "\n", sep="")
      mae <- mean(abs(x$test_response - x$test_pred))
      rmse <- sqrt(mean((x$test_response - x$test_pred)^2))
      cat("      MAE of test predictions: ", format(round(mae, digits=3), digits=3, nsmall=3), "\n", sep="")
      cat("     RMSE of test predictions: ", format(round(rmse, digits=3), digits=3, nsmall=3), "\n", sep="")
    }

    if (!is.null(x$oob_pred)) {
      cat("\n")
      ml <- mean(x$oob_pred_interval$upper - x$oob_pred_interval$lower)
      cat("     Mean PI length (OOB PIs): ", format(round(ml, digits=3), digits=3, nsmall=3),  "\n", sep="")
      coverage <- mean((x$oob_pred_interval$lower <= x$train_response) * (x$train_response <= x$oob_pred_interval$upper))
      cat("           Coverage (OOB PIs): ", format(round(coverage*100, digits=1), digits=1, nsmall=1), "%",  "\n", sep="")
      mae <- mean(abs(x$train_response - x$oob_pred))
      rmse <- sqrt(mean((x$train_response - x$oob_pred)^2))
      cat(" MAE of OOB train predictions: ", format(round(mae, digits=3), digits=3, nsmall=3), "\n", sep="")
      cat("RMSE of OOB train predictions: ", format(round(rmse, digits=3), digits=3, nsmall=3), "\n", sep="")
    }

  }

  ## rfpi
  if (sum(inherits(x, c("rfpredinterval", "rfpi"), TRUE) == c(1, 2)) == 2) {

    cat("                   Split rule: ", toupper(x$split_rule),  "\n", sep="")
    cat("-------------------------------------------------------------------------------------------", "\n")
    cat("                                      Mean PI length", sep="")
    if (!is.null(x$test_response)) {
      cat("      Coverage", sep="")
      if (!is.null(x$alphaw)) {cat("          alpha_w", sep="")}
    } else {
      if (!is.null(x$alphaw)) {cat("       alpha_w", sep="")}
    }
    cat("\n", sep="")

    if (!is.null(x$lm_interval)) {
      cat("Classical method (LM)",  sep="")
      ml <- mean(x$lm_interval$upper - x$lm_interval$lower)
      cat(format(round(ml, digits=3), digits=3, nsmall=3, width=27), sep="")
      if (!is.null(x$test_response)) {
        coverage <- mean((x$lm_interval$lower <= x$test_response) * (x$test_response <= x$lm_interval$upper))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=16), "%", sep="")
      }
      if (!is.null(x$alphaw)) {cat(format(round(x$alphaw["lm"], digits=3), digits=3, nsmall=3, width=17), sep="")}
      cat("\n", sep="")
    }

    if (!is.null(x$spi_interval)) {
      cat("Shortest prediction interval (SPI)",  sep="")
      ml <- mean(x$spi_interval$upper - x$spi_interval$lower)
      cat(format(round(ml, digits=3), digits=3, nsmall=3, width=14), sep="")
      if (!is.null(x$test_response)) {
        coverage <- mean((x$spi_interval$lower <= x$test_response) * (x$test_response <= x$spi_interval$upper))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=16), "%", sep="")
      }
      if (!is.null(x$alphaw)) {cat(format(round(x$alphaw["spi"], digits=3), digits=3, nsmall=3, width=17),sep="")}
      cat("\n", sep="")
    }

    if (!is.null(x$quant_interval)) {
      cat("Quantile method (Quant)",  sep="")
      ml <- mean(x$quant_interval$upper - x$quant_interval$lower)
      cat(format(round(ml, digits=3), digits=3, nsmall=3, width=25), sep="")
      if (!is.null(x$test_response)) {
        coverage <- mean((x$quant_interval$lower <= x$test_response) * (x$test_response <= x$quant_interval$upper))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=16), "%", sep="")
      }
      if (!is.null(x$alphaw)) {cat(format(round(x$alphaw["quant"], digits=3), digits=3, nsmall=3, width=17), sep="")}
      cat("\n", sep="")
    }

    if (!is.null(x$hdr_interval)) {
      cat("Highest density region (HDR)",  sep="")
      ml <- mean(unlist(Map(function(pi){sum(pi[, "upper"] - pi[, "lower"])}, pi=x$hdr_interval)))
      cat(format(round(ml, digits=3), digits=3, nsmall=3, width=20), sep="")
      if (!is.null(x$test_response)) {
        coverage <- mean(as.numeric(unlist(Map(function(pi, truey){sum((pi[, "lower"] <= truey) * (truey <= pi[, "upper"]))},
                                               pi=x$hdr_interval, truey=x$test_response))))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=16), "%", sep="")
      }
      if (!is.null(x$alphaw)) {cat(format(round(x$alphaw["hdr"], digits=3), digits=3, nsmall=3, width=17), sep="")}
      cat("\n", sep="")
    }

    if (!is.null(x$chdr_interval)) {
      cat("Contiguous HDR (CHDR)",  sep="")
      ml <- mean(x$chdr_interval$upper - x$chdr_interval$lower)
      cat(format(round(ml, digits=3), digits=3, nsmall=3, width=27), sep="")
      if (!is.null(x$test_response)) {
        coverage <- mean((x$chdr_interval$lower <= x$test_response) * (x$test_response <= x$chdr_interval$upper))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=16), "%", sep="")
      }
      if (!is.null(x$alphaw)) {cat(format(round(x$alphaw["chdr"], digits=3), digits=3, nsmall=3, width=17), sep="")}
      cat("\n", sep="")
    }
    cat("-------------------------------------------------------------------------------------------", "\n")

    if (!is.null(x$test_response)) {
      mae <- mean(abs(x$test_response - x$test_pred))
      rmse <- sqrt(mean((x$test_response - x$test_pred)^2))
      cat("      MAE of test predictions: ", format(round(mae, digits=3), digits=3, nsmall=3), "\n", sep="")
      cat("     RMSE of test predictions: ", format(round(rmse, digits=3), digits=3, nsmall=3), "\n", sep="")
    }

    if (!is.null(x$oob_pred)) {
      cat("\n")
      cat("-------------------------------------------------------------------------------------------", "\n")
      cat("                                       Mean PI length (OOB PIs)      Coverage (OOB PIs)", "\n")

      if ("lm" %in% names(x$oob_pred_interval)) {
        cat("Classical method (LM)",  sep="")
        ml <- mean(x$oob_pred_interval$lm$upper - x$oob_pred_interval$lm$lower)
        cat(format(round(ml, digits=3), digits=3, nsmall=3, width=32), sep="")
        coverage <- mean((x$oob_pred_interval$lm$lower <= x$train_response) * (x$train_response <= x$oob_pred_interval$lm$upper))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=27), "%",  "\n", sep="")
      }

      if ("spi" %in% names(x$oob_pred_interval)) {
        cat("Shortest prediction interval (SPI)",  sep="")
        ml <- mean(x$oob_pred_interval$spi$upper - x$oob_pred_interval$spi$lower)
        cat(format(round(ml, digits=3), digits=3, nsmall=3, width=19), sep="")
        coverage <- mean((x$oob_pred_interval$spi$lower <= x$train_response) * (x$train_response <= x$oob_pred_interval$spi$upper))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=27), "%",  "\n", sep="")
      }

      if ("quant" %in% names(x$oob_pred_interval)) {
        cat("Quantile method (Quant)",  sep="")
        ml <- mean(x$oob_pred_interval$quant$upper - x$oob_pred_interval$quant$lower)
        cat(format(round(ml, digits=3), digits=3, nsmall=3, width=30), sep="")
        coverage <- mean((x$oob_pred_interval$quant$lower <= x$train_response) * (x$train_response <= x$oob_pred_interval$quant$upper))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=27), "%",  "\n", sep="")
      }

      if ("hdr" %in% names(x$oob_pred_interval)) {
        cat("Highest density region (HDR)",  sep="")
        ml <- mean(unlist(Map(function(pi){sum(pi[, "upper"] - pi[, "lower"])}, pi=x$oob_pred_interval$hdr)))
        cat(format(round(ml, digits=3), digits=3, nsmall=3, width=25), sep="")
        coverage <- mean(as.numeric(unlist(Map(function(pi, truey){sum((pi[, "lower"] <= truey) * (truey <= pi[, "upper"]))},
                                               pi=x$oob_pred_interval$hdr, truey=x$train_response))))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=27), "%",  "\n", sep="")
      }

      if ("chdr" %in% names(x$oob_pred_interval)) {
        cat("Contiguous HDR (CHDR)",  sep="")
        ml <- mean(x$oob_pred_interval$chdr$upper - x$oob_pred_interval$chdr$lower)
        cat(format(round(ml, digits=3), digits=3, nsmall=3, width=32), sep="")
        coverage <- mean((x$oob_pred_interval$chdr$lower <= x$train_response) * (x$train_response <= x$oob_pred_interval$chdr$upper))
        cat(format(round(coverage*100, digits=1), nsmall=1, width=27), "%",  "\n", sep="")
      }
      cat("-------------------------------------------------------------------------------------------", "\n")

      oob_mae <- mean(abs(x$train_response - x$oob_pred))
      oob_rmse <- sqrt(mean((x$train_response - x$oob_pred)^2))
      cat(" MAE of OOB train predictions: ", format(round(oob_mae, digits=3), digits=3, nsmall=3), "\n", sep="")
      cat("RMSE of OOB train predictions: ", format(round(oob_rmse, digits=3), digits=3, nsmall=3), "\n", sep="")
    }

  }

  ## piall
  if (sum(inherits(x, c("rfpredinterval", "piall"), TRUE) == c(1, 2)) == 2) {

    cat("----------------------------------------", "\n")
    cat("             Mean PI length", sep="")
    if (!is.null(x$test_response)) {cat("    Coverage", sep="")}
    cat("\n", sep="")

    if (!is.null(x$test_response)) {
      coverage <- rep(NA, 16)
      names(coverage) <- names(x)[1:16]
      for (m in names(coverage)) {
        if (grepl("_HDR", m)) {
          coverage[m] <- mean(as.numeric(unlist(Map(function(pi, truey){sum((pi[, "lower"] <= truey) * (truey <= pi[, "upper"]))},
                                                    pi=x[[m]], truey=x$test_response))))
        } else {
          coverage[m] <- mean((x[[m]]$lower <= x$test_response) * (x$test_response <= x[[m]]$upper))
        }
      }
      coverage <- coverage*100
    } else {
      coverage <- NULL
      mae <- NULL
      rmse <- NULL
    }

    cat("PIBF", format(round(mean(x$PIBF$upper - x$PIBF$lower), digits=3), digits=3, nsmall=3, width=19), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["PIBF"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("LS-LM", format(round(mean(x$LS_LM$upper - x$LS_LM$lower), digits=3), digits=3, nsmall=3, width=18), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["LS_LM"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("LS-SPI", format(round(mean(x$LS_SPI$upper - x$LS_SPI$lower), digits=3), digits=3, nsmall=3, width=17), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["LS_SPI"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("LS-Quant", format(round(mean(x$LS_Quant$upper - x$LS_Quant$lower), digits=3), digits=3, nsmall=3, width=15), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["LS_Quant"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("LS-HDR", format(round(mean(unlist(Map(function(pi){sum(pi[, "upper"] - pi[, "lower"])}, pi=x$LS_HDR))), digits=3), digits=3, nsmall=3, width=17), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["LS_HDR"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("LS-CHDR", format(round(mean(x$LS_CHDR$upper - x$LS_CHDR$lower), digits=3), digits=3, nsmall=3, width=16), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["LS_CHDR"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("L1-LM", format(round(mean(x$L1_LM$upper - x$L1_LM$lower), digits=3), digits=3, nsmall=3, width=18), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["L1_LM"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("L1-SPI", format(round(mean(x$L1_SPI$upper - x$L1_SPI$lower), digits=3), digits=3, nsmall=3, width=17), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["L1_SPI"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("L1-Quant", format(round(mean(x$L1_Quant$upper - x$L1_Quant$lower), digits=3), digits=3, nsmall=3, width=15), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["L1_Quant"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("L1-HDR", format(round(mean(unlist(Map(function(pi){sum(pi[, "upper"] - pi[, "lower"])}, pi=x$L1_HDR))), digits=3), digits=3, nsmall=3, width=17), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["L1_HDR"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("L1-CHDR", format(round(mean(x$L1_CHDR$upper - x$L1_CHDR$lower), digits=3), digits=3, nsmall=3, width=16), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["L1_CHDR"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("SPI-LM", format(round(mean(x$SPI_LM$upper - x$SPI_LM$lower), digits=3), digits=3, nsmall=3, width=17), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["SPI_LM"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("SPI-SPI", format(round(mean(x$SPI_SPI$upper - x$SPI_SPI$lower), digits=3), digits=3, nsmall=3, width=16), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["SPI_SPI"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("SPI-Quant", format(round(mean(x$SPI_Quant$upper - x$SPI_Quant$lower), digits=3), digits=3, nsmall=3, width=14), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["SPI_Quant"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("SPI-HDR", format(round(mean(unlist(Map(function(pi){sum(pi[, "upper"] - pi[, "lower"])}, pi=x$SPI_HDR))), digits=3), digits=3, nsmall=3, width=16), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["SPI_HDR"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("SPI-CHDR", format(round(mean(x$SPI_CHDR$upper - x$SPI_CHDR$lower), digits=3), digits=3, nsmall=3, width=15), sep="")
    if (!is.null(coverage)) {cat(format(round(coverage["SPI_CHDR"], digits=1), nsmall=1, width=14), "%", sep="")}
    cat("\n", sep="")

    cat("----------------------------------------", "\n")

    if (!is.null(x$test_response)) {
      mae <- rep(NA, 4)
      names(mae) <- c("PIBF", "LS split", "L1 split", "SPI split")
      mae["PIBF"] <- mean(abs(x$test_response - x$pred_pibf))
      mae["LS split"] <- mean(abs(x$test_response - x$pred_ls))
      mae["L1 split"] <- mean(abs(x$test_response - x$pred_l1))
      mae["SPI split"] <- mean(abs(x$test_response - x$pred_spi))

      rmse <- rep(NA, 4)
      names(rmse) <- c("PIBF", "LS split", "L1 split", "SPI split")
      rmse["PIBF"] <- sqrt(mean((x$test_response - x$pred_pibf)^2))
      rmse["LS split"] <- sqrt(mean((x$test_response - x$pred_ls)^2))
      rmse["L1 split"] <- sqrt(mean((x$test_response - x$pred_l1)^2))
      rmse["SPI split"] <- sqrt(mean((x$test_response - x$pred_spi)^2))

      cat("                   MAE","            RMSE", "\n", sep="")
      cat("PIBF", format(round(mae["PIBF"], digits=3), digits=3, nsmall=3, width=19),
          format(round(rmse["PIBF"], digits=3), digits=3, nsmall=3, width=15), "\n", sep="")
      cat("LS split", format(round(mae["LS split"], digits=3), digits=3, nsmall=3, width=15),
          format(round(rmse["LS split"], digits=3), digits=3, nsmall=3, width=15), "\n", sep="")
      cat("L1 split", format(round(mae["L1 split"], digits=3), digits=3, nsmall=3, width=15),
          format(round(rmse["L1 split"], digits=3), digits=3, nsmall=3, width=15), "\n", sep="")
      cat("SPI split", format(round(mae["SPI split"], digits=3), digits=3, nsmall=3, width=14),
          format(round(rmse["SPI split"], digits=3), digits=3, nsmall=3, width=15), "\n", sep="")
    }
    cat("\n")
  }

}
