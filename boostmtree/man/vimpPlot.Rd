\name{vimpPlot}
\alias{vimpPlot}
\title{
Variable Importance (VIMP) plot
}
\description{
Barplot displaying VIMP.
}
\usage{
vimpPlot(vimp,
         Q_set = NULL,
         Time_Interaction = TRUE,
         xvar.names = NULL,
         cex.xlab = NULL,
         ymaxlim = 0,
         ymaxtimelim = 0,
         subhead.cexval = 1,
         yaxishead = NULL,
         xaxishead = NULL,
         main = "Variable Importance (\%)",
         col = grey(0.8),
         cex.lab = 1.5,
         subhead.labels = c("Time-Interactions Effects", "Main Effects"),
         ylbl = FALSE,
         seplim = NULL,
         eps = 0.1,
         Width_Bar = 1,
         path_saveplot = NULL,
         Verbose = TRUE)
}
\arguments{
  \item{vimp}{
VIMP values.
}
\item{Q_set}{
Provide names for various levels of nominal or ordinal response.
}
  \item{Time_Interaction}{
Whether VIMP is estimated from a longitudinal data, in which case VIMP
is available for covariate and covariate-time interaction. Default is TRUE.
If FALSE, VIMP is assumed to be estimated from a cross-sectional data.
}
  \item{xvar.names}{
Names of the covariates. If NULL, names are assigned as x1, x2,...,xp.
}
  \item{cex.xlab}{
Magnification of the names of the covariates above (and below) the barplot.
}
  \item{ymaxlim}{
By default, we use the range of the vimp values for the covariates for the ylim. If one wants to
extend the ylim, add the amount with which the ylim will extend above.
}
  \item{ymaxtimelim}{
By default, we use the range of the vimp values for the covariates-time for the ylim. If one wants to
extend the ylim, add the amount with which the ylim will extend below. Argument only works for the longitudinal setting.
}
  \item{subhead.cexval}{
Magnification of the \code{subhead.labels}. Argument only works for the longitudinal setting.
}
  \item{yaxishead}{
This represent a vector with two values which are points on the y-axis. Corresponding to the values, the lables for \code{subhead.labels} is shown. First argument corresponds to covariate-time interaction, whereas second argument is for the main effect. Argument only works for the longitudinal setting.
}
  \item{xaxishead}{
This represent a vector with two values which are points on the x-axis. Corresponding to the values, the lables for \code{subhead.labels} is shown. First argument corresponds to covariate-time interaction, whereas second argument is for the main effect. Argument only works for the longitudinal setting.}
  \item{main}{
Main title for the plot.
}
  \item{col}{
Color of the plot.
}
  \item{cex.lab}{
Magnification of the x and y lables.
}
  \item{subhead.labels}{
Labels corresponding to the plot. Default is "Time-Interactions Effects" for the barplot below x-axis, and "Main Effects" for the barplot above x-axis.
}
  \item{ylbl}{
Should labels for the sub-headings be shown on left side of the y-axis.
}
  \item{seplim}{
if \code{ylbl} is \code{TRUE}, the distance between the lables of the sub-headings.
}
  \item{eps}{
Amount of gap between the top of the barplot and variable names.
}
  \item{Width_Bar}{
Width of the barplot.
}
\item{path_saveplot}{Provide the location where plot should be saved. By default the plot will be saved at temporary folder.}
\item{Verbose}{Display the path where the plot is saved?}
}
\details{
Barplot displaying VIMP. If the analysis is for the univariate case,
VIMP is displayed above the x-axis. If the analysis is for the
longitudinal case, VIMP for covariates (main effects) are shown above
the x-axis while VIMP for covariate-time interactions (time interaction
effects) are shown below the x-axis. In either case, negative vimp value
is set to zero.
}
\author{
  Hemant Ishwaran, Amol Pande and Udaya B. Kogalur
}
\examples{
\dontrun{
##------------------------------------------------------------
## Synthetic example
## high correlation, quadratic time with quadratic interaction
##-------------------------------------------------------------
#simulate the data
dta <- simLong(n = 50, N = 5, rho =.80, model = 2,family = "Continuous")$dtaL

#basic boosting call
boost.grow <- boostmtree(dta$features, dta$time, dta$id, dta$y, 
              family = "Continuous",M = 300, cv.flag = TRUE)
vimp.grow <- vimp.boostmtree(object = boost.grow)              

# VIMP plot
vimpPlot(vimp = vimp.grow, ymaxlim = 20, ymaxtimelim = 20,
         xaxishead = c(3,3), yaxishead = c(65,65),
         cex.xlab = 1, subhead.cexval = 1.2)
}
}
\keyword{plot}
