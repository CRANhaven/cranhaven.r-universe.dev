\name{h-methods}

\docType{methods}

\alias{h}
\alias{h-methods}
\alias{h,copula-method}
\alias{h,indepCopula-method}
\alias{h,normalCopula-method}
\alias{h,tCopula-method}
\alias{h,claytonCopula-method}
\alias{h,gumbelCopula-method}
\alias{h,fgmCopula-method}
\alias{h,frankCopula-method}
\alias{h,galambosCopula-method}

\title{Methods for the h-functions}

\usage{
h(copula, x, v, eps)
}

\arguments{
  \item{copula}{A bivariate \code{\linkS4class{copula}} object.}

  \item{x}{Numeric vector with values in \eqn{[0,1]}.}

  \item{v}{Numeric vector with values in \eqn{[0,1]}.}

  \item{eps}{To avoid numerical problems for extreme values, the values of
    \code{x}, \code{v} and return values close to \code{0} and \code{1} are
    substituted by \code{eps} and \code{1 - eps}, respectively. The default
    \code{eps} value for most of the copulas is \code{.Machine$double.eps^0.5}.}
}

\description{
The \eqn{h} function represents the conditional distribution function of a
bivariate copula and it should be defined for every copula used in
a pair-copula construction. It is defined as the partial derivative of the
distribution function of the copula w.r.t. the second argument
\eqn{h(x,v) = F(x|v) = \partial C(x,v) / \partial v}.
}

\section{Methods}{
\describe{
  \item{\code{signature(copula = "copula")}}{
    Default definition of the \eqn{h} function for a bivariate copula.
    This method is used if no particular definition is given for a copula.
    The partial derivative is calculated numerically using the
    \code{\link{numericDeriv}} function.}

  \item{\code{signature(copula = "indepCopula")}}{
    The \eqn{h} function of the independence copula.
    \deqn{h(x, v) = x}{}}

  \item{\code{signature(copula = "normalCopula")}}{
    The \eqn{h} function of the normal copula.
    \deqn{h(x, v; \rho) =
      \Phi \left( \frac{\Phi^{-1}(x) - \rho\ \Phi^{-1}(v)}
                       {\sqrt{1-\rho^2}} \right)}{}}

  \item{\code{signature(copula = "tCopula")}}{
    The \eqn{h} function of the t copula.
    \deqn{h(x, v; \rho, \nu) =
      t_{\nu+1} \left( \frac{t^{-1}_{\nu}(x) - \rho\ t^{-1}_{\nu}(v)}
                            {\sqrt{\frac{(\nu+(t^{-1}_{\nu}(v))^2)(1-\rho^2)}
                                        {\nu+1}}} \right)}{}}

  \item{\code{signature(copula = "claytonCopula")}}{
    The \eqn{h} function of the Clayton copula.
    \deqn{h(x, v; \theta) = v^{-\theta-1}(x^{-\theta}+v^{-\theta}-1)^{-1-1/\theta}}{}}

  \item{\code{signature(copula = "gumbelCopula")}}{
    The \eqn{h} function of the Gumbel copula.
    \deqn{h(x, v; \theta) = C(x, v; \theta)\ \frac{1}{v}\ (-\log v)^{\theta-1}
                            \left((-\log x)^{\theta} + (-\log v)^{\theta} \right)^{1/\theta-1}}{}}

  \item{\code{signature(copula = "fgmCopula")}}{
    The \eqn{h} function of the Farlie-Gumbel-Morgenstern copula.
    \deqn{h(x, v; \theta) =
      (1 + \theta \ (-1 + 2v) \ (-1 + x)) \ x}{}}

  \item{\code{signature(copula = "frankCopula")}}{
    The \eqn{h} function of the Frank copula.
    \deqn{h(x, v; \theta) =
      \frac{e^{-\theta v}}
           {\frac{1 - e^{-\theta}}{1 - e^{-\theta x}} + e^{-\theta v} - 1}}{}}

  \item{\code{signature(copula = "galambosCopula")}}{
    The \eqn{h} function of the Galambos copula.
    \deqn{h(x, v; \theta) =
      \frac{C(x, v; \theta)}{v}
      \left( 1 - \left[ 1 + \left(\frac{-\log v}{-\log x}\right)^{\theta} \right]^{-1-1/\theta} \right)}{}}
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
