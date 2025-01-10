\encoding{UTF-8}

\name{CEDA-class}

\docType{class}

\alias{CEDA}
\alias{CEDA-class}
\alias{edaLearnCEDA}
\alias{edaSampleCEDA}
\alias{edaLearn,CEDA-method}
\alias{edaSample,CEDA-method}

\title{Class for Copula EDAs}

\description{
Extends the \code{\linkS4class{EDA}} class to implement EDAs based on
multivariate copulas. Objects are created by calling the \code{CEDA}
function.
}

\section{Slots}{
\describe{
  \item{\code{name}:}{See the documentation of the slot in the
  	\code{\linkS4class{EDA}} class.}

  \item{\code{parameters}:}{See the documentation of the slot in the
  	\code{\linkS4class{EDA}} class.}
}
}

\section{Methods}{
\describe{
  \item{edaLearn}{\code{signature(eda = "CEDA")}: The \code{edaLearnCEDA}
    function.}

  \item{edaSample}{\code{signature(eda = "CEDA")}: The \code{edaSampleCEDA}
    function.}
}
}

\details{
Copula EDAs (CEDA) are a class of EDAs that model the search distributions
using a multivariate copula. These algorithms estimate separately the
univariate marginal distributions and the dependence structure from the
selected population. The dependence structure is represented through a
multivariate copula. The following instances of CEDA are implemented.

\itemize{
  \item{If the dependence structure is modeled using a product copula,
    the resulting algorithm corresponds to the Univariate Marginal
    Distribution Algorithm (UMDA) for the continuous domain
    (Larrañaga et al. 1999, 2000).}

  \item{If the dependence structure is modeled using a normal copula, the
    resulting algorithm corresponds to the Gaussian Copula Estimation of
    Distribution Algorithm (GCEDA) (Soto et al. 2007; Arderí 2007).
    If non-normal marginal distributions are used, the correlation
    matrix is calculated using the inversion of Kendall's tau for each pair
    of variables (Demarta and McNeil 2005). The correction proposed in
    (Rousseeuw and Molenberghs 1993) is applied if the resulting correlation
    matrix is not positive-definite. If normal marginal distributions are
    used, the correlation matrix is estimated directly from the
    selected population using the \code{\link{cor}} function.}
}

The following parameters are recognized by the functions that implement the
\code{\link{edaLearn}} and \code{\link{edaSample}} methods for the
\code{\linkS4class{CEDA}} class.

\describe{
  \item{\code{copula}}{Multivariate copula. Supported values are:
    \code{"indep"} (independence or product copula) and \code{"normal"}
    (normal copula). Default value: \code{"normal"}.}

  \item{\code{margin}}{Marginal distributions. If this argument is \code{"xxx"},
    the algorithm will search for three functions named \code{fxxx}.
    \code{pxxx} and \code{qxxx} to fit each marginal distribution
    and evaluate the cumulative distribution function and its inverse,
    respectively. Default value: \code{"norm"}.}

  \item{\code{popSize}}{Population size. Default value: \code{100}.}
}
}

\references{
Arderí RJ (2007). Algoritmo con estimación de distribuciones con cópula gaussiana.
Bachelor's thesis, University of Havana, Cuba.

Demarta S, McNeil AJ (2005). The t Copula and Related Copulas.
\emph{International Statistical Review}, \bold{73}(1), 111--129.

Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.

Larrañaga P, Etxeberria R, Lozano JA, Peña JM (1999). Optimization by Learning
and Simulation of Bayesian and Gaussian Networks. Technical Report
EHU-KZAA-IK-4/99, University of the Basque Country.

Larrañaga P, Etxeberria R, Lozano JA, Peña JM (2000). Optimization in
Continuous Domains by Learning and Simulation of Gaussian Networks.
In \emph{Proceedings of the Workshop in Optimization by Building and Using
Probabilistic Models in the Genetic and Evolutionary Computation
Conference (GECCO 2000)}, pp. 201--204.

Rousseeuw P, Molenberghs G (1993). Transformation of Nonpositive Semidefinite
Correlation Matrices. \emph{Communications in Statistics: Theory and Methods},
\bold{22}, 965--984.

Soto M, Ochoa A, Arderí RJ (2007). Gaussian Copula Estimation of Distribution
Algorithm. Technical Report ICIMAF 2007-406, Institute of Cybernetics,
Mathematics and Physics, Cuba. ISSN 0138-8916.
}

\examples{
setMethod("edaTerminate", "EDA", edaTerminateEval)
setMethod("edaReport", "EDA", edaReportSimple)

UMDA <- CEDA(copula = "indep", margin = "norm",
    popSize = 200, fEval = 0, fEvalTol = 1e-03)
UMDA@name <- "Univariate Marginal Distribution Algorithm"

GCEDA <- CEDA(copula = "normal", margin = "norm",
    popSize = 200, fEval = 0, fEvalTol = 1e-03)
GCEDA@name <- "Gaussian Copula Estimation of Distribution Algorithm"

resultsUMDA <- edaRun(UMDA, fSphere, rep(-600, 5), rep(600, 5))
resultsGCEDA <- edaRun(GCEDA, fSphere, rep(-600, 5), rep(600, 5))

show(resultsUMDA)
show(resultsGCEDA)
}

\keyword{classes}
