\name{cctfac}
\alias{cctfac}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Accessor function for the factor coefficients after \code{dat <- cctscree(dat)} has been run. 
}
\description{
Outputs a vector of the factor coefficients obtained from a principal components analysis of the respondent by respondent correlation matrix of the data.
}
\usage{
cctfac(dat)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dat}{The object as obtained from the \code{dat <- cctscree(dat)} function.}
}
\examples{
data(hotcold)
dat <- cctscree(hotcold)
cctfac(dat)
}
