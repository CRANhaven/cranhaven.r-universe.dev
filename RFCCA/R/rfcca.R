#' Random Forest with Canonical Correlation Analysis
#'
#' Estimates the canonical correlations between two sets of variables depending
#'   on the subject-related covariates.
#'
#' @param X The first multivariate data set which has \eqn{n} observations and
#'   \eqn{px} variables. A data.frame of numeric values.
#' @param Y The second multivariate data set which has \eqn{n} observations and
#'   \eqn{py} variables. A data.frame of numeric values.
#' @param Z The set of subject-related covariates which has \eqn{n} observations
#'   and \eqn{pz} variables. Used in random forest growing. A data.frame with
#'   numeric values and factors.
#' @param ntree Number of trees.
#' @param mtry Number of z-variables randomly selected as candidates for
#'   splitting a node. The default is \eqn{pz/3} where \eqn{pz} is the number of
#'   z variables. Values are always rounded up.
#' @param nodesize Forest average number of unique data points in a terminal
#'   node. The default is the \eqn{3 * (px+py)} where \eqn{px} and \eqn{py} are
#'   the number of x and y variables, respectively.
#' @param nodedepth Maximum depth to which a tree should be grown. In the
#'   default, this parameter is ignored.
#' @param nsplit Non-negative integer value for the number of random splits to
#'   consider for each candidate splitting variable. When zero or \code{NULL},
#'   all possible splits considered.
#' @param importance Should variable importance of z-variables be assessed? The
#'   default is \code{FALSE}.
#' @param finalcca Which CCA should be used for final canonical correlation
#'   estimation? Choices are \code{cca}, \code{scca} and \code{rcca}, see below
#'   for details. The default is \code{cca}.
#' @param bootstrap Should the data be bootstrapped? The default value is
#'   \code{TRUE} which bootstraps the data by sampling without replacement.
#'   If \code{FALSE} is chosen, the data is not bootstrapped. It is not possible
#'   to return OOB predictions and variable importance measures if \code{FALSE}
#'   is chosen.
#' @param samptype Type of bootstrap. Choices are \code{swor} (sampling without
#' replacement/sub-sampling) and \code{swr} (sampling with replacement/
#' bootstrapping). The default action here (as in \code{randomForestSRC}) is
#' sampling without replacement.
#' @param sampsize Size of sample to draw. For sampling without replacement, by
#' default it is .632 times the sample size. For sampling with replacement, it
#' is the sample size.
#' @param forest Should the forest object be returned? It is used for prediction
#'   on new data. The default is \code{TRUE}.
#' @param membership Should terminal node membership and inbag information be
#'   returned?
#' @param bop Should the Bag of Observations for Prediction (BOP) for training
#'   observations be returned? The default is \code{TRUE}.
#' @param Xcenter Should the columns of X be centered? The default is
#'   \code{TRUE}.
#' @param Ycenter Should the columns of Y be centered? The default is
#'   \code{TRUE}.
#' @param ... Optional arguments to be passed to other methods.
#'
#' @section Details: \describe{
#'
#'   \item{\emph{Final canonical correlation estimation:}}{Final canonical
#'   correlation can be computed with CCA (Hotelling, 1936), Sparse CCA (Witten
#'   et al., 2009) or Regularized CCA (Vinod,1976; Leurgans et al., 1993). If
#'   Regularized CCA will be used, \eqn{\lambda_1} and \eqn{\lambda_2} should be
#'   specified.}
#'
#'   }
#'
#' @return An object of class \code{(rfcca,grow)} which is a list with the
#'   following components:
#'
#'   \item{call}{The original call to \code{rfcca}.}
#'   \item{n}{Sample size of the data (\code{NA}'s are omitted).}
#'   \item{ntree}{Number of trees grown.}
#'   \item{mtry}{Number of variables randomly selected for splitting at each
#'     node.}
#'   \item{nodesize}{Minimum forest average number of unique data points in a
#'     terminal node.}
#'   \item{nodedepth}{Maximum depth to which a tree is allowed to be grown.}
#'   \item{nsplit}{Number of randomly selected split points.}
#'   \item{xvar}{Data frame of x-variables.}
#'   \item{xvar.names}{A character vector of the x-variable names.}
#'   \item{yvar}{Data frame of y-variables.}
#'   \item{yvar.names}{A character vector of the y-variable names.}
#'   \item{zvar}{Data frame of z-variables.}
#'   \item{zvar.names}{A character vector of the z-variable names.}
#'   \item{leaf.count}{Number of terminal nodes for each tree in the forest.
#'     Vector of length \code{ntree}.}
#'   \item{bootstrap}{Was the data bootstrapped?}
#'   \item{forest}{If \code{forest=TRUE}, the \code{rfcca} forest object is
#'     returned. This object is used for prediction with new data.}
#'   \item{membership}{A matrix recording terminal node membership where each
#'     cell represents the node number that an observations falls in for that
#'     tree.}
#'   \item{importance}{Variable importance measures (VIMP) for each z-variable.}
#'   \item{inbag}{A matrix recording inbag membership where each cell represents
#'     whether the observation is in the bootstrap sample in the corresponding
#'     tree.}
#'   \item{predicted.oob}{OOB predicted canonical correlations for training
#'     observations based on the selected final canonical correlation estimation
#'     method.}
#'   \item{predicted.coef}{Predicted canonical weight vectors for x- and y-
#'     variables.}
#'   \item{bop}{If \code{bop=TRUE}, a list containing BOP for each training
#'     observation is returned.}
#'   \item{finalcca}{The selected CCA used for final canonical correlation
#'     estimations.}
#'   \item{rfsrc.grow}{An object of class \code{(rfsrc,grow)} is returned. This
#'     object is used for prediction with training or new data.}
#'
#' @references Hotelling, H. (1936). Relations between two sets of variates.
#'   Biometrika, 28(3/4), 321–377.
#' @references Leurgans, S. E., Moyeed, R. A., & Silverman, B. W. (1993).
#'   Canonical correlation analysis when the data are curves. Journal of the
#'   Royal Statistical Society: Series B (Methodological), 55(3), 725-740.
#' @references Vinod, H.D. (1976). Canonical ridge and econometrics of joint
#'   production. Journal of econometrics, 4(2), 147–166.
#' @references Witten, D. M., Tibshirani, R., & Hastie, T. (2009). A penalized
#'   matrix decomposition, with applications to sparse principal components and
#'   canonical correlation analysis. Biostatistics, 10(3), 515-534.
#'
#' @examples
#' \donttest{
#' ## load generated example data
#' data(data, package = "RFCCA")
#' set.seed(2345)
#'
#' ## define train/test split
#' smp <- sample(1:nrow(data$X), size = round(nrow(data$X) * 0.7),
#'   replace = FALSE)
#' train.data <- lapply(data, function(x) {x[smp, ]})
#' test.Z <- data$Z[-smp, ]
#'
#' ## train rfcca
#' rfcca.obj <- rfcca(X = train.data$X, Y = train.data$Y, Z = train.data$Z,
#'   ntree = 100, importance = TRUE)
#'
#' ## print the grow object
#' print(rfcca.obj)
#'
#' ## get the OOB predictions
#' pred.oob <- rfcca.obj$predicted.oob
#'
#' ## predict with new test data
#' pred.obj <- predict(rfcca.obj, newdata = test.Z)
#' pred <- pred.obj$predicted
#'
#' ## get the variable importance measures
#' z.vimp <- rfcca.obj$importance
#'
#' ## train rfcca and estimate the final canonical correlations with "scca"
#' rfcca.obj2 <- rfcca(X = train.data$X, Y = train.data$Y, Z = train.data$Z,
#'   ntree = 100, finalcca = "scca")
#' }
#'
#' @seealso
#'   \code{\link{predict.rfcca}}
#'   \code{\link{global.significance}}
#'   \code{\link{vimp.rfcca}}
#'   \code{\link{print.rfcca}}

rfcca <- function(X,
                  Y,
                  Z,
                  ntree = 200,
                  mtry = NULL,
                  nodesize = NULL, nodedepth = NULL,
                  nsplit = 10,
                  importance = FALSE,
                  finalcca = c("cca", "scca", "rcca"),
                  bootstrap = TRUE,
                  samptype = c("swor", "swr"),
                  sampsize = if (samptype == "swor") function(x){x * .632} else function(x){x},
                  forest = TRUE,
                  membership = FALSE,
                  bop = TRUE,
                  Xcenter = TRUE,
                  Ycenter = TRUE,
                  ...)
{
  ## get any hidden options to be used in rfsrc
  user.option <- list(...)
  do.trace <- is.hidden.do.trace(user.option)
  split.depth <- is.hidden.split.depth(user.option)
  statistics <- is.hidden.statistics(user.option)
  var.used <- is.hidden.var.used(user.option)
  lambda1 <- is.hidden.lambda1(user.option)
  lambda2 <- is.hidden.lambda2(user.option)
  rfsrc.forest <- is.hidden.rfsrc.forest(user.option)
  seed <- is.hidden.seed(user.option)
  ## verify key options
  bootstrap <- match.arg(as.character(bootstrap), c(TRUE, FALSE))
  bop <- match.arg(as.character(bop), c(TRUE, FALSE))
  finalcca <- match.arg(as.character(finalcca), c("cca", "scca", "rcca"))
  forest <- match.arg(as.character(forest), c(TRUE, FALSE))
  importance <- match.arg(as.character(importance), c(FALSE, TRUE))
  membership <- match.arg(as.character(membership), c(FALSE, TRUE))
  samptype <- match.arg(samptype, c("swor", "swr"))
  Xcenter <- match.arg(as.character(Xcenter), c(TRUE, FALSE))
  Ycenter <- match.arg(as.character(Ycenter), c(TRUE, FALSE))
  ## initial checks
  if (is.null(X)) {stop("X is missing")}
  if (is.null(Y)) {stop("Y is missing")}
  if (is.null(Z)) {stop("Z is missing")}
  if (!is.data.frame(X)) {stop("'X' must be a data frame.")}
  if (!is.data.frame(Y)) {stop("'Y' must be a data frame.")}
  if (!is.data.frame(Z)) {stop("'Z' must be a data frame.")}
  ## get data and variable names
  xvar <- X
  yvar <- Y
  zvar <- Z
  xvar.names <- names(xvar)
  yvar.names <- names(yvar)
  zvar.names <- names(zvar)
  ## if regularized cca is the final estimation method
  ## check for lambda1 and lambda2
  if ((finalcca == "rcca") & (is.null(lambda1) || is.null(lambda2))) {
    stop("when rcca is the final estimation method, 'lambda1' and 'lambda2' should be entered")
  }
  ## check for missing data
  na.xvar <- NULL
  na.yvar <- NULL
  na.zvar <- NULL
  if (any(is.na(xvar))) {
    warning("X has missing values, entire record will be removed")
    na.xvar <- which(is.na(xvar))
  }
  if (any(is.na(yvar))) {
    warning("Y has missing values, entire record will be removed")
    na.yvar <- which(is.na(yvar))
  }
  if (any(is.na(zvar))) {
    warning("Z has missing values, entire record will be removed")
    na.zvar <- which(is.na(zvar))
  }
  ## remove entire record for missing values
  na.all <- unique(c(na.xvar, na.yvar, na.zvar))
  if (!is.null(na.all)) {
    xvar <- xvar[-na.all, ]
    yvar <- yvar[-na.all, ]
    zvar <- zvar[-na.all, ]
  }
  ## mean centering
  if (Xcenter) {xvar <- as.data.frame(scale(xvar, center = TRUE, scale = FALSE))}
  if (Ycenter) {yvar <- as.data.frame(scale(yvar, center = TRUE, scale = FALSE))}
  ## get dimension info
  n <- as.numeric(nrow(zvar))
  px <- as.numeric(ncol(xvar))
  py <- as.numeric(ncol(yvar))
  pz <- as.numeric(ncol(zvar))
  ## coherence checks on option parameters
  ntree <- round(ntree)
  if (ntree < 1) stop("Invalid choice of 'ntree'.  Cannot be less than 1.")
  if (!is.null(nodedepth)) nodedepth = round(nodedepth) else nodedepth = -1
  if (!is.null(nodesize) && nodesize < 1)
    stop("Invalid choice of 'nodesize'. Cannot be less than 1.")
  if (!is.null(nodesize) && nodesize < (px+py) && finalcca == "cca")
    stop("Invalid choice of 'nodesize'. Cannot be smaller than total number of X and Y variables with 'cca' final estimation.")
  ## initialize nodesize if it is null by 3 times the total number of X and Y variables
  if (is.null(nodesize)) {
    nodesize <- 3 * (px + py)
  } else {
    nodesize <- round(nodesize)
  }
  ## initialize mtry if it is null by 1/3 times the number of Z variables
  if (is.null(mtry)) {
    mtry <- ceiling(pz/3)
  } else {
    mtry <- ceiling(mtry)
    if (mtry < 1) stop("Invalid choice of 'mtry'.  Cannot be less than 1.")
  }
  ## set the formula
  formula <- as.formula(cca(t)~.)
  ## form the data for rfsrc
  rfsrcdata <- zvar
  rfsrcdata$t <- seq(1,n,1)
  ## train random forest with rfsrc
  rf <- rfsrc(formula = formula,
              data = rfsrcdata,
              mvdata1 = xvar,
              mvdata2 = yvar,
              ntree = ntree,
              mtry = mtry,
              nodesize = nodesize,
              nodedepth = nodedepth,
              splitrule = "custom2",
              nsplit = nsplit,
              membership = TRUE,
              importance = FALSE,
              forest = TRUE,
              bootstrap = (if (bootstrap) {"by.root"} else {"none"}),
              samptype = samptype,
              sampsize = sampsize,
              var.used = var.used,
              split.depth = split.depth,
              do.trace = do.trace,
              statistics = statistics,
              seed = seed)
  ## get membership info for training observations
  inbag <- rf$inbag
  mem <- rf$membership
  ## get predictions for training observations
  predicted.oob <- NULL
  predicted.coef <- NULL
  vimp.out <- NULL
  bop.out <- NULL
  if (bootstrap) {
    ## find BOPs for training observations,
    ## BOP of train observation i is constructed with the inbag observations
    ## in the terminal nodes where i is ended up as an OOB
    bop.out <- lapply(1:n, "findforestbop", mem.train = mem, inbag = inbag, ntree = ntree, bop.type = "oob")
    bop.out <- lapply(bop.out, mergelist)
    if (sum(sapply(bop.out, is.null)) > 0) {
      stop("Some observations have empty BOP. Re-run rfcca with larger 'ntree'.")
    }
    ## compute canonical correlation estimations for training observations
    if (finalcca == "cca") {
      predicted.out <- sapply(bop.out, ccaest, xtrain = xvar, ytrain = yvar)
    } else if (finalcca == "scca") {
      predicted.out <- sapply(bop.out, sccaest, xtrain = xvar, ytrain = yvar)
    } else if (finalcca == "rcca") {
      predicted.out <- sapply(bop.out, rccaest, xtrain = xvar, ytrain = yvar, lambda1 = lambda1, lambda2 = lambda2)
    }
    predicted.oob <- predicted.out["cor", ]
    predicted.coef <- list(coefx = t(predicted.out[xvar.names, ]), coefy = t(predicted.out[yvar.names, ]))
    ## find variable importance measures
    if (importance) {
      vimpdata <- zvar
      vimpdata$t <- predicted.oob
      rfvimp <- rfsrc(formula = t~.,
                      data = vimpdata,
                      mvdata1 = xvar,
                      mvdata2 = yvar,
                      ntree = ntree,
                      mtry = mtry,
                      nodesize = nodesize,
                      nodedepth = nodedepth,
                      nsplit = nsplit,
                      importance = TRUE,
                      samptype = samptype,
                      sampsize = sampsize)
      vimp.out <- rfvimp$importance
      names(vimp.out) <- zvar.names
    }
  } else {
    warning("when bootstrap is FALSE, OOB predictions cannot be computed")
    if(importance) {
      warning("when bootstrap is FALSE, importance cannot be computed")
    }
  }
  ## create forest output
  if (forest) {
    forest.out <- list(forest = TRUE,
                       nativeArray = rf$forest$nativeArray,
                       nativeFactorArray = rf$forest$nativeFactorArray,
                       totalNodeCount = nrow(rf$forest$nativeArray),
                       nodesize = nodesize,
                       nodedepth = nodedepth,
                       ntree = ntree,
                       xvar = xvar,
                       xvar.names = xvar.names,
                       yvar = yvar,
                       yvar.names = yvar.names,
                       zvar = zvar,
                       zvar.names = zvar.names,
                       seed = rf$forest$seed,
                       bootstrap = bootstrap,
                       sampsize = rf$forest$sampsize.function,
                       samptype = rf$forest$samptype,
                       terminal.qualts = rf$forest$terminal.qualts,
                       terminal.quants = rf$forest$terminal.quants,
                       nativeArrayTNDS = rf$forest$nativeArrayTNDS)
    ## Initialize the default class of the forest.
    class(forest.out) <- c("rfcca", "forest")
  }
  ## the forest is NULL (the user has requested not to save the forest)
  ## add basic information needed for printing
  else {
    forest.out <- list(forest = FALSE,
                       nodesize = nodesize,
                       nodedepth = nodedepth,
                       ntree = ntree,
                       xvar = xvar,
                       xvar.names = xvar.names,
                       yvar = yvar,
                       yvar.names = yvar.names,
                       zvar = zvar,
                       zvar.names = zvar.names,
                       seed = rf$forest$seed,
                       bootstrap = bootstrap,
                       sampsize = rf$forest$sampsize.function,
                       samptype = rf$forest$samptype)
  }
  ## make the output object
  rfccaOutput <- list(
    call = match.call(),
    n = n,
    ntree = ntree,
    mtry = mtry,
    nodesize = nodesize,
    nodedepth = nodedepth,
    nsplit = nsplit,
    xvar = xvar,
    xvar.names = xvar.names,
    yvar = yvar,
    yvar.names = yvar.names,
    zvar = zvar,
    zvar.names = zvar.names,
    leaf.count = rf$leaf.count,
    bootstrap = bootstrap,
    samptype = samptype,
    sampsize = sampsize,
    forest = forest.out,
    membership = (if (membership) {mem} else {NULL}),
    importance = vimp.out,
    inbag = (if (membership) {inbag} else {NULL}),
    predicted.oob = predicted.oob,
    predicted.coef = predicted.coef,
    bop = (if (bop) {bop.out} else {NULL}),
    finalcca = finalcca,
    rfsrc.grow = rf
  )

  if (var.used != FALSE) {
    rfccaOutput[["var.used"]] <- rf$var.used
  }
  if (split.depth != FALSE) {
    rfccaOutput[["split.depth"]] <- rf$split.depth
  }
  if (statistics) {
    rfccaOutput[["node.stats"]] <- rf$node.stats
  }

  class(rfccaOutput) <- c("rfcca", "grow")

  return(rfccaOutput)
}
