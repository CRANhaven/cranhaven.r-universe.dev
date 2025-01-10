\encoding{UTF-8}

\name{margins}

\alias{fnorm}

\alias{ftruncnorm}

\alias{fkernel}
\alias{pkernel}
\alias{qkernel}

\alias{ftrunckernel}
\alias{ptrunckernel}
\alias{qtrunckernel}

\title{Marginal Distributions}

\description{
Functions that implement marginal distributions.
}

\usage{
fnorm(x, lower, upper)

ftruncnorm(x, lower, upper)

fkernel(x, lower, upper)
pkernel(q, X, h)
qkernel(p, X, h)

ftrunckernel(x, lower, upper)
ptrunckernel(q, a, b, X, h)
qtrunckernel(p, a, b, X, h)
}

\arguments{
\item{x, q}{Vector of quantiles.}

\item{lower, a}{Lower bound of the variable.}

\item{upper, b}{Upper bound of the variable.}

\item{p}{Vector of probabilities}

\item{X}{Observations of the variable.}

\item{h}{Bandwidth of the kernel.}
}

\details{
The functions \code{fnorm}, \code{\link{pnorm}}, and \code{\link{qnorm}}
implement the normal marginal distributions for EDAs with the \code{margin}
parameter set to \code{"norm"}. The \code{fnorm} function fits the parameters,
it returns a \code{list} object with the mean (\code{mean} component) and
the standard deviation (\code{sd} component). These components determine the
values of the corresponding arguments of the \code{\link{pnorm}} and
\code{\link{qnorm}} functions.

The functions \code{ftruncnorm}, \code{\link{ptruncnorm}}, and
\code{\link{qtruncnorm}} implement the normal marginal distributions for
EDAs with the \code{margin} parameter set to \code{"truncnorm"}. The
\code{ftruncnorm} function fits the parameters, it returns a \code{list}
object with the lower and upper bounds (\code{a} and \code{b} components,
respectively), the mean (\code{mean} component) and the standard deviation
(\code{sd} component). These components determine the values of the
corresponding arguments of the \code{\link{ptruncnorm}} and
\code{\link{qtruncnorm}} functions.

The functions \code{fkernel}, \code{pkernel}, and \code{qkernel}
implement the kernel-smoothed empirical marginal distributions for EDAs
with the \code{margin} parameter set to \code{"kernel"}. The \code{fkernel}
function fits the marginal distribution, it returns a \code{list} object with
the observations of the variable (\code{X} component) and the bandwidth of a
Gaussian kernel density estimator (\code{h} component). The bandwidth is
calculated using Silverman's rule of thumb (see \code{\link{bw.nrd0}}).
The components of the \code{list} object returned by \code{fkernel} are used
as aditional arguments in the \code{pkernel} and \code{qkernel} functions.
The \code{pkernel} function calculates the empirical cumulative distribution
function. The expression of the empirical cumulative distribution function
includes the modification used in the copula context to avoid problems
in the boundary of the \eqn{[0,1]} interval. The \code{qkernel} function uses
the Gaussian kernel density estimator fitted by \code{fkernel} to evaluate the
inverse of the cumulative distribution function, following the procedure
suggested in (Azzalini 1981).

The functions \code{ftrunckernel}, \code{ptrunckernel}, and \code{qtrunckernel}
implement the truncated kernel-smoothed empirical marginal distributions for
EDAs with the \code{margin} parameter set to \code{"trunckernel"}. The
distribution is computed from the corresponding kernel-smoothed empirical
marginal distributions without truncation by following the procedure
illustrated in (Nadarajah and Kotz 2006).
}

\references{
Azzalini, A (1981) A Note on the Estimation of a Distribution Function and
Quantiles by a Kernel Method, \emph{Biometrika}, \bold{68}, 326-328.

Gonzalez-Fernandez Y, Soto M (2014). \pkg{copulaedas}: An \R
Package for Estimation of Distribution Algorithms Based on Copulas.
\emph{Journal of Statistical Software}, \bold{58}(9), 1-34.
\url{http://www.jstatsoft.org/v58/i09/}.

Nadarajah S, Kotz S (2006) \R Programs for Computing Truncated Distributions,
\emph{Journal of Statistical Software}, \bold{16}, Code Snippet 2.
}

\seealso{
\code{\link{pnorm}},
\code{\link{qnorm}},
\code{\link{ptruncnorm}},
\code{\link{qtruncnorm}}.
}
