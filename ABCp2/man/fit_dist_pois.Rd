\name{fit_dist_pois}
\alias{fit_dist_pois}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Fit Offspring Distribution to the Poisson Distribution}
\description{This function fits offspring data to the Poisson distribution, and tests the goodness of fit using the chi-squared test.}
\usage{
fit_dist_pois(dist)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dist}{a numeric vector of data values for number of offspring per dam.}
}

\value{
  \item{estimate}{Lambda parameter estimated from the supplied distribution.} 
  \item{sd}{Standard deviation of the lambda estimate.}
  \item{vcov}{Variance/covariance matrix of the lambda estimate.}
  \item{loglik}{the log-likelihood of the lambda estimate.}
  \item{n}{The number of observations.}
  \item{statistic}{The chi-squared test statistic.}
  \item{parameter}{Degrees of freedom for the chi-squared test.}
  \item{p.value}{P-value for the chi-squared test.}
  \item{data_pois}{Vector of values generated from the Poisson distribution.}
  }

\author{M. Catherine Duryea, Andrew D. Kern, Robert M. Cox, and Ryan Calsbeek}


%% ~Make other sections like Warning with \section{Warning }{....} ~


\examples{
#Fit the Lambda parameter to a distribution of offspring.
#Test the goodness of fit.

data(fungus)
fungus_fit<-fit_dist_pois(fungus$Total_Offspring)
fungus_fit$fit_pois
fungus_fit$chi_pois
hist(fungus_fit$data_pois)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1  }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
