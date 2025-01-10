\name{vineFit-class}

\docType{class}

\alias{vineFit-class}
\alias{show,vineFit-method}

\title{Class for the Results of Vine Inference}

\description{
Base class of all classes providing information about vine inference. 
Objects of this class (or subclasses) are created by calling the 
\code{\link{vineFit}} function.
}

\section{Slots}{
\describe{
  \item{\code{vine}:}{Object of class \code{\linkS4class{Vine}}. Fitted vine.}

  \item{\code{observations}:}{Object of class \code{numeric}. Number of 
    observations in the sample.}

  \item{\code{method}:}{Object of class \code{character}. Inference method.}
}
}

\section{Methods}{
\describe{
  \item{show}{\code{signature(object = "vineFit")}: 
    Print the result of the vine inference.}
}
}

\seealso{
\code{\link{vineFit}},
\code{\linkS4class{vineFitML}}.
}

\keyword{classes}
\keyword{multivariate}
\keyword{models}
