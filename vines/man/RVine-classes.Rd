\name{RVine-classes}

\docType{class}

\alias{RVine-class}
\alias{CVine-class}
\alias{show,CVine-method}
\alias{DVine-class}
\alias{show,DVine-method}

\title{Classes for Regular Vines}

\description{
Extend the \code{\linkS4class{Vine}} class to represent regular vines.
}

\section{Slots}{
See \code{\linkS4class{Vine}} for information about the inherited slots.
}

\section{Methods}{
\describe{
  \item{show}{\code{signature(object = "CVine")}:
    Print a textual representation of the C-vine.}
}
\describe{
  \item{show}{\code{signature(object = "DVine")}:
    Print a textual representation of the D-vine.}
}
}

\seealso{
\code{\linkS4class{Vine}}.
}

\keyword{classes}
\keyword{multivariate}
\keyword{models}
