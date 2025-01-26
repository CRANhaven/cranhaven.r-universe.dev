\name{Power}
\alias{Power}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Estimates power to detect significant among-individual variation in intercepts and slopes.
}
\description{
 Power analysis for object created with anal.MultiRR.
}
\usage{
Power(x)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
Object created with Anal.MultiRR.
}
}

\value{
A list of data frames with the power to detect among-individual variation in intercepts and slopes in a multi-level random regression model.
}

\references{
Araya-Ajoy Y.G., Mathot, K. J., Dingemanse N. J. (2015) An approach to estimate short-term, long-term, and reaction norm repeatability. Methods in Ecology and Evolution.
}
\author{
Yimen Araya
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{Sim.MultiRR}},
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
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ multi-level random regression }
\keyword{ power } % __ONLY ONE__ keyword per line

