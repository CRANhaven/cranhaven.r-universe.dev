\encoding{UTF-8}

\name{edaOptimize}

\alias{edaOptimize}
\alias{edaOptimizeDisabled}

\title{Local Optimization Methods}

\description{
Methods for the \code{edaOptimize} generic function.
}

\usage{
edaOptimizeDisabled(eda, gen, pop, popEval, f, lower, upper)
}

\arguments{
\item{eda}{\code{\linkS4class{EDA}} instance.}

\item{gen}{Generation.}

\item{pop}{Matrix with one row for each solution in the population.}

\item{popEval}{Vector with the evaluation of each solution in \code{pop}.}

\item{f}{Objective function.}

\item{lower}{Lower bounds of the variables of the objective function.}

\item{upper}{Upper bounds of the variables of the objective function.}
}

\details{
Local optimization methods improve the solutions sampled by the search
distribution. These methods can also be used to implement repairing
strategies for constrained problems in which the simulated solutions may be
unfeasible and some strategy to repair these solutions is available.

The following local optimization methods are implemented.

\describe{
  \item{\code{edaOptimizeDisabled}}{Disable local optimization. This is
  the default method of the \code{edaOptimize} generic function.}
}
}

\value{
A \code{list} with the following components.

\item{pop}{Matrix with one row for each solution in the optimized population.}

\item{popEval}{Vector with the evaluation of each solution in \code{pop}.}
}

\references{
Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.
}
