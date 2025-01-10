\name{tabdev}
\alias{tabdev}
\alias{summary.tabdev}
\alias{tabdev.stride}
\alias{tabdev.default}
\title{Classification Validity Assessment by Table Deviance}
\description{Table deviance is a method to assess the quality of classifications
by calculating the clarity of the classification with respect to the original
data, as opposed to a dissimilarity or distance matrix representation}

\usage{
    \method{tabdev}{default}(x,clustering,nitr=999,\dots)
    \method{tabdev}{stride}(x,taxa,\dots)
    \method{summary}{tabdev}(object,p=0.05,\dots)
}
\arguments{
    \item{x}{a matrix or data.frame of multivariate observations, with objects as rows,
                and attributes as columns}
    \item{clustering}{a vector of integer cluster assignments, or an object of
                class \sQuote{clustering} or \sQuote{partana}}
    \item{nitr}{number of iterations to perform in calculating the probability of
                obtaining as effective a classification as observed}
    \item{taxa}{a data.frame with samples as rows and species as columns}
    \item{object}{and object of class \sQuote{tabdev}}
    \item{p}{the maximum probability threshold to list species in the summary table}
    \item{\dots}{ancillary arguments to maintain compatibility with generic summary function}
}

\details{Tabdev calculates the concentration of values within clusters.  For each
column, tabdev calculates the sum of values within classes and the sum within classes
divided by the sum of that column to get fractional sums by class.  These values are
used to calculate the deviance of each row.  Attributes that are widely dispersed
among classes exhibit high deviance; attributes that are concentrated within a single
class contribute zero deviance.  An effective classification should exhibit low
deviance.

Tabdev then permutes the values within columns and calculates the probability of
observing as low a deviance as observed as
$$ (m+1)/(niter + 1)$$
where $m$ is the number of cases with as low or lower deviance as observed.
}

\value{a list with components:
\item{spcdev}{a data.frame with species, deviance, and probability as columns}
\item{totdev}{the total deviance of the entire table}
}

\author{
	David W. Roberts
	\email{droberts@montana.edu}
	\url{http://ecology.msu.montana.edu/labdsv/R}
}
\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
opt.5 <- optpart(5,dis.bc)
tabdev(shoshveg,opt.5)
}
\keyword{cluster}
