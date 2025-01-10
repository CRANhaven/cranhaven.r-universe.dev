\name{optindval}
\alias{optindval}
\title{Optimizing Classification by Maximizing Dufrene and Legendre's Indicator Value}
\description{optindval is a iterative re-assignment classification algorithm
that assigns samples to clusters to maximize the sum of indicator values.}
\usage{optindval(comm,clustering,maxitr=100,minsiz=5)}
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
is reached.  In optindval, the goodness-of-clustering statistic is the sum of Dufrene and Legendre
indicator values}

\value{a list of class "optindval","clustering" with components:
\item{numitr}{the number of iterations performed} 
\item{sums}{a vector of indicator value probability sums}
\item{clustering}{the vector of cluster memberships (as integers) for each sample}
}
\note{Like many iterative re-assignment algorithms, optindval is likely to be
VERY slow from a random start or poor initial condition.  optindval is maybe better
used to polish existing classifications}
\references{\url{http://ecology.msu.montana.edu/labdsv/R}}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
}
\seealso{\code{optpart}, \code{opttdev}, \code{optsil}}
\examples{
data(shoshveg) # returns a data.frame of vegetation data called shoshveg
dis.bc <- dsvdis(shoshveg,'bray') # generate Bray/Curtis dissimilarity 
                                  # matrix
opt.5 <- optpart(5,dis.bc) # generate 5-cluster optpart
\dontrun{res <- optindval(shoshveg,opt.5)} # polish the optpart result
\dontrun{classmatch(opt.5,res)} # see the plot re-assignments
}
\keyword{cluster}
