\encoding{UTF-8}

\name{VEDA-class}

\docType{class}

\alias{VEDA}
\alias{VEDA-class}
\alias{edaLearnVEDA}
\alias{edaSampleVEDA}
\alias{edaLearn,VEDA-method}
\alias{edaSample,VEDA-method}

\title{Class for Vine EDAs}

\description{
Extends the \code{\linkS4class{EDA}} class to implement EDAs based on vines.
Objects are created by calling the \code{VEDA} function.
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
Vine EDAs (VEDAs) are a class of EDAs (Soto and Gonzalez-Fernandez 2010;
Gonzalez-Fernandez 2011) that model the search distributions using vines.
Vines are graphical models that represent high-dimensional distributions by
decomposing the multivariate density into conditional bivariate copulas,
unconditional bivariate copulas, and one-dimensional densities
(Joe 1996; Bedford and Cooke 2001; Aas et al. 2009; Kurowicka and Cooke 2006).
In particular, VEDAs are based on the simplified pair-copula construction
(Hobaek Haff et al. 2010). Similarly to Copula EDAs, these algorithms estimate
separately the univariate marginal distributions and the dependence structure
from the selected population. Instead of representing the dependence structure
using a single multivariate copula, VEDAs can model a rich variety of
dependencies by combining bivariate copulas that belong to different families.
The following instances of VEDA are implemented.

\itemize{
\item{C-vine EDA (CVEDA), that models the search distributions using C-vines
    (Soto and Gonzalez-Fernandez 2010; Gonzalez-Fernandez 2011).}
\item{D-vine EDA (DVEDA), that models the search distributions using D-vines
    (Soto and Gonzalez-Fernandez 2010; Gonzalez-Fernandez 2011).}
}

Greedy heuristics based on the empirical Kendall's tau between each variable
in the selected population are used to determine the structure of the C-vines
and D-vines in CVEDA and DVEDA, respectively (Brechmann 2010).

The selection of each bivariate copula in both decompositions starts with
an independence test (Genest and Rémillard 2004; Genest et al. 2007).
The independence copula is selected if there is not enough evidence against
the null hypothesis of independence at a given significance level. In the
other case, the parameters of a group of candidate copulas are estimated
and the one that minimizes a distance to the empirical copula is selected.
A Cramér-von Mises statistic is used as the measure of distance
(Genest and Rémillard 2008).

The parameters of all the candidate copulas but the t copula are estimated
using the inversion of Kendall's tau. In the case of the t copula,
the correlation coefficient is computed using the inversion of Kendall's tau
and the degrees of freedom are estimated by maximum likelihood with the
correlation parameter fixed (Demarta and McNeil 2005).

To simplify the construction of the vines the truncation strategy presented in
(Brechmann 2010) is applied. If a vine is truncated at a given tree, all the
copulas in the subsequent trees are assumed to be product copulas. By default,
a model selection procedure based on AIC (Akaike Information Criterion) is
applied to detect the required number of trees, but it is also possible to
base the selection on BIC (Bayesian Information Criterion) or completely
disable the truncation strategy. Also, a maximum number of dependence trees
of the vine can be set, which may be helpful when dealing with high-dimensional
problems.

The following parameters are recognized by the functions that implement
the \code{\link{edaLearn}} and \code{\link{edaSample}} methods for the
\code{\linkS4class{VEDA}} class.

\describe{
  \item{\code{vine}}{Vine type. Supported values are: \code{"CVine"}
    (Canonical vine) and \code{"DVine"} (D-vine). Default value:
    \code{"DVine"}.}

  \item{\code{trees}}{Maximum number of dependence trees of the vine.
    The default is to estimate a full vine.}

  \item{\code{truncMethod}}{Method used to automatically truncate the vine if
    enough dependence is captured in the first trees. Supported values
    are: \code{"AIC"}, \code{"BIC"} and \code{""} (no truncation). Default
    value: \code{"AIC"}.}

  \item{\code{copulas}}{A \code{character} vector specifying the candidate
    copulas. Supported values are: \code{"normal"} (normal copula),
    \code{"t"} (t copula), \code{"clayton"} (Clayton copula),
    \code{"frank"} (Frank copula), and \code{"gumbel"} (Gumbel copula).
    Default value: \code{c("normal")}.}

  \item{\code{indepTestSigLevel}}{Significance level of the independence
    test. Default value: \code{0.01}.}

  \item{\code{margin}}{Marginal distributions. If this argument is \code{"xxx"},
    the algorithm will search for three functions named \code{fxxx}.
    \code{pxxx} and \code{qxxx} to fit each marginal distribution
    and evaluate the cumulative distribution function and its inverse,
    respectively. Default value: \code{"norm"}.}

  \item{\code{popSize}}{Population size. Default value: \code{100}.}
}
}

\references{
Aas K, Czado C, Frigessi A, Bakken H (2009). Pair-Copula Constructions of
Multiple Dependence. \emph{Insurance: Mathematics and Economics},
\bold{44}(2), 182--198.

Bedford T, Cooke RM (2001). Probability Density Decomposition for Conditionally
Dependent Random Variables Modeled by Vines. \emph{Annals of Mathematics and
Artificial Intelligence}, \bold{32}(1), 245--268.

Brechmann EC (2010). Truncated and Simplified Regular Vines and Their
Applications. Diploma thesis, University of Technology, Munich, Germany.

Demarta S, McNeil AJ (2005). The t Copula and Related Copulas.
\emph{International Statistical Review}, \bold{73}(1), 111--129.

Genest C, Rémillard B (2004). Tests of Independence or Randomness Based
on the Empirical Copula Process. \emph{Test}, \bold{13}(2), 335--369.

Genest C, Quessy JF, Rémillard B (2007). Asymptotic Local Efficiency of
Cramér-von mises Tests for Multivariate Independence. \emph{The Annals
of Statistics}, \bold{35}, 166--191.

Genest C, Rémillard B (2008). Validity of the Parametric Bootstrap for
Goodness-of-Fit Testing in Semiparametric Models. \emph{Annales de
l'Institut Henri Poincaré: Probabilités et Statistiques}, \bold{44},
1096--1127.

Gonzalez-Fernandez Y (2011). Algoritmos con estimación de distribuciones
basados en cópulas y vines. Bachelor's thesis, University of Havana, Cuba.

Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.

Hobaek Haff I, Aas K, Frigessi A (2010). On the Simplified Pair-Copula
Construction --- Simply Useful or Too Simplistic? Journal of Multivarite
Analysis, \bold{101}, 1145--1152.

Joe H (1996). Families of \eqn{m}-variate Distributions with Given Margins
and \eqn{m(m-1)/2} Bivariate Dependence Parameters. In L Röschendorf,
B Schweizer, MD Taylor (eds.), \emph{Distributions with fixed marginals
and related topics}, pp. 120--141.

Soto M, Gonzalez-Fernandez Y (2010). Vine Estimation of Distribution Algorithms.
Technical Report ICIMAF 2010-561, Institute of Cybernetics, Mathematics and
Physics, Cuba. ISSN 0138-8916.
}

\examples{
setMethod("edaTerminate", "EDA", edaTerminateEval)
setMethod("edaReport", "EDA", edaReportSimple)

CVEDA <- VEDA(vine = "CVine",
    copulas = c("normal", "clayton", "frank", "gumbel"),
    indepTestSigLevel = 0.01, margin = "norm",
    popSize = 200, fEval = 0, fEvalTol = 1e-03)
CVEDA@name <- "C-vine Estimation of Distribution Algorithm"

DVEDA <- VEDA(vine = "DVine",
    copulas = c("normal", "clayton", "frank", "gumbel"),
    indepTestSigLevel = 0.01, margin = "norm",
    popSize = 200, fEval = 0, fEvalTol = 1e-03)
DVEDA@name <- "D-vine Estimation of Distribution Algorithm"

resultsCVEDA <- edaRun(CVEDA, fSphere, rep(-600, 5), rep(600, 5))
resultsDVEDA <- edaRun(DVEDA, fSphere, rep(-600, 5), rep(600, 5))

show(resultsCVEDA)
show(resultsDVEDA)
}

\keyword{classes}
