\encoding{UTF-8}

\name{edaIndepRuns}

\alias{edaIndepRuns}

\title{Independent Runs}

\description{
Execute independent runs.
}

\usage{
edaIndepRuns(eda, f, lower, upper, runs, verbose = FALSE)
}

\arguments{
\item{eda}{\code{\linkS4class{EDA}} instance.}

\item{f}{Objective function.}

\item{lower}{Lower bounds of the variables of the objective function.}

\item{upper}{Upper bounds of the variables of the objective function.}

\item{runs}{Number of runs.}

\item{verbose}{Print information after each run and a final summary.}
}

\value{
An \code{\linkS4class{EDAResults}} instance.
}

\references{
Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.
}

\seealso{
\code{\linkS4class{EDA}},
\code{\link{edaRun}}.
}

\examples{
setMethod("edaReport", "EDA", edaReportSimple)
setMethod("edaTerminate", "EDA",
    edaTerminateCombined(edaTerminateMaxGen,
        edaTerminateEval))

DVEDA <- VEDA(vine = "DVine", copulas = c("normal"),
    indepTestSigLevel = 0.01, margin = "norm", popSize = 200,
    maxGens = 50, fEval = 0, fEvalTol = 1e-03)
DVEDA@name <- "D-vine Estimation of Distribution Algorithm"

results <- edaIndepRuns(DVEDA, fSphere, rep(-600, 5), rep(600, 5), 5)

show(results)
summary(results)
}
