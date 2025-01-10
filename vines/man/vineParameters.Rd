\name{vineParameters}

\alias{vineParameters}
\alias{vineParameters<-}

\title{Parameters of a Vine}

\description{
Retrieve or set the parameters of a \code{\linkS4class{Vine}}.
}

\usage{
vineParameters(vine)
vineParameters(vine) <- value
}

\arguments{
  \item{vine}{A \code{\linkS4class{Vine}} object.}

  \item{value}{Vector with the parameters of the copulas in the pair-copula 
    construction. This vector is the result of the concatenation of the 
    \code{parameters} slots of the \code{\linkS4class{copula}} objects in the 
    \code{copulas} slot of the \code{\linkS4class{Vine}} object (by rows).}
}

\examples{
dimension <- 5
copulas <- matrix(c(list(tCopula(-0.25, df = 2),
                         tCopula(-0.5, df = 4),
                         tCopula(0.25, df = 6),
                         tCopula(0.5, df = 8)),
                    rep(list(NULL), 12)),
                  ncol = dimension - 1, 
                  nrow = dimension - 1,
                  byrow = TRUE)
vine <- DVine(dimension = dimension, trees = 1, 
              copulas = copulas)
dimnames(vine) <- c("A", "B", "C", "D", "E")

vineParameters(vine)
show(vine)

vineParameters(vine) <- c(-0.25, 3, -0.5, 5, 0.25, 7, 0.5, 9)

vineParameters(vine)
show(vine)
}
