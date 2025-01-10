\name{disdiam}
\alias{disdiam}
\alias{disdiam.default}
\alias{disdiam.stride}
\alias{print.disdiam}

\title{Dissimilarity Diameters of a Partition}

\description{Calculates the diameter (maximum within-cluster dissimilarity) of
all clusters in a partition, as well as the average diameter across all
clusters.}

\usage{
disdiam(x,dist,digits)
\method{disdiam}{stride}(x,dist,digits=3)
\method{print}{disdiam}(x, \dots)
}

\arguments{
\item{x}{a vector of integers or an object of class \sQuote{clustering},
\sQuote{partition}, \sQuote{partana}, or \sQuote{stride}}
\item{dist}{an object of class \sQuote{dist} from \code{\link{dist}},
\code{\link[labdsv]{dsvdis}}, or \code{\link[vegan]{vegdist}}}
\item{digits}{the number of significant digits reported in the output}
\item{\dots}{ancillary arguments to the print function}
}

\details{
disdiam is a cluster validation routine, and calculates the diameter 
(maximum within-cluster dissimilarity) of each cluster, as well as the average
diameter of across all clusters of size greater than one.
}

\value{
A list with components:
\item{diameters}{a data.frame with clusters as rows, and
cluster ID, cluster size, and diameter as cols}
\item{mean}{the weighted mean diameter of clusters of size greater than one.  The mean is
weighted for cluster size.}
}

\author{
David W. Roberts 
\email{droberts@montana.edu}
}

\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray')
opt.5 <- optpart(5,dis.bc)
disdiam(opt.5,dis.bc)
}

\keyword{cluster}




