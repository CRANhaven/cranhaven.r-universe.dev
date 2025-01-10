\name{gensilwidth}
\alias{gensilwidth}
\title{Generalized Silhouette Width}
\usage{gensilwidth(clust, dist, p=1)}
\arguments{
\item{clust}{an integer vector of cluster memberships or a classification 
object of class \sQuote{clustering}}
\item{dist}{an object of class \sQuote{dist}}
\item{p}{the scaling parameter of the analysis}
}
\description{Calculates mean cluster silhouette widths using a generalized
mean.}
\details{gensilwidth calculates mean cluster silhouette widths using a generalized
mean.  The scaling parameter can be set between \eqn{[-\infty,\infty]} where values 
less than one emphasize connectivity, and values greater than one emphasize 
compactedness.   Individual sample unit silhouette widths are still calculated as 
\eqn{s _i = (b_i - a_i) / \max(b_i,a_i)} where \eqn{a_i} is the mean dissimilarity of a
sample unit to the cluster to which it is assigned, and \eqn{b_i} is the mean 
dissimilarity to the nearest neighbor cluster.  Given \eqn{s_i} for all members of a cluster,
the generalized mean is calculated as 

\deqn{\bar s = \left( {1\over n} \sum_{k=1}^n s_k^p \right)^{1/p}}

Exceptions exist for specific values:

for p=0 \deqn{s_i = \left( \prod_{k=1}^n s_k \right)^{1/n}}

for p=\eqn{-\infty} \deqn{s_i = \min_{k=1}^n s_k}

for p=\eqn{\infty} \deqn{s_i = \max_{k=1}^n s_k}

\eqn{p=-1} = harmonic mean, \eqn{p=0} = geometric mean, and \eqn{p=1} = arithmetic mean.
}
\value{an object of class \sQuote{silhouette}, a list with components
\item{cluster}{the assigned cluster for each sample unit}
\item{neighbor}{the identity of the nearest neighbor cluster for each sample unit}
\item{sil_width}{the silhouette width for each sample unit}
}

\author{
    Attila Lengyel and Zoltan Botta-Dukat wrote the algorithm
    
    David W. Roberts
    \email{droberts@montana.edu}
    \url{http://ecology.msu.montana.edu/labdsv/R}
}

\references{Lengyel, A. and Z. Botta-Dukat.  2019.  
Silhouette width using generalized mean: A flexible method for assessing clustering efficiency.
Ecology and Evolution https://doi.org/10.1002/ece3.5774}

\seealso{\code{\link[cluster]{silhouette}}}


\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray')
opt.5 <- optpart(5,dis.bc)
gensilwidth(opt.5,dis.bc)
}


