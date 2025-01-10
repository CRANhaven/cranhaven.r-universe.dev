\name{lambda}
\alias{lambda}
\title{Goodman- Kruskal Lambda Index of Classification Association}
\description{Compares two classifications by calculating the Goodman-Kruskal Index
of association}
\usage{lambda(x,y,digits=5)}
\arguments{
    \item{x}{an object of class \sQuote{clustering}, \sQuote{partana},
               \sQuote{partition} or a vector identifying membership
               of objects in classes with names attribute}
    \item{y}{an object of class \sQuote{clustering}, \sQuote{partana},
               \sQuote{partition} or a vector identifying membership
               of objects in classes with names attribute}
    \item{digits}{the number of digits of the statsitic to report}
}
\details{lambda calculates the Goodman-Kruskal index of association:

\eqn{\sum_i max_j (n_{ij}) + \sum_j max_i (n_{ij}) - max(n_{i,}) - max(n{_.j})
\over
2*\sum_i\sum_j n_{ij} - max(n_{i,}) - max(n{_.j)}}
}

\value{
 Prints a cross-tabulated table and the lambda statistic, and 
(invisibly) returns the lambda statistic}

\references{\url{http://ecology.msu.montana.edu/labdsv/R}}

\author{
    David W. Roberts
    \email{droberts@montana.edu}
}

\seealso{\code{\link[cluster]{partition}}, \code{\link[optpart]{optpart}},
          \code{\link[optpart]{slice}},\code{\link[optpart]{classmatch}}}

\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
opt.5 <- optpart(5,dis.bc)
pam.5 <- pam(dis.bc,5)
lambda(opt.5,pam.5)
}

\keyword{cluster}

