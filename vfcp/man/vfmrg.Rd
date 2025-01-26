\name{vfmrg}
\alias{vfmrg}

\title{
Auxiliary function
}
\description{
Auxiliary function used in \code{vfploto}. It computes random
  variable value of the CDF or survival which can be
  one of the c("weibull", "gamma", "lnorm", "norm", "betapr", "beta").
}
\usage{
vfmrg(rdj, i, cosi, yo, cdf)
}

\arguments{
  \item{rdj}{
A character vector. Its components are from
  c("weibull", "gamma", "lnorm", "norm", "betapr", "beta").
}
  \item{i}{
An index of the \code{rdj}
}
  \item{cosi}{
A vector of probabilities
}
  \item{yo}{
Vector size \code{2*length(rdj)} of parameters of \code{rdj} \cr
  \tabular{rl}{
  \code{yo[1], yo[3]} \tab {\code{scale}, \code{meanlog},
    \code{mean}, \code{shape1}} \cr
  \code{yo[2], yo[4]} \tab {\code{shape}, \code{sdlog},
    \code{sd}, \code{shape2}} \cr
  }
}
  \item{cdf}{
Cumulative distribution function when \code{TRUE}, survival otherwise.
}
}
\details{
\code{"betapr"} is the name of 'BetaPrime' distribution from
    \code{extrDistr} package. The other name 'BetaPrime' is 'Inverted Beta'.
}
\value{
Numeric vector
}


\author{
Josef Brejcha
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
