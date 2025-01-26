\name{MultiRR-package}
\alias{MultiRR-package}
\alias{MultiRR}
\docType{package}
\title{
Simulation Package for Multi-level random regressions
}
\description{
Calculates bias, precision, and power for multi-level random regressions. Random regressions are types of hierarchical models in which data are structured in groups and (regression) coefficients can vary by groups. Tools to estimate model performance are designed mostly for scenarios where (regression) coefficients vary at just one level. 'MultiRR' provides simulation and analytical tools (based on 'lme4') to study model performance for random regressions that vary at more than one level (multi-level random regressions), allowing researchers to determine optimal sampling designs.
}
\details{
\tabular{ll}{
Package: \tab MultiRR\cr
Type: \tab Package\cr
Version: \tab 1.0\cr
Date: \tab 2015-05-11\cr
License: \tab GPL -2\cr
}
Use the function \code{\link{Sim.MultiRR}} to simulate n data sets, then use the function \code{\link{Anal.MultiRR}} to perform a multi-level random regression to n simulated data sets. You can view the results using the function \code{\link{Summary}} or \code{\link{Plot.Sim}}, estimate bias using the function \code{\link{Bias}}, imprecision using the function \code{\link{Imprecision}}, and power using the function \code{\link{Power}}. 
}
\author{
Yimen Araya: <yimencr@gmail.com>

}
\references{
Araya-Ajoy Y.G., Mathot, K. J., Dingemanse N. J. (2015) An approach to estimate short-term, long-term, and reaction norm repeatability. Methods in Ecology and Evolution.
}
\keyword{ package }
\examples{
#Example 1: Balanced sampling design.
#Define sample sizes.
n.ind <-c(40, 50) ##Numbers of individuals to simulate.
SeriesPerInd <- c(4, 5) ##Number of series per individual to simulate.
ObsPerLevel <- 2 ##Number of observations per level in the environmental gradient.
 
#Number of simulated data sets, use at least 10.
n.sim=3

#Define the environmetal gradient.
EnvGradient <- c(-0.5, 0.5)
 
#Define the population level parameters.
PopInt <- 0 ##Population level intercept.
PopSlope <- -0.5 ##Population level slope.
 
#Define individual level parameters
VCVInd <-matrix(c(0.3, 0.15, 0.15, 0.3),2,2) ##Creates a variance-covariance matrix.
 
#Define series level parameters
VCVSeries <-matrix(c(0.3, 0.15, 0.15, 0.3),2,2) ##Creates a variance-covariance matrix.
 
#Define the residual variance.
ResVar <- 0.4
 
#Simulate the data sets.
sim.data <- Sim.MultiRR(n.ind=n.ind, SeriesPerInd=SeriesPerInd, 
ObsPerLevel=ObsPerLevel, EnvGradient=EnvGradient, PopInt=PopInt, PopSlope=PopSlope, 
VCVInd=VCVInd, VCVSeries=VCVSeries, ResVar=ResVar, n.sim=3)
 
#Analyze the simulated data sets. This may take a while.
ressim <- Anal.MultiRR(sim.data)

#Summarize the results of the multi-level random regressions. 
Summary(ressim) 
 
#Estimate bias.
Bias(ressim)
 
#Estiamte imprecision.
Imprecision(ressim)
 
#Estimate power.
Power(ressim)

#Example 2: Unbalanced sampling design.
#Define sample sizes.
n.ind <-40 ##Numbers of individuals to simulate.
SeriesPerInd <- 4 ##Number of series per individual to simulate.
ObsPerLevel <- 2 ##Number of observations per level in the environmental gradient.

#Define the proportion of individuals that were sampled in all the series.
#All individuals were assayed at least once, 0.9 of individuals twice...

prop.ind<-c(1, 0.9, 0.8, 0.7)

#Define the total number of observations
n.obs=300

#Number of simulated data sets, use at least 10.
n.sim=3

#Define the environmetal gradient.
EnvGradient <- c(-0.5, 0.5)
 
#Define the population level parameters.
PopInt <- 0 ##Population level intercept.
PopSlope <- -0.5 ##Population level slope.

#Define the individual level parameters.
VCVInd <-matrix(c(0.3, 0.15, 0.15, 0.3),2,2) ##Creates a variance-covariance matrix.
 
#Define the series level parameters.
VCVSeries <-matrix(c(0.3, 0.15, 0.15, 0.3),2,2) ##Creates a variance-covariance matrix.
 
#Define the residual variance.
ResVar <- 0.4
 
#Simulate the data.
sim.data <- Sim.MultiRR(n.ind=n.ind, SeriesPerInd=SeriesPerInd, ObsPerLevel=ObsPerLevel,
EnvGradient=EnvGradient, PopInt=PopInt, PopSlope=PopSlope, VCVInd= VCVInd, VCVSeries=VCVSeries,
ResVar=ResVar, n.sim=n.sim, unbalanced=TRUE, prop.ind=c(1, 0.9, 0.8, 0.7), 
complete.observations=FALSE, n.obs=n.obs)
 
#Analyze simulated data sets. This may take a while.
ressim <- Anal.MultiRR(sim.data)
 
#Summarize the results of the multi-level random regressions.
Summary(ressim)
 
#Estimate bias.
Bias(ressim)
 
#Estiamte imprecision.
Imprecision(ressim)
 
#Estimate power.
Power(ressim)  
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ simulation }
\keyword{multi-level random regression} % __ONLY ONE__ keyword per line
