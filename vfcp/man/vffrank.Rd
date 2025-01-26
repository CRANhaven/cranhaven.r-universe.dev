\name{vffrank}
\alias{vffrank}
\title{
Frank Copula Variable Given Second One and Copula Probability
}
\description{
\code{v} for Frank copula \code{C(u, v)} given probability
\code{C(u, v)} and \code{u}.
}
\usage{
vffrank(C, u, tht)
}
\arguments{
  \item{C}{
Probability value of the Frank copula. It can be a vector.
}
  \item{u}{
The first variable value of the \code{C(u, v)}.
  \code{u} can be a vector if \code{C} is a single.
  \code{u} is a matrix with \code{nrow = length(C)} if \code{C} is a vector.
}
  \item{tht}{
Copula parameter
}
}
\details{
The value of the \code{u} must be grater than \code{C}.
}
\value{
The value of the second variable depending on the first variable
and copula probability value.
}
\author{
Josef Brejcha
}
\examples{
C <- 0.3
tht <- 6
u <- c(0.35, 0.4, 0.45)
v <- vffrank(C, u, tht)
kop = frankCopula(tht)
pCopula(cbind(u, v), kop)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
