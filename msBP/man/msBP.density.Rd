\name{msBP.pdf}
\alias{msBP.pdf}
\alias{msBP.cdf}
\title{
Random probability density function and random cumulative distribution function from a msBP
}
\description{
Compute the density and the cumulative distribution functions of a random density drawn from an msBP(a,b) process
}
\usage{
msBP.pdf(weights, n.points, y)
msBP.cdf(weights, n.points, log, y)
}
\arguments{
  \item{weights}{
An object of the class binaryTree containing probability weights
}
  \item{n.points}{
Length of the grid over (0,1) in which calculate the value of the random density
}
  \item{log}{
Logical. TRUE for computing the log-cdf
}  
\item{y}{
Vector of values in which the random density is evaluated. If used, \code{n.points} is not considered.
}
}
\value{
Vector of size \code{n.points} or \code{length(y)}
}
\references{
Canale, A. and Dunson, D. B. (2016), "Multiscale Bernstein polynomials for densities", Statistica Sinica, 26(3), 1175-1195.

Canale, A. (2017), "msBP: An R Package to Perform Bayesian Nonparametric Inference Using Multiscale Bernstein Polynomials Mixtures". Journal of Statistical Software, 78(6), 1-19. 
}
\seealso{
\code{\link{msBP.rtree}}
}
\examples{
prob <-structure(list( T = list(0.15, c(0.05,0.05), c(0.05,0.2,0.1,0.1), 
		c(0,0,0.3,0,0,0,0,0) ), max.s=3), class  = "binaryTree")
density <- msBP.pdf(prob, 100)
probability <- msBP.cdf(prob, 100)
par(mfrow=c(1,2))
plot(density$dens~density$y, ty='l', main = "pdf")
plot(probability$prob~density$y, ty='l', main = "cdf")
}
