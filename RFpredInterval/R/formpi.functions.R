## functions to build prediction interval

################################################################################
## form prediction interval with boosted forest and SPI
formpi <- function (alpha, BOP, mean, response = NULL) {
  BOP <- Map(function(b, m) b+m, b = BOP, m = mean)
  out1 <- vapply(BOP, formpi2, alpha = alpha, numeric(2))
  if (!is.null(response)) {
    cov <- as.numeric((response >= out1[1, ]) * (response <= out1[2, ]))
    out <- list(lower = out1[1, ], upper = out1[2, ], cov = cov)
  } else {
    out <- list(lower = out1[1, ], upper = out1[2, ])
  }
  return(out)
}

formpi2 <- function (bop, alpha) {
  n <- length(bop)
  sx <- sort(bop)
  m <- ceiling((1-alpha) * n)
  lo <- sx[1:(n-m+1)]
  up <- sx[m:n]
  minid <- which.min(up-lo)
  pi <- c(lo[minid], up[minid])
  return(pi)
}

################################################################################
## form prediction interval with LM
formpi_lm <- function (alpha, BOP, response = NULL) {
  out1 <- vapply(BOP, formpi_lm2, alpha = alpha, numeric(2))
  if (!is.null(response)) {
    cov <- as.numeric((response >= out1[1, ]) * (response <= out1[2, ]))
    out <- list(lower = out1[1, ], upper = out1[2, ], cov = cov)
  } else {
    out <- list(lower = out1[1, ], upper = out1[2, ])
  }
  return(out)
}

formpi_lm2 <- function (bop, alpha) {
  lm.obj <- stats::lm(formula = bop ~ 1)
  pred.obj <- as.matrix(predict(lm.obj, newdata = data.frame(1), interval = "predict", level = (1-alpha)))
  pi <- c(pred.obj[2], pred.obj[3])
  return(pi)
}

################################################################################
## form prediction interval with quantiles
formpi_quant <- function (alpha, BOP, response = NULL) {
  quant <- c(alpha/2, 1-(alpha/2))
  out1 <- vapply(BOP, formpi_quant2, quant = quant, numeric(2))
  if (!is.null(response)) {
    cov <- as.numeric((response >= out1[1, ]) * (response <= out1[2, ]))
    out <- list(lower = out1[1, ], upper = out1[2, ], cov = cov)
  } else {
    out <- list(lower = out1[1, ], upper = out1[2, ])
  }
  return(out)
}

formpi_quant2 <- function (bop, quant) {
  pi <- as.vector(quantile(bop, probs = quant))
  return(pi)
}

################################################################################
## form prediction interval with SPI
formpi_spi <- function (alpha, BOP, response = NULL) {
  out1 <- vapply(BOP, formpi_spi2, alpha = alpha, numeric(2))
  if (!is.null(response)) {
    cov <- as.numeric((response >= out1[1, ]) * (response <= out1[2, ]))
    out <- list(lower = out1[1, ], upper = out1[2, ], cov = cov)
  } else {
    out <- list(lower = out1[1, ], upper = out1[2, ])
  }
  return(out)
}

formpi_spi2 <- function (bop, alpha) {
  n <- length(bop)
  sx <- sort(bop)
  m <- ceiling((1-alpha) * n)
  lo <- sx[1:(n-m+1)]
  up <- sx[m:n]
  minid <- which.min(up-lo)
  pi <- c(lo[minid], up[minid])
  return(pi)
}

################################################################################
## find optimal bandwidth for HDR and CHDR
opt_bw <- function(BOP, alpha, nn = 10){
  smp <- sample(1:length(BOP), length(BOP), replace = FALSE)
  bw <- c()
  i <- 0
  while ( (length(bw) < nn) & (i < length(BOP)) ) {
    i <- i + 1
    BOP1 <- BOP[[smp[i]]]
    if (!is.null(BOP1) & ((quantile(BOP1, 0.75)-quantile(BOP1, 0.25)) > 0)) {
      bw1 <- try(hdrcde::hdrbw(BOP1, HDRlevel = (1-alpha)), silent = TRUE)
      if (!inherits(bw1, "try-error")) {
        bw <- c(bw, bw1)
      }
    }
  }
  if (length(bw) > 0) {
    meanbw <- mean(bw)
  } else {
    stop("Optimal bandwidth could not find with 'hdrbw' function of 'hdrcde' package.")
  }
  return(meanbw)
}

################################################################################
## form prediction interval with HDR
formpi_hdr <- function (alpha, BOP, bw, response = NULL) {
  out1 <- lapply(BOP, formpi_hdr2, alpha = alpha, bw = bw)
  if (!is.null(response)) {
    cov <- unlist(Map(function(pi, r) sum((r >= pi[, 1]) * (r <= pi[, 2])), pi = out1, r = response))
    out <- list(pi = out1, cov = cov)
  } else {
    out <- list(pi = out1)
  }
  return(out)
}

formpi_hdr2 <- function (bop, alpha, bw) {
  hdr <- as.vector(hdrcde::hdr(bop, prob = (1-alpha)*100, h = bw)$hdr)
  if (length(hdr) < 2) {
    pi <- cbind(hdr[1], hdr[1])
  } else if (length(hdr) %% 2 == 0) {
    lo <- seq(1,length(hdr),2)
    up <- seq(2,length(hdr),2)
    pi <- cbind(hdr[lo], hdr[up])
  } else if (length(hdr) %% 2 != 0) {
    hdr <- hdr[-length(hdr)]
    lo <- seq(1,length(hdr),2)
    up <- seq(2,length(hdr),2)
    pi <- cbind(hdr[lo], hdr[up])
  }
  rownames(pi) <- 1:(length(hdr)/2)
  colnames(pi) <- c("lower", "upper")
  return(pi)
}

################################################################################
## form prediction interval with contiguous HDR (CHDR)
formpi_chdr <- function (alpha, BOP, bw, response = NULL) {
  out1 <- vapply(BOP, formpi_chdr2, alpha = alpha, bw = bw, numeric(2))
  if (!is.null(response)) {
    cov <- as.numeric((response >= out1[1, ]) * (response <= out1[2, ]))
    out <- list(lower = out1[1, ], upper = out1[2, ], cov = cov)
  } else {
    out <- list(lower = out1[1, ], upper = out1[2, ])
  }
  return(out)
}

formpi_chdr2 <- function (bop, alpha, bw) {
  hdr <- as.vector(hdrcde::hdr(bop, prob = (1-alpha)*100, h = bw)$hdr)
  if (length(hdr) < 2) {
    pi <- c(hdr[1], hdr[1])
  } else {
    pi <- c(hdr[1], hdr[length(hdr)])
  }
  return(pi)
}
