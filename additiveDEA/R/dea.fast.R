dea.fast <-
function(base, noutput, fixed = NULL, rts = 2, bound = NULL, 
                     add.model = c('additive', 'RAM', 'BAM', 'MIP', 
                     'LovPast', 'SBM'), blockSize = 200) {
  
  baseEfficient <- list()
  n <- nrow(base)
  mod <- (n - (n %% blockSize)) / blockSize
  blocks <- c(1, 1:mod * blockSize + 1)
  for (i in 1:mod) {
    aux <- blocks[i]:(blocks[i + 1] - 1)
    base1 <- base[aux, ]
    bound1 <- bound[aux, ]
    if (add.model != 'SBM') {
      eff <- round(dea.gem(base = base1, noutput, fixed, rts, 
        bound = bound1, add.model)$eff, 7)
      index <- which(is.na(eff))
      if (length(index) > 0) {
        eff[index] <- round(dea.gem(base = base1, noutput, fixed, rts, 
          bound = bound1, add.model, whichDMUs = index)$eff, 7)
      }
      baseEfficient[[i]] <- base1[which(eff == 0), ]
    } else {
      eff <- round(dea.sbm(base = base1, noutput, fixed, rts, 
        bound = bound1)$eff, 7)
      index <- which(is.na(eff))
      if (length(index) > 0) {
        eff[index] <- round(dea.sbm(base = base1, noutput, fixed, rts, 
          bound = bound1, whichDMUs = index)$eff, 7)
      }
      baseEfficient[[i]] <- base1[which(eff == 1), ]
    }
  }
  if (n %% blockSize != 0) {
    aux <- (n - (n %% blockSize) + 1):n
    base1 <- base[aux, ]
    bound1 <- bound[aux, ]
    if (add.model != 'SBM') {
      eff <- round(dea.gem(base = base1, noutput, fixed, rts, 
        bound = bound1, add.model)$eff, 7)
      index <- which(is.na(eff))
      if (length(index) > 0) {
        eff[index] <- round(dea.gem(base = base1, noutput, fixed, rts, 
          bound = bound1, add.model, whichDMUs = index)$eff, 7)
      }
      baseEfficient[[i + 1]] <- base1[which(eff == 0), ]
    } else {
      eff <- round(dea.sbm(base = base1, noutput, fixed, rts, 
        bound = bound1)$eff, 7)
      index <- which(is.na(eff))
      if (length(index) > 0) {
        eff[index] <- round(dea.sbm(base = base1, noutput, fixed, rts, 
          bound = bound1, whichDMUs = index)$eff, 7)
      }
      baseEfficient[[i + 1]] <- base1[which(eff == 1), ]
    }
  }
  
  baseEfficient <- do.call("rbind", baseEfficient)
  if (add.model != 'SBM') {
    eff <- round(dea.gem(base = base1, noutput, fixed, rts, 
      bound = bound1, add.model)$eff, 7)
    index <- which(is.na(eff))
    if (length(index) > 0) {
      eff[index] <- round(dea.gem(base = base1, noutput, fixed, rts, 
        bound = bound1, add.model, whichDMUs = index)$eff, 7)
    }
    baseEfficient <- base1[which(eff == 0), ]
  } else {
    eff <- round(dea.sbm(base = base1, noutput, fixed, rts, 
      bound = bound1)$eff, 7)
    index <- which(is.na(eff))
    if (length(index) > 0) {
      eff[index] <- round(dea.sbm(base = base1, noutput, fixed, rts, 
        bound = bound1, whichDMUs = index)$eff, 7)
    }
    baseEfficient <- base1[which(eff == 1), ]
  }

  eff <- list()
  for (i in 1:mod) {
    aux <- blocks[i]:(blocks[i + 1] - 1)
    base1 <- base[aux, ]
    base1 <- rbind(base1, baseEfficient)
    bound1 <- bound[aux, ]
    if (!is.null(bound)) {
      df <- data.frame(matrix(0, 
        nrow = nrow(base1[1:(nrow(base1) - blockSize), ]), 
        ncol = ncol(base1)))
      names(df) <- names(bound1)
      bound1 <- rbind(bound1, df)
    }
    if (add.model != 'SBM') {
      eff[[i]] <- dea.gem(base = base1, noutput, fixed, rts, 
        bound = bound1, add.model, whichDMUs = 1:blockSize)$eff
      index <- which(is.na(eff[[i]]))
      if (length(index) > 0) {
        eff[[i]][index] <- dea.gem(base = base1, noutput, fixed, rts, 
          bound = bound1, add.model, whichDMUs = index)$eff
      }
    } else {
      eff[[i]] <- dea.sbm(base = base1, noutput, fixed, rts, 
        bound = bound1, whichDMUs = 1:blockSize)$eff
      index <- which(is.na(eff[[i]]))
      if (length(index) > 0) {
        eff[[i]][index] <- dea.sbm(base = base1, noutput, fixed, rts, 
          bound = bound1, whichDMUs = index)$eff
      }
    }
  }
  if (n %% blockSize != 0) {
    aux <- (n - (n %% blockSize) + 1):n
    base1 <- base[aux, ]
    base1 <- rbind(base1, baseEfficient)
    bound1 <- bound[aux, ]
    newBlockSize <- nrow(base) - mod * blockSize
    if (!is.null(bound)) {
      df <- data.frame(matrix(0, 
        nrow = nrow(base1[1:(nrow(base1) - newBlockSize), ]), 
        ncol = ncol(base1)))
     names(df) <- names(bound1)
     bound1 <- rbind(bound1, df)
    }
    if (add.model != 'SBM') {
      eff[[i + 1]] <- dea.gem(base = base1, noutput, fixed, rts, 
        bound = bound1, add.model, whichDMUs = 1:newBlockSize)$eff
      index <- which(is.na(eff[[i + 1]]))
      if (length(index) > 0) {
        eff[[i + 1]][index] <- dea.gem(base = base1, noutput, fixed, rts, 
          bound = bound1, add.model, whichDMUs = index)$eff
      }
    } else {
      eff[[i + 1]] <- dea.sbm(base = base1, noutput, fixed, rts, 
        bound = bound1, whichDMUs = 1:newBlockSize)$eff
      index <- which(is.na(eff[[i + 1]]))
      if (length(index) > 0) {
        eff[[i + 1]][index] <- dea.sbm(base = base1, noutput, fixed, rts, 
          bound = bound1, whichDMUs = index)$eff
      }
    }
  }
  eff <- unlist(eff)
  return(eff)
}
