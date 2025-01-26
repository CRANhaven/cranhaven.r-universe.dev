\name{vfenuo}
\alias{vfenuo}

\title{
Expected values of marginal distributions
}
\description{
Auxiliary function that calculates the expected values of marginal
  distributions.
}
\usage{
vfenuo(marg, xo)
}

\arguments{
  \item{marg}{
Character vector size greater than or equal to 2. Its components
  can now be c("weibull", "gamma", "lnorm", "norm", "betapr", "beta").
}
  \item{xo}{
Vector size \code{2*length(marg)} of parameters of \code{marg}. \cr
  \tabular{rl}{
  \code{xo[odd]} \tab {\code{scale}, \code{meanlog},
    \code{mean}, \code{shape1}} \cr
  \code{xo[even]} \tab {\code{shape}, \code{sdlog},
    \code{sd}, \code{shape2}} \cr
  }
}
}

\value{
Numeric vector size equal to \code{length(marg)}.
}

\author{
Josef Brejcha
}

\examples{
vfenuo(marg = c("betapr", "beta", "norm", "weibull"),
  xo = c(5, 5, 3, 20, 30, 5, 100, 1.5))
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
