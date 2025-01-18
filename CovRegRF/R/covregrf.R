#' Covariance Regression with Random Forests
#'
#' Estimates the covariance matrix of a multivariate response given a set of
#'   covariates using a random forest framework.
#'
#' @param formula Object of class \code{formula} or \code{character} describing
#'   the model to fit. Interaction terms are not supported.
#' @param data The multivariate data set which has \eqn{n} observations and
#'   \eqn{px+py} variables where \eqn{px} and \eqn{py} are the number of
#'   covariates (\eqn{X}) and response variables (\eqn{Y}), respectively. Should
#'   be a data.frame.
#' @param params.rfsrc List of parameters that should be passed to
#'   \code{randomForestSRC}. In the default parameter set, \code{ntree} = 1000,
#'   \code{mtry} = \eqn{px/3}  (rounded up), \code{nsplit} =
#'   \eqn{max(round(n/50), 10)}. See \code{randomForestSRC} for possible
#'   parameters.
#' @param nodesize.set The set of \code{nodesize} levels for tuning. Default set
#'   includes the power of two times the sub-sample size (\eqn{.632n}) greater
#'   than the number of response variables (\eqn{py}). See below for details of
#'   the \code{nodesize} tuning.
#' @param importance Should variable importance of covariates be assessed? The
#'   default is \code{FALSE}.
#'
#' @section Details:
#'   For mean regression problems, random forests search for the optimal level
#'   of the \code{nodesize} parameter by using out-of-bag (OOB) prediction
#'   errors computed as the difference between the true responses and OOB
#'   predictions. The \code{nodesize} value having the smallest OOB prediction
#'   error is chosen. However, the covariance regression problem is
#'   unsupervised by nature. Therefore, we tune \code{nodesize} parameter with a
#'   heuristic method. We use OOB covariance matrix estimates. The general idea
#'   of the proposed tuning method is to find the \code{nodesize} level where
#'   the OOB covariance matrix predictions converge. The steps are as follows.
#'   Firstly, we train separate random forests for a set of \code{nodesize}
#'   values. Secondly, we compute the OOB covariance matrix estimates for each
#'   random forest. Next, we compute the mean absolute difference (MAD) between
#'   the upper triangular OOB covariance matrix estimates of two consecutive
#'   \code{nodesize} levels over all observations. Finally, we take the pair of
#'   \code{nodesize} levels having the smallest MAD. Among these two
#'   \code{nodesize} levels, we select the smaller since in general deeper trees
#'   are desired in random forests.
#'
#' @return An object of class \code{(covregrf, grow)} which is a list with the
#'   following components:
#'
#'   \item{predicted.oob}{OOB predicted covariance matrices for training
#'     observations.}
#'   \item{importance}{Variable importance measures (VIMP) for covariates.}
#'   \item{best.nodesize}{Best \code{nodesize} value selected with the proposed
#'     tuning method.}
#'   \item{params.rfsrc}{List of parameters that was used to fit random forest
#'     with \code{randomForestSRC}.}
#'   \item{n}{Sample size of the data (\code{NA}'s are omitted).}
#'   \item{xvar.names}{A character vector of the covariate names.}
#'   \item{yvar.names}{A character vector of the response variable names.}
#'   \item{xvar}{Data frame of covariates.}
#'   \item{yvar}{Data frame of responses.}
#'   \item{rf.grow}{Fitted random forest object. This object is used for
#'     prediction with training or new data.}
#'
#' @examples
#' options(rf.cores=2, mc.cores=2)
#'
#' ## load generated example data
#' data(data, package = "CovRegRF")
#' xvar.names <- colnames(data$X)
#' yvar.names <- colnames(data$Y)
#' data1 <- data.frame(data$X, data$Y)
#'
#' ## define train/test split
#' set.seed(2345)
#' smp <- sample(1:nrow(data1), size = round(nrow(data1)*0.6), replace = FALSE)
#' traindata <- data1[smp,,drop=FALSE]
#' testdata <- data1[-smp, xvar.names, drop=FALSE]
#'
#' ## formula object
#' formula <- as.formula(paste(paste(yvar.names, collapse="+"), ".", sep=" ~ "))
#'
#' ## train covregrf
#' covregrf.obj <- covregrf(formula, traindata, params.rfsrc = list(ntree = 50),
#'   importance = TRUE)
#'
#' ## get the OOB predictions
#' pred.oob <- covregrf.obj$predicted.oob
#'
#' ## predict with new test data
#' pred.obj <- predict(covregrf.obj, newdata = testdata)
#' pred <- pred.obj$predicted
#'
#' ## get the variable importance measures
#' vimp <- covregrf.obj$importance
#'
#'
#' @seealso
#'   \code{\link{predict.covregrf}}
#'   \code{\link{significance.test}}
#'   \code{\link{vimp.covregrf}}
#'   \code{\link{print.covregrf}}

covregrf <- function(formula,
                     data,
                     params.rfsrc = list(ntree = 1000, mtry = ceiling(px/3),
                                         nsplit = max(round(n/50), 10)),
                     nodesize.set = round(0.5^(1:100) * sampsize)[round(0.5^(1:100) * sampsize) > py],
                     importance = FALSE)
{
  ## initial checks for the data set
  if (is.null(data)) {stop("'data' is missing.")}
  if (!is.data.frame(data)) {stop("'data' must be a data frame.")}

  ## make formula object
  formula <- as.formula(formula)

  ## check for missing data
  na.ix <- NULL
  if (any(is.na(data))) {
    warning("'data' has missing values, entire record will be removed")
    na.ix <- which(is.na(data))
    data <- data[-na.ix, ]
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
      xvar.names <- names(data)
    } else {
      xvar.names <- names(data)[!is.element(names(data), all.names[1:py])]
    }
  } else {
    if(py == 0) {
      xvar.names <- all.names
    } else {
      xvar.names <- all.names[-c(1:py)]
    }
    not.specified <- !is.element(xvar.names, names(data))
    if (sum(not.specified) > 0) {
      stop("formula is misspecified, object ", xvar.names[not.specified], " not found")
    }
  }
  xvar <- data[, xvar.names, drop = FALSE]
  yvar <- data[, yvar.names, drop = FALSE]
  n <- nrow(data)
  px <- length(xvar.names)

  ## check y-variables for numeric
  if (sum(sapply(1:py, function(j) !is.numeric(yvar[,j]))) > 0) {
    stop("Response variables should be numeric.")
  }

  ## make a new formula object for the modified rfsrc function
  newformula <- as.formula(covreg(t)~.)

  ## form the data for the modified rfsrc function
  newdata <- xvar
  newdata$t <- seq(1,n,1)

  ## set base parameters for random forest training
  if (is.null(params.rfsrc)) {
    params.rfsrc <- list()
  }
  param.names <- names(params.rfsrc)
  if ("bootstrap" %in% param.names) {
    if (params.rfsrc[["bootstrap"]] == "none") {stop("'bootstrap' in params.rfsrc cannot be 'none'.")}
  }
  if (!("ntree" %in% param.names)){params.rfsrc[["ntree"]] <- 1000}
  if (!("mtry" %in% param.names)) {params.rfsrc[["mtry"]] <- ceiling(px/3)}
  if (!("nsplit" %in% param.names)) {params.rfsrc[["nsplit"]] <- max(round(n/50), 10)}
  params.rfsrc[["samptype"]] <- "swor"
  params.rfsrc[["sampsize"]] <- round(.632*n)
  params.rfsrc[["membership"]] <- TRUE
  params.rfsrc[["forest"]] <- TRUE
  params.rfsrc[["importance"]] <- FALSE
  params.rfsrc[["formula"]] <- newformula
  params.rfsrc[["data"]] <- newdata
  params.rfsrc[["splitrule"]] <- "custom2"
  params.rfsrc[["mvresp"]] <- yvar
  sampsize <- params.rfsrc[["sampsize"]]

  if (is.null(nodesize.set)) {
    nodesize.set <- round(0.5^(1:100) * sampsize)[round(0.5^(1:100) * sampsize) > py]
  } else {
    nodesize.set <- as.numeric(nodesize.set)
    nodesize.set <- nodesize.set[nodesize.set > py]
    if (length(nodesize.set) < 1) {
      stop("nodesize.set should have values more than number of response variables.")
    }
  }

  predicted.oob <- vector("list", length = length(nodesize.set))
  names(predicted.oob) <- nodesize.set
  if (length(nodesize.set) > 1) {
    ## train covariance regression forest for each nodesize level
    nodesize.set <- sort(nodesize.set, decreasing = TRUE)
    rf <- vector("list", length = length(nodesize.set))
    names(rf) <- nodesize.set
    for (nodesize in nodesize.set) {
      params.rfsrc.ns <- params.rfsrc
      params.rfsrc.ns[["nodesize"]] <- nodesize

      ## train covariance forest
      rf[[as.character(nodesize)]] <- do.call(rfsrc, params.rfsrc.ns)

      ## get membership info for training observations
      inbag <- rf[[as.character(nodesize)]]$inbag
      membership <- rf[[as.character(nodesize)]]$membership

      ## find global BOPs for training observations,
      ## BOP of train observation i is constructed with the OOB observations
      ## in the terminal nodes where i is ended up as an OOB
      BOPoob <- buildoobbop(membership, inbag)
      if (nrow(BOPoob) < n) {
        stop("Some observations have empty BOP. Increase the number of trees, 'ntree' in params.rfsrc.")
      }

      ## compute OOB covariance matrix estimations for training observations
      predicted.oob[[as.character(nodesize)]] <-
        lapply(1:n, function(i) {x=BOPoob[i,]; cov.wt(yvar, wt=x, center=TRUE, method="ML")$cov * sum(x) / (sum(x)-1)})
    }

    ## compute the avg euclidean distance between
    ## OOB predictions of two consecutive nodesize levels (upper triangular covariance matrix)
    dist.names <- paste0("d(ns=",nodesize.set[-length(nodesize.set)],",ns=",nodesize.set[-1],")")
    dist <- rep(NA, length(nodesize.set)-1)
    names(dist) <- dist.names
    for (i in 1:(length(nodesize.set)-1)) {
      ns1 <- t(sapply(predicted.oob[[as.character(nodesize.set[i])]], function(x) as.vector(x[upper.tri(x, diag=TRUE)])))
      ns2 <- t(sapply(predicted.oob[[as.character(nodesize.set[i+1])]], function(x) as.vector(x[upper.tri(x, diag=TRUE)])))
      dist[i] <- mean(abs(ns1 - ns2))
    }

    ## find the best nodesize and correponsing predictions
    mindist <- names(dist)[which.min(dist)]
    best.nodesize <- nodesize.set[-1][which.min(dist)]
    rf.out <- rf[[as.character(best.nodesize)]]
    predicted.oob.out <- predicted.oob[[as.character(best.nodesize)]]
  } else {
    best.nodesize <- nodesize.set
    params.rfsrc.ns <- params.rfsrc
    params.rfsrc.ns[["nodesize"]] <- best.nodesize

    ## train covariance forest
    rf.out <- do.call(rfsrc, params.rfsrc.ns)

    ## get membership info for training observations
    inbag <- rf.out$inbag
    membership <- rf.out$membership

    ## find global BOPs for training observations,
    ## BOP of train observation i is constructed with the OOB observations
    ## in the terminal nodes where i is ended up as an OOB
    BOPoob <- buildoobbop(membership, inbag)
    if (nrow(BOPoob) < n) {
      stop("Some observations have empty BOP. Increase the number of trees, 'ntree' in params.rfsrc.")
    }

    ## compute OOB covariance matrix estimations for training observations
    predicted.oob.out <-
      lapply(1:n, function(i) {x=BOPoob[i,]; cov.wt(yvar, wt=x, center=TRUE, method="ML")$cov * sum(x) / (sum(x)-1)})
  }

  ## get variable importance
  if (importance) {
    ## form multivariate response data with vectorizing covariance matrix elements
    covmat.names <- matrix(NA, py, py)
    for (j in 1:py) {
      for (k in j:py) {
        if (j==k) {
          covmat.names[j,k] <- yvar.names[j]
        } else {
          covmat.names[j,k] <- paste(yvar.names[j], yvar.names[k], sep = "_")
        }
      }
    }
    covmat.names <- covmat.names[upper.tri(covmat.names, diag=TRUE)]
    vimpdata <- t(sapply(predicted.oob.out, function(x) x[upper.tri(x, diag=TRUE)]))
    colnames(vimpdata) <- covmat.names

    params.rfsrc.vimp <- params.rfsrc
    params.rfsrc.vimp[["membership"]] <- FALSE
    params.rfsrc.vimp[["forest"]] <- FALSE
    params.rfsrc.vimp[["importance"]] <- TRUE
    params.rfsrc.vimp[["formula"]] <- get.mv.formula(colnames(vimpdata))
    params.rfsrc.vimp[["data"]] <- data.frame(xvar, vimpdata)
    params.rfsrc.vimp[["splitrule"]] <- "mahalanobis"

    ## train multivariate rf with Mahalanobis distance
    vimprf <- do.call(rfsrc, params.rfsrc.vimp)

    ## get vimp output
    vimp.out <- rowMeans(get.mv.vimp(vimprf,  standardize = TRUE))
  }

  ## make the output object
  covregrf.output <- list(
    predicted.oob = predicted.oob.out,
    importance = if (importance) {vimp.out} else {NULL},
    best.nodesize = best.nodesize,
    params.rfsrc = params.rfsrc,
    n = n,
    xvar.names = xvar.names,
    yvar.names = yvar.names,
    xvar = xvar,
    yvar = yvar,
    rf.grow = rf.out
  )

  class(covregrf.output) <- c("covregrf", "grow")

  return(covregrf.output)
}
