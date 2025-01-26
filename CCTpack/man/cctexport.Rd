\name{cctexport}
\alias{cctexport}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Export the results (the cctfit object)
}
\description{
Exports the \code{cctfit} object as an .Rdata file, as well as .jpeg and .eps files of the relevant plots
}
\usage{
cctexport(cctfit, filename = "CCTpackdata.Rdata")
}
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
  \item{filename}{The filename and location you would like to use. If no location is specified, it is saved to the current R working directory (see \code{getwd()}).}
}
\details{
Saves the \code{cctfit} object as an .Rdata file, as well as .jpeg and .eps files of the relevant plots, which include: the scree plot, results plot, and posterior predictive check plots.
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = TRUE)
# cctexport(cctfit, filename = "C:/CCTpack/CCTpackdata.Rdata")
}
