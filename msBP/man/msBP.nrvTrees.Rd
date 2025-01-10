\name{msBP.nrvTrees}
\alias{msBP.nrvTrees}
\title{
Nesting of the sample through the tree
}
\description{
Compute the path of each subject in the binary tree of weights and returns 3 tree: the \code{n} tree, the \code{r} tree, and the \code{v} tree (see values}
\usage{
msBP.nrvTrees(sh, maxS = max(sh[,1]))
}
\arguments{
  \item{sh}{
A matrix with 2 columns and a number of rows equal to the sample size denoting the scale and node labels of each unit
}
  \item{maxS}{
Upper bound for the scale
}
}
\value{
A list containing tree objects of the class \code{binaryTree}.  \code{n} is the tree containing at each node the number of subjects allocated to that node, \code{r} is the tree containing at each node the number of subjects that went right at that node, and  \code{v} is the tree containing at each node the number of subjects that passed through that node.}
\references{
Canale, A. and Dunson, D. B. (2016), "Multiscale Bernstein polynomials for densities", Statistica Sinica, 26(3), 1175-1195.

Canale, A. (2017), "msBP: An R Package to Perform Bayesian Nonparametric Inference Using Multiscale Bernstein Polynomials Mixtures". Journal of Statistical Software, 78(6), 1-19. }
\examples{
sh <- cbind(c(2,2,2,3,3,3,3,3,3,3), c(1,2,2,1,2,3,4,5,6,7))
nrv.trees <- msBP.nrvTrees(sh)
plot(nrv.trees$n)
}
