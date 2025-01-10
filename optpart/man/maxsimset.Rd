\name{maxsimset}
\alias{maxsimset}
\alias{maxpact}
\alias{mss.test}
\alias{plot.mss}
\alias{getsets}
\alias{getsets.mss}
\title{Maximally Similar Sets Analysis}
\description{Maximally similar sets is an approach to deriving relatively homogeneous
subsets of objects as determined by similarity of the composition of the objects.  Maximally
similar sets are a covering, as opposed to a partition, of objects.  The sets
so derived can be tested against random sets of the same size to determine whether a
vector of independent data exhibits an improbably restricted distribution within the sets.
}
\usage{
maxsimset(dist,size=NULL,alphac=NULL,mean=FALSE)
mss.test(mss, env, panel = 'all', main = deparse(substitute(env)), 
         \dots)
\method{plot}{mss}(x, \dots)
\method{getsets}{mss}(mss)
}
\arguments{
    \item{dist}{a dist object from \code{dist}, \code{dsvdis}, or \code{vegdist}}
    \item{size}{the size of desired sets}
    \item{alphac}{the alpha-cut to specify maximum dissimilarity for inclusion in a set}
    \item{mean}{if mean is FALSE (the default), the algorithm uses a furthest neighbor
	criterion; if mean is TRUE, it uses a mean similarity criterion}
    \item{mss}{an object of class \sQuote{mss}}
    \item{env}{a quantitative environmental variable for analysis}
    \item{main}{a title for the plot of mss.test}
    \item{panel}{an integer switch to indicate which panel to draw}
    \item{x}{an object of class \sQuote{mss} from maxsimset}
    \item{\dots}{ancillary arguments for \sQuote{plot}}
}
\details{maxsimset starts with each sample as a seed, and adds the most similar
plot to the set.  Plots are added in turn to the set (up to the size specified,
or to the maximum dissimilarity specified)
in order of maximum similarity.  If mean is FALSE, the sample most similar to
set is the sample with the max-min similarity, that is, the sample whose minimum
similarity to the set if highest, equivalent to furthest-neighbor or
complete-linkage in cluster analysis.  If mean is TRUE, the sample most similar
to a set is the sample with highest mean similarity to the set.  Once the sets
are determined for each seed, the list is examined for duplicate sets, which are
deleted, to return the list of unique sets.

If \sQuote{alphac} is specified, sets are grown to maximum size, or to maximum
dissimilarity as specified by alphac, whichever is smaller.

The \sQuote{mss.test} function analyzes within-set variability in attributes
of the objects other than those used to calculate the similarity relation.  If maximally similar 
sets exhibit a narrower range of values than expected at random it may be that the
variable analyzed has an underlying role in determining the attributes on which the similarity
is calculated.  The function \sQuote{plot} plots the sorted within-set range of values in red,
and the sorted
range of values of random sets of the same size in black.  This followed by a boxplot of
within-set values for the random replicates versus the observed sets, and calculates a
Wilcoxon rank sum test of the difference.

\sQuote{getsets} expands and pulls out the maximally similar sets as a list of 
logical membership vectors for use in other analyses.
}



\value{an object of class \sQuote{mss}, a list with elements:
\item{musubx}{a matrix of sample membership in the sets where membership is given by the
similarity with which a sample joined the set}
\item{member}{a list of set members in the order they were added to the set}
\item{numset}{the number of unique sets derived}
\item{size}{the number of members in each set}
\item{distname}{the name of the dissimilarity/distance object employed}
}
\author{
	David W. Roberts
	\email{droberts@montana.edu}
}
\examples{
data(shoshveg)
data(shoshsite)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
mss.10 <- maxsimset(dis.bc,10)
\dontrun{mss.test(mss.10,shoshsite$elevation) }
      # plots graph and produces summary
}
\keyword{cluster}

