\name{clique.test}
\alias{clique.test}
\title{Clique Test}
\usage{clique.test(cliq,env,minsize=2,plotit=FALSE)}
\arguments{
    \item{cliq}{an object of class \sQuote{clique}}
    \item{env}{a continuous environmental variable to test}
    \item{minsize}{the minimum size clique to test for range}
    \item{plotit}{a switch to control plotting each clique individually}
}
\description{The \sQuote{clique.test} function analyzes within-clique
variability in attributes of objects other than those used to calculate the
similarity relation.  If the cliques exhibit a narrower range of values than
expected at random it may be that the variable analyzed has an underlying role
in determining the attributes on which the similarity is calculated.}

\note{The \sQuote{clique.test} function actually calls the
\code{\link[labdsv]{envrtest}} function once for each clique and stores the
associated probability as determined by \code{\link[labdsv]{envrtest}} }

\value{
Produces a vector of probabilities, one for each clique that expresses the
probability of obtaining a range of \sQuote{env} as small as observed.  Also
produces a plot of the sorted probabilities on the current device.}

\author{
    David W. Roberts \email{droberts@montana.edu}
}
\seealso{\code{\link[optpart]{clique}}, \code{\link[optpart]{mss.test}},
\code{\link[labdsv]{envrtest}}
}
\examples{
data(shoshveg)
data(shoshsite)
dis.bc <- dsvdis(shoshveg,'bray')
\dontrun{cli.60 <- clique(dis.bc,0.60)}             # will run for several
\dontrun{print(clique.test(cli.60,shoshsite$swb))}  # minutes
}
    
\keyword{hplot}
\keyword{multivariate}
