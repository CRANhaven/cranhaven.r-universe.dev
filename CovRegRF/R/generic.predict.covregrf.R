generic.predict.covregrf <- function(object,
                                   newdata,
                                   ...)
{
  ## get any hidden options
  user.option <- list(...)

  ## object cannot be missing
  if (missing(object)) {stop("object is missing!")}

  ## incoming object must be a grow forest object
  if (sum(inherits(object, c("covregrf", "grow"), TRUE) == c(1, 2)) != 2)
    stop("this function only works for objects of class `(covregrf, grow)'")

  ## pull the xvar and yvar from the grow object
  xvar <- object$xvar
  yvar <- object$yvar
  xvar.names <- object$xvar.names
  yvar.names <- object$yvar.names

  ## if newdata is missing we assume training predictions will be returned
  if (missing(newdata)) {
    outcome <- "train"
    predicted.out <- object$predicted.oob
  } else { ## there is a test data
    outcome <- "test"

    ## initial checks for the newdata
    if (!is.data.frame(newdata)) {stop("newdata must be a data frame.")}

    ## Filter the test data based on the formula
    newdata <- newdata[, is.element(names(newdata),
                                    c(yvar.names, xvar.names)), drop = FALSE]

    ## check for missing data
    na.newdata <- NULL
    if (any(is.na(newdata))) {
      warning("'newdata' has missing values, entire record will be removed")
      na.newdata <- which(is.na(newdata))
      newdata <- newdata[-na.newdata, ]
    }

    ## get membership info for training observations
    mem.train <- object$rf.grow$membership
    inbag <- object$rf.grow$inbag

    ## get membership info for new observations
    pred <- predict.rfsrc(object$rf.grow, newdata, membership = TRUE)
    mem.test <- pred$membership

    ## find global BOPs for new observations,
    ## BOP of new observation i is constructed with the OOB training obs.
    ## in the terminal nodes where i is ended up
    BOPtest <- buildtestbop(mem.train, mem.test, inbag)

    ## compute covariance matrix estimations for test observations
    predicted.out <- lapply(1:nrow(newdata),
                            function(i) {x=BOPtest[i,]; cov.wt(yvar, wt=x, center=TRUE, method="ML")$cov * sum(x) / (sum(x)-1)})
  }

  ## make the output object
  covregrf.output <- list(
    predicted = predicted.out,
    n = ifelse(outcome == "test", nrow(newdata), object$n),
    xvar.names = xvar.names,
    yvar.names = yvar.names
  )

  class(covregrf.output) <- c("covregrf", "predict")

  return(covregrf.output)
}
