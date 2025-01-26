\name{vfploto}
\alias{vfploto}

\title{
Plotting the cumulative distribution function or survival function
}
\description{
Plotting the cumulative distribution function or survival function.
}
\usage{
vfploto(cx, pro, fam, marg, xo, tht, cdf=TRUE, plt=TRUE, rtn=FALSE,
  ped = TRUE)
}

\arguments{
  \item{cx}{
A vector of copula probabilities.
}
  \item{pro}{
Numeric vector. Its \code{pro[1]} is upper value of the \code{u}.
  Next \code{pro[-1]} are then all greater than or equal to 1.
  The second case of \code{pro} is all \code{pro} less than 1.
  The first case is an extra calculation of the \code{u} values.
  In the latter case, \code{u} values can be pre-selected.
}
 \item{fam}{
character; A name of copula. One of c("clayton", "frank", "gumbel",
    "amh", "joe", "fgm"). "amh", "joe", "fgm" names are for
    Ali-Mikhail-Haq, Joe, Farlie-Gumbel-Morgenstern copulas.
}
 \item{marg}{
A vector size 2. Combination of these marginals: \cr
  c("weibull", "gamma", "lnorm", "norm", "betapr", "beta").
}
  \item{xo}{
A vector of marginal distribution parameters. It is size 4
  with these components: \cr
\tabular{rl}{
  \code{xo[1], xo[3]} \tab {scale, meanlog, mean, shape1} \cr
  \code{xo[2], xo[4]} \tab {shape, sdlog, sd, shape2} \cr
}
}
  \item{tht}{
copula parameter
}
 \item{cdf}{
logical; Computation for CDF when TRUE. If FALSE
  is the same for Survival.
}
  \item{plt}{
Plot only when TRUE.
}
  \item{rtn}{
Print output value only when TRUE.
}
  \item{ped}{
Compute and add to plot an expected values o f marginal
  distributions when \eqn{ped = TRUE}.
  }
}

\details{
Must not be \code{plt} and \code{rtn} at the same time equal to FALSE.
}
\value{
If \code{rtn} is TRUE, then a list of these components: \cr
\tabular{rl}{
  \code{Type} \tab {character; \code{"CDF"} or \code{"Survival"}} \cr
  \code{P} \tab {numeric; CDF or Survival value} \cr
  \code{x} \tab {numeric vector of the first marginal values for \code{P}} \cr
  \code{y} \tab {numeric vector of the second marginal values for \code{P}} \cr
  \code{u} \tab {numeric vector of the first copula marginal values} \cr
  \code{v} \tab {numeric vector of the second copula marginal values} \cr
}
}

\author{
Josef Brejcha
}

\examples{
require(copula)
tht = 0.475
cx = c(0.0025, 0.05, seq(0.1, 0.9, 0.1), 0.95, 0.975)
# nC = length(cx)
proh = c(0.9999999, 8, 4, 4, 4)
prod = c(0.999, 8, 4, 4, 4)
fam = "clayton"
marg = c("weibull", "lnorm")
xo = c(100, 1.5, 3, 0.425)
suro = vfploto(cx, proh, fam, marg, xo, tht, cdf=FALSE, plt=TRUE, rtn=FALSE)
cdfo = vfploto(cx, prod, fam, marg, xo, tht, cdf=TRUE, plt=TRUE, rtn=FALSE)
##
cx = 0.4
vfploto(cx, proh, fam, marg, xo, tht, cdf=TRUE, plt=FALSE, rtn=TRUE,
        ped = TRUE)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
