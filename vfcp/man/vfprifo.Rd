\name{vfprifo}
\alias{vfprifo}

\title{
Computation of the vector \code{u} to compute the second vector \code{v}
}
\description{
Auxiliary function. Each vector value \code{u} must be greater
  than the probability of the copula.
}
\usage{
vfprifo(ck, pro)
}

\arguments{
  \item{ck}{
Copula probability. Single value. Not a vector.
}
  \item{pro}{
Numeric vector. All its components are less than 1. \code{u} can
  be pre-set in the desired values.
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
