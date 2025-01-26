\name{Sim.MultiRR}
\alias{Sim.MultiRR}
%%Also NEED an '\alias' for EACH other topic documented here.
\title{
Simulate data setes to be analyzed by a multi-level random regression.
}
\description{
Simulate n data sets to be analyzed with a multi-level random regression.
}
\usage{
Sim.MultiRR(n.ind, SeriesPerInd, ObsPerLevel, EnvGradient, PopInt, 
PopSlope, VCVInd, VCVSeries, ResVar, n.sim, unbalanced = FALSE, 
prop.ind, complete.observations = TRUE, n.obs)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n.ind}{
A vector consisting of the total individuals sampled.
}
  \item{SeriesPerInd}{
A vector consisting of the number of series sampled for each individual.
}
  \item{ObsPerLevel}{
The number of observations per series in each level of the environment.
}
  \item{EnvGradient}{
A vector consisting of the levels in the environmental gradient.
}
  \item{PopInt}{
Population level intercept.
}
  \item{PopSlope}{
Population level slope.
}
  \item{VCVInd}{
A positive definite variance covariance matrix of dimensions 2 X 2, defining the among-individual variance in intercepts and slopes in the diagonals and their covariance in the off diagonals.
}
  \item{VCVSeries}{
A positive definite variance covariance matrix of dimensions 2 X 2, defining the among-series variance in intercepts and slopes in the diagonals and their covariance in the off diagonals.
}
  \item{ResVar}{
Residual variance
}
  \item{n.sim}{
Number of data sets to simulate.
}
  \item{unbalanced}{
Optional argument determining whether not all the individuals were assayed the same number of series. The default is "FALSE".
}
  \item{prop.ind}{
When unbalanced = "TRUE", A vector that has the same length as the number of series per individual, with the proportion of individuals measured n times. All individuals should have been measured once (1,.,.,.).
}
  \item{complete.observations}{
Optional argument determining whether all the levels were assayed the same number of times. The default is "TRUE".
}
  \item{n.obs}{
The total number of observations, if complete.observartions = "FALSE".
}
}

\value{
A list of data sets to be analyzed by Anal.MultiRR.

}
\references{
Araya-Ajoy Y.G., Mathot, K. J., Dingemanse N. J. (2015) An approach to estimate short-term, long-term, and reaction norm repeatability. Methods in Ecology and Evolution.
}
\author{
Yimen Araya
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{ 
\code{\link{Anal.MultiRR}}
}
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

#Example 2: Unbalanced sampling desing.
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
\keyword{ multi-level random regression } % __ONLY ONE__ keyword per line
