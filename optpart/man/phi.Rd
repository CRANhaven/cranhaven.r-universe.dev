\name{phi}
\alias{phi}
\title{Calculating the phi Statistic on Taxon Classifications}
\description{Calculates the \eqn{phi} statistic on a classified 
table of taxa}
\usage{
phi(comm,clustering,minplt=10,p.adjust=FALSE)
}
\arguments{
\item{comm}{a data.frame with samples as rows and attributes as columns}
\item{clustering}{a vector of integers or an object of class \sQuote{clustering},
\sQuote{partition}, or \sQuote{partana}}
\item{minplt}{the minimum number of samples a species must occur in to be included 
in the calculation}
\item{p.adjust}{switch to control adjusting probabilities for simultaneous inference 
by Hochberg correction}
}

\details{\eqn{phi} is a statistic of agreement between two vectors.  In this case
the function calculates the distribution of each species within clusters of a partition, 
calculates the \eqn{phi} statistic for each species in each cluster. 

\deqn{\phi = \frac{ad - bc}{\sqrt{(a+b)\times(c+d)\times(a+c)\times(b+c)}}}

where:
\tabular{ll}{
a \tab sample is in specified type and species is present\cr
b \tab sample is not in group and species is present\cr
c \tab sample is in type but species is not present\cr
d \tab sample is not in type and species is not present\cr
}
}

\value{A data.frame of \eqn{\phi} values with species as rows and clusters as columns}

\references{Tichy, L. and M. Chytry.  2006.  Statistical determination of
diagnostic species for site groups of unequal size.  Journal of Vegetation Science
17:809-818.}

\author{
David W. Roberts
\email{droberts@montana.edu}
}

\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray')
opt.5 <- optpart(5,dis.bc)
phi(shoshveg,opt.5)
}

\keyword{htest}
