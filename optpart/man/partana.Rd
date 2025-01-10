\name{partana}
\alias{partana}
\alias{partana.default}
\alias{partana.partition}
\alias{partana.clustering}
\alias{partana.stride}
\alias{summary.partana}
\alias{plot.partana}
\title{Partition Analysis}
\description{Partition analysis evaluates the within-cluster to among-cluster
similarity of classifications as a measure of cluster validity}

\usage{partana(c,dist)
\method{summary}{partana}(object, \dots)
\method{plot}{partana}(x,panel='all',zlim=range(x$ptc),col=heat.colors(12),\dots)
}

\arguments{
    \item{c}{an integer or factor vector, or an object of class \sQuote{clustering},
            \sQuote{partana}, \sQuote{partition}, or \sQuote{stride}}
    \item{dist}{an object of class \sQuote{dist} from functions \code{\link{dist}},
           \code{\link{dsvdis}} or \code{\link[vegan]{vegdist}}}.  
    \item{object}{an object of class \sQuote{partana}}
    \item{x}{an object of class \sQuote{partana}}
    \item{panel}{an integer switch to indicate which panel to draw}
    \item{zlim}{the min and max values for the color map}
    \item{col}{a color map name (heat.colors(12) is the default)}
    \item{\dots}{ancillary arguments to pass to summary or plot}
}
\details{Calculates mean object-to-cluster similarity, mean cluster-to-cluster
similarity, and mean within-cluster to among-cluster similarity.  partana operates
on partitions or clusterings produced by a wide range of algorithms, including specific 
methods for the products of functions \code{\link{optpart}}, \code{\link{slice}}, 
\code{\link{pam}} and \code{\link{diana}}.

\code{summary} produces a matrix of the mean cluster-to-cluster similarities,
and the overall within-cluster/among-cluster similarity ratio.

\code{plot} plots two panels in sequence in the current device. The first shows
the mean similarity of every object to each cluster, sorted by mean similarity
to the other members of its own cluster, with objects as columns and clusters
as rows. The second panel shows the mean similarity of every cluster to every
other cluster and mean within-cluster similarity, ignoring cluster size. These
plots are known as \sQuote{Mondriaan} plots, where the similarities are given by lines
colored from min to max.  If the \sQuote{partana} object was produced by optpart, a
third panel is plotted showing the trace of the optimization.  
}


\value{an object of class \sQuote{partana} with components:
\item{ptc}{matrix of mean object-to-cluster similarity}
\item{ctc}{matrix of mean cluster-to-cluster similarity}
\item{clustering}{vector of numeric cluster assignments}
\item{ratio}{within-cluster to among-cluster similarity ratio}
}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\seealso{\code{\link{partition}}, \code{\link{optpart}},
         \code{\link{plot.partana}}}
\examples{
data(shoshveg)
data(shoshsite)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
demo.part <- partana(cut(shoshsite$elev,5),dis.bc)
summary(demo.part)
}
\keyword{cluster}
