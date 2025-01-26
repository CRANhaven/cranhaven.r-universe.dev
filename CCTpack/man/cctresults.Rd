\name{cctresults}
\alias{cctresults}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Plot the posterior results from the model inference
}
\description{
Plot the posterior results from the model inference, a specialized display is produced depending on the model that is applied.
}
\usage{
cctresults(cctfit)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# cctresults(cctfit)
}
