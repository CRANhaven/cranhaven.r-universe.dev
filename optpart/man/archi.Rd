\name{archi}
\alias{archi}
\title{Archipelago Analysis}
\description{Archipelago analysis finds connected clusters in a dissimilarity
matrix.  Samples in the same cluster are at most alpha dissimilar to at least
one other sample in the cluster, and are more than alpha dissimilar to all
samples in all other clusters.  The solution is equivalent to slicing a nearest
neighbor cluster analysis at alpha, but does not require (or produce) a
hierarchical structure.}

\usage{archi(dist,alpha)}
\arguments{
    \item{dist}{an object of class \sQuote{dist} from \code{\link{dist}},
       \code{\link[vegan]{vegdist}}, or \code{\link[labdsv]{dsvdis}}}
    \item{alpha}{the dissimilarity threshold to establish the relationship}
}
\details{Archipelago analysis is a topological, as opposed to metric space,
cluster routine that returns connected clusters.  Every sample in a  cluster is
connected by a path with step lengths of at most alpha dissimilarity to every
other sample in the cluster, and is more than alpha dissimilar to all other
samples in all other clusters.}

\value{produces an object of class \sQuote{clustering}, a list with a vector
\sQuote{clustering} of cluster memberships}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}

\examples{
data(shoshveg) # produces a vegetation dataframe
dis.bc <- dsvdis(shoshveg,'bray/curtis') 
               # produces a Bray/Curtis dissimilarity matrix
arc.50 <- archi(dis.bc,0.5) # clusters at 0.5 dissimilarity 
table(arc.50$clustering)
}
\keyword{cluster}
