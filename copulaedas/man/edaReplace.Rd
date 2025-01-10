\encoding{UTF-8}

\name{edaReplace}

\alias{edaReplace}
\alias{edaReplaceComplete}
\alias{edaReplaceRTR}

\title{Replacement Methods}

\description{
Methods for the \code{edaReplace} generic function.
}

\usage{
edaReplaceComplete(eda, gen, pop, popEval, sampledPop, sampledEval)
edaReplaceRTR(eda, gen, pop, popEval, sampledPop, sampledEval)
}

\arguments{
\item{eda}{\code{\linkS4class{EDA}} instance.}

\item{gen}{Generation.}

\item{pop}{Matrix with one row for each solution in the population.}

\item{popEval}{Vector with the evaluation of each solution in \code{pop}.}

\item{sampledPop}{Matrix with one row for each solution sampled in the
  current generation.}

\item{sampledEval}{Vector with the evaluation of the candidate solutions
  in \code{sampledPop}.}
}

\details{
Replacement methods combine the candidate solutions sampled in the current
generation with the candidate solutions from the population of the previous
generation. The following replacement methods are implemented.

\describe{
  \item{\code{edaReplaceComplete}}{The population sampled in the current
    generation completely replaces the population of the previous generation.
    This is the default method of the \code{edaReplace} generic function.}

  \item{\code{edaReplaceRTR}}{Restricted Tournament Replacement is a niching
    method that can be used to promote the preservation of alternative candidate
    solutions. See (Pelikan 2005) for a pseudocode of the algorithm implemented
    here. The parameter \code{windowSize} specifies the window size (default
    value: \code{min(ncol(pop), nrow(pop) / 2)}).}
}
}

\value{
A \code{list} with the following components.

\item{pop}{Matrix with one row for each solution in the new population.}

\item{popEval}{Vector with the evaluation of each solution in \code{pop}.}
}

\references{
Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.
}
