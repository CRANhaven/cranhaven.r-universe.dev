\encoding{UTF-8}

\name{edaCriticalPopSize}

\alias{edaCriticalPopSize}

\title{Critical Population Size}

\description{
Determine the critical population size using a bisection method.
}

\usage{
edaCriticalPopSize(eda, f, lower, upper, fEval, fEvalTol,
    totalRuns = 30, successRuns = totalRuns, lowerPop = 2,
    upperPop = NA, stopPercent = 10, verbose = FALSE)
}

\arguments{
\item{eda}{\code{\linkS4class{EDA}} instance.}

\item{f}{Objective function.}

\item{lower}{Lower bounds of the variables of the objective function.}

\item{upper}{Upper bounds of the variables of the objective function.}

\item{fEval}{Optimum value of the objective function.}

\item{fEvalTol}{A run is considered successful if the difference between
  \code{fEval} and the best found solution is less than \code{fEvalTol}.}

\item{totalRuns}{Total number of runs.}

\item{successRuns}{Required number of successfully runs.}

\item{lowerPop}{Lower bound of the initial interval for the population.}

\item{upperPop}{Upper bound of the initial interval for the population.}

\item{stopPercent}{Stop percent.}

\item{verbose}{Print progress information.}
}

\details{
This function determines the minimum population size required by the EDA to
reach the value \code{fEval} of the objective function in \code{successRuns}
runs out of a total of \code{totalRuns} independent runs (critical
population size).

The population size is determined using a bisection method starting with the
interval delimited by \code{lowerPop} and \code{upperPop}. The bisection
procedure stops when the estimated population size is less than
\code{stopPercent} percent away from the critical population size. If either
\code{lowerPop} or \code{upperPop} is not specified, the algorithm will
determine an initial interval based on the value of the \code{popSize}
parameter and then continue using the bisection method.

See (Pelikan 2005) for a pseudocode of a similar algorithm.
}

\value{
Either \code{NULL} if the critical population size was not determined or
an \code{\linkS4class{EDAResults}} instance with the results of the runs
of the EDA using the critical population size.
}

\references{
Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.

Pelikan M (2005). \emph{Hierarchical Bayesian Optimization Algorithm.
Toward a New Generation of Evolutionary Algorithms}. Springer-Verlag.
}

\seealso{
\code{\linkS4class{EDA}},
\code{\link{edaRun}}.
}

\examples{
setMethod("edaReport", "EDA", edaReportDisabled)
setMethod("edaTerminate", "EDA",
    edaTerminateCombined(edaTerminateEval,
        edaTerminateMaxEvals))

UMDA <- CEDA(copula = "indep", margin = "norm",
    fEval = 0, fEvalTol = 1e-03, maxEvals = 10000)
UMDA@name <- "Univariate Marginal Distribution Algorithm"

results <- edaCriticalPopSize(UMDA, fSphere, rep(-600, 10),
    rep(600, 10), 0, 1e-03, totalRuns = 30, successRuns = 30,
    lowerPop = 50, upperPop = 100, verbose = TRUE)

show(results)
summary(results)
}
