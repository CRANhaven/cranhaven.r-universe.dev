\name{classmatch}
\alias{classmatch}
\title{Classification Matching and Differencing}
\description{Compares two classifications by cross-tabulating the assignment
of objects to classes, and (optionally) produces a new classification to
reflect the congruences and differences}
\usage{classmatch(x,y,type='full')}
\arguments{
    \item{x}{an object of class \sQuote{clustering}, \sQuote{partana},
               \sQuote{partition} or a vector identifying membership
               of objects in classes}
    \item{y}{an object of class \sQuote{clustering}, \sQuote{partana},
               \sQuote{partition} or a vector identifying membership
               of objects in classes}
    \item{type}{a switch, either \sQuote{full} or \sQuote{direct},
            to control the parameters of the algorithm}
}
\details{classmatch first calculates a cross-tabulation of the two classifications.
Then, if \sQuote{type=="full"}, the default, it finds all cases of agreement in order of number
of objects.  Objects are assigned to new clusters to reflect that order.
It's important to note that a single class may be partitioned into
several new classes, and the the number of new classes produced may be higher than
either of the classifications considered.

If \sQuote{type=="direct"} classmatch assumes a one-to-one relation between the
two classifications compared.  Classmatch finds the largest case of agreement,
and assigns that match to class 1.  It then zeros out the rows and columns
corresponding to those classes, and iterates.
}

\value{
 A list with components:
\item{tab}{the cross-tabulation analyzed}
\item{pairs}{the x and y values considered matched in order of solution}
\item{partial}{a cumulative fraction of agreement as a function of number of clusters}
\item{ord}{a table showing the order of new clusters}
\item{combo}{a new vector of assignment of objects to clusters, only produced if
\sQuote{type=="full"}}
}

\references{\url{http://ecology.msu.montana.edu/labdsv/R}}

\author{
    David W. Roberts
    \email{droberts@montana.edu}
}

\seealso{\code{\link[cluster]{partition}}, \code{\link[optpart]{optpart}},
          \code{\link[optpart]{slice}}}

\examples{
data(shoshveg)
dis.bc <- dsvdis(shoshveg,'bray/curtis')
opt.5 <- optpart(5,dis.bc)
pam.5 <- pam(dis.bc,5)
classmatch(opt.5,pam.5)
}

\keyword{cluster}

