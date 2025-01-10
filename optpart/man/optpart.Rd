\name{optpart}
\alias{optpart}
\alias{optpart.default}
\alias{optpart.clustering}
\alias{optpart.partana}
\alias{optpart.partition}
\alias{optpart.stride}
\title{Optimal Partitioning of Dissimilarity/Distance Matrices}
\description{Optimal partitioning is an
iterative re-allocation algorithm to maximize the ratio of within-cluster 
similarity/among-cluster similarity for a given number of clusters.  Optpart can operate as either
a crisp (classical) partitioning, or a fuzzy partitioning algorithm.}
\usage{
optpart(x, dist, maxitr = 100, mininc = 0.001, maxdmu = 1)
}
\arguments{
	\item{x}{an integer, integer vector, factor vector, or objects of class \sQuote{clustering},
                \sQuote{partana}, \sQuote{partition} or \sQuote{stride}} 
	\item{dist}{a object of class \sQuote{dist} from \code{\link{dist}}, 
               \code{\link{dsvdis}}, or \code{\link[vegan]{vegdist}}}
	\item{maxitr}{the maximum number of iterations to perform}
        \item{mininc}{the minimum increment in the within/among similarity ratio to
                  continue iterating}
	\item{maxdmu}{the \sQuote{maximum delta mu}.  If 1, a crisp (non-fuzzy) partition
            results.  If (0,1) a fuzzy partition results.}
}
\details{optpart produces a partition, or clustering, of items into clusters by
iterative reallocation of items to clusters so as to maximize the within cluster/
among cluster similarity ratio.  At each iteration optpart ranks all possible
re-allocations of a sample from one cluster to another.  The re-allocation that maximizes
the change in the within-cluster/among-cluster ratio is performed.  The next best
reallocation is considered, and if it does not include any clusters already modified, it is
also performed, as re-allocations of independent clusters are independent and additive in
effect.  When no further re-allocations can be performed in that iteration, the algorithm
recalculates all possible re-allocations and iterates again.  When no re-allocations exist that
improve the within/among ratio greater than \sQuote{mininc}, 
or the maximum number of iterations is reached, the algorithm stops.

optpart is designed to run from a random start or the levels of a factor, or
preferably from existing initial partitions.  Specifying a single integer gives the number of clusters
desired using a random start.  Specifying an integer vector gives the initial assignments of
items to clusters.   Initial assignments can also be extracted from a number of objects.
Specific
methods exist for objects of class \sQuote{clustering} from functions
\code{\link{slice}} or \code{\link{archi}}, class \sQuote{partana} from function
\code{\link{partana}}, class \sQuote{stride} from \code{\link{stride}}, or 
class \sQuote{partition} from functions
\code{\link{pam}} or \code{\link{diana}}.  optpart is deterministic from a
given initial condition.  To get good results from a random start, multiple
random starts should be attempted, using function \code{\link{bestopt}}.

Optpart is an unweighted algorithm, i.e. each of the \eqn{(n^2-n)/2} pairwise distances or
dissimilarities is included in the calculation of the ratio exactly once.  Optpart
somewhat penalizes small clusters, as small clusters contribute only \eqn{(n_i^2-n_i)/2} values
to the numerator; the extreme case is that a cluster with a single member does not
contribute anything to the numerator.

It is an interesting characteristic of optpart that no minimum cluster size is enforced,
and it is common for partitions of a large number of clusters to contain null clusters, i.e.
clusters with no members.  This is not a bug or error, but rather an indication that a
partition with a fewer number of clusters achieves a better within/among similarity ratio
than does a larger number.  It is also somewhat common that for solutions with a small or
intermediate number of clusters, optpart places outliers in a small \sQuote{trash} cluster.

When optpart is run as a fuzzy partitioning algorithm, it often achieves a surprisingly low
entropy, with many items assigned completely to a single cluster.
}

\value{an object of class \code{partana}, a list with elements:
\item{ptc}{a matrix of item mean similarity to each cluster}
\item{ctc}{a matrix of mean cluster-to-cluster similarity}
\item{musubx}{a matrix of membership of each item to each cluster.  If \code{maxdmu}
is 1, this will be a single 1 in the appropriate cluster and 0 in all others.  If
\code{maxdmu} is (0,1) then the musubx represent fuzzy memberships in each cluster.}
\item{clustering}{a vector giving the cluster each item is assigned to.  If optpart
is run as a fuzzy partitioning, this is determined by the maximum membership observed.}
\item{ratio}{the vector of within/among similarities achieved at each iteration.  The final
non-zero value is the final ratio achieved.}
\item{numitr}{the number of iterations performed}
\item{names}{the names of the items clustered}
}
\author{
	David W. Roberts
	\email{droberts@montana.edu}
	\url{http://ecology.msu.montana.edu/labdsv/R}
}
\seealso{
\code{partana}
}
\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
opt.5 <- optpart(5,dis.bc)
summary(opt.5)
}
\keyword{cluster}

