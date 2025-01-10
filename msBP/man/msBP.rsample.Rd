\name{msBP.rsample}
\alias{msBP.rsample}

\title{
Random numbers from a random msBP densty 
}
\description{
Random numbers generation from a random density drawn from a msBP process. }
\usage{
msBP.rsample(n, msBPtree)
}
\arguments{
  \item{n}{
Size of the sample to be generated
}
  \item{msBPtree}{
An object of the class msBPtree
}
}
\value{
A vector containing the random sample
}
\references{
Canale, A. and Dunson, D. B. (2016), "Multiscale Bernstein polynomials for densities", Statistica Sinica, 26(3), 1175-1195.

Canale, A. (2017), "msBP: An R Package to Perform Bayesian Nonparametric Inference Using Multiscale Bernstein Polynomials Mixtures". Journal of Statistical Software, 78(6), 1-19. 
}
\seealso{
\code{\link{msBP.rtree}}
}
\examples{
rand.tree <- msBP.rtree(50,2, 4)
rand.samp <- msBP.rsample(50, rand.tree)
hist(rand.samp, prob=TRUE)
prob <- msBP.compute.prob(rand.tree)
density <- msBP.pdf(prob, 100)
points(density$dens~density$y, ty='l', col=4)
}
