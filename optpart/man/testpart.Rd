\name{testpart}
\alias{testpart}
\title{Identify Misclassified Plots in a Partition}
\description{testopt analyzes 
the mean similarity of each sample to the cluster to which it is assigned to all 
other clusters, and lists those samples which have similarity higher to another
cluster than to the one to which they are assigned.}
\usage{testpart(part,ord=TRUE)}
\arguments{
	\item{part}{a object of class \sQuote{partana} from \code{partana} or  \code{optpart}} 
        \item{ord}{a switch to control whether the output is ordered}
}
\details{Simply examines each sample plot, comparing the mean similarity of that 
sample to all other samples in the cluster to which it is assigned as compared to its
mean similarity to all other clusters.  Samples which are more similar to other
clusters than to the one to which they are assigned are listed in a table which gives
their current cluster assignment, the cluster to which they are more similar, and 
the mean similarities of that sample to all clusters.

If \sQuote{ord=TRUE} then the output is ordered to reflect target clusters.

}

\value{a table of values}
\author{
	David W. Roberts
	\email{droberts@montana.edu}
}
\seealso{
\code{\link{partana}}, \code{\link{partana}}, \code{\link{silhouette}}
}
\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
opt.5 <- optpart(5,dis.bc)
testpart(opt.5)
}
\keyword{cluster}

