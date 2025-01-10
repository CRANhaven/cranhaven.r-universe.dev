\name{clique}
\alias{clique}
\alias{plot.clique}
\alias{summary.clique}
\title{Maximal Clique Analysis}
\description{Maximal clique analysis produces the set of maximal cliques of a
dissimilarity or distance matrix.  Maximal cliques are sets where every member
of the set is <= alpha-dissimilar to every other member.
}

\usage{
clique(dist,alphac,minsize=1,mult=100)
\method{summary}{clique}(object, \dots)
\method{plot}{clique}(x, panel = 'all', \dots)
}
\arguments{
    \item{dist}{an object of class \sQuote{dist} from \code{\link{dist}},
       \code{\link[vegan]{vegdist}}, or \code{\link[labdsv]{dsvdis}}}
    \item{alphac}{the dissimilarity threshold to establish the relationship}
    \item{minsize}{the minimum size clique to list in the results}
    \item{mult}{scratch space multiplier to control stack size (see below)}
    \item{object}{an object of class \sQuote{clique}}
    \item{\dots}{ancillary arguments to \code{summary} or \code{plot}}
    \item{x}{an object of class \sQuote{clique}}
    \item{panel}{an integer switch to indicate which panel to plot}
}
\details{Maximal clique analysis produces a covering, as opposed to a partition,
i.e. objects can belong to more than one clique, and every object belongs to at
least one clique.  The maximal clique solution is solved for by symbolic
computation, as opposed to numerical computation, and produces a unique
solution.  The number of cliques produced cannot be known beforehand,
and can significantly exceed the number of objects.  The \sQuote{mult} argument controls the
size of the stack to hold intermediate terms in the equation as the solution
proceeds.  At each iteration, the algorithm simplifies the equation to the
extent possible, and recovers space used to hold terms that have been
eliminated.  Nonetheless, it is possible for the equation to grow quite large at
intermediate steps.  The initial value of \sQuote{mult=100} sets the stack to
100 times the number of objects in the dissimilarity/distance matrix.  If the
memory allocated is exceeded, the output is set to NULL, and a message is printed
to increase the \sQuote{mult} argument to a higher value.
}
\note{WARNING.  The run time of maximal clique analysis is approximately \eqn{2^n+n}
for \eqn{n} objects.  The number of cliques generated, and the run time, is sensitive
to \sQuote{alpha}, as values of \sQuote{alpha} close to the mean dissimilarity
of the matrix are likely to produce the most cliques and longest run time.  A
solution for 1200 objects once took approximately 20 CPU days on a SparcStation.
The example shown below (100 objects) runs in a few seconds on a modern computer.}

\value{produces a list with elements:
   \item{alphac}{the threshold value used to establish the cliques}
   \item{musubx}{a matrix of object membership in each of the maximal cliques}
   \item{member}{a list of members of each clique}
}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
    \url{http://ecology.msu.montana.edu/labdsv/R}
}

\examples{
data(shoshveg) # produces a vegetation dataframe
dis.bc <- dsvdis(shoshveg,'bray/curtis') 
    # produces a Bray/Curtis dissimilarity matrix
cli.50 <- clique(dis.bc,0.5) # clusters at 0.5 dissimilarity, likely
    # to run for a few seconds in most PCs
summary(cli.50)
}
\keyword{cluster}
