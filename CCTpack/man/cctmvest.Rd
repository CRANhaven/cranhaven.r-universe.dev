\name{cctmvest}
\alias{cctmvest}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Accessor function for the missing value estimates of the data, based on the cctfit (if there were missing values in the data). 
}
\description{
Outputs an N by 3 matrix, where N is the number of missing values estimated by the model, column 1 is the person index, column 2 the item index, column 3 is the value estimate.
}
\usage{
cctmvest(cctfit)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# cctmvest(cctfit)
}
