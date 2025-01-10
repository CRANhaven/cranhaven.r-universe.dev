\name{typal}
\alias{typal}
\title{Identification of Typal Samples in a Partition}
\description{Identifies samples that typify clusters in a partition based on dissimilarity.}
\usage{
typal(clustering,dist,k=1)
}
\arguments{
\item{clustering}{a vector of integers or an object of class \sQuote{clustering},
\sQuote{partition}, or \sQuote{partana}}
\item{dist}{and object of class \sQuote{dist} from \code{dist}, \code{\link[labdsv]{dsvdis}},
or \code{\link[vegan]{vegdist}}}
\item{k}{number of typal species/cluster to identify}
}

\details{
typal calculates two versions of typal species based on silhouette analysis 
(see \code{\link[cluster]{silhouette}}) and partana analysis 
(see \code{\link[optpart]{partana}}).  With respect to silhouette analysis, the 
function returns k species with the largest positive silhouette width for each 
cluster.  With respect to the partana analysis the function returns the k species
with the highest mean similarity to the cluster.
}

\value{
Returns a list with two data.frames.  The first, partana, gives the 
clusters as rows and typal samples as columns from the perspective of
the partana ratio.  The second, silhouette,
also gives the clusters as rows and typal samples as columns but from the perspective
of silhouette widths.
}

\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray')
opt.5 <- bestopt(dis.bc,5,20)
typal(opt.5,dis.bc,3)
}



\author{
David W. Roberts
\email{droberts@montana.edu}
}

\keyword{cluster}
