\name{eks}
\alias{eks}
\title{
  eks: transforming a non-transitive index number matrix into a transitive one
}
\description{
  This function takes a matrix of all non-transitive binary index numbers comparisons of a data set and transforms it into a matrix of transitive index numbers using the EKS method.
}
\usage{
eks(mat)
}
\arguments{
  \item{mat}{
  Matrix of non transitive bilateral comparisons. To be transformed into transitive matrix via the EKS method.
}
}
\details{
  The function should be applied to a matrix that contains superlative index numbers comparisons.
}
\value{
  It returns the set of transitive indexes associated with the benchmark unit/period.  
}
\references{
 T. J. Coelli, D. S. Prasada Rao, C. J. O'Donnell, and G. E. Battese. \emph{An introduction to Efficiency and Productivity Analysis}, 2nd edition. Springer Science + Business Media, New York, 2005.
}
\author{
 Edoardo Baldoni
}

\examples{

# Trasforming a non-transitive Fisher matrix into a transitive one
data(multil_data)

I_nt[1,3]*I_nt[3,4]
I_nt[1,4] #non-transitive

I_t = eks(I_nt)
I_t[1,3]*I_t[3,4]
I_t[1,4] #transitive


} 
