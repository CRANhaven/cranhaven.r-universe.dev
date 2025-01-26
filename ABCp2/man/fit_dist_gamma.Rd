\name{fit_dist_gamma}
\alias{fit_dist_gamma}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Fit Offspring Distribution to the Gamma Distribution}
\description{This function fits offspring data to a special case of the gamma distribution, in which zero values of offspring are excluded and all values are rounded to a whole number, and tests the goodness of fit using the chi-squared test.}
\usage{
fit_dist_gamma(dist)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dist}{a numeric vector of data values for number of offspring per dam.}
}

\value{
  \item{estimate}{Shape and rate parameters estimated from the supplied distribution.} 
  \item{sd}{Standard deviation of the shape and rate estimates.}
  \item{vcov}{Variance/covariance matrix of the shape and rate estimates.}
  \item{loglik}{the log-likelihood of the shape and rate estimates.}
  \item{n}{The number of observations.}
  \item{statistic}{The chi-squared test statistic.}
  \item{parameter}{Degrees of freedom for the chi-squared test.}
  \item{p.value}{P-value for the chi-squared test.}
  \item{data_gamma}{Vector of values generated from a special case of the gamma distribution.}
}

\author{M. Catherine Duryea, Andrew D. Kern, Robert M. Cox, and Ryan Calsbeek}


%% ~Make other sections like Warning with \section{Warning }{....} ~


\examples{
#Fit the Shape and Rate parameters to a distribution of offspring.
#Test the goodness of fit.

data(fungus)
fungus_fit<-fit_dist_gamma(fungus$Total_Offspring)
fungus_fit$fit_gamma
fungus_fit$chi_gamma
hist(fungus_fit$data_gamma)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
