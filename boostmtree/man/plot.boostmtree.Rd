\name{plot.boostmtree}
\alias{plot.boostmtree}
\title{Plot Summary Analysis}
\description{
  Plot summary analysis of the boosting analysis.
}
\usage{\method{plot}{boostmtree}(x, use.rmse = TRUE, path_saveplot = NULL, Verbose = TRUE, ...)}
\arguments{
  \item{x}{An object of class \code{(boostmtree, grow)} or
    \code{(boostmtree, predict)}.}
  \item{use.rmse}{Report performance values in terms of standardized
    root-mean-squared-error (RMSE) or mean-squared-error (MSE)?  Default
  is standardized RMSE.}
  \item{path_saveplot}{Provide the location where plot should be saved. By default the plot will be saved at temporary folder.}
  \item{Verbose}{Display the path where the plot is saved?}
  \item{...}{Further arguments passed to or from other methods.}
}
\details{
  Plot summary output, including predicted values and residuals.  Also plots
  various parameters against the number of boosting iterations.
}
\author{
  Hemant Ishwaran, Amol Pande and Udaya B. Kogalur
}
\references{
  Pande A., Li L., Rajeswaran J., Ehrlinger J., Kogalur U.B.,
  Blackstone E.H., Ishwaran H. (2017).  Boosted multivariate trees for
  longitudinal data, \emph{Machine Learning}, 106(2): 277--305. 
}
\keyword{plot}
