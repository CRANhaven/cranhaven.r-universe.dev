\name{Vine}

\alias{Vine}
\alias{CVine}
\alias{DVine}

\title{Create Vine Objects}

\description{
Functions to create \code{\linkS4class{Vine}} objects.
}

\usage{
Vine(type, dimension = 2, trees = dimension - 1,
     copulas = matrix(list(indepCopula()), 
                      dimension - 1, dimension - 1))
CVine(dimension = 2, trees = dimension - 1,
      copulas = matrix(list(indepCopula()), 
                       dimension - 1, dimension - 1))
DVine(dimension = 2, trees = dimension - 1,
      copulas = matrix(list(indepCopula()), 
                       dimension - 1, dimension - 1))
}

\arguments{
  \item{type}{Type of vine. Supported values: \code{"CVine"} and \code{"DVine"}.}

  \item{dimension}{See the documentation of the \code{\linkS4class{Vine}} slot.}

  \item{trees}{See the documentation of the \code{\linkS4class{Vine}} slot.}

  \item{copulas}{See the documentation of the \code{\linkS4class{Vine}} slot.}
}

\seealso{
\code{\linkS4class{Vine}},
\code{\linkS4class{CVine}},
\code{\linkS4class{DVine}}.
}

\examples{
dimension <- 3
copulas <- matrix(list(normalCopula(0.5),
                       claytonCopula(2.75),
                       tCopula(0.75, df = 2),
                       NULL),
                  ncol = dimension - 1,
                  nrow = dimension - 1,
                  byrow = TRUE)

Vine("DVine", dimension = dimension, trees = dimension - 1,
     copulas = copulas)
DVine(dimension = dimension, trees = dimension - 1,
      copulas = copulas)
}
