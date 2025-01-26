\name{vfpripo}
\alias{vfpripo}

\title{
Computation of the vector \code{u} to compute the second vector \code{v}
}
\description{
Auxiliary function. Each vector value \code{u} must be greater
  than the probability of the copula.
}
\usage{
vfpripo(ck, pro)
}

\arguments{
  \item{ck}{
Copula probability. Single value. Not a vector.
}
  \item{pro}{
Numeric vector. Its \code{pro[1:k]} are upper values of the \code{u}.
  Next \code{pro[-c(1:k)]} are then all greater than or equal to 1.
}
}
\value{
Numeric vector.
}

\author{
Josef Brejcha
}
\examples{
prk = c(0.99999, 0.9999, 0.999, 0.99, 8, 4, 2)
C = 0.1
u = vfpripo(ck = C, pro = prk)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
