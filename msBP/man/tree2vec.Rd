\name{tree2vec}
\alias{tree2vec}
\alias{vec2tree}

\title{
Conversions between tree and vector
}
\description{
Convert a binary tree object into a vector and _vice versa_
}
\usage{
tree2vec(tree)
vec2tree(vec)
}
\arguments{
  \item{tree}{
	An object of the class binaryTree 
}
  \item{vec}{A vector of numbers. It must have size 2^s - 1, with s an integer.
}
}
\details{
An object of the class binaryTree is a binary tree containing at each node a value. 
}
\value{
A vector of size \eqn{2^{D+1}-1}, where \eqn{D} is the depth of the binary tree, or a binary tree with depth \eqn{\log_2(}\code{length(vec) + 1}\eqn{)}.
}
\examples{
tree <- vec2tree(1:(2^5 - 1))
vector <- tree2vec(tree)
}
