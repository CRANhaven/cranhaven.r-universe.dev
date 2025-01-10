\encoding{UTF-8}

\name{edaReport}

\alias{edaReport}
\alias{edaReportDisabled}
\alias{edaReportSimple}
\alias{edaReportDumpPop}
\alias{edaReportDumpSelectedPop}
\alias{edaReportCombined}

\title{Reporting Methods}

\description{
Methods for the \code{edaReport} generic function.
}

\usage{
edaReportDisabled(eda, gen, fEvals, model, pop, popEval)
edaReportSimple(eda, gen, fEvals, model, pop, popEval)
edaReportDumpPop(eda, gen, fEvals, model, pop, popEval)
edaReportDumpSelectedPop(eda, gen, fEvals, model, pop, popEval)
edaReportCombined(...)
}

\arguments{
\item{eda}{\code{\linkS4class{EDA}} instance.}

\item{gen}{Generation.}

\item{fEvals}{Evaluations of the objective function.}

\item{model}{Model learned in the current generation.}

\item{pop}{Matrix with one row for each solution in the population.}

\item{popEval}{Vector with the evaluation of each solution in \code{pop}.}

\item{\dots}{Functions that implement reporting methods.}
}

\details{
Reporting methods provide progress information during the execution of the
EDA. The following reporting methods are implemented.

\describe{
  \item{\code{edaReportDisabled}}{Disable reporting progress. This is the
    default method of the \code{edaReport} generic function.}

  \item{\code{edaReportSimple}}{Print one line at each generation with the
    number of generations, and the minimum, mean and standard deviation of
    the evaluation of the candidate solutions in the population.}

  \item{\code{edaReportDumpPop}}{Save the population at each generation
    in a different plain-text file in the current working directory.
    The names of the files are \code{pop_1.txt}, \code{pop_2.txt},
    and so on.}

  \item{\code{edaReportDumpSelectedPop}}{Save the selected population at
    each generation in a different plain-text file in the current working
    directory. The names of the files are \code{sel_1.txt}, \code{sel_2.txt},
    and so on.}

  \item{\code{edaReportCombined}}{Execute all the reporting methods specified
    in \code{\dots}.}
}
}

\references{
Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.
}
