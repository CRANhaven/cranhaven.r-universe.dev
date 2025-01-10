\name{vineLogLik}

\alias{vineLogLik}

\title{Vine Log-likelihood Evaluation}

\description{
Evaluate the log-likelihood of a \code{\linkS4class{Vine}}.
}

\usage{
vineLogLik(vine, data)
}

\arguments{
  \item{vine}{A \code{\linkS4class{Vine}} object.}

  \item{data}{Data matrix of pseudo-observations.}
}

\examples{
dimension <- 3
copulas <- matrix(list(normalCopula(0.5), 
                       claytonCopula(2.75),
                       NULL, NULL),
                  ncol = dimension - 1,
                  nrow = dimension - 1,
                  byrow = TRUE)
vine <- DVine(dimension = dimension, trees = 1, 
              copulas = copulas)

data <- matrix(runif(dimension * 100), 
               ncol = dimension, nrow = 100)
               
vineLogLik(vine, data)
}
