\name{vfgumbel}
\alias{vfgumbel}
\title{
Gumbel Copula Variable Given Second One and Copula Probability
}
\description{
\code{v} for Gumbel copula \code{C(u, v)} given probability
\code{C(u, v)} and \code{u}.
}
\usage{
vfgumbel(C, u, tht)
}
\arguments{
  \item{C}{
Probability value of the Gumbel copula. It can be a vector.
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
v <- vfgumbel(C, u, tht)
kop = gumbelCopula(tht)
pCopula(cbind(u, v), kop)
#
vfgumbel(c(0.3, 0.4), u = rbind(seq(0.35, 0.45, 0.05),
  seq(0.45, 0.55, 0.05)), 8)
#           [,1]      [,2]      [,3]
# [1,] 0.3184504 0.3053987 0.3017235
# [2,] 0.4184819 0.4051936 0.4015295
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
