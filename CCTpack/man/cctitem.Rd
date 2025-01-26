\name{cctitem}
\alias{cctitem}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Accessor function for the item parameters (obtained from the model applied to the data) 
}
\description{
Outputs a table read out of the item parameters of the model inference (for example: item #, estimated consensus answer for each cluster, and item difficulty for each cluster)
}
\usage{
cctitem(cctfit)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# cctitem(cctfit)
}
