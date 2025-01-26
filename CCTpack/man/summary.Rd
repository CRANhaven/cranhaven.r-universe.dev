\name{summary}
\alias{summary}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Summary of the cctfit object of class 'cct'.
}
\description{
Summary method for a cctfit object of class 'cct'. Information about the data, the fit, posterior predictive checks.
}
\usage{
summary(object, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{The \code{cctfit} object as obtained from the \code{cctapply()} function, which has class 'cct'.}
  \item{...}{Additional arguments}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# summary(cctfit)
}
