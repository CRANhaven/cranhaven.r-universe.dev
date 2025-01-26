\name{cctsubj}
\alias{cctsubj}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Accessor function for the subject parameters (obtained from the model applied to the data) 
}
\description{
Outputs a table read out of the subject parameters of the model inference (for example: participant #, cluster membership, competency, response biases)
}
\usage{
cctsubj(cctfit)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# cctsubj(cctfit)
}
