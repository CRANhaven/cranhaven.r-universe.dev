#' Global significance test
#'
#' This function runs a permutation test to evaluates the global effect of
#'   subject-related covariates (Z). Returns an estimated \emph{p}-value.
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
#' @param nperm Number of permutations.
#' @param nodesize Forest average number of unique data points in a terminal
#'   node. The default is the \eqn{3 * (px+py)} where \eqn{px} and \eqn{py} are
#'   the number of x and y variables, respectively.
#' @param nodedepth Maximum depth to which a tree should be grown. In the
#'   default, this parameter is ignored.
#' @param nsplit Non-negative integer value for the number of random splits to
#'   consider for each candidate splitting variable. When zero or \code{NULL},
#'   all possible splits considered.
#' @param Xcenter Should the columns of X be centered? The default is
#'   \code{TRUE}.
#' @param Ycenter Should the columns of Y be centered? The default is
#'   \code{TRUE}.
#'
#' @return An object of class \code{(rfcca,globalsignificance)} which is a list
#' with the following components:
#'
#'   \item{call}{The original call to \code{global.significance}.}
#'   \item{pvalue}{*p*-value, see below for details.}
#'   \item{n}{Sample size of the data (\code{NA}'s are omitted).}
#'   \item{ntree}{Number of trees grown.}
#'   \item{nperm}{Number of permutations.}
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
#'   \item{predicted.oob}{OOB predicted canonical correlations for training
#'     observations based on the selected final canonical correlation estimation
#'     method.}
#'   \item{predicted.perm}{Predicted canonical correlations for the permutations.
#'     A matrix of predictions with observations on the rows and permutations on
#'     the columns.}
#'
#' @section Details:
#' We perform a hypothesis test to evaluate the global effect of the
#'   subject-related covariates on distinguishing between canonical correlations.
#'   Define the unconditional canonical correlation between \eqn{X} and
#'   \eqn{Y} as \eqn{\rho_{CCA}(X,Y)} which is found by computing CCA with
#'    all \eqn{X} and \eqn{Y}, and the conditional canonical correlation between
#'    \eqn{X} and \eqn{Y} given \eqn{Z} as \eqn{\rho(X,Y | Z)} which is found by
#'    \code{rfcca()}. If there is a global effect of \eqn{Z} on correlations
#'    between \eqn{X} and \eqn{Y}, \eqn{\rho(X,Y | Z)} should be significantly
#'    different from \eqn{\rho_{CCA}(X,Y)}. We conduct a permutation test
#'    for the null hypothesis \deqn{H_0 : \rho(X,Y | Z) = \rho_{CCA}(X,Y)}
#'    We estimate a *p*-value with the permutation test. If the *p*-value is
#'    less than the pre-specified significance level \eqn{\alpha}, we reject the
#'    null hypothesis.
#'
#' @examples
#' \donttest{
#' ## load generated example data
#' data(data, package = "RFCCA")
#' set.seed(2345)
#'
#' global.significance(X = data$X, Y = data$Y, Z = data$Z, ntree = 40,
#'   nperm = 5)
#' }
#'
#' @seealso
#'   \code{\link{rfcca}}
#'   \code{\link{predict.rfcca}}
#'   \code{\link{print.rfcca}}

global.significance <- function(X,
                                Y,
                                Z,
                                ntree = 200,
                                mtry = NULL,
                                nperm = 500,
                                nodesize = NULL,
                                nodedepth = NULL,
                                nsplit = 10,
                                Xcenter = TRUE,
                                Ycenter = TRUE)
{
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
  if (!is.null(nodesize) && nodesize < 1) stop("Invalid choice of 'nodesize'. Cannot be less than 1.")
  if (!is.null(nodesize) && nodesize < (px+py)) stop("Invalid choice of 'nodesize'. Cannot be smaller than total number of X and Y variables.")
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
  ## run rfcca for training observations
  rfcca.out <- rfcca(
    X = xvar,
    Y = yvar,
    Z = zvar,
    ntree = ntree,
    mtry = mtry,
    nodesize = nodesize,
    nodedepth = nodedepth,
    splitrule = "custom2",
    nsplit = nsplit,
    Xcenter = Xcenter,
    Ycenter = Ycenter
  )
  ## get predictions for training observations
  predicted.oob <- rfcca.out$predicted.oob
  ## Compute CCA for X and Y
  cca <- cancor(xvar, yvar, xcenter = Xcenter, ycenter = Ycenter)$cor[1]
  ## Compute global test statistic T
  Tstat <- mean((predicted.oob - cca) ^ 2)
  ## Permutations
  Tstat.perm <- rep(0, nperm)
  predicted.perm <- matrix(0, n, nperm)
  for (perm in 1:nperm) {
    ## Permute Z
    zvar.perm <- zvar[sample(n), ]
    ## run rfcca for permuted data
    rfcca.out <- rfcca(
      X = xvar,
      Y = yvar,
      Z = zvar.perm,
      ntree = ntree,
      mtry = mtry,
      nodesize = nodesize,
      nodedepth = nodedepth,
      splitrule = "custom2",
      nsplit = nsplit,
      Xcenter = Xcenter,
      Ycenter = Ycenter
    )
    ## get predictions for permuted data
    predicted.perm[, perm] <- rfcca.out$predicted.oob
    # Compute global test statistic T for permutations
    Tstat.perm[perm] <- mean((predicted.perm[, perm] - cca) ^ 2)
  }
  # Approximate p-value
  pvalue <- sum(Tstat.perm > Tstat) / nperm
  ## make the output object
  rfccaOutput <- list(
    call = match.call(),
    pvalue = pvalue,
    n = n,
    ntree = ntree,
    nperm = nperm,
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
    predicted.oob = predicted.oob,
    predicted.perm = predicted.perm
  )

  class(rfccaOutput) <- c("rfcca", "globalsignificance")

  return(rfccaOutput)
}
