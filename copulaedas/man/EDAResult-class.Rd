\encoding{UTF-8}

\name{EDAResult-class}

\docType{class}

\alias{EDAResult-class}
\alias{show,EDAResult-method}

\title{Class for the Results of a Run of an EDA}

\description{
Results of a run of an EDA. Objects are created by calling the
\code{\link{edaRun}} function.
}

\section{Slots}{
\describe{
  \item{\code{eda}:}{Object of class \code{EDA}.}

  \item{\code{f}:}{Object of class \code{function}. Objective function.}

  \item{\code{lower}:}{Object of class \code{numeric}. Lower bounds of
    the variables of the objective function.}

  \item{\code{upper}:}{Object of class \code{numeric}. Upper bounds of
    the variables of the objective function.}

  \item{\code{numGens}:}{Object of class \code{numeric}. Number of
    generations.}

  \item{\code{fEvals}:}{Object of class \code{numeric}. Number of
    evaluations of the objective function.}

  \item{\code{bestEval}:}{Object of class \code{numeric}. Best evaluation
    of the objective function.}

  \item{\code{bestSol}:}{Object of class \code{numeric}. Best solution.}

  \item{\code{cpuTime}:}{Object of class \code{numeric}. Run time of the
    algorithm in seconds.}
}
}
\section{Methods}{
\describe{
  \item{show}{\code{signature(object = "EDAResult")}: Prints the results.}
}
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

\keyword{classes}
