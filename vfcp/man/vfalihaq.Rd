\name{vfalihaq}
\alias{vfalihaq}

\title{
Ali-Mikhail-Haq Copula Variable Given Second One and Copula Probability
}
\description{
\code{v} for Ali-Mikhail-Haq copula \code{C(u, v)} given probability
\code{C(u, v)} and \code{u}.
}
\usage{
vfalihaq(C, u, tht)
}
\arguments{
  \item{C}{
Probability value of the Ali-Mikhail-Haq copula. It can be a vector.
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
require(copula)
C = 0.3
tht = 0.5
u = c(0.35, 0.40, 0.45)
v <- vfalihaq(C, u, tht)
kali <- archmCopula(family = "amh", param = tht, dim = 2)
pCopula(cbind(u, v), kali)
#
Cf <- c(0.3, 0.4)
mx <- matrix(c(seq(0.35, 0.45, 0.05), seq(0.5, 0.6, 0.05)),
             nrow = 2, ncol = 3, byrow = TRUE)
rownames(mx) <- Cf
vfalihaq(C = Cf, u = mx , tht=0.5)
#          [,1]      [,2]      [,3]
# 0.3 0.8019802 0.6774194 0.5918367
# 0.4 0.7500000 0.6739130 0.6153846
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
