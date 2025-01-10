\name{reordclust}
\alias{reordclust}
\title{Re-order Clusters in a Classification}
\description{In it's simplest form simply reassigns cluster numbers 
in an existing classification to re-order tables and graphs.  Can also
be used to combine clusters into a fewer number of clusters.
}
\usage{reordclust(clustering,from,to)
}
\arguments{
    \item{clustering}{a vector of (interger) cluster mmeberships, or an object
          of class \sQuote{clustering}, \sQuote{partana}, or \sQuote{partition}}
    \item{from}{an integer vector equal in length to the number of clusters
                that specifies the current clusters}
    \item{to}{an integer vector equal in length to the number of clusters
                that specifies the clusters the current clusters map to}
}
\details{The function simply maps cluster numbers in the \sQuote{from} 
vector to the respective cluster number in the \sQuote{to} vector.
}

\value{an object of class \sQuote{clustering}}
\references{\url{http://ecology.msu.montana.edu/labdsv/R}}
\note{As demonstrated in the examples below, reordclass can also combine existing
clusters into fewer clusters while reordering if more than one cluster in the 
\sQuote{from} vector maps to the same cluster in the \sQuote{to} cluster.}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\seealso{\code{mergeclust}

}
\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray')
opt.10 <- optpart(10,dis.bc)
new <- reordclust(opt.10,1:10,c(1,3,5,7,9,2,4,6,8,10))
           # simply re-ordered
new2 <- reordclust(opt.10,1:10,c(1,1,2,2,3,3,4,4,5,5))
           # merge 1 and 2 into 1, 3 and 4 into 2, etc.
}
\keyword{clustering}

