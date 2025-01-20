generic.predict.rfcca <- function(object,
                                  newdata,
                                  membership = FALSE,
                                  finalcca = c("cca", "scca", "rcca"),
                                  ...)
{
  ## get any hidden options
  user.option <- list(...)
  do.trace <- is.hidden.do.trace(user.option)
  split.depth <- is.hidden.split.depth(user.option)
  statistics <- is.hidden.statistics(user.option)
  var.used <- is.hidden.var.used(user.option)
  lambda1 <- is.hidden.lambda1(user.option)
  lambda2 <- is.hidden.lambda2(user.option)
  ## verify key options
  finalcca <- match.arg(as.character(finalcca), c("cca", "scca","rcca"))
  ## object cannot be missing
  if (missing(object)) {stop("object is missing!")}
  ## incoming object must be a grow forest object
  if (sum(inherits(object, c("rfcca", "grow"), TRUE) == c(1, 2)) != 2)
    stop("this function only works for objects of class `(rfcca, grow)'")
  ## grow forests must have true forest information
  if (sum(inherits(object, c("rfcca", "grow"), TRUE) == c(1, 2)) == 2) {
    if (is.forest.missing(object)) {
      stop("Forest information for prediction is missing. Re-run rfcca with forest=TRUE")
    }
  }
  ## if regularized cca is the final estimation method
  ## check for lambda1 and lambda2
  if ((finalcca == "rcca") & (is.null(lambda1) || is.null(lambda2))) {
    stop("when rcca is the final estimation method, 'lambda1' and 'lambda2' should be entered")
  }
  ## pull the z-variable names from the grow object
  zvar.names <- object$zvar.names
  ## pull the ntree from the grow object
  ntree <- object$ntree
  ## if newdata is missing we assume training predictions will be returned
  if (missing(newdata)) {
    outcome <- "train"
    n <- object$n
    xvar <- object$xvar
    yvar <- object$yvar
    zvar <- object$zvar
    xvar.names <- object$xvar.names
    yvar.names <- object$yvar.names
    zvar.names <- object$zvar.names
    if (membership) {
      membership.out <- object$rfsrc.grow$membership
    } else {
      membership.out <- NULL
    }
    if (finalcca == "cca"){
      predicted <- object$predicted.oob
      predicted.coef <- object$predicted.coef
    } else {
      if (!is.null(object$bop)) {
        bop.out <- object$bop
      } else {
        inbag <- object$rfsrc.grow$inbag
        mem <- object$rfsrc.grow$membership
        ## find BOPs for training observations,
        ## BOP of train observation i is constructed with the inbag observations
        ## in the terminal nodes where i is ended up as an OOB
        bop.out <- lapply(1:n, "findforestbop", mem.train = mem, inbag = inbag, ntree = ntree, bop.type = "oob")
        bop.out <- lapply(bop.out, mergelist)
        if (sum(sapply(bop.out, is.null)) > 0) {
          stop("Some observations have empty BOP. Re-run rfcca with larger 'ntree'.")
        }
      }
      ## compute canonical correlation estimations for training observations
      if (finalcca == "scca") {
        predicted.out <- sapply(bop.out, sccaest, xtrain = xvar, ytrain = yvar)
      } else if (finalcca == "rcca") {
        predicted.out <- sapply(bop.out, rccaest, xtrain = xvar, ytrain = yvar, lambda1 = lambda1, lambda2 = lambda2)
      }
      predicted <- predicted.out["cor", ]
      predicted.coef <- list(coefx = predicted.out[xvar.names, ], coefy = predicted.out[yvar.names, ])
    }
  } else { ## there is a test data
    outcome <- "test"
    ## Filter the test data based on the formula
    if (!is.data.frame(newdata)) {stop("newdata must be a data frame.")}
    newdata <- newdata[, is.element(names(newdata),zvar.names), drop = FALSE]
    ## get membership info for training observations
    membership.train <- object$rfsrc.grow$membership
    inbag <- object$rfsrc.grow$inbag
    ## get the training data
    xvar <- object$xvar
    yvar <- object$yvar
    xvar.names <- object$xvar.names
    yvar.names <- object$yvar.names
    ## get membership info for new observations
    pred <- predict(object$rfsrc, newdata, membership = TRUE)
    membership.test <- pred$membership
    ## get sample size
    n <- pred$n
    ## get predictions for new observations
    ## find BOPs for new observations,
    ## BOP of new observation i is constructed with the training obs.
    ## in the terminal nodes where i is ended up
    bop.out <- lapply(1:n, "findforestbop", mem.train = membership.train, mem.test = membership.test, inbag = inbag, ntree = ntree, bop.type = "test")
    bop.out <- lapply(bop.out, mergelist)
    ## compute canonical correlation estimations for training observations
    if (finalcca == "cca") {
      predicted.out <- sapply(bop.out, ccaest, xtrain = xvar, ytrain = yvar)
    } else if (finalcca == "scca") {
      predicted.out <- sapply(bop.out, sccaest, xtrain = xvar, ytrain = yvar)
    } else if (finalcca == "rcca") {
      predicted.out <- sapply(bop.out, rccaest, xtrain = xvar, ytrain = yvar, lambda1 = lambda1, lambda2 = lambda2)
    }
    predicted <- predicted.out["cor", ]
    predicted.coef <- list(coefx = t(predicted.out[xvar.names, ]), coefy = t(predicted.out[yvar.names, ]))
    if (membership) {
      membership.out <- membership.test
    } else {
      membership.out <- NULL
    }
  }
  ## make the output object
  rfccaOutput <- list(
    call = object$call,
    n = n,
    ntree = ntree,
    xvar = xvar,
    xvar.names = xvar.names,
    yvar = yvar,
    yvar.names = yvar.names,
    zvar = (if (outcome == "test") {pred$xvar} else {zvar}),
    zvar.names = (if (outcome == "test") {pred$xvar.names} else {zvar.names}),
    forest = object$forest,
    membership = membership.out,
    predicted = predicted,
    predicted.coef = predicted.coef,
    finalcca = finalcca
  )

  class(rfccaOutput) <- c("rfcca", "predict")

  return(rfccaOutput)
}
