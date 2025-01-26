\name{vffgm}
\alias{vffgm}

\title{
Farlie-Gumbel-Morgenstern Copula Variable Given Second One and
Copula Probability
}
\description{
\code{v} for Farlie-Gumbel-Morgenstern copula \code{C(u, v)}
given probability \code{C(u, v)} and \code{u}.
}
\usage{
vffgm(C, u, tht)
}
\arguments{
  \item{C}{
Probability value of the Farlie-Gumbel-Morgenstern copula.
It can be a vector.
}
  \item{u}{
The first variable value of the \code{C(u, v)}.
  \code{u} can be a vector if \code{C} is a single.
  \code{u} is a matrix with \code{nrow = length(C)} if \code{C}
    is a vector.
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
\references{
A.K. SUZUKI, F. LOUZADA and V.G. CANCHO, On estimation and
  influence diagnostics for a Bivariate Promotion Lifetime Model
  Based on the FGM Copula: A Fully Bayesian Computation,
  \emph{Tendˆencias em Matem´ atica Aplicada e Computacional, 14,
  N. 3 (2013), 441-461}, \url{http://www.scielo.br/pdf/tema/v14n3/a14v14n3.pdf}
}
\examples{
require(copula)
C = 0.3
tht = 0.5
u = c(0.35, 0.40, 0.45)
v <- vffgm(C, u, tht)
kfgm <- fgmCopula(tht)
pCopula(c(u, v), kfgm)
#
Cf <- c(0.3, 0.4)
mx <- matrix(c(seq(0.35, 0.45, 0.05), seq(0.5, 0.6, 0.05)),
             nrow = 2, ncol = 3, byrow = TRUE)
rownames(mx) <- Cf
vffgm(C = Cf, u = mx , tht=0.5)
#          [,1]      [,2]      [,3]
# 0.3 0.8064052 0.6853009 0.6007056
# 0.4 0.7535751 0.6781648 0.6195239
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
