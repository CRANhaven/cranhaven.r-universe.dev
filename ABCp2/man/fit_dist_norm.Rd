\name{fit_dist_norm}
\alias{fit_dist_norm}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Fit Offspring Distribution to the Normal Distribution}
\description{This function fits offspring data to a special case of the normal distribution, in which zero and negative values of offspring are excluded, and tests the goodness of fit using the chi-squared test.}
\usage{
fit_dist_norm(dist)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dist}{a numeric vector of data values for number of offspring per dam.}
}

\value{
  \item{estimate}{Mean and standard deviation parameters estimated from the supplied distribution.} 
  \item{sd}{Standard deviation of the mean and standard deviation estimates.}
  \item{vcov}{Variance/covariance matrix of the mean and standard deviation estimates.}
  \item{loglik}{the log-likelihood of the mean and standard deviation estimates.}
  \item{n}{The number of observations.}
  \item{statistic}{The chi-squared test statistic.}
  \item{parameter}{Degrees of freedom for the chi-squared test.}
  \item{p.value}{P-value for the chi-squared test.}
  \item{data_norm}{Vector of values generated from a special case of the normal distribution.}

}

\author{M. Catherine Duryea, Andrew D. Kern, Robert M. Cox, and Ryan Calsbeek}


%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
#Fit the Mean and Standard Deviation parameters to a distribution of offspring.
#Test the goodness of fit.

data(fungus)
fungus_fit<-fit_dist_norm(fungus$Total_Offspring)
fungus_fit$fit_norm
fungus_fit$chi_norm
fungus_fit$data_norm
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
