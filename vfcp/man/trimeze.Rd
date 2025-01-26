\name{trimeze}
\alias{trimeze}
\title{
Coordinates of an object defined by CDF and survival functions
}
\description{
Calculates the coordinates of the object defined matrices \code{C1}
  and \code{C23}. Both matrices are two-row.
}
\usage{
trimeze(C1, C23)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{C1}{
numerical probability two-row matrix defining survival line
}
  \item{C23}{
numerical probability two-row matrix defining CDF line
}
}
\value{
A list with components as follows: \cr
\tabular{rl}{
  \code{tlc} \tab upper left corner coordinates \cr
  \code{brc} \tab bottom right corner coordinates \cr
  \code{sp} \tab survival line coordinates \cr
  \code{cp} \tab CDF line coordinates \cr
}
}
\author{
Josef Brejcha
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
