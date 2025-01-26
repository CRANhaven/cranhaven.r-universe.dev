\name{cctmemb}
\alias{cctmemb}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Accessor function for the cluster memberships of the respondents. 
}
\description{
Outputs the cluster (cultural) assignment of each respondent, as determined by the CCT model fit to the data .
}
\usage{
cctmemb(cctfit)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# cctmemb(cctfit)
}
