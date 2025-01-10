\name{vineFitML-class}

\docType{class}

\alias{vineFitML-class}
\alias{show,vineFitML-method}

\title{Class for the Results of Vine Inference by Maximum Likelihood}

\description{
Extends the \code{\linkS4class{vineFit}} class to include information
about the Maximum Likelihood inference.
}

\section{Slots}{
See \code{\linkS4class{vineFit}} for information about inherited slots.

\describe{
  \item{\code{optimMethod}:}{Object of class \code{character}. 
    \code{\link{optim}} method.}

  \item{\code{optimConv}:}{Object of class \code{numeric}. \code{\link{optim}} 
    convergence code (0 indicates successful completion).}

  \item{\code{startParams}:}{Object of class \code{numeric}. Vector with the 
    parameters of the copulas in the pair-copula construction calculated using 
    the sequential estimation procedure.}

  \item{\code{finalParams}:}{Object of class \code{numeric}. Vector with the 
    parameters of the copulas in the pair-copula construction after the 
    maximization of the log-likelihood.}
}
}

\section{Methods}{
\describe{
  \item{show}{\code{signature(object = "vineFitML")}: 
    Print information about the fitted vine.}
}
}

\seealso{
\code{\linkS4class{vineFit}},
\code{\link{vineFit}},
\code{\link{vineParameters}}.
}

\keyword{classes}
\keyword{multivariate}
\keyword{models}
