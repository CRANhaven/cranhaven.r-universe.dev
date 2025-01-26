\name{ABC_P2_pois}
\alias{ABC_P2_pois}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ABC Estimation of P2 for Poisson Distribution}
\description{This function fits offspring data to the Poisson distribution and estimates P2 based on that distribution and the specificed priors.}
\usage{
ABC_P2_pois(n, ObsMean, L_Lo, L_Hi, delta, iter)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n}{the number of observations.}
  \item{ObsMean}{the observed mean number of offspring sired by the second male.}
  \item{L_Lo}{minimum lambda value for the distribution.}
  \item{L_Hi}{maximum lambda value for the distribution.}
  \item{delta}{maximum allowed difference between the estimated mean and observed mean number of offspring produced by the second male.}
  \item{iter}{number of iterations used to build the posterior.}
}

\value{
	\item{posterior}{Posterior distribution of P2 values.}
	\item{Lambda}{Vector of values for the lambda parameter.}
	}

\author{M. Catherine Duryea, Andrew D. Kern, Robert M. Cox, and Ryan Calsbeek}


%% ~Make other sections like Warning with \section{Warning }{....} ~


\examples{
#Fit the Lambda hyperprior to a distribution of offspring.

data(fungus)
fit_dist_pois(fungus$Total_Offspring)

#Use hyperiors and priors calculated from the data to estimate P2. 
#Plot the saved distributions for the Lambda parameter. 
#Adjust, if necessary.

fungus_P2<-ABC_P2_pois(12, 9.9, 13.24, 15.42, 0.1, 100)
hist(fungus_P2$posterior)
hist(fungus_P2$Lambda)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
