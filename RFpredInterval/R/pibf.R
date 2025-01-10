#' Prediction intervals with boosted forests
#'
#' Constructs prediction intervals with boosted forests.
#'
#' @param formula Object of class \code{formula} or \code{character} describing
#'   the model to fit.
#' @param traindata Training data of class \code{data.frame}.
#' @param testdata Test data of class \code{data.frame}.
#' @param alpha Confidence level. (1 - \code{alpha}) is the desired coverage
#'   level. The default is \code{alpha} = 0.05 for the 95% prediction interval.
#' @param calibration Calibration method for finding working level of
#'   \code{alpha}, i.e. \eqn{\alpha_w}. Options are \code{"cv"}, \code{"oob"},
#'   and \code{FALSE} standing for calibration with cross-validation, OOB
#'   calibration, and no calibration, respectively. See below for details. The
#'   default is \code{"cv"}.
#' @param coverage_range The allowed target calibration range for coverage level.
#'   \eqn{\alpha_w} is selected such that the \code{"cv"} or \code{"oob"}
#'   coverage is within \code{coverage_range}.
#' @param numfolds Number of folds for calibration with cross-validation. The
#'   default is 5 folds.
#' @param params_ranger List of parameters that should be passed to
#'   \code{ranger}. In the default parameter set, \code{num.trees} = 2000,
#'   \code{mtry} = \eqn{px/3} (rounded up), \code{min.node.size} = 5,
#'   \code{replace} = TRUE. See \code{ranger} for possible parameters.
#' @param oob Should out-of-bag (OOB) predictions and prediction intervals for
#'   the training observations be returned?
#'
#' @section Details:
#'
#'   \strong{Calibration process}
#'
#'   Let (\eqn{1-\alpha}) be the target coverage level. The goal of the
#'   calibration is to find the value of \eqn{\alpha_w}, which is the working
#'   level of \eqn{\alpha} called by Roy and Larocque (2020), such that the
#'   coverage level of the PIs for the training observations is closest to the
#'   target coverage level. Two calibration procedures are provided: calibration
#'   with cross-validation and out-of-bag (OOB) calibration.
#'
#'   \enumerate{
#'   \item In calibration with CV, we apply k-fold cross-validation to form
#'   prediction intervals for the training observations. In each fold, we split
#'   the original training data set into training and testing sets. For the
#'   training set, we train a one-step boosted random forest and compute the OOB
#'   residuals. Then, for each observation in the testing set, we build a PI.
#'   After completing CV, we compute the coverage level with the constructed PIs
#'   and if the coverage is not within the acceptable coverage range
#'   (\code{coverage_range}), then we apply a grid search to find the
#'   \eqn{\alpha_w} such that \eqn{\alpha_w} is the closest to the target
#'   \eqn{\alpha} among the set of \eqn{\alpha_w}'s that ensures the target
#'   coverage level for the constructed PIs. Once we find the \eqn{\alpha_w}, we
#'   use this level to build the PI for the new observations.
#'
#'   \item The OOB calibration procedure is proposed by Roy and Larocque (2020)
#'   and it is the default calibration procedure of \code{rfpi()}. See details
#'   section of \code{rfpi()} for the detailed explanation of this calibration
#'   procedure.
#'   }
#'
#'   In terms of computational time, OOB calibration is faster than calibration
#'   with CV. However, empirical results show that OOB calibration may result in
#'   conservative prediction intervals. Therefore, the recommended calibration
#'   procedure for the PIBF method is calibration with CV.
#'
#'
#' @return A list with the following components:
#'
#'   \item{pred_interval}{Prediction intervals for test data. A list containing
#'   lower and upper bounds.}
#'   \item{test_pred}{Bias-corrected random forest predictions for test data.}
#'   \item{alphaw}{Working level of \code{alpha}, i.e. \eqn{\alpha_w}. If
#'   \code{calibration = FALSE}, it returns \code{NULL}.}
#'   \item{test_response}{If available, test response.}
#'   \item{oob_pred_interval}{Out-of-bag (OOB) prediction intervals for train
#'   data. Prediction intervals are built with \code{alpha}. If
#'   \code{oob = FALSE}, it returns \code{NULL}.}
#'   \item{oob_pred}{Bias-corrected out-of-bag (OOB) predictions for train data.
#'   If \code{oob = FALSE}, it returns \code{NULL}.}
#'   \item{train_response}{Train response.}
#'
#' @references Alakus, C., Larocque, D., & Labbe, A. (2022). RFpredInterval: An
#'   R Package for Prediction Intervals with Random Forests and Boosted Forests.
#'   R JOURNAL, 14(1), 300-319.
#' @references Roy, M. H., & Larocque, D. (2020). Prediction intervals with
#'   random forests. Statistical methods in medical research, 29(1), 205-229.
#'   doi:10.1177/0962280219829885.
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
#'   testdata = testdata, calibration = "cv", numfolds = 5,
#'   params_ranger = list(num.trees = 40))
#'
#' ## get the PI for the first observation in the testdata
#' c(out$pred_interval$lower[1], out$pred_interval$upper[1])
#'
#' ## get the bias-corrected random forest predictions for testdata
#' out$test_pred
#'
#' ## construct 90% PI with "oob" calibration
#' out2 <- pibf(formula = medv ~ ., traindata = traindata,
#'   testdata = testdata, alpha = 0.1, calibration = "oob",
#'   coverage_range = c(0.89,91), params_ranger = list(num.trees = 40))
#'
#' ## get the PI for the testdata
#' out2$pred_interval
#'
#' ## get the working level of alpha (alphaw)
#' out2$alphaw
#' }
#'
#' @seealso \code{\link{piall}} \code{\link{rfpi}}
#' \code{\link{print.rfpredinterval}}

pibf <- function(formula,
                 traindata,
                 testdata,
                 alpha = 0.05,
                 calibration = c("cv", "oob", FALSE),
                 coverage_range = c(1-alpha-0.005, 1-alpha+0.005),
                 numfolds = 5,
                 params_ranger = list(num.trees = 2000, mtry = ceiling(px/3),
                                      min.node.size = 5, replace = TRUE),
                 oob = FALSE)
{
  ## make formula object
  formula <- as.formula(formula)

  ## initial checks for data sets
  if (is.null(traindata)) {stop("'traindata' is missing.")}
  if (is.null(testdata)) {stop("'testdata' is missing.")}
  if (!is.data.frame(traindata)) {stop("'traindata' must be a data frame.")}
  if (!is.data.frame(testdata)) {stop("'testdata' must be a data frame.")}
  traindata <- as.data.frame(traindata)
  testdata <- as.data.frame(testdata)

  ## verify key options
  calibration <- match.arg(as.character(calibration), c("cv", "oob", FALSE))
  oob <- match.arg(as.character(oob), c(FALSE, TRUE))

  ## check the dimension of coverage_range
  if (length(as.numeric(coverage_range)) != 2) {
    stop("'coverage_range' should be a numeric vector of length 2.")
  }
  ## sort coverage_range
  coverage_range <- sort(coverage_range)
  ## check if target coverage level is within coverage_range
  if ( ((1-alpha) < coverage_range[1]) | ((1-alpha) > coverage_range[2]) ) {
    stop("1-alpha is not within the limits of 'coverage_range'.")
  }

  ## get variable names
  all.names <- all.vars(formula, max.names = 1e7)
  yvar.names <- all.vars(formula(paste(as.character(formula)[2], "~ .")), max.names = 1e7)
  yvar.names <- yvar.names[-length(yvar.names)]
  py <- length(yvar.names)
  if (length(all.names) <= py) {
    stop("formula is misspecified: total number of variables does not exceed total number of y-variables")
  }
  if (all.names[py + 1] == ".") {
    if (py == 0) {
      xvar.names <- names(traindata)
    } else {
      xvar.names <- names(traindata)[!is.element(names(traindata), all.names[1:py])]
    }
  } else {
    if(py == 0) {
      xvar.names <- all.names
    } else {
      xvar.names <- all.names[-c(1:py)]
    }
    not.specified <- !is.element(xvar.names, names(traindata))
    if (sum(not.specified) > 0) {
      stop("formula is misspecified, object ", xvar.names[not.specified], " not found")
    }
  }
  xvar <- traindata[, xvar.names, drop = FALSE]
  yvar <- traindata[, yvar.names, drop = FALSE]
  traindata <- cbind(xvar, yvar)
  yvar <- yvar[, yvar.names]

  ## get sample size and px
  ntrain <- nrow(traindata)
  px <- ncol(xvar)

  ## set parameters for ranger
  if (is.null(params_ranger)) {
    params_ranger <- list()
  }
  param_names <- names(params_ranger)
  if (!("mtry" %in% param_names)) {params_ranger[["mtry"]] <- ceiling(px/3)}
  if (!("num.trees" %in% param_names)) {params_ranger[["num.trees"]] <- 2000}
  if (!("min.node.size" %in% param_names)) {params_ranger[["min.node.size"]] <- 5}
  if (!("replace" %in% param_names)) {params_ranger[["replace"]] <- TRUE}
  params_ranger[["formula"]] <- formula

  ## train first RF: mean RF
  params_ranger[["data"]] <- traindata
  params_ranger[["keep.inbag"]] <- FALSE
  rf.mean <- do.call(ranger::ranger, params_ranger)

  ## get oob mean predictions
  mean.oob <- rf.mean$predictions
  if (sum(is.nan(mean.oob)) > 0) {
    stop("Some of the OOB predictions are NaN. Increase the number of trees, 'num.trees' in params_ranger.")
  }

  ## compute oob residuals
  res <- yvar - as.numeric(mean.oob)

  ## train second RF: residual RF
  traindata.res <- traindata
  traindata.res[, yvar.names] <- res
  params_ranger[["data"]] <- traindata.res
  params_ranger[["keep.inbag"]] <- TRUE
  rf.res <- do.call(ranger::ranger, params_ranger)

  ## update the oob mean predictions with oob bias predictions
  bias.oob <- rf.res$predictions
  mean.oob <- mean.oob + bias.oob

  ## compute new residuals after bias correction
  res <- yvar - as.numeric(mean.oob)

  ## filter the test data based on the formula
  testdata <- testdata[, is.element(names(testdata),
                                    c(yvar.names, xvar.names)), drop = FALSE]

  ## get bias-corrected predictions for test data
  mean.test <- predict(rf.mean, data = testdata)$predictions
  bias.test <- predict(rf.res, data = testdata)$predictions
  mean.test <- mean.test + bias.test

  ## build BOP for test data using the second RF
  ntree <- rf.res$num.trees
  mem.train <- predict(rf.res, data = traindata, type = "terminalNodes")$predictions
  mem.test <- predict(rf.res, data = testdata, type = "terminalNodes")$predictions
  inbag <- matrix(unlist(rf.res$inbag.counts, use.names = FALSE), ncol = ntree, byrow = FALSE)
  BOPtest <- buildtestbop(mem.train = mem.train, mem.test = mem.test, inbag = inbag, residual = res)

  ## calibration process
  if (calibration == FALSE) {
    alphaw <- alpha
  } else if (calibration == "cv") {
    alphaw <- calibrate_cv(coverage_range, alpha, traindata, numfolds, params_ranger, yvar.names)
  } else if (calibration == "oob") {
    BOPoob <- buildoobbop(mem.train, inbag, residual = res)
    if (sum(sapply(BOPoob, is.null)) > 0) {
      stop("Some observations have empty BOP. Increase the number of trees, 'num.trees' in params_ranger.")
    }
    alphaw <- calibrate_oob(coverage_range, alpha, BOPoob, mean.oob, yvar)
  }

  ## PI construction for test data
  PI.obj <- formpi(alpha = alphaw,
                   BOP = BOPtest,
                   mean = mean.test,
                   response = NULL)

  ## store PI information
  pred.interval <- list(lower = PI.obj$lower,
                       upper = PI.obj$upper)

  ## PI construction for train data with OOB predictions and OOB-BOP
  if (oob) {
    if (calibration != "oob") {
      BOPoob <- buildoobbop(mem.train, inbag, residual = res)
    }
    PI.obj <- formpi(alpha = alpha,
                     BOP = BOPoob,
                     mean = mean.oob,
                     response = NULL)
    oob.pred.interval <- list(lower = PI.obj$lower,
                              upper = PI.obj$upper)
  }

  ## return list
  out <- list(pred_interval = pred.interval,
              test_pred = mean.test,
              alphaw = if(calibration == FALSE){NULL}else{alphaw},
              test_response = if(is.element(yvar.names, names(testdata))){testdata[, yvar.names]}else{NULL},
              oob_pred_interval = if(oob){oob.pred.interval}else{NULL},
              oob_pred = if(oob){mean.oob}else{NULL},
              train_response = yvar)

  class(out) <- c("rfpredinterval", "pibf")
  return(out)
}
