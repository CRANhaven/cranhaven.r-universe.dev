\name{dtraceplot}
\alias{dtraceplot}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Traceplots for discrete parameters of a cctfit object
}
\description{
Produces all of the traceplots the discrete parameters of a cctfit object, in a 3x3 design and multiple plot windows, via traceplot from \pkg{R2jags}.
}
\usage{
dtraceplot(cctfit,ask = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
  \item{ask}{logical; if \code{TRUE}, the user is asked before each plot, to proceed to the next. See \code{par(ask=.)}}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# dtraceplot(cctfit)
}
