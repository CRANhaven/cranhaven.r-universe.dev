\name{vineGoF}

\alias{vineGoF}

\title{Vine Goodness-of-fit Tests}

\description{
Goodness-of-fit tests to verify whether the dependence structure of a sample
is appropriately modeled by vine model.
}

\usage{
vineGoF(vine, data, method = "PIT", ...)
}

\arguments{
  \item{vine}{A \code{\linkS4class{Vine}} object.}

  \item{data}{Data matrix of pseudo-observations.}

  \item{method}{Goodness-of-fit method. Supported values: 
    \code{"PIT"} (Probability Integral Transform).}

  \item{...}{Additional arguments for the goodness-of-fit method.}
}

\value{
A \code{\linkS4class{vineGoF}} or a subclass with specific information about 
the goodness-of-fit method used. The \code{statistic} slot of this object 
contains the value of the statistic and \code{pvalue} the p-value.
}

\details{
The \code{"PIT"} (Probability Integral Transform) method uses the 
\code{\link{vinePIT}} function to transform the data into variables which 
are independent and Uniform(0,1) and then use a hypothesis 
test to verify whether the resulting variables are independent and 
Uniform(0,1). The additional parameter \code{statistic} specifies 
the test to be applied for this purpose.

\describe{
  \item{\code{statistic}}{Statistic used to verify if the transformed variables
    are independent and Uniform(0,1). The default value is \code{"Breymann"} 
    and supported methods are:
    \describe{
      \item{\code{"Breymann"}}{Test proposed in the Section 7.1 of 
      (Aas et al., 2009). See (Breymann et al., 2003) for more information.}
    }}
}
}

\examples{
copula <- normalCopula(c(-0.25, -0.21, 0.34, 0.51, -0.07, -0.18), 
                       dispstr = "un", dim = 4)
data <- rCopula(100, copula)

selectCopula <- function (vine, j, i, x, y) {
    data <- cbind(x, y)
    fit <- fitCopula(normalCopula(), data, method = "itau")
    fit@copula
}
normalCVine <- vineFit("CVine", data, method = "ml",
                       selectCopula = selectCopula,
                       optimMethod = "")@vine
normalDVine <- vineFit("DVine", data, method = "ml",
                       selectCopula = selectCopula,
                       optimMethod = "")@vine
show(normalCVine)
show(normalDVine)

normalCVineGof <- vineGoF(normalCVine, data, method = "PIT",
                          statistic = "Breymann")
normalDVineGof <- vineGoF(normalDVine, data, method = "PIT",
                          statistic = "Breymann")
show(normalCVineGof)
show(normalDVineGof)
}

\seealso{
\code{\linkS4class{vineGoF}},
\code{\link{vinePIT}}.
}

\references{
Aas, K. and Czado, C. and Frigessi, A. and Bakken, H. (2009)
Pair-copula constructions of multiple dependence.
\emph{Insurance: Mathematics and Economics} \bold{44}, 182--198.

Breymann, W. and Dias, A. and Embrechts, P. (2003) Dependence 
structures for multivariate high-frequency data in finance. 
\emph{Quantitative Finance} \bold{1}, 1--14.
}
