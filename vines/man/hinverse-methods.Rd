\name{hinverse-methods}

\docType{methods}

\alias{hinverse}
\alias{hinverse-methods}
\alias{hinverse,copula-method}
\alias{hinverse,indepCopula-method}
\alias{hinverse,normalCopula-method}
\alias{hinverse,tCopula-method}
\alias{hinverse,claytonCopula-method}
\alias{hinverse,frankCopula-method}

\title{Methods for the Inverse of the h-functions}

\usage{
hinverse(copula, u, v, eps)
}

\arguments{
  \item{copula}{A bivariate \code{\linkS4class{copula}} object.}

  \item{u}{Numeric vector with values in \eqn{[0,1]}.}

  \item{v}{Numeric vector with values in \eqn{[0,1]}.}

  \item{eps}{To avoid numerical problems for extreme values, the values of
    \code{u}, \code{v} and return values close to \code{0} and \code{1} are
    substituted by \code{eps} and \code{1 - eps}, respectively. The default
    \code{eps} value for most of the copulas is \code{.Machine$double.eps^0.5}.}
}

\description{
The \eqn{h^{-1}} function represents the inverse of the \eqn{h} function with
respect to its first argument. It should be defined for every copula used
in a pair-copula construction (or it will be evaluated numerically).
}

\section{Methods}{
\describe{
  \item{\code{signature(copula = "copula")}}{
    Default definition of the \eqn{h^{-1}} function for a bivariate copula.
    This method is used if no particular definition is given for a copula.
    The inverse is calculated numerically using the \code{\link{uniroot}}
    function.}

  \item{\code{signature(copula = "indepCopula")}}{
    The \eqn{h^{-1}} function of the Independence copula.
    \deqn{h^{-1}(u, v) = u}{}}

  \item{\code{signature(copula = "normalCopula")}}{
    The \eqn{h^{-1}} function of the normal copula.
    \deqn{h^{-1}(u, v; \rho) = \Phi \left( \Phi^{-1}(u) \sqrt{1-\rho^2} +
                                           \rho\ \Phi^{-1}(v) \right)}{}}

  \item{\code{signature(copula = "tCopula")}}{
    The \eqn{h^{-1}} function of the t copula.
    \deqn{h^{-1}(u, v; \rho, \nu) =
      t_{\nu} \left( t^{-1}_{\nu+1}(u)\
                     \sqrt{\frac{(\nu+(t^{-1}_{\nu}(v))^2)(1-\rho^2)}{\nu+1}} +
                     \rho\ t^{-1}_{\nu}(v)
              \right)}{}}

  \item{\code{signature(copula = "claytonCopula")}}{
    The \eqn{h^{-1}} function of the Clayton copula.
    \deqn{h^{-1}(u, v; \theta) =
      \left( \left( u\ v^{\theta+1}\right)^{-\frac{\theta}{\theta+1}} +
                    1 - v^{-\theta} \right)^{-1/\theta}}{}}

  \item{\code{signature(copula = "frankCopula")}}{
    The \eqn{h^{-1}} function of the Frank copula.
    \deqn{h^{-1}(u, v; \theta) =
      -\log \left( 1 - \frac{1-e^{-\theta}}
                            {(u^{-1} - 1) e^{-\theta v} + 1} \right) / \theta}{}}
}
}

\references{
Aas, K. and Czado, C. and Frigessi, A. and Bakken, H. (2009)
Pair-copula constructions of multiple dependence.
\emph{Insurance: Mathematics and Economics} \bold{44}, 182--198.

Schirmacher, D. and Schirmacher, E. (2008)
Multivariate dependence modeling using pair-copulas.
\emph{Enterprise Risk Management Symposium, Chicago}.
}

\keyword{methods}
