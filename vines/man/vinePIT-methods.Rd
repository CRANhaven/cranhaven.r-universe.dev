\name{vinePIT-methods}
\docType{methods}

\alias{vinePIT}
\alias{vinePIT-methods}
\alias{vinePIT,CVine-method}
\alias{vinePIT,DVine-method}

\title{Vine Probability Integral Transform Methods}

\description{
Probability integral transform (PIT) of (Rosenblatt, 1952) for vine models. 
The PIT converts a set of dependent variables into a new set of variables 
which are independent and uniformly distributed in \eqn{(0,1)} under the 
hypothesis that the data follows a given multivariate distribution.
}

\usage{
vinePIT(vine, u)
}

\arguments{
  \item{vine}{A \code{\linkS4class{Vine}} object.}

  \item{u}{Vector with one component for each variable of the vine or 
    a matrix with one column for each variable of the vine.}
}

\value{
A matrix with one column for each variable of the vine and one row for 
each observation.
}

\section{Methods}{
\describe{
  \item{\code{signature(vine = "CVine")}}{PIT algorithm for
    \code{\linkS4class{CVine}} objects based on the Algorithm 5 of
    (Aas et al., 2009).}

  \item{\code{signature(vine = "DVine")}}{PIT algorithm for
    \code{\linkS4class{DVine}} objects based on the Algorithm 6 of
    (Aas et al., 2009).}
}}

\references{
Aas, K. and Czado, C. and Frigessi, A. and Bakken, H. (2009)
Pair-copula constructions of multiple dependence.
\emph{Insurance: Mathematics and Economics} \bold{44}, 182--198.

Rosenblatt, M. (1952) Remarks on multivariate transformation.
\emph{Annals of Mathematical Statistics} \bold{23}, 1052--1057.
}

\examples{
dimension <- 3
copulas <- matrix(list(normalCopula(0.5), 
                       claytonCopula(2.75),
                       NULL, NULL),
                  ncol = dimension - 1,
                  nrow = dimension - 1,
                  byrow = TRUE)
vine <- CVine(dimension = dimension, trees = 1,
              copulas = copulas)

data <- matrix(runif(dimension * 100), 
               ncol = dimension, nrow = 100)

vinePIT(vine, data)
}

\seealso{
\code{\link{vinePIT}}.
}

\keyword{methods}
