\name{vfjoe}
\alias{vfjoe}

\title{
Joe Copula Variable Given Second One and Copula Probability
}
\description{
\code{v} for Joe copula \code{C(u, v)} given probability
\code{C(u, v)} and \code{u}.
}
\usage{
vfjoe(C, u, tht)
}
\arguments{
  \item{C}{
Probability value of the Joe copula. It can be a vector.
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
v <- vfjoe(C, u, tht)
kop = joeCopula(tht)
pCopula(cbind(u, v), kop)
#
Cf <- c(0.3, 0.4)
mx <- matrix(c(seq(0.35, 0.45, 0.05), seq(0.5, 0.6, 0.05)),
             nrow = 2, ncol = 3, byrow = TRUE)
rownames(mx) <- Cf
vfjoe(C = Cf, u = mx , tht=6)
#           [,1]      [,2]      [,3]
# [1,] 0.4021216 0.3513741 0.3274672
# [2,] 0.4379531 0.4184746 0.4087143
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
