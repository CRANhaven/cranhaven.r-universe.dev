\name{vineGoF-class}

\docType{class}

\alias{vineGoF-class}
\alias{show,vineGoF-method}

\title{Class for the Results of Vine Goodness-of-fit Tests}

\description{
Base class of all classes containing information about vine goodness-of-fit 
tests. Objects of this class (or subclasses) are created by calling the 
\code{\link{vineGoF}} function.
}

\section{Slots}{
\describe{
  \item{\code{method}:}{Object of class \code{character}.
    Goodness-of-fit method.}

  \item{\code{statistic}:}{Object of class \code{numeric}. 
    Value of the test statistic.}

  \item{\code{pvalue}:}{Object of class \code{numeric}. P-value.}
}
}

\section{Methods}{
\describe{
  \item{show}{\code{signature(object = "vineGoF")}: 
    Print the result of the goodness-of-fit test.}
}
}

\keyword{classes}
\keyword{multivariate}
\keyword{models}
\keyword{htest}

\seealso{
\code{\link{vineGoF}}.
}
