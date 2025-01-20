generic.vimp.rfcca <- function(object,
                               ...)
{
  ## check for bootstrap in forest object
  if (object$bootstrap == "none") {
    stop("when bootstrap is 'none', importance cannot be computed")
  }
  ## object cannot be missing
  if (missing(object)) {stop("object is missing!")}
  ## incoming object must be a grow forest object
  if (sum(inherits(object, c("rfcca", "grow"), TRUE) == c(1, 2)) != 2)
    stop("this function only works for objects of class '(rfcca, grow)'")
  ## pull the x, y, z-variables and names from the grow object
  xvar <- object$xvar
  yvar <- object$yvar
  zvar <- object$zvar
  zvar.names <- object$zvar.names
  ## pull the training predictions from the grow object
  predicted.oob <- object$predicted.oob
  ## run rfsrc for predictions
  vimpdata <- zvar
  vimpdata$t <- predicted.oob
  rfvimp <- rfsrc(formula = t~.,
                  data = vimpdata,
                  mvdata1 = xvar,
                  mvdata2 = yvar,
                  ntree = object$ntree,
                  mtry = object$mtry,
                  nodesize = object$nodesize,
                  nodedepth = object$nodedepth,
                  nsplit = object$nsplit,
                  importance = TRUE,
                  samptype = object$samptype,
                  sampsize = object$sampsize)
  vimp.out <- rfvimp$importance
  names(vimp.out) <- zvar.names
  ## make the output object
  rfccaOutput <- list(
    call = object$call,
    n = object$n,
    ntree = object$ntree,
    zvar = zvar,
    zvar.names = zvar.names,
    predicted.oob = predicted.oob,
    finalcca = object$finalcca,
    importance = vimp.out
  )

  class(rfccaOutput) <- c("rfcca", "predict")

  return(rfccaOutput)
}
