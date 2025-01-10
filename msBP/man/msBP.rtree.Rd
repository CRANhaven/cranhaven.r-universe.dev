\name{msBP.rtree}
\alias{msBP.rtree}
\title{
Random msBP tree
}
\description{
Draw a random tree from the msBP process
}
\usage{
msBP.rtree(a, b, max.s = 10)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{a}{
Scalar parameter
}
  \item{b}{
Scalar parameter
}
  \item{max.s}{
Maximum depth of the random trees
}
}
\value{
An object of the class \code{msBPTree}
}
\references{
Canale, A. and Dunson, D. B. (2016), "Multiscale Bernstein polynomials for densities", Statistica Sinica, 26(3), 1175-1195.

Canale, A. (2017), "msBP: An R Package to Perform Bayesian Nonparametric Inference Using Multiscale Bernstein Polynomials Mixtures". Journal of Statistical Software, 78(6), 1-19. }
\seealso{
\code{\link{msBP.rsample}}, \code{\link{msBP.compute.prob}} 
}
\examples{
msBP.rtree(2, 2, 4)
}
