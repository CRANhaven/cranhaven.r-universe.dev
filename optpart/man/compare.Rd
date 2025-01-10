\name{compare}
\alias{compare}
\title{Compare Species Constancy for Specified Clusters}
\description{Extracts specified columns from a constancy table
(see \code{\link[labdsv]{const}}) and identifies species which
occur in one of the two clusters (potential diagnostic species) 
or in both.
}
\usage{
compare(const,left,right,thresh=0.2)
}
\arguments{
    \item{const}{a constancy table produced by function \code{\link[labdsv]{const}}}
    \item{left}{a numeric cluster}
    \item{right}{a cluster number}
    \item{thresh}{a minimum differential abundance to list in the table}
}
\details{compare extracts two columns (left and right) from a constancy table produced by
\code{\link[labdsv]{const}}, and calculates the pairwise differences.  
Differences greater than the specified threshold appear in the set \sQuote{left}; 
negative differences less then minus one times the threshold appear in the set \sQuote{right},
and species which occur in both columns but with an absolute value of difference less 
than the threshold appear in set \sQuote{both}.

}

\value{a list with elements
  \item{left}{a data.frame of species diagnostic of set \sQuote{left}}
  \item{right}{a data.frame of species diagnostic of set \sQuote{right}}
  \item{both}{species occuring in both sets and diagnostic of neither}
}
\references{\url{http://ecology.msu.montana.edu/labdsv/R}}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\examples{
data(shoshveg)        # returns vegetation data set
data(shoshsite)       # returns site data
elev.clust <- as.numeric(factor(cut(shoshsite$elevation,5)))
                      # 5 elevation bands
elev.const <- const(shoshveg,elev.clust)
compare(elev.const,1,2)   # identify diagnostic species 
}
\keyword{multivariate}
