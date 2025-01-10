#' Prediction intervals with all methods
#'
#' Constructs prediction intervals with the 16 methods (PIBF method implemented
#' in \code{pibf()} and 15 method variations implemented in \code{rfpi()}).
#'
#' @param formula Object of class \code{formula} or \code{character} describing
#'   the model to fit.
#' @param traindata Training data of class \code{data.frame}.
#' @param testdata Test data of class \code{data.frame}.
#' @param alpha Confidence level. (1 - \code{alpha}) is the desired coverage
#'   level. The default is \code{alpha} = 0.05 for the 95% prediction interval.
#' @param num.trees Number of trees. The default is \code{num.trees} = 2000
#' @param mtry Number of variables randomly selected as candidates for splitting
#'   a node. The default is rounded up \eqn{px/3} where \eqn{px} is the number
#'   of variables.
#'
#' @return A list with the following components:
#'
#'   \item{PIBF}{Prediction intervals for test data with PIBF method. A list
#'   containing lower and upper bounds.}
#'   \item{LS_LM}{Prediction intervals for test data with least-squares (LS)
#'   splitting rule and classical method (LM). A list containing lower and upper
#'   bounds.}
#'   \item{LS_SPI}{Prediction intervals for test data with least-squares (LS)
#'   splitting rule and shortest PI (SPI) method. A list containing lower and
#'   upper bounds.}
#'   \item{LS_Quant}{Prediction intervals for test data with least-squares (LS)
#'   splitting rule and quantiles method. A list containing lower and upper
#'   bounds.}
#'   \item{LS_HDR}{Prediction intervals for test data with least-squares (LS)
#'   splitting rule and highest density region (HDR) method. A list containing
#'   lower and upper bounds of prediction interval for each test observation.
#'   There may be multiple PIs for a single observation.}
#'   \item{LS_CHDR}{Prediction intervals for test data with least-squares (LS)
#'   splitting rule and contiguous HDR method. A list containing lower and upper
#'   bounds.}
#'   \item{L1_LM}{Prediction intervals for test data with \eqn{L_1} splitting
#'   rule and classical method (LM). A list containing lower and upper bounds.}
#'   \item{L1_SPI}{Prediction intervals for test data with \eqn{L_1} splitting
#'   rule and shortest PI (SPI) method. A list containing lower and upper
#'   bounds.}
#'   \item{L1_Quant}{Prediction intervals for test data with \eqn{L_1} splitting
#'   rule and quantiles method. A list containing lower and upper bounds.}
#'   \item{L1_HDR}{Prediction intervals for test data with \eqn{L_1} splitting
#'   rule and highest density region (HDR) method. A list containing lower and
#'   upper bounds of prediction interval for each test observation. There may be
#'   multiple PIs for a single observation.}
#'   \item{L1_CHDR}{Prediction intervals for test data with \eqn{L_1} splitting
#'   rule and contiguous HDR method. A list containing lower and upper bounds.}
#'   \item{SPI_LM}{Prediction intervals for test data with shortest PI (SPI)
#'   splitting rule and classical method (LM). A list containing lower and upper
#'   bounds.}
#'   \item{SPI_SPI}{Prediction intervals for test data with shortest PI (SPI)
#'   splitting rule and shortest PI (SPI) method. A list containing lower and
#'   upper bounds.}
#'   \item{SPI_Quant}{Prediction intervals for test data with shortest PI (SPI)
#'   splitting rule and quantiles method. A list containing lower and upper
#'   bounds.}
#'   \item{SPI_HDR}{Prediction intervals for test data with shortest PI (SPI)
#'   splitting rule and highest density region (HDR) method. A list containing
#'   lower and upper bounds of prediction interval for each test observation.
#'   There may be multiple PIs for a single observation.}
#'   \item{SPI_CHDR}{Prediction intervals for test data with shortest PI (SPI)
#'   splitting rule and contiguous HDR method. A list containing lower and upper
#'   bounds.}
#'   \item{pred_pibf}{Bias-corrected random forest predictions for test data.}
#'   \item{pred_ls}{Random forest predictions for test data with least-squares
#'   (LS) splitting rule.}
#'   \item{pred_l1}{Random forest predictions for test data with \eqn{L_1}
#'   splitting rule.}
#'   \item{pred_spi}{Random forest predictions for test data with shortest PI
#'   (SPI) splitting rule.}
#'   \item{test_response}{If available, true response values of the test data.
#'   Otherwise, \code{NULL}.}
#'
#' @examples
#' \donttest{
#' ## load example data
#' data(BostonHousing, package = "RFpredInterval")
#' set.seed(2345)
#'
#' ## define train/test split
#' testindex <- 1
#' trainindex <- sample(2:nrow(BostonHousing), size = 50, replace = FALSE)
#' traindata <- BostonHousing[trainindex, ]
#' testdata <- BostonHousing[testindex, ]
#'
#' ## construct 95% PI with 16 methods for the first observation in testdata
#' out <- piall(formula = medv ~ ., traindata = traindata,
#'   testdata = testdata, num.trees = 50)
#' }
#'
#' @seealso \code{\link{pibf}} \code{\link{rfpi}}
#' \code{\link{plot.rfpredinterval}} \code{\link{print.rfpredinterval}}

piall <- function(formula,
                  traindata,
                  testdata,
                  alpha = 0.05,
                  num.trees = 2000,
                  mtry = ceiling(px/3))
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

  ## set parameters for ranger and rfsrc
  params_ranger <- list(num.trees = num.trees, mtry = mtry)
  params_rfsrc <- list(ntree = num.trees, mtry = mtry)

  ## build PIs with PIBF
  pibf_obj <- pibf(formula, traindata, testdata, alpha,
                   calibration = "cv", params_ranger = params_ranger)

  ## build PIs with RFPI
  pi_method <- c("lm", "spi", "quant", "hdr", "chdr")

  rfpi_ls_obj <- rfpi(formula, traindata, testdata, alpha,
                      split_rule = "ls", pi_method = pi_method,
                      rf_package = "ranger", params_ranger = params_ranger)

  rfpi_l1_obj <- rfpi(formula, traindata, testdata, alpha,
                      split_rule = "l1", pi_method = pi_method,
                      rf_package = "rfsrc", params_rfsrc = params_rfsrc)

  rfpi_spi_obj <- rfpi(formula, traindata, testdata, alpha,
                       split_rule = "spi", pi_method = pi_method,
                       rf_package = "rfsrc", params_rfsrc = params_rfsrc)

  ## merge all PIs and point predictions into a list
  out <- list(PIBF = pibf_obj$pred_interval,
              LS_LM = rfpi_ls_obj$lm_interval,
              LS_SPI = rfpi_ls_obj$spi_interval,
              LS_Quant = rfpi_ls_obj$quant_interval,
              LS_HDR = rfpi_ls_obj$hdr_interval,
              LS_CHDR = rfpi_ls_obj$chdr_interval,
              L1_LM = rfpi_l1_obj$lm_interval,
              L1_SPI = rfpi_l1_obj$spi_interval,
              L1_Quant = rfpi_l1_obj$quant_interval,
              L1_HDR = rfpi_l1_obj$hdr_interval,
              L1_CHDR = rfpi_l1_obj$chdr_interval,
              SPI_LM = rfpi_spi_obj$lm_interval,
              SPI_SPI = rfpi_spi_obj$spi_interval,
              SPI_Quant = rfpi_spi_obj$quant_interval,
              SPI_HDR = rfpi_spi_obj$hdr_interval,
              SPI_CHDR = rfpi_spi_obj$chdr_interval,
              pred_pibf = as.numeric(pibf_obj$test_pred),
              pred_ls = as.numeric(rfpi_ls_obj$test_pred),
              pred_l1 = as.numeric(rfpi_l1_obj$test_pred),
              pred_spi = as.numeric(rfpi_spi_obj$test_pred),
              test_response = if(is.element(yvar.names, names(testdata))){testdata[, yvar.names]}else{NULL})

  class(out) <- c("rfpredinterval", "piall")
  return(out)
}
