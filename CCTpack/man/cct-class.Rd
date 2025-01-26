\name{cct-class}
\Rdversion{1.1}
\docType{class}
\alias{cct-class}
\alias{plot,cct,rjags-method}

\title{Class \code{"cct"}}
\description{
Virtual class that contains "rjags" class, used to create plot, summary, and screeplot methods for the cctfit objects from package CCTpack.
}
\section{Objects from the Class}{
Objects can be created by calls of the form \code{new("cct", ...)}.
%%  ~~ describe objects here ~~ 
}
\section{Slots}{
  \describe{
    \item{\code{model}:}{Object of class \code{"jags"} ~~ }
    \item{\code{BUGSoutput}:}{Object of class \code{"bugs"} ~~ }
  }
}
\section{Extends}{
Class \code{"\linkS4class{rjags}"}, directly.
}
\section{Methods}{
  \describe{
    \item{plot}{\code{signature(x = "cct", y = "rjags")}: ... }
	 }
}
\author{
Royce Anders
Maintainer: Royce Anders <andersr@uci.edu>
}
\examples{
showClass("cct")
}
\keyword{classes}
