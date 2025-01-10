\name{vineOrder}

\alias{vineOrder}

\title{Select an Order of the Variables}

\description{
Select an order of the variables. The order of the variables determines the 
bivariate dependencies that will be explicit modeled in the first tree of 
the vine.
}

\usage{
vineOrder(type, data, method = "greedy", ...)
}

\arguments{
  \item{type}{Type of vine. Supported values: \code{"CVine"} and \code{"DVine"}.}

  \item{data}{Data matrix of pseudo-observations.}

  \item{method}{Ordering method. Supported values: \code{"random"}, 
    \code{"greedy"}.}

  \item{...}{Additional arguments for the order method.}
}

\value{
A vector with the ordered indexes of the variables. This vector should be 
used to reorder the variables of the \code{data} matrix.
}

\details{
In D-vines, the order of the variables determines the structure of 
all the trees of the vine. This is not the case for C-vines where 
the root node of each tree can be selected.

The \code{"random"} method returns a random permutation of the variables.

The \code{"greedy"} method returns an order of the variables that intends to
capture as much dependence as possible in the first tree of the vine. The
method finds the order of the variables that defines a tree that maximizes 
a given dependence measure used as edge weights. For C-vines, it is determined 
iteratively checking each variable as root node. For D-vines, it is equivalent 
to solve the traveling salesman problem (TSP), see (Brechmann, 2010) 
for details. The TSP is solved using the cheapest insertion algorithm
implemented by the \code{\link{solve_TSP}} function of the \pkg{TSP} package.
The following are additional parameters for this method.

\describe{
  \item{\code{according}}{Dependence measure. The default value is 
    \code{"kendall"} and supported values are:
    \describe{
      \item{\code{"kendall"}}{Absolute value of Kendall's \eqn{\tau}{tau}.}

      \item{\code{"spearman"}}{Absolute value of Spearman's \eqn{\rho}{rho}.}

      \item{\code{"pearson"}}{Absolute value of Pearson's product moment
        correlation coefficient.}

      \item{\code{"df"}}{Smaller degrees of freedom of a bivariate t copula.}
    }}
}
}

\examples{
data <- matrix(runif(5 * 100), ncol = 5, nrow = 500)

vineOrder("CVine", data, method = "random")
vineOrder("DVine", data, method = "greedy",
          according = "spearman")
}

\references{
Brechmann, E. C. (2010) Truncated and simplified regular vines 
and their applications. Diploma thesis. \emph{Technische 
Universitaet Muenchen}.
}
