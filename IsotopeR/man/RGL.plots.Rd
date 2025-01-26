\name{RGL.plots}
\alias{RGL.plots}
\title{
Mixing Space, 3 isotopes
}
\description{
A mixing space plot used to plot the source estimations and the observations or model fits when the number of isotopes used is 3.
}
\usage{
RGL.plots(jags.1, X, sources, plot.mix=FALSE, plot.ind.flag=FALSE, color.plots=FALSE)
}
\arguments{
\item{jags.1}{A jags object, output from the runjags package.}
\item{X}{Isotopic mixture data}
\item{sources}{A matrix including all source information. Should be formatted as a source file as discussed in the IsotopeR vignette.}
\item{plot.mix}{A flag, plots the estimated mixture values, when TRUE (1). If FALSE (0) then the the function plots the observed mixture values. }
\item{plot.ind.flag}{A flag, plots the observed mixture values, when TRUE (1).}
\item{color.plots}{ Denotes whether plots should be color, or greyscale. The user does not have the ability to specify which colors should be used.}
}
\author{
Jake Ferguson
}


