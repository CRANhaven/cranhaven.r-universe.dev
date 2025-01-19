\name{partialPlot}
\alias{partialPlot}
\title{Partial plot analysis}
\description{
  Partial dependence plot of x against adjusted predicted y.
}
\usage{partialPlot(object,
            M = NULL,
            xvar.names,
            tm.unq,
            xvar.unq = NULL,
            npts = 25,
            subset,
            prob.class = FALSE,
            conditional.xvars = NULL,
            conditional.values = NULL,
            plot.it = FALSE,
            Variable_Factor = FALSE,
            path_saveplot = NULL,
            Verbose = TRUE,
            useCVflag = FALSE,
            ...)}
\arguments{
  \item{object}{A boosting object of class \code{(boostmtree, grow)}.}
  \item{M}{Fixed value for the boosting step number. If NULL, then use Mopt
  if it is available from the object, else use M}
  \item{xvar.names}{Names of the x-variables to be used.  By default,
    all variables are plotted.}
  \item{tm.unq}{Unique time points used for the plots of x against y.  By default,
    the deciles of the observed time values are used.}
  \item{xvar.unq}{Unique values used for the partial plot. Default is NULL in which case
  unique values are obtained uniformaly based on the range of variable. Values must
  be provided using list with same length as lenght of \code{xvar.names}.}
  \item{npts}{Maximum number of points used for x.  Reduce this value if
    plots are slow.}
  \item{subset}{Vector indicating which rows of the x-data to be used for the
    analysis.  The default is to use the entire data.}
  \item{prob.class}{In case of ordinal response, use class probability rather than cumulative probability.}
  \item{conditional.xvars}{Vector of character values indicating names of the x-variables
    to be used for further conditioning (adjusting) the predicted y values. Variable names
    should be different from \code{xvar.names}.}
  \item{conditional.values}{Vector of values taken by the variables from \code{conditional.xvars}.
    The length of the vector should be same as the length of the vector for \code{conditional.xvars}, which means only one value per conditional variable.}
  \item{plot.it}{Should plots be displayed?}
  \item{Variable_Factor}{Default is FALSE. Use TRUE if the variable specified
  in \code{xvar.names} is a factor.}
  \item{path_saveplot}{Provide the location where plot should be saved. By default the plot will be saved at temporary folder.}
  \item{Verbose}{Display the path where the plot is saved?}
  \item{useCVflag}{Should the predicted value be based on the estimate derived from oob sample?}
  \item{...}{Further arguments passed to or from other methods.}
}
\details{
  Partial dependence plot (Friedman, 2001) of x values specified by
  \code{xvar.names} against the adjusted predicted y-values over a set
  of time points specified by \code{tm.unq}.  Analysis can be restricted to
  a subset of the data using \code{subset}. Further conditioning can be
  imposed using \code{conditional.xvars}.
}
\author{
  Hemant Ishwaran, Amol Pande and Udaya B. Kogalur
}
\references{
  Friedman J.H. Greedy function approximation: a gradient
  boosting machine, \emph{Ann. of Statist.}, 5:1189-1232, 2001.
}
\examples{
\dontrun{
##------------------------------------------------------------
## Synthetic example (Response is continuous)
## high correlation, quadratic time with quadratic interaction
##-------------------------------------------------------------
#simulate the data
dta <- simLong(n = 50, N = 5, rho =.80, model = 2,family = "Continuous")$dtaL

#basic boosting call
boost.grow <- boostmtree(dta$features, dta$time, dta$id, dta$y,family = "Continuous",M = 300)

#plot results
#x1 has a linear main effect
#x2 is quadratic with quadratic time trend
pp.obj <- partialPlot(object = boost.grow, xvar.names = "x1",plot.it = TRUE)
pp.obj <- partialPlot(object = boost.grow, xvar.names = "x2",plot.it = TRUE)

#partial plot using "x2" as the conditional variable
pp.obj <- partialPlot(object = boost.grow, xvar.names = "x1",
                      conditional.xvar = "x2", conditional.values = 1,plot.it = TRUE)
pp.obj <- partialPlot(object = boost.grow, xvar.names = "x1",
                      conditional.xvar = "x2", conditional.values = 2,plot.it = TRUE)

##------------------------------------------------------------
## Synthetic example (Response is binary)
## high correlation, quadratic time with quadratic interaction
##-------------------------------------------------------------
#simulate the data
dta <- simLong(n = 50, N = 5, rho =.80, model = 2,family = "Binary")$dtaL

#basic boosting call
boost.grow <- boostmtree(dta$features, dta$time, dta$id, dta$y,family = "Binary",M = 300)

#plot results
#x1 has a linear main effect
#x2 is quadratic with quadratic time trend
pp.obj <- partialPlot(object = boost.grow, xvar.names = "x1",plot.it = TRUE)
pp.obj <- partialPlot(object = boost.grow, xvar.names = "x2",plot.it = TRUE)

##----------------------------------------------------------------------------
## spirometry data
##----------------------------------------------------------------------------
data(spirometry, package = "boostmtree")

#boosting call: cubic B-splines with 15 knots
spr.obj <- boostmtree(spirometry$features, spirometry$time, spirometry$id, spirometry$y,
            family = "Continuous",M = 300, nu = .025, nknots = 15)

#partial plot of double-lung group at 5 years
dltx <- partialPlot(object = spr.obj, xvar.names = "AGE",
                    tm.unq = 5, subset=spr.obj$x$DOUBLE==1,plot.it = TRUE)

#partial plot of single-lung group at 5 years
sltx <- partialPlot(object = spr.obj, xvar.names = "AGE",
                    tm.unq = 5, subset=spr.obj$x$DOUBLE==0,plot.it = TRUE)

#combine the two plots: we use lowess smoothed values
dltx <- dltx$l.obj[[1]]
sltx <- sltx$l.obj[[1]]
plot(range(c(dltx[, 1], sltx[, 1])), range(c(dltx[, -1], sltx[, -1])),
     xlab = "age", ylab = "predicted y (adjusted)", type = "n")
lines(dltx[, 1], dltx[, -1], lty = 1, lwd = 2, col = "red")
lines(sltx[, 1], sltx[, -1], lty = 1, lwd = 2, col = "blue")
legend("topright", legend = c("DLTx", "SLTx"), lty = 1, fill = c(2,4))
}
}
\keyword{plot}
