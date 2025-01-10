\name{msBP.compute.prob}
\alias{msBP.compute.prob}
\title{
Compute binary tree of probabilities
}
\description{
Compute the binary tree of probabilities using the multiscale stick-breaking process of Canale and Dunson (2016). 
}
\usage{
msBP.compute.prob(msBPtree, root = TRUE)
}
\arguments{
  \item{msBPtree}{
An object of the class msBPTree
}
\item{root}{logical. if the root needs to be considered (default) or it should be cut (fixing \eqn{S_{01} = 0})
}
}
\details{
Compute a binary tree of weights. The general weights for node \eqn{h} of scale \eqn{s}, is
\deqn{ \pi_{s,h} = S_{s,h} \prod_{r<s} (1-S_{r,g_{shr}}) T_{shr}}{%
\pi_{s,h} = S_{s,h} \prod_{r<s} (1-S_{r,g_{shr}}) T_{shr}
}
where \eqn{g_{shr} = \lceil h/2^{s-r} \rceil} and \eqn{T_{shr} = R_{r,g_{shr}}} if \eqn{(r+1,g_{shr+1})} is the right daughter of node \eqn{(r,g_{shr})}, or \eqn{T_{shr} = 1-R_{r,g_{shr}}} if \eqn{(r+1,g_{shr+1})} is the left daughter of \eqn{(r,g_{shr})}.  
An object of the msBPTree class is basically a list containing two objects of the class \code{binaryTree}: the \eqn{S} tree (representing the stoping probabilities) and the \eqn{R} tree (representing the proceed-right probabilities).
}
\value{
An object of the class \code{msbpTree}.
}
\references{
Canale, A. and Dunson, D. B. (2016), "Multiscale Bernstein polynomials for densities", Statistica Sinica, 26(3), 1175-1195.

Canale, A. (2017), "msBP: An R Package to Perform Bayesian Nonparametric Inference Using Multiscale Bernstein Polynomials Mixtures". Journal of Statistical Software, 78(6), 1-19. 
}
\seealso{
\code{\link{msBP.rtree}}
}
\examples{
S <-structure(list( T = list(1/8,c(1/3,1/3), c(1/4,1/4,1/4,1/4), 
	rep(1,8)), max.s=3), class  = "binaryTree")
R <-structure(list( T = list(1/2,c(1/2,1/2), c(1/4,1/2,1/2,1/2), 
	rep(1,8)), max.s=3), class  = "binaryTree")
RS <-structure(list(S = S, R = R), class  = "msbpTree")
probabilities <- msBP.compute.prob(RS)
}

