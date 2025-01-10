## calibration functions

################################################################################
## calibration with cross-validation
calibrate_cv <- function (coverage_range, alpha, traindata, numfolds, params_ranger, yvar.names) {
  ntrain <- nrow(traindata)
  folds <- rep_len(1:numfolds, ntrain)
  cv.mean.oob <- numeric(ntrain)
  BOPcv <- vector("list", ntrain)

  ## build CV-BOP with cross-validation
  for (k in 1:numfolds) {
    ## split into train and test sets for the current fold
    testindex <- which(folds == k)
    cv.traindata <- traindata[-testindex, ]
    cv.testdata <- traindata[testindex, ]
    yvar <- cv.traindata[, yvar.names]

    ## train first RF: mean RF
    params_ranger[["data"]] <- cv.traindata
    params_ranger[["keep.inbag"]] <- FALSE
    rf.mean <- do.call(ranger::ranger, params_ranger)

    ## get oob mean predictions
    mean.oob <- rf.mean$predictions
    if (sum(is.nan(mean.oob)) > 0) {
      stop("Some of the OOB predictions are NaN. Increase the number of trees, 'num.trees' in params_ranger")
    }

    ## compute oob residuals
    res <- yvar - as.numeric(mean.oob)

    ## train second RF: residual RF
    traindata.res <- cv.traindata
    traindata.res[, yvar.names] <- res
    params_ranger[["data"]] <- traindata.res
    params_ranger[["keep.inbag"]] <- TRUE
    rf.res <- do.call(ranger::ranger, params_ranger)

    ## update the oob mean predictions with oob bias predictions
    bias.oob <- rf.res$predictions
    mean.oob <- mean.oob + bias.oob

    ## compute residuals after bias correction
    res <- yvar - as.numeric(mean.oob)

    ## get bias-corrected predictions for test data
    mean.test <- predict(rf.mean, data = cv.testdata)$predictions
    bias.test <- predict(rf.res, data = cv.testdata)$predictions
    mean.test <- mean.test + bias.test
    cv.mean.oob[testindex] <- mean.test

    ## construct test-BOP
    ntree <- rf.res$num.trees
    mem.cv.train <- predict(rf.res, data = cv.traindata, type = "terminalNodes")$predictions
    mem.cv.test <- predict(rf.res, data = cv.testdata, type = "terminalNodes")$predictions
    cv.inbag <- matrix(unlist(rf.res$inbag.counts, use.names = FALSE), ncol = ntree, byrow = FALSE)
    BOPcvtest <- buildtestbop(mem.train = mem.cv.train, mem.test = mem.cv.test, inbag = cv.inbag, residual = res)
    BOPcv[testindex] <- BOPcvtest

    if (sum(sapply(BOPcvtest, is.null)) > 0) {
      stop("Some observations have empty BOP. Increase the number of trees, 'num.trees' in params_ranger.")
    }
  } # end of cross-validation

  ## compute CV-coverage with alpha before calibration
  PI.obj <- formpi(alpha = alpha,
                   BOP = BOPcv,
                   mean = cv.mean.oob,
                   response = traindata[, yvar.names])
  init.cov <- mean(PI.obj$cov)

  ## if CV-coverage is not within the coverage_range
  ## form a grid of alphaw values to be searched
  if ( (init.cov <= coverage_range[2]) & (init.cov >= coverage_range[1]) ) {
    alphaw <- alpha
    search.alphaw <- FALSE
  } else if (init.cov < coverage_range[1]) {
    range_alphaw <- seq(0.001, (alpha-0.001), 0.001)
    search.alphaw <- TRUE
  } else {
    range_alphaw <- seq((alpha+0.001), 0.3, 0.001)
    search.alphaw <- TRUE
  }

  ## apply grid search for alphaw values
  if (search.alphaw) {
    covset <- lapply(range_alphaw,
                     formpi,
                     BOP = BOPcv,
                     mean = cv.mean.oob,
                     response = traindata[, yvar.names])
    covset <- vapply(covset, function(x) mean(x$cov), numeric(1))
    alphaw <- findbestalphaw(covset, alpha, range_alphaw, coverage_range)
  }

  return(alphaw)
}

################################################################################
## OOB calibration
calibrate_oob <- function (coverage_range, alpha, BOPoob, mean.oob, yvar) {
  ## compute OOB-coverage with alpha before calibration
  PI.obj <- formpi(alpha = alpha,
                   BOP = BOPoob,
                   mean = mean.oob,
                   response = yvar)
  init.cov <- mean(PI.obj$cov)

  ## if OOB-coverage is not within the coverage_range
  ## form a grid of alphaw values to be searched
  if ( (init.cov <= coverage_range[2]) & (init.cov >= coverage_range[1]) ) {
    alphaw <- alpha
    search.alphaw <- FALSE
  } else if (init.cov < coverage_range[1]) {
    range_alphaw <- seq(0.001, (alpha-0.001), 0.001)
    search.alphaw <- TRUE
  } else {
    range_alphaw <- seq((alpha+0.001), 0.3, 0.001)
    search.alphaw <- TRUE
  }

  ## apply grid search for alphaw values
  if (search.alphaw) {
    covset <- lapply(range_alphaw,
                     formpi,
                     BOP = BOPoob,
                     mean = mean.oob,
                     response = yvar)
    covset <- vapply(covset, function(x) mean(x$cov), numeric(1))
    alphaw <- findbestalphaw(covset, alpha, range_alphaw, coverage_range)
  }

  return(alphaw)
}

################################################################################
## function to select best alphaw
findbestalphaw <- function (covset, alpha, range_alphaw, coverage_range) {
  ## find alphaw that are within coverage_range
  cov.ix <- which(covset >= coverage_range[1] & covset <= coverage_range[2])

  if (length(cov.ix) == 1) {
    alphaw <- range_alphaw[cov.ix]
  } else if (length(cov.ix) > 1) {
    ## if there is alphaw with the coverage_range
    ## select the one closest to alpha
    diff <- abs(range_alphaw[cov.ix] - alpha)
    ix <- which.min(diff)
    alphaw <- range_alphaw[cov.ix[ix]]
  } else {
    ## if there is no alphaw within the coverage_range
    ## select the one with the coverage closest to (1-alpha)
    diff <- abs(1 - alpha - covset)
    cov.ix <- which(diff == min(diff))
    diff2 <- abs(range_alphaw[cov.ix] - alpha)
    ix <- which.min(diff2)
    alphaw <- range_alphaw[cov.ix[ix]]
  }

  return(alphaw)
}

################################################################################
## calibration function for Roy's methods
calibration <- function (params_calib, params_formpi, formpi_fnc) {
  level <- params_calib[["start"]]
  range <- params_calib[["range"]]
  step <- params_calib[["step"]]
  refine <- params_calib[["refine"]]
  laststep <- 0
  covw <- 0
  ## until coverage is within the limits search for alphaw
  while (!(range[2] >= covw & covw >= range[1])) {
    params_formpi[["alpha"]] <- (1-level)
    covw <- do.call(formpi_fnc, params_formpi)
    covw <- mean(covw$cov)
    if (covw < range[1]) {
      if (laststep == 1) {
        if (refine) {
          step <- step/2
          if (step < .002) {break}
        } else {
          level <- oldlevel
          break
        }
      }
      oldlevel <- level
      level <- level + step
      laststep <- 2
    }
    if (covw > range[2]) {
      if (laststep == 2) {
        if (refine) {
          step <- step/2
          if (step < .002) {break}
        } else {break}
      }
      oldlevel <- level
      level <- level - step
      laststep <- 1
    }
    if (level >= .999) {break}
    if (level >= .99) {step <- .002}
  }
  alphaw <- 1 - level

  return(alphaw)
}
