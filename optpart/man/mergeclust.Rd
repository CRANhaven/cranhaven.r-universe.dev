\name{mergeclust}
\alias{mergeclust}
\title{Merge Specified Clusters in a Classification}
\description{Re-assigns members of one cluster to another specified cluster,
reducing the number of clusters by one.
}
\usage{mergeclust(clustering,from,to)
}
\arguments{
    \item{clustering}{a vector of (integer) cluster memberships, or an
object of class\sQuote{partition}, \sQuote{partana}, or \sQuote{clustering}}
    \item{from}{ the cluster number to be vacated}
    \item{to}{the cluster to which members will be re-assigned}
}
\details{The function simply renumbers members of one cluster with the number of another,
but greatly simplifies managing the list objects class\sQuote{partition}, \sQuote{partana}, 
or \sQuote{clustering} and simplifes the syntax.
}

\value{A list object of class \sQuote{clustering} specifying cluster membership for 
every object.
}
\references{\url{http://ecology.msu.montana.edu/labdsv/R}}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\seealso{\code{\link[cluster]{partition}}, \code{\link[optpart]{partana}}, and 
\code{\link[optpart]{clustering}}}
\examples{
data(shoshveg)                   # returns a vegetation data.frame
dis.bc <- dsvdis(shoshveg,'bray/curtis')   # returns a Bray/Curtis 
                                 # dissimilarity matrix
opt.5 <- optpart(5,dis.bc)       # five cluster partition
opt.5a <- mergeclust(opt.5,5,4)  # reassigns member from cluster 
                                 #   5 to 4
}
\keyword{clustering}
