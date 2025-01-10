\name{extract}
\alias{extract}
\alias{extract.stride}
\title{Extract A Specific Cluster Solution From A Stride}
\description{Extracts a specified cluster solution from an object of class
\sQuote{stride}.  The desired solution is specified by the number of clusters.
}

\usage{
\method{extract}{stride}(stride,k)
}

\arguments{
\item{stride}{an object of class \sQuote{stride} from function
\code{\link[optpart]{stride}}}
\item{k}{the number of clusters desired}
}

\details{
A stride object consists of a list with a data.frame of cluster solutions for
varying numbers of clusters.  Extract simply selects one column of this
data.frame (specified by number of clusters desired, not column number) and
returns that solution as an object of class \sQuote{clustering}.
}

\value{an object of class \sQuote{clustering}.}

\author{
David W. Roberts
\email{droberts@montana.edu}
}

\examples{
data(shoshveg)		                # get vegetation data
dis.bc <- dsvdis(shoshveg,'bray')   # calculate dissimilarity 
                                    #   matrix
avg.hcl <- hclust(dis.bc,'average') # average linkage cluster 
                                    #   analysis
avg.2.10 <- stride(2:10,avg.hcl)    # compute stride
res <- extract(avg.2.10,8)          # extract 8-cluster solution
}

\keyword{cluster}
