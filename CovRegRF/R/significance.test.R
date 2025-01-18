#' Significance test
#'
#' This function runs a permutation test to evaluate the effect of a subset of
#'   covariates on the covariance matrix estimates. Returns an estimated
#'   \emph{p}-value.
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
#'   than the number of response variables (\eqn{py}).
#' @param nperm Number of permutations.
#' @param test.vars Subset of covariates whose effect on the covariance matrix
#'   estimates will be evaluated. A character vector defining the names of the
#'   covariates. The default is \code{NULL}, which tests for the global effect
#'   of the whole set of covariates.
#'
#' @return An object of class \code{(covregrf, significancetest)} which is a list
#' with the following components:
#'
#'   \item{pvalue}{Estimated *p*-value, see below for details.}
#'   \item{best.nodesize}{Best \code{nodesize} value selected with the proposed
#'     tuning method using all covariates including the \code{test.vars}.}
#'   \item{best.nodesize.control}{Best \code{nodesize} value selected with the
#'     proposed tuning method using only the set of controlling covariates. If
#'     \code{test.vars} is \code{NULL}, returns \code{NULL}.}
#'   \item{test.vars}{Covariates whose effect on the covariance matrix estimates
#'     is evaluated.}
#'   \item{control.vars}{Controlling set of covariates.}
#'   \item{predicted.oob}{OOB predicted covariance matrices for training
#'     observations using all covariates including the \code{test.vars}.}
#'   \item{predicted.perm}{Predicted covariance matrices for the permutations
#'     using all covariates including the \code{test.vars}. A list of
#'     predictions for each permutation.}
#'   \item{predicted.oob.control}{OOB predicted covariance matrices for training
#'     observations using only the set of controlling covariates. If
#'     \code{test.vars} is \code{NULL}, returns \code{NULL}.}
#'   \item{predicted.perm.control}{Predicted covariance matrices for the
#'     permutations using only the set of controlling covariates. If
#'     \code{test.vars} is \code{NULL}, returns \code{NULL}.}
#'
#' @section Details:
#' We perform a hypothesis test to evaluate the effect of a subset of covariates
#'   on the covariance matrix estimates, while controlling for the rest of the
#'   covariates. Define the conditional covariance matrix of \eqn{Y} given all
#'   \eqn{X} variables as \eqn{\Sigma_{X}}, and the conditional covariance
#'   matrix of \eqn{Y} given only the set of controlling \eqn{X} variables as
#'   \eqn{\Sigma_{X}^{c}}. If a subset of covariates has an effect on the
#'   covariance matrix estimates obtained with the proposed method, then
#'   \eqn{\Sigma_{X}} should be significantly different from \eqn{\Sigma_{X}^{c}}.
#'   We conduct a permutation test for the null hypothesis
#'   \deqn{H_0 : \Sigma_{X} = \Sigma_{X}^{c}} We estimate a
#'   \eqn{p}-value with the permutation test. If the \eqn{p}-value is less than the
#'   pre-specified significance level \eqn{\alpha}, we reject the null
#'   hypothesis.
#'
#'   Testing the global effect of the covariates on the conditional covariance
#'   estimates is a particular case of the proposed significance test. Define
#'   the unconditional covariance matrix estimate of \eqn{Y} as
#'   \eqn{\Sigma_{root}} which is computed as the sample covariance matrix of
#'   \eqn{Y}, and the conditional covariance matrix of \eqn{Y} given \eqn{X} as
#'   \eqn{\Sigma_{X}} which is obtained with \code{covregrf()}. If there is a
#'   global effect of \eqn{X} on the covariance matrix estimates, the
#'   \eqn{\Sigma_{X}} should be significantly different from \eqn{\Sigma_{root}}.
#'   The null hypothesis for this particular case is
#'   \deqn{H_0 : \Sigma_{X} = \Sigma_{root}}
#'
#' @seealso
#'   \code{\link{covregrf}}
#'   \code{\link{predict.covregrf}}
#'   \code{\link{print.covregrf}}

significance.test <- function(formula,
                              data,
                              params.rfsrc = list(ntree = 1000, mtry = ceiling(px/3),
                                                  nsplit = max(round(n/50), 10)),
                              nodesize.set = round(0.5^(1:100) * round(.632*n))[round(0.5^(1:100) * round(.632*n)) > py],
                              nperm = 500,
                              test.vars = NULL)
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
  n <- nrow(data)
  px <- length(xvar.names)
  xvar <- data[, xvar.names, drop = FALSE]
  yvar <- data[, yvar.names, drop = FALSE]

  ## check y-variables for numeric
  if (sum(sapply(1:py, function(j) !is.numeric(yvar[,j]))) > 0) {
    stop("Response variables should be numeric.")
  }

  if (is.null(test.vars)) { ## global significance test
    ## run covregrf for training observations
    covregrf.out <- covregrf(
      formula,
      data = data.frame(xvar, yvar),
      params.rfsrc,
      nodesize.set,
      importance = FALSE
    )

    ## get predictions for training observations
    predicted.oob <- covregrf.out$predicted.oob

    ## get best nodesize
    best.nodesize <- covregrf.out$best.nodesize

    ## compute sample covariance matrix for the response
    cov.root <- cov(yvar)
    upp.cov.root <- cov.root[upper.tri(cov.root, diag = TRUE)]

    ## compute global test statistic T
    Tstat <- mean(sapply(predicted.oob,
                         function(x) sqrt(sum((x[upper.tri(x, diag = TRUE)] - upp.cov.root)^2))))

    ## permutations
    n <- covregrf.out$n
    Tstat.perm <- rep(0, nperm)
    predicted.perm <- vector("list", nperm)
    for (perm in 1:nperm) {
      ## permute covariates
      xvar.perm <- xvar[sample(n), ]

      ## run covregrf for training observations
      covregrf.out <- covregrf(
        formula,
        data = data.frame(xvar.perm, yvar),
        params.rfsrc,
        nodesize.set = best.nodesize,
        importance = FALSE
      )

      ## get predictions for permuted data
      predicted.perm[[perm]] <- covregrf.out$predicted.oob

      ## compute global test statistic T for permutations
      Tstat.perm[perm] <- mean(sapply(predicted.perm[[perm]],
                                      function(x) sqrt(sum((x[upper.tri(x, diag = TRUE)] - upp.cov.root)^2))))
    }

    control.vars <- xvar.names

  } else { ## partial significance test
    ## check if test variables are in xvar.names
    if (sum(!(test.vars %in% xvar.names)) > 0) {stop("some/all elements of test.vars are not in data.")}

    ## get px for control data
    ## check if there are any control variables
    control.vars <- setdiff(xvar.names, test.vars)
    pxc <- length(control.vars)
    if (pxc < 1) {stop("there are no control variables.")}

    ## run covregrf for all variables
    covregrf.out <- covregrf(
      formula,
      data = data.frame(xvar, yvar),
      params.rfsrc,
      nodesize.set,
      importance = FALSE
    )
    params.rfsrc.all <- covregrf.out$params.rfsrc

    ## get predictions for observations
    predicted.oob <- covregrf.out$predicted.oob

    ## get best nodesize
    best.nodesize <- covregrf.out$best.nodesize

    ## run covregrf for control variables
    formula.control = as.formula(paste(paste(yvar.names, collapse="+"), paste(control.vars, collapse="+"), sep=" ~ "))
    covregrf.out.control <- covregrf(
      formula.control,
      data = data.frame(xvar[, control.vars, drop=FALSE], yvar),
      params.rfsrc,
      nodesize.set,
      importance = FALSE
    )
    params.rfsrc.control <- covregrf.out.control$params.rfsrc

    ## get predictions for training observations
    predicted.oob.control <- covregrf.out.control$predicted.oob

    ## get best nodesize
    best.nodesize.control <- covregrf.out.control$best.nodesize

    ## compute global test statistic T
    Tstat <- mean(sapply(1:n,
                         function(i) sqrt(sum((predicted.oob[[i]][upper.tri(predicted.oob[[i]], diag = TRUE)] -
                                                 predicted.oob.control[[i]][upper.tri(predicted.oob.control[[i]], diag = TRUE)])^2))))

    ## permutations
    n <- covregrf.out$n
    Tstat.perm <- rep(0, nperm)
    predicted.perm <- vector("list", nperm)
    predicted.perm.control <- vector("list", nperm)
    for (perm in 1:nperm) {
      ## permute covariates
      xvar.perm <- xvar[sample(n), ]

      ## run covregrf for all variables
      covregrf.out <- covregrf(
        formula,
        data = data.frame(xvar.perm, yvar),
        params.rfsrc.all,
        nodesize.set = best.nodesize,
        importance = FALSE
      )

      ## get predictions for permuted data
      predicted.perm[[perm]] <- covregrf.out$predicted.oob

      ## run covregrf for control variables
      covregrf.out.control <- covregrf(
        formula.control,
        data = data.frame(xvar.perm[, control.vars, drop=FALSE], yvar),
        params.rfsrc.control,
        nodesize.set = best.nodesize.control,
        importance = FALSE
      )

      ## get predictions for permuted data
      predicted.perm.control[[perm]] <- covregrf.out.control$predicted.oob

      ## compute global test statistic T for permutations
      Tstat.perm[perm] <- mean(sapply(1:n,
                                      function(i) sqrt(sum((predicted.perm[[perm]][[i]][upper.tri(predicted.perm[[perm]][[i]], diag = TRUE)] -
                                                              predicted.perm.control[[perm]][[i]][upper.tri(predicted.perm.control[[perm]][[i]], diag = TRUE)])^2))))
    }
  }

  # approximate p-value
  pvalue <- sum(Tstat.perm > Tstat) / nperm

  ## make the output object
  covregrf.output <- list(
    pvalue = pvalue,
    best.nodesize = best.nodesize,
    best.nodesize.control = if (is.null(test.vars)) {NULL} else {best.nodesize.control},
    test.vars = test.vars,
    control.vars = control.vars,
    predicted.oob = predicted.oob,
    predicted.perm = predicted.perm,
    predicted.oob.control = if (is.null(test.vars)) {NULL} else {predicted.oob.control},
    predicted.perm.control = if (is.null(test.vars)) {NULL} else {predicted.perm.control}
  )

  class(covregrf.output) <- c("covregrf", "significancetest")

  return(covregrf.output)
}
