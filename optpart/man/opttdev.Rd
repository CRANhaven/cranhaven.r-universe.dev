\name{opttdev}
\alias{opttdev}
\title{Optimizing Classification by Minimizing Table Deviance}
\description{opttdev is a iterative re-assignment classification algorithm
that assigns samples to clusters to minimize the total deviance of a table
with respect to the row-wise relative abundance of the elements}
\usage{opttdev(comm,clustering,maxitr=100,minsiz=5)}
\arguments{
    \item{comm}{a vegetation or other taxon table with samples as rows and taxa as columns}
    \item{clustering}{an index of cluster membership for each sample. May be either
                      a numeric vector of length equal to the number of samples, or
                      an object that inherits from class \sQuote{cluster}}
   \item{maxitr}{the maximum number of iterations to attempt}
   \item{minsiz}{the minimum size cluster to consider reassigning a sample out of}
}
\details{Iterative re-allocation algorithms temporarily re-assign each sample to each 
of the other possible clusters and calculate a goodness-of-clustering statistic for each
re-assignment.  The best of all possible re-assignments is then executed and the algorithm 
iterates until there are no more good re-assignments or the maximum number of iterations
is reached.  In opttdev, the goodness-of-clustering statistic is total table deviance
as calculated by \code{\link{tabdev}}.  See the help file for 
\code{\link{tabdev}} for more detail.}

\value{a list which inherits from class \sQuote{opttdev}, \sQuote{clustering} with components:
\item{numitr}{the number of iterations performed} 
\item{dev}{a vector of total table deviance at each iteration of length \sQuote{numitr}}
\item{clustering}{the vector of cluster memberships (as integers) for each sample}
}
\note{Like many iterative re-assignment algorithms, opttdev is likely to be
VERY slow from a random start or poor initial condition.  opttdev is maybe better
used to polish existing classifications}
\references{\url{http://ecology.msu.montana.edu/labdsv/R}}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\seealso{\code{\link{optpart}}, \code{\link{optindval}}, \code{\link{optsil}}
}
\examples{
\dontrun{data(shoshveg)} # returns a data.frame of vegetation
\dontrun{data(shoshsite)}
\dontrun{res <- opttdev(shoshveg,
                  as.numeric(cut(shoshsite$elevation,5)))} 
\dontrun{# likely to be VERY slow}
}
\keyword{cluster}

