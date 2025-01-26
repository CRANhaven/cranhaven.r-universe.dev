
\name{load.prev.func}
\alias{load.prev.func}
\title{load.prev.func}

\description{A function for Isotoper that is used to plot output from previous runs of IsotopeR.}
\usage{load.prev.func(file.name="SampleOutput.Rdata", plot.observations=TRUE, 
plot.mixing.estimates=TRUE, plot.dietary.source.contributions=TRUE, color.plots=TRUE)}
\arguments{
	\item{file.name}{The .Rdata file from a previous run of IsotopeR.}
	\item{plot.observations}{This will make a plot of the mixing space, meaning the estimated sources and source concentrations, along with the mixture observations. If measurement error data is provided, the estimated 95 percent CI's will be displayed.}
	\item{plot.mixing.estimates}{This will make a plot of the mixing space, meaning the estimated sources and source concentrations, along with the estimate mixture values along with their estimated 95 percent CI's will be displayed.}
	 \item{plot.dietary.source.contributions}{ Plots the smoothed histograms of the population level diet estimates (black) along with individual level estimates (blue). }
	   \item{color.plots}{The flag defines whether plots should be made in color, or grayscale.}
}
\author{
Jake Ferguson
}

