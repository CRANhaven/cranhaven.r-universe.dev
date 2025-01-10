\name{Vine-distribution}

\alias{dvine}
\alias{dvine-methods}
\alias{dvine,CVine-method}
\alias{dvine,DVine-method}
\alias{pvine}
\alias{pvine-methods}
\alias{pvine,CVine-method}
\alias{pvine,DVine-method}
\alias{rvine}
\alias{rvine-methods}
\alias{rvine,CVine-method}
\alias{rvine,DVine-method}

\title{Vine Distribution Functions}

\description{
Density evaluation, distribution function evaluation, and random number generation.
}

\usage{
dvine(vine, u)
pvine(vine, u)
rvine(vine, n)
}

\arguments{
  \item{vine}{A \code{\linkS4class{Vine}} object.}

  \item{u}{Vector of the same dimension of the vine or a matrix with one column
    for each variable of the vine.}

  \item{n}{Number of observations.}
}

\details{
The implementation of the \code{dvine} function for \code{\linkS4class{CVine}}
and \code{\linkS4class{DVine}} objects is based on the Algorithms 3 and 4 
of (Aas et al. 2009), respectively.

The \code{pvine} function is evaluated through the numerical integration of 
the density function (using the \code{\link{cubature}} package). This is a 
computationally demanding procedure, even for small dimensions.
  
The implementation of the \code{rvine} function for \code{\linkS4class{CVine}} 
and \code{\linkS4class{DVine}} objects is based on the Algorithms 1 and 2 
of (Aas et al. 2009), respectively.
}

\value{
\code{dnorm} returns a vector with the evaluation of the density.
\code{pnorm} returns a vector with the evaluation of the distribution 
function. \code{rvine} returns a matrix with one column for each variable
of the vine and one row for each observation.
}

\references{
Aas, K. and Czado, C. and Frigessi, A. and Bakken, H. (2009)
Pair-copula constructions of multiple dependence.
\emph{Insurance: Mathematics and Economics} \bold{44}, 182--198.

Bedford, T. and Cooke, R. M. (2001) Monte Carlo simulation of vine
dependent random variables for applications in uncertainty analysis. 
In \emph{2001 Proceedings of ESREL2001, Turin, Italy}.

Bedford, T. and Cooke, R. M. (2001) Probability density decomposition 
for conditionally dependent random variables modeled by vines. 
\emph{Annals of Mathematics and Artificial Intelligence} \bold{32},
245--268.

Kurowicka, D. and Cooke, R. M. (2005) Sampling algorithms for generating 
joint uniform distributions using the vine-copula method. In \emph{3rd 
IASC World Conference on Computational Statistics & Data Analysis, 
Limassol, Cyprus}.
}

\examples{
dimension <- 3
copulas <- matrix(list(normalCopula(0.5), 
                       claytonCopula(2.75),
                       tCopula(0.75, df = 2), 
                       NULL),
                  ncol = dimension - 1, 
                  nrow = dimension - 1)
vine <- DVine(dimension = dimension, trees = dimension - 1,
              copulas = copulas)
dimnames(vine) <- c("A", "B", "C")

data <- rvine(vine, 1)
dvine(vine, data)
pvine(vine, data)
}

\keyword{methods}
\keyword{distribution}
\keyword{multivariate}
