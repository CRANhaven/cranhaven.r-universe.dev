\encoding{UTF-8}

\name{edaRun}

\alias{edaRun}
\alias{edaLearn}
\alias{edaSample}

\title{Main Loop of an EDA}

\description{
Main loop of an EDA.
}

\usage{
edaRun(eda, f, lower, upper)
}

\arguments{
\item{eda}{\code{\linkS4class{EDA}} instance.}

\item{f}{Objective function.}

\item{lower}{Lower bounds of the variables of the objective function.}

\item{upper}{Upper bounds of the variables of the objective function.}
}

\details{
EDAs are implemented using S4 classes with generic functions for its main
parts: seeding (\code{\link{edaSeed}}), selection (\code{\link{edaSelect}}),
learning (\code{edaLearn}), sampling (\code{edaSample}), replacement
(\code{\link{edaReplace}}), local optimization (\code{\link{edaOptimize}}),
termination (\code{\link{edaTerminate}}), and reporting
(\code{\link{edaReport}}). The following pseudocode illustrates the interactions
between all the generic functions. It is a simplified version of the
implementation of the \code{\link{edaRun}} function.

\preformatted{
gen <- 0
fEvals <- 0
terminate <- FALSE

while (!terminate) {
  gen <- gen + 1

  if (gen == 1) {
    model <- NULL
    pop <- edaSeed(lower, upper)
    # Set popEval to the evaluation of each solution in pop.
    # Update fEvals.
    r <- edaOptimize(gen, pop, popEval, f, lower, upper)
    pop <- r$pop; popEval <- r$popEval
  } else {
    s <- edaSelect(gen, pop, popEval)
    selectedPop <- pop[s, ]; selectedEval <- popEval[s]
    model <- edaLearn(gen, model, selectedPop, selectedEval,
                      lower, upper)
    sampledPop <- edaSample(gen, model, lower, upper)
    # Set sampledEval to the evaluation of each solution
    # in sampledPop. Update fEvals.
    r <- edaOptimize(gen, sampledPop, sampledEval, f, lower, upper)
    sampledPop <- r$pop; sampledEval <- r$popEval
    r <- edaReplace(gen, pop, popEval, sampledPop, sampledEval)
    pop <- r$pop; popEval <- r$popEval
  }

  edaReport(gen, fEvals, model, pop, popEval)
  terminate <- edaTerminate(gen, fEvals, pop, popEval)
}
}
}

\value{
An \code{\linkS4class{EDAResult}} instance.
}

\references{
Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.
}

\seealso{
\code{\linkS4class{EDA}},
\code{\linkS4class{EDAResult}},
\code{\link{edaIndepRuns}}.
}

\examples{
setMethod("edaReport", "EDA", edaReportSimple)
setMethod("edaTerminate", "EDA",
    edaTerminateCombined(edaTerminateMaxGen,
        edaTerminateEval))

DVEDA <- VEDA(vine = "DVine", copulas = c("normal"),
    indepTestSigLevel = 0.01, margin = "norm",
    popSize = 200, maxGens = 50, fEval = 0,
    fEvalTol = 1e-03)
DVEDA@name <- "D-vine Estimation of Distribution Algorithm"

result <- edaRun(DVEDA, fSphere, rep(-600, 5), rep(600, 5))

show(result)
}
