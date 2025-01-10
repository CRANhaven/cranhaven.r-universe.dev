\name{slice}
\alias{slice}
\title{Slice a Hierarchical Clustering Dendrogram with a Mouse}
\description{
Allows a simple classification of objects by slicing a dendrogram of a
hierarchical cluster analysis graphically with a mouse, or by simply
giving a number.}
\usage{slice(clust, k=NULL)}
\arguments{
    \item{clust}{an object of class \sQuote{hclust} produced by \code{hclust}}
    \item{k}{a desired number of clusters.  If null, the function waits
           on a mouse click}
}
\note{This function is a simple wrapper for \code{cutree} that allows users
to click their mouse at the height they desire to slice the dendrogram, and to establish
the result with a class of \sQuote{clustering} for ease of use in other functions.  If you
want to use the mouse, the dendrogram must have been previously plotted in the current
graphic device.}
\value{an object of class \sQuote{clustering}, a list with a vector of cluster memberships}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
    \url{http://ecology.msu.montana.edu/labdsv/R}
}
\seealso{\code{\link[labdsv]{ordpart}}
}
\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
demo <- hclust(dis.bc,'ave')
ave.5 <- slice(demo,5)
\dontrun{plot(demo)}
\dontrun{ave.clust <- slice(demo)}
}
\keyword{cluster}
