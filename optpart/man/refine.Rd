\name{refine}
\alias{refine}
\alias{refine.default}
\alias{refine.dsvord}
\alias{refine.nmds}
\alias{refine.pco}
\title{Refining a Classification by Re-Assigning Memberships}
\description{Refine allows you to re-assign specific elements of a
classification from one class or cluster to another.  In the default case, you
simply interactively enter sample IDs and give a new cluster assignment.  For
PCO and NMDS ordinations, you do the assignments with a mouse.
}
\usage{
\method{refine}{default}(comm,clustering,\dots)
\method{refine}{dsvord}(x,clustering,ax=1,ay=2,\dots)
}
\arguments{
    \item{comm}{a community data.frame}
    \item{x}{an ordination of class \sQuote{dsvord}}
    \item{clustering}{a clustering identity or membership vector}
    \item{ax}{the X axis of the ordination}
    \item{ay}{the Y axis of the ordination}
    \item{\dots}{ancillary arguments to allow differing numbers of arguments}
}

\value{a list object of class \sQuote{clustering} with one component.
\item{clustering}{a numeric vector giving the cluster assignment for each
sample}
}
\references{\url{http://ecology.msu.montana.edu/labdsv/R}}
\note{There are many, many ways to produce classifications in R, including
several in package \sQuote{optpart}.  refine is designed to take one of these
classifications and polish it by making relatively few transfers.  The
ordination-based routines allow visual assessment of cluster validity, although
in reduced dimensionality, which can be misleading.
}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\examples{
\dontrun{data(shoshveg)}
\dontrun{dis.bc <- dsvdis(shoshveg,'bray')}
\dontrun{opt.5 <- optpart(5,dis.bc)}
\dontrun{nmds.bc <- nmds(dis.bc)}
\dontrun{plot(nmds.bc)}
\dontrun{res <- refine(nmds.bc,opt.5)}
}
\keyword{cluster}

