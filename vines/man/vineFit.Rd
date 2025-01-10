\name{vineFit}

\alias{vineFit}

\title{Vine Inference}

\description{
Estimate a vine model from multivariate data in the unit hypercube. Data can be 
pseudo-observations constructed from empirical or parametric marginal cumulative 
distribution functions.
}

\usage{
vineFit(type, data, method = "ml", ...)
}

\arguments{
  \item{type}{Type of vine. Supported values: \code{"CVine"} and \code{"DVine"}.}

  \item{data}{Data matrix of pseudo-observations.}

  \item{method}{Inference method. Supported values: 
    \code{"ml"} (Maximum Likelihood).}
    
  \item{...}{Additional arguments for the inference method.}
}

\value{
A \code{\linkS4class{vineFit}} object or a subclass with specific 
information about inference method used. The \code{vine} slot of this object 
contains the fitted \code{\linkS4class{Vine}} object.
}

\details{
The \code{"ml"} (Maximum Likelihood) method starts with the sequential estimation
procedure described in (Aas et al., 2009) and then executes a numerical
maximization of the full log-likelihood of the vine. The sequential procedure
is used to determine the family and the initial values of the parameters of 
each bivariate copula in the decomposition. Additional arguments for this 
method are:

\describe{
  \item{\code{selectCopula}}{Function provided by the user to select the
    copulas in the pair-copula construction. This function should return 
    a \code{\linkS4class{copula}} object and expect the following arguments.
    \describe{
      \item{\code{vine}}{Vine object being constructed.}

      \item{\code{j, i}}{Indexes of the copula under selection in the matrix of the
        \code{copulas} slot of the vine.}

      \item{\code{x, y}}{Bivariate sample.}
    }
    The default value is \code{function (vine, j, i, x, y) indepCopula()}
    that assigns the independence copula to all the arcs of the vine.}

  \item{\code{trees}}{Maximum number of dependence trees of the vine. Independence
    copulas will be used in all the arcs of the following trees. The final number
    of dependence trees could be smaller because of the use of a truncation method. 
    The default value is \code{ncol(data) - 1}.}

  \item{\code{truncMethod}}{Method used to automatically truncate the vine if
    enough dependence is captured in a given number of trees. Supported methods
    are \code{"AIC"} and \code{"BIC"}. See (Brechmann, 2010; Brechmann et al., 2010)
    for information about these methods. The default value is \code{""} that
    means no truncation.}
  
  \item{\code{optimMethod}}{\code{\link{optim}} method used in the optimization
    of the log-likelihood function. If \code{""} is specified the optimization
    is disabled and the vine calculated using the sequential estimation procedure 
    is returned. The default value is \code{"Nelder-Mead"}.}

  \item{\code{optimControl}}{List of control parameters for \code{\link{optim}}.
    The default value is \code{list()}.}
}
}

\examples{
data <- matrix(runif(5 * 100), ncol = 5, nrow = 100)
colnames(data) <- c("A", "B", "C", "D", "E")

selectCopula <- function (vine, j, i, x, y) {
    data <- cbind(x, y)
    fit <- fitCopula(normalCopula(), data, method = "itau")
    fit@copula
}
fit <- vineFit("DVine", data, method = "ml", 
               selectCopula = selectCopula, 
               optimMethod = "")

show(fit)
show(fit@vine)
}

\seealso{
\code{\linkS4class{CVine}},
\code{\linkS4class{DVine}},
\code{\linkS4class{vineFit}},
\code{\linkS4class{vineFitML}}.
}

\references{
Aas, K. and Czado, C. and Frigessi, A. and Bakken, H. (2009)
Pair-copula constructions of multiple dependence.
\emph{Insurance: Mathematics and Economics} \bold{44}, 182--198.

Brechmann, E. C. (2010) Truncated and simplified regular vines 
and their applications. Diploma thesis. \emph{Technische 
Universitaet Muenchen}.

Brechmann, E. C. and Czado, C. and Aas, K. (2010) Truncated regular 
vines in high dimensions with application to financial data. 
\emph{Norwegian Computing Center, NR}. Note SAMBA/60/10.
}
