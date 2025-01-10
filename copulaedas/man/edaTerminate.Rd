\name{edaTerminate}

\alias{edaTerminate}
\alias{edaTerminateMaxGen}
\alias{edaTerminateMaxEvals}
\alias{edaTerminateEval}
\alias{edaTerminateEvalStdDev}
\alias{edaTerminateCombined}

\title{Termination Methods}

\description{
Methods for the \code{edaTerminate} generic function.
}

\usage{
edaTerminateMaxGen(eda, gen, fEvals, pop, popEval)
edaTerminateMaxEvals(eda, gen, fEvals, pop, popEval)
edaTerminateEval(eda, gen, fEvals, pop, popEval)
edaTerminateEvalStdDev(eda, gen, fEvals, pop, popEval)
edaTerminateCombined(...)
}

\arguments{
\item{eda}{\code{\linkS4class{EDA}} instance.}

\item{gen}{Generation.}

\item{fEvals}{Evaluations of the objective function.}

\item{pop}{Matrix with one row for each solution in the population.}

\item{popEval}{Vector with the evaluation of each solution in \code{pop}.}

\item{\dots}{Functions that implement termination methods.}
}

\details{
Termination methods decide when to stop the main loop of the EDA.
The following termination methods are implemented.

\describe{
  \item{\code{edaTerminateMaxGen}}{Stop when a maximum number of generations
    has been reached. The parameter \code{maxGen} specifies the number of
    generations (default value: \code{100}). This is the default
    method of the \code{edaTerminate} generic function.}

  \item{\code{edaTerminateMaxEvals}}{Stop when a maximum number of evaluations
    of the objective function has been reached. The parameter \code{maxEvals}
    specifies the number of evaluations (default value: \code{1000}.)}

  \item{\code{edaTerminateEval}}{Stop when a given value of the objective
    function has been reached. The parameters \code{fEval} (default value:
    \code{0}) and \code{fEvalTol} (default value: \code{1e-06}) set the value
    of the objective function and the tolerance, respectively.}

  \item{\code{edaTerminateEvalStdDev}}{Stop when the standard deviation of
    the evaluation of the solutions in the population is less than the value
    given by the parameter \code{fEvalStdDev} (default value: \code{1e-02})}.

  \item{\code{edaTerminateCombined}}{Evaluate all the termination criteria
    specified in \code{\dots} and stop if (at least) one of them returns
    \code{TRUE}.}
}
}

\value{
A \code{logical} value that indicates if the algorithm should stop.
}

\references{
Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.
}
