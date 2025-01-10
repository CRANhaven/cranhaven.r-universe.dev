\name{optimclass}
\alias{optimclass}
\title{Optimum Classification by Counts of Indicator Species}
\description{Calculates the number of indicator species/cluster across a 
range of partitions}
\usage{
optimclass(comm, stride, pval = 0.01, counts = 2)
}
\arguments{
\item{comm}{a community matrix with sample units as rows and species as columns}
\item{stride}{an object of class \sQuote{stride}from function 
\code{\link[optpart]{stride}}}
\item{pval}{the minimum probability for inclusion in the list of indicators}
\item{counts}{the minimum number of clusters for inclusion in the list}
}

\details{Calculates the number of indicator species/cluster and the number of
clusters with at least \sQuote{counts} indicators, using the \eqn{\phi} index to
identify indicators with probabilities less than or equal to \sQuote{pval}.
Arguably the optimal partition is the one with the most indicator species and
the most clusters with adequate indicators.} 

\note{The concept and first
implementation were by Tichy in software package \sQuote{Juice}, and this is a
simple port of the algorithm to R.}


\value{A data.frame of 
\item{clusters}{number of clusters}
\item{sig.spc}{the number of species with significant indicator value}
\item{sig.clust}{the number of clusters with at least \sQuote{counts} indicator species}
}

\references{Tichy, L., M. Chytry, M. Hajek, S. Talbot, and Z. Botta-Dukat.  2010.
OptimClass: Using species-to-cluster fidelity to determine the
optimal partition in classification of ecological communities.  J. Veg. Sci.
21:287-299.}

\seealso{\code{\link[labdsv]{indval}}}

\author{
   Lubomir Tichy wrote the original algorithm

   David W. Roberts \email{droberts@montana.edu}
}

\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray')
opt.2.10 <- stride(2:20,dis.bc)
\dontrun{optimclass(shoshveg,opt.2.10)}
}

\keyword{multivariate}

