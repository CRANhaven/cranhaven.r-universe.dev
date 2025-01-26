\name{ABC_P2_gamma}
\alias{ABC_P2_gamma}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ABC Estimation of P2 for Gamma Distribution}
\description{This function fits offspring data to a special case of the gamma distribution, in which zero values of offspring are excluded and all values are rounded to a whole number, and estimates P2 based on that distribution and the specificed priors.}
\usage{
ABC_P2_gamma(n, ObsMean, S_Lo, S_Hi, R_Lo, R_Hi, delta, iter)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n}{number of observations.}
  \item{ObsMean}{the observed mean number of offspring sired by the second male.}
  \item{S_Lo}{minimum shape value for the distribution.}
  \item{S_Hi}{maximum shape value for the distribution.}
  \item{R_Lo}{minimum rate value for the distribution.}
  \item{R_Hi}{maximum rate value for the distribution.}
  \item{delta}{maximum allowed difference between the estimated mean and observed mean number of offspring produced by the second male.}
  \item{iter}{number of iterations used to build the posterior.}
}

\value{
	\item{posterior}{Posterior distribution of P2 values.}
	\item{Shape}{Vector of values for the shape parameter.}
	\item{Rate}{Vector of values for the rate parameter.}
	}

\author{M. Catherine Duryea, Andrew D. Kern, Robert M. Cox, and Ryan Calsbeek}

%% ~Make other sections like Warning with \section{Warning }{....} ~


\examples{
#Fit the Shape and Rate hyperpriors to a distribution of offspring. 

data(fungus)
fit_dist_gamma(fungus$Total_Offspring)

#Use hyperiors and priors calculated from the data to estimate P2. 
#Plot the saved distributions for the Shape and Rate parameters.
#Adjust, if necessary.

fungus_P2<-ABC_P2_gamma(12, 9.9, 1.14, 2.52, 0.06, 0.18, 0.1, 100)
hist(fungus_P2$posterior)
hist(fungus_P2$Shape)
hist(fungus_P2$Rate)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
