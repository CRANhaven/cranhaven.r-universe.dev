\name{neighbor}
\alias{neighbor}

\title{Neighbor Analysis of Partitions}

\description{Calculates the nearest neighbor (least dissimilar cluster) for each
item in partition to identify the topology of the partition.}

\usage{
neighbor(x,all=FALSE)
}

\arguments{
\item{x}{an object of class \sQuote{pam} or class \sQuote{partana}}
\item{all}{a logical switch to control which items are included in the
calculation}
}

\details{Each item in a partition has membership in a cluster.  The nearest
neighbor of an item is the cluster to which the item is least dissimilar, other
than the one to which it it belongs.  If \sQuote{all} is TRUE, then every item
is included in the analysis.  If \sQuote{all} is FALSE, only \sQuote{misfits}
are included in the calculation.  If the first argument is an object of class
\sQuote{pam}, then a misfit is an item with a negative silhouette width (see
\code{\link[cluster]{silhouette}}).  If the first argument is an object of class
\sQuote{partana}, a misfit is an item with lower mean dissimilarity to another
cluster than to the one to which it belongs.
}

\value{
A table with clusters as rows, and neighbors as columns.
}

\author{
David W. Roberts
\email{droberts@montana.edu}
}

\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray')
opt.5 <- optpart(5,dis.bc)
neighbor(opt.5,all=TRUE)
}

\keyword{cluster}



