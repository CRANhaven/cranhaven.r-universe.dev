\name{bestfit}
\alias{bestfit}
\title{Identify the Goodness-of-Fit of Cluster Members}
\description{Sorts the members of clusters by maximum similarity
goodness-of-fit}
\usage{
bestfit(x,cluster)
}
\arguments{
    \item{x}{an object of class \sQuote{partana} or \sQuote{silhouette}}
    \item{cluster}{a specific cluster number}
}
\details{Simply finds all members of a specific cluster and lists them in order
of (1) mean similarity to their cluster (if x is an object of class \sQuote{partana}) or
silhouette width (if x is an object of class \sQuote{silhouette} as produced by
functions in package \sQuote{cluster})
}

\value{returns a data.frame with cluster members in column \sQuote{ID} and goodness-of-fit 
in column \sQuote{fit}
}
\references{\url{http://ecology.msu.montana.edu/labdsv/}}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\seealso{\code{\link[optpart]{typal}}}

\examples{
data(shoshveg)                      # returns vegetation matrix
dis.bc <- dsvdis(shoshveg,'bray')   # Bray/Curtis dissimilarity matrix 
opt.5 <- optpart(5,dis.bc)          # 5 cluster partition
print(class(opt.5))
fit <- bestfit(opt.5,1)             # goodness-of-fit for cluster 1
sil.5 <- silhouette(opt.5,dis.bc)   # calculate silhouette widths
fit2 <- bestfit(sil.5,1)            # goodness-of-fit for cluster 1
}
\keyword{clustering}

