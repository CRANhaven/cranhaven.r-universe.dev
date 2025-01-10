\name{Vine-class}

\docType{class}

\alias{Vine-class}
\alias{show,Vine-method}
\alias{dimnames<-,Vine,ANY-method}
\alias{dimnames<-,Vine-method}
\alias{dimnames,Vine-method}

\title{Base Vine Class}

\description{
Base class of all classes that implement vine models in the package. 
It is a virtual class, no objects may be created from it.
}

\section{Slots}{
\describe{
  \item{\code{type}:}{Object of class \code{"character"}. Descriptive name of 
    the type of vine: Canonical vine or D-vine.}

  \item{\code{dimension}:}{Object of class \code{"numeric"}. Dimension of the vine.}

  \item{\code{dimensionNames}:}{Object of class \code{"character"}. Names of the 
    variables of the vine. It is either an empty character vector or a vector
    with one element for each variable of the vine.}

  \item{\code{copulas}:}{Object of class \code{"matrix"}. It contains the 
    \code{\linkS4class{copula}} objects for each copula in the pair-copula
    decomposition. The indexes of the matrix follow the notation used for the 
    subscripts of \eqn{\Theta}{theta} in (Aas et al., 2009).}

  \item{\code{trees}:}{Object of class \code{"numeric"}. Number of dependence 
    trees of the vine. It should be an integer between \code{0} and 
    \code{dimension - 1}, including both endpoints. Functions acting on
    vines assume that copulas in arcs of all trees greater than \code{trees} 
    are independence copulas.}
}
}

\section{Methods}{
\describe{
  \item{show}{\code{signature(object = "Vine")}: 
    Print a textual representation of the vine.}

  \item{dimnames}{\code{signature(x = "Vine")}: 
    Retrieve the names of the variables of the vine.}

  \item{dimnames<-}{\code{signature(x = "Vine")}: 
    Set the names of the variables of the vine.}
}
}

\seealso{
\code{\linkS4class{RVine}},
\code{\linkS4class{CVine}},
\code{\linkS4class{DVine}}.
}

\references{
Aas, K. and Czado, C. and Frigessi, A. and Bakken, H. (2009)
Pair-copula constructions of multiple dependence.
\emph{Insurance: Mathematics and Economics} \bold{44}, 182--198.
}

\keyword{classes}
\keyword{multivariate}
\keyword{models}
