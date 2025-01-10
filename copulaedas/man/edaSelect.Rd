\encoding{UTF-8}

\name{edaSelect}

\alias{edaSelect}
\alias{edaSelectTruncation}
\alias{edaSelectTournament}

\title{Selection Methods}

\description{
Methods for the \code{edaSelect} generic function.
}

\usage{
edaSelectTruncation(eda, gen, pop, popEval)
edaSelectTournament(eda, gen, pop, popEval)
}

\arguments{
\item{eda}{\code{\linkS4class{EDA}} instance.}

\item{gen}{Generation.}

\item{pop}{Matrix with one row for each solution in the population.}

\item{popEval}{Vector with the evaluation of each solution in \code{pop}.}
}

\details{
Selection methods determine the solutions to be modeled by the search
distribution (selected population). These solutions are usually the most
promising solutions of the population. The following selection methods are
implemented.

\describe{
  \item{\code{edaSelectTruncation}}{In truncation selection, the
    \code{100 * truncFactor} percent of the solutions with the best evaluation
    in the population are selected. The parameter \code{truncFactor} specifies
    the truncation factor (default value: \code{0.3}). This is the default
    method of the \code{edaSelect} generic function.}

  \item{\code{edaSelectTournament}}{In tournament selection, a group of
    solutions are randomly picked from the population and the best one is
    selected. This process is repeated as many times as needed to complete
    the selected population. The parameter \code{tournamentSize} specifies
    the number of solutions randomly picked from the population (default
    value: \code{2}), \code{selectionSize} specifies the size of the selected
    population (default value: \code{nrow(pop)}), and \code{replacement}
    specifies whether to sample with replacement or not (default value:
    \code{TRUE}).}
}
}

\value{
An \code{integer} vector with the indexes of the solutions selected
from \code{pop}.
}

\references{
Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.

Pelikan M (2005). \emph{Hierarchical Bayesian Optimization Algorithm.
Toward a New Generation of Evolutionary Algorithms}. Springer-Verlag.
}
