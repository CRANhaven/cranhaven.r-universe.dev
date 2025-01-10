\name{bestopt}
\alias{bestopt}
\title{Best Of Set Optimal Partitions From Random Starts}
\description{Produces a specified number of \code{\link[optpart]{optpart}}
solutions from random starts, keeping the best result of the set}
\usage{bestopt(dist,numclu,numrep,maxitr=100)
}
\arguments{
    \item{dist}{an object of class \sQuote{dist} from \code{\link{dist}},
       \code{\link[vegan]{vegdist}}, or \code{\link[labdsv]{dsvdis}},
        or a symmetric dissimilarity matrix}
    \item{numclu}{the number of clusters desired}
    \item{numrep}{the number of random starts requested}
    \item{maxitr}{the maximum number of iterations per replicate}
}
\details{calls function \code{optpart} with an random initial
assignment of items to clusters \sQuote{numitr} times, keeping the best result
(highest within/among ratio observed).  See \code{\link[optpart]{optpart}} for more details.
}
\value{an object of class partana, with components:
\item{ptc}{the mean similarity of each item to each cluster}
\item{ctc}{the mean similarity of each cluster to other clusters}
\item{musubx}{the membership of each item in each cluster}
\item{clustering}{the best \sQuote{crisp} partition from musubx}
\item{ratio}{the within-cluster/among-cluster similarity ratio achieved at each iteration
of the selected result.}
}

\note{This is a simple wrapper function to automate independent random 
starts of function \link[optpart]{optpart}.}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\seealso{
\code{\link[optpart]{optpart}},
\code{\link[optpart]{partana}},
\code{\link[cluster]{pam}}
}
\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
x <- bestopt(dis.bc,5,10)
summary(x)
\dontrun{plot(x)} 
}
\keyword{cluster}
