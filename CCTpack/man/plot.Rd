\name{plot}
\alias{plot}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Plot method for a cctfit object of class 'cct';  equivalent to function cctresults().
}
\description{
Plots the posterior results from the model inference, a specialized display is produced depending on the model that is applied.
}
\usage{
plot(x,y,...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{is a \code{cctfit} object as obtained from the \code{cctapply()} function, which has class 'cct'.}
  \item{y}{NULL}
  \item{...}{Additional arguments}
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# plot(cctfit)
}
