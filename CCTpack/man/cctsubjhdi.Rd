\name{cctsubjhdi}
\alias{cctsubjhdi}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Accessor function for the subject parameter credible intervals (obtained from the model applied to the data) 
}
\description{
Outputs a table read out of the credible intervals (posterior highest density intervals, HDIs) of the subject parameters of the model inference (for example, the lower and upper bounds of estimated participant knowledge competencies and response biases)
}
\usage{
cctsubjhdi(cctfit)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# cctsubjhdi(cctfit)
}
