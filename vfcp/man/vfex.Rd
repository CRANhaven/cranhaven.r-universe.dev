\name{vfex}
\alias{vfex}

\title{
Compute vector V for C(u, V)
}
\description{
A vector \code{v} is computed for \code{C} and numeric probability
  vector \code{u}.
}
\usage{
vfex(C, u, th, fm)
}

\arguments{
  \item{C}{
Copula probability. It is a single value.
}
  \item{u}{
Probability vector. All its components are greater than \code{C}.
}
  \item{th}{
Copula parameter.
}
  \item{fm}{
character; A name of copula. One of c("clayton", "frank", "gumbel",
    "amh", "joe", "fgm"). "amh", "joe", "fgm" names are for
    Ali-Mikhail-Haq, Joe, Farlie-Gumbel-Morgenstern copulas.
}
}

\value{
Numeric vector.
}

\author{
Josef Brejcha
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
