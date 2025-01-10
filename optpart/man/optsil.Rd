\name{optsil}
\alias{optsil}
\alias{optsil.default}
\alias{optsil.clustering}
\alias{optsil.partana}
\alias{optsil.partition}
\alias{optsil.stride}
\title{Clustering by Optimizing Silhouette Widths}
\description{Silhouette width is a measurement of the mean similarity of each
object to the other objects in its cluster, compared to its mean similarity to
the most similar cluster (see \code{\link[cluster]{silhouette}}).  Optsil is an
iterative re-allocation algorithm to maximize the mean silhouette width of a
clustering for a given number of clusters.}

\usage{optsil(x,dist,maxitr)
}

\arguments{
        \item{x}{an integer, a vector of integers, an object of class \sQuote{clustering},
                 \sQuote{partana}, \sQuote{partition}, or \sQuote{stride}}
	\item{dist}{a object of class \sQuote{dist} from \code{\link{dist}}, 
               \code{\link[labdsv]{dsvdis}},
               or \code{\link[vegan]{vegdist}}}
	\item{maxitr}{the maximum number of iterations to perform}
}
\details{optsil produces a partition, or clustering, of items into clusters by
iterative reallocation of items to clusters so as to maximize the mean
silhouette width of the classification.  At each iteration optsil ranks all
possible re-allocations of a item from one cluster to another.  The
reallocation that maximizes the change in the mean silhouette width is performed.
Because silhouette widths are not independent of clusters that are not modified,
only a single reallocation can be preformed in a single iteration.  When no
further re-allocations result in an improvement, or the maximum number of
iterations is achieved, the algorithm stops.

Optsil is an unweighted algorithm, i.e. each of the objects is
included in the calculation exactly once.

Optsil can be extremely slow to converge, and is best used to \sQuote{polish} an
existing partition or clusterings resulting from slicing an \code{\link{hclust}} or 
from functions \code{\link[optpart]{optpart}}, \code{\link[cluster]{pam}},
\code{\link[cluster]{diana}} or other initial clusterings.  It is possible 
to run optsil from a random start, but is EXTREMELY SLOW to converge, and should be 
done only with caution.
}

\value{a list with elements:
\item{clustering}{a vector of integers giving the cluster assignment for each
object}
\item{sils}{a vector of the silhouette widths achieved at each iteration}
\item{numitr}{the number of iterations performed}
}
\author{
	David W. Roberts
	\email{droberts@montana.edu}
}
\seealso{
\code{\link[optpart]{optpart}}
}
\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
opt.5 <- optpart(5,dis.bc)
sil.5 <- optsil(opt.5,dis.bc,100) # make take a few minutes
summary(silhouette(sil.5,dis.bc))
\dontrun{plot(silhouette(sil.5,dis.bc))}
}
\keyword{cluster}

