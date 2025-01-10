#' Prediction intervals with random forests
#'
#' Constructs prediction intervals with 15 distinct variations proposed by Roy
#' and Larocque (2020). The variations include two aspects: The method used to
#' build the forest and the method used to build the prediction interval. There
#' are three methods to build the forest, (i) least-squares (LS), (ii) L1 and
#' (iii) shortest prediction interval (SPI) from the CART paradigm. There are
#' five methods for constructing prediction intervals, classical method,
#' shortest prediction interval, quantile method, highest density region, and
#' contiguous HDR.
#'
#' @param formula Object of class \code{formula} or \code{character} describing
#'   the model to fit.
#' @param traindata Training data of class \code{data.frame}.
#' @param testdata Test data of class \code{data.frame}.
#' @param alpha Confidence level. (1 - \code{alpha}) is the desired coverage
#'   level. The default is \code{alpha} = 0.05 for the 95% prediction interval.
#' @param split_rule Split rule for building a forest. Options are \code{"ls"}
#'   for CART with least-squares (LS) splitting rule, \code{"l1"} for CART with
#'   L1 splitting rule, \code{"spi"} for CART with shortest prediction interval
#'   (SPI) splitting rule. The default is \code{"ls"}.
#' @param pi_method Methods for building a prediction interval. Options are
#'   \code{"lm"} for classical method, \code{"spi"} for shortest prediction
#'   interval, \code{"quant"} for quantile method, \code{"hdr"} for highest
#'   density region, and \code{"chdr"} for contiguous HDR. The default is to use
#'   all methods for PI construction. Single method or a subset of methods can
#'   be applied.
#' @param calibration Apply OOB calibration for finding working level of
#'   \code{alpha}, i.e. \eqn{\alpha_w}. See below for details. The default is
#'   \code{TRUE}.
#' @param rf_package Random forest package that can be used for RF training.
#'   Options are \code{"rfsrc"} for \code{randomForestSRC} and \code{"ranger"}
#'   for \code{ranger} packages. Split rule \code{"ls"} can be used with both
#'   packages. However, \code{"l1"} and \code{"spi"} split rules can only be
#'   used with \code{"rfsrc"}. The default is \code{"rfsrc"}.
#' @param params_rfsrc List of parameters that should be passed to
#'   \code{randomForestSRC}. In the default parameter set, \code{ntree} = 2000,
#'   \code{mtry} = \eqn{px/3}  (rounded up), \code{nodesize} = 5,
#'   \code{samptype} = "swr". See \code{randomForestSRC} for possible
#'   parameters.
#' @param params_ranger List of parameters that should be passed to
#'   \code{ranger}. In the default parameter set, \code{num.trees} = 2000,
#'   \code{mtry} = \eqn{px/3}  (rounded up), \code{min.node.size} = 5,
#'   \code{replace} = TRUE. See \code{ranger} for possible parameters.
#' @param params_calib List of parameters for calibration procedure.
#'   \code{range} is the allowed target calibration range for coverage level.
#'   The value that provides a coverage level within the range is chosen as
#'   \eqn{\alpha_w}. \code{start} is the initial coverage level to start
#'   calibration procedure. \code{step} is the coverage step size for each
#'   calibration iteration. \code{refine} is the gradual decrease in \code{step}
#'   value when close to target coverage level, the default is \code{TRUE} which
#'   allows gradual decrease.
#' @param oob Should out-of-bag (OOB) predictions and prediction intervals for
#'   the training observations be returned?
#'
#' @section Details:
#'
#'   \strong{Calibration process}
#'
#'   The calibration procedure uses the "Bag of Observations for Prediction"
#'   (BOP) idea. BOP for a new observation is built with the set inbag
#'   observations that are in the same terminal nodes as the new observation.
#'   The calibration procedure uses the BOPs constructed for the training
#'   observations. BOP for a training observation is built using only the trees
#'   where this training observation is out-of-bag (OOB).
#'
#'   Let (\eqn{1-\alpha}) be the target coverage level. The goal of the
#'   calibration is to find the value of \eqn{\alpha_w}, which is the working
#'   level of \eqn{\alpha} called by Roy and Larocque (2020), such that the
#'   coverage level of the prediction intervals for the training observations is
#'   closest to the target coverage level. The idea is to find the value of
#'   \eqn{\alpha_w} using the OOB-BOPs. Once found, (\eqn{1-\alpha_w}) becomes
#'   the level used to build the prediction intervals for the new observations.
#'
#'
#' @return A list with the following components:
#'
#'   \item{lm_interval}{Prediction intervals for test data with the classical
#'   method. A list containing lower and upper bounds.}
#'   \item{spi_interval}{Prediction intervals for test data with SPI method. A
#'   list containing lower and upper bounds.}
#'   \item{hdr_interval}{Prediction intervals for test data with HDR method. A
#'   list containing lower and upper bounds of prediction interval for each test
#'   observation. There may be multiple PIs for a single observation.}
#'   \item{chdr_interval}{Prediction intervals for test data with contiguous HDR
#'   method. A list containing lower and upper bounds.}
#'   \item{quant_interval}{Prediction intervals for test data with quantiles
#'   method. A list containing lower and upper bounds.}
#'   \item{test_pred}{Random forest predictions for test data.}
#'   \item{test_response}{If available, test response.}
#'   \item{alphaw}{Working level of \code{alpha}, i.e. \eqn{\alpha_w}. A numeric
#'   array for the PI methods entered with \code{pi_method}. If
#'   \code{calibration = FALSE}, it returns \code{NULL}.}
#'   \item{split_rule}{Split rule used for building the random forest.}
#'   \item{rf_package}{Random forest package that was used for RF training.}
#'   \item{oob_pred_interval}{Out-of-bag (OOB) prediction intervals for train
#'   data. Prediction intervals are built with \code{alpha}. If
#'   \code{oob = FALSE}, it returns \code{NULL}.}
#'   \item{oob_pred}{Out-of-bag (OOB) predictions for train data.
#'   If \code{oob = FALSE}, it returns \code{NULL}.}
#'   \item{train_response}{Train response.}
#'
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
#' ## contruct 90% PI with "l1" split rule and "spi" PI method with calibration
#' out <- rfpi(formula = medv ~ ., traindata = traindata,
#'   testdata = testdata, alpha = 0.1, calibration = TRUE,
#'   split_rule = "l1", pi_method = "spi", params_rfsrc = list(ntree = 50),
#'   params_calib = list(range = c(0.89, 0.91), start = 0.9, step = 0.01,
#'   refine = TRUE))
#'
#' ## get the PI with "spi" method for first observation in the testdata
#' c(out$spi_interval$lower[1], out$spi_interval$upper[1])
#'
#' ## get the random forest predictions for testdata
#' out$test_pred
#'
#' ## get the working level of alpha (alphaw)
#' out$alphaw
#'
#' ## contruct 95% PI with "ls" split rule, "lm" and "quant" PI methods
#' ## with calibration and use "ranger" package for RF training
#' out2 <- rfpi(formula = medv ~ ., traindata = traindata,
#'   testdata = testdata, split_rule = "ls", pi_method = c("lm", "quant"),
#'   rf_package = "ranger", params_ranger = list(num.trees = 50))
#'
#' ## get the PI with "quant" method for the testdata
#' cbind(out2$quant_interval$lower, out2$quant_interval$upper)
#' }
#'
#' @seealso \code{\link{piall}} \code{\link{pibf}}
#' \code{\link{print.rfpredinterval}}

rfpi <- function(formula,
                 traindata,
                 testdata,
                 alpha = 0.05,
                 split_rule = c("ls", "l1", "spi"),
                 pi_method = c("lm", "spi", "quant", "hdr", "chdr"),
                 calibration = TRUE,
                 rf_package = c("rfsrc", "ranger"),
                 params_rfsrc = list(ntree = 2000, mtry = ceiling(px/3),
                                     nodesize = 5, samptype = "swr"),
                 params_ranger = list(num.trees = 2000, mtry = ceiling(px/3),
                                      min.node.size = 5, replace = TRUE),
                 params_calib = list(range = c(1-alpha-0.005, 1-alpha+0.005),
                                     start = (1-alpha), step = 0.01, refine = TRUE),
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
  rf_package <- match.arg(rf_package, c("rfsrc", "ranger"))
  split_rule <- match.arg(split_rule, c("ls", "l1", "spi"))
  pi_method <- match.arg(pi_method, c("lm", "spi", "quant", "hdr", "chdr"), several.ok = TRUE)
  set_pi_method <- pi_method
  oob <- match.arg(as.character(oob), c(FALSE, TRUE))

  ## check for split_rule - package consistency
  if ((split_rule == "l1" || split_rule == "spi") & rf_package == "ranger") {
    stop(paste0(split_rule," split rule cannot be applied with ranger package. Change rf_package to rfsrc."))
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

  ## filter the test data based on the formula
  testdata <- testdata[, is.element(names(testdata),
                                    c(yvar.names, xvar.names)), drop = FALSE]

  if (rf_package == "rfsrc") {

    ## set parameters for rfsrc
    if (is.null(params_rfsrc)) {
      params_rfsrc <- list()
    }
    param_names <- names(params_rfsrc)
    if (!("mtry" %in% param_names)) {params_rfsrc[["mtry"]] <- ceiling(px/3)}
    if (!("ntree" %in% param_names)){params_rfsrc[["ntree"]] <- 2000}
    if (!("nodesize" %in% param_names)) {params_rfsrc[["nodesize"]] <- 5}
    if (!("samptype" %in% param_names)) {params_rfsrc[["samptype"]] <- "swr"}
    params_rfsrc[["formula"]] <- formula
    params_rfsrc[["data"]] <- traindata
    params_rfsrc[["membership"]] <- TRUE
    if (split_rule == "l1") {
      params_rfsrc[["split_rule"]] <- "custom2"
    } else if (split_rule == "spi") {
      params_rfsrc[["split_rule"]] <- "custom3"
    }

    ## train RF with rfsrc
    rf <- do.call(rfsrc, params_rfsrc)

    ## get oob mean predictions
    mean.oob <- rf$predicted.oob

    ## get test predictions
    pred <- predict(rf, newdata = testdata, membership = TRUE)
    mean.test <- pred$predicted

    ## get membership and inbag information
    ntree <- rf$ntree
    mem.train <- rf$membership
    mem.test <- pred$membership
    inbag <- rf$inbag

  } else if (rf_package == "ranger") {

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
    params_ranger[["data"]] <- traindata
    params_ranger[["keep.inbag"]] <- TRUE

    ## train RF with ranger
    rf <- do.call(ranger::ranger, params_ranger)

    ## get oob mean predictions
    mean.oob <- rf$predictions

    ## get test predictions
    mean.test <- predict(rf, data = testdata)$predictions

    ## get membership and inbag information
    ntree <- rf$num.trees
    mem.train <- predict(rf, traindata, type="terminalNodes")$predictions
    mem.test <- predict(rf, testdata, type="terminalNodes")$predictions
    inbag <- matrix(unlist(rf$inbag.counts, use.names = FALSE), ncol = ntree, byrow = FALSE)

  }

  ## build test-BOP
  BOPtest <- buildtestbop_ib(mem.train, mem.test, inbag, yvar)

  ## initialize storage
  PI_list <- list()
  oob_PI_list <- list()
  alphaw_list <- list()
  bw <- NULL

  ## form PI for each PI method
  for (pi_method in set_pi_method) {
    ## assign the function of pi method
    if (pi_method == "lm") {
      formpi_fnc <- as.function(formpi_lm)
    } else if (pi_method == "spi") {
      formpi_fnc <- as.function(formpi_spi)
    } else if (pi_method == "quant") {
      formpi_fnc <- as.function(formpi_quant)
    } else if (pi_method == "hdr") {
      formpi_fnc <- as.function(formpi_hdr)
    } else if (pi_method == "chdr") {
      formpi_fnc <- as.function(formpi_chdr)
    }

    ## calibration process
    if (calibration) {
      ## set parameters for calibration
      if (is.null(params_calib)) {
        params_calib <- list()
      }
      param_names <- names(params_calib)
      if (!("range" %in% param_names)) {params_calib[["range"]] <- c(1-alpha-0.005, 1-alpha+0.005)}
      if (!("start" %in% param_names)) {params_calib[["start"]] <- 1-alpha}
      if (!("step" %in% param_names)) {params_calib[["step"]] <- 0.01}
      if (!("refine" %in% param_names)) {params_calib[["refine"]] <- TRUE}

      ## build OOB-BOP
      BOPoob <- buildoobbop_ib(mem.train, inbag, yvar)
      if (sum(sapply(BOPoob, is.null)) > 0) {
        if (rf_package == "ranger") {
          stop("Some observations have empty BOP. Increase the number of trees, 'num.trees' in params_ranger.")
        } else {
          stop("Some observations have empty BOP. Increase the number of trees, 'ntree' in params_rfsrc.")
        }
      }

      ## compute optimal bandwidth for hdr and chdr
      if (pi_method %in% c("hdr","chdr")) {
        if (is.null(bw)) {
          bw <- opt_bw(BOP = BOPoob, alpha = alpha, nn = 10)
        }
      }

      ## set parameters for form PI functions
      params_formpi <- list(BOP = BOPoob, response = yvar)
      if (pi_method %in% c("hdr","chdr")) {
        params_formpi[["bw"]] <- bw
      }

      ## find alphaw
      alphaw <- calibration(params_calib, params_formpi, formpi_fnc)
    } else {
      ## assign alpha to alphaw
      alphaw <- alpha

      ## compute optimal bandwidth for hdr and chdr
      if (pi_method %in% c("hdr","chdr")) {
        if (is.null(bw)) {
          ## build OOB-BOP
          BOPoob <- buildoobbop_ib(mem.train, inbag, yvar)
          if (sum(sapply(BOPoob, is.null)) > 0) {
            if (rf_package == "ranger") {
              stop("Some observations have empty BOP. Increase the number of trees, 'num.trees' in params_ranger.")
            } else {
              stop("Some observations have empty BOP. Increase the number of trees, 'ntree' in params_rfsrc.")
            }
          }
          bw <- opt_bw(BOP = BOPoob, alpha = alpha, nn = 10)
        }
      }
    }

    ## PI construction for test data
    if (pi_method %in% c("hdr","chdr")) {
      PI.obj <- formpi_fnc(BOP = BOPtest,
                           alpha = alphaw,
                           bw = bw,
                           response = NULL)
    } else {
      PI.obj <- formpi_fnc(BOP = BOPtest,
                           alpha = alphaw,
                           response = NULL)
    }

    ## store PI information
    if (pi_method == "hdr") {
      pred_interval <- PI.obj$pi
    } else {
      pred_interval = list(lower = PI.obj$lower, upper = PI.obj$upper)
    }
    PI_list[[pi_method]] <- pred_interval
    alphaw_list[[pi_method]] <- alphaw

    ## PI construction for train data with OOB predictions and OOB-BOP
    if (oob) {
      if (pi_method %in% c("hdr","chdr")) {
        PI.obj <- formpi_fnc(BOP = BOPoob,
                             alpha = alpha,
                             bw = bw,
                             response = NULL)
      } else {
        BOPoob <- buildoobbop_ib(mem.train, inbag, yvar)
        PI.obj <- formpi_fnc(BOP = BOPoob,
                             alpha = alpha,
                             response = NULL)
      }

      ## store PI information for train data
      if (pi_method == "hdr") {
        oob_pred_interval <- PI.obj$pi
      } else {
        oob_pred_interval = list(lower = PI.obj$lower, upper = PI.obj$upper)
      }
      oob_PI_list[[pi_method]] <- oob_pred_interval
    }
  }## end of PI construction for each PI method

  alphaw <- unlist(alphaw_list)

  ## return list
  out <- list(lm_interval = if("lm" %in% set_pi_method){PI_list[["lm"]]}else{NULL},
              spi_interval = if("spi" %in% set_pi_method){PI_list[["spi"]]}else{NULL},
              hdr_interval = if("hdr" %in% set_pi_method){PI_list[["hdr"]]}else{NULL},
              chdr_interval = if("chdr" %in% set_pi_method){PI_list[["chdr"]]}else{NULL},
              quant_interval = if("quant" %in% set_pi_method){PI_list[["quant"]]}else{NULL},
              test_pred = mean.test,
              test_response = if(is.element(yvar.names, names(testdata))){testdata[, yvar.names]}else{NULL},
              alphaw = if(calibration){alphaw}else{NULL},
              split_rule = split_rule,
              rf_package = rf_package,
              oob_pred_interval = if(oob){oob_PI_list}else{NULL},
              oob_pred = if(oob){mean.oob}else{NULL},
              train_response = yvar)

  class(out) <- c("rfpredinterval", "rfpi")
  return(out)
}
