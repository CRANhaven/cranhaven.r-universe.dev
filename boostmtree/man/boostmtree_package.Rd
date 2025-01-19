\name{boostmtree-package}
\alias{boostmtree-package}
\docType{package}
\title{
  Boosted multivariate trees for longitudinal data.
}
\description{
  Multivariate extension of Friedman's (2001) gradient descent boosting
  method for modeling longitudinal response
  using multivariate tree base learners.
  Longitudinal response could be continuous, binary, nominal or ordinal.
  Covariate-time interactions are modeled using penalized B-splines
  (P-splines) with estimated adaptive smoothing parameter.
}

\section{Package Overview}{
  This package contains many useful functions and users should read the
  help file in its entirety for details.  However, we briefly mention
  several key functions that may make it easier to navigate and
  understand the layout of the package.

  \enumerate{
    \item \command{\link{boostmtree}}

    This is the main entry point to the package.  It grows a
    multivariate tree using user supplied training data.  Trees are
    grown using the \pkg{randomForestSRC} R-package.

    \item \command{\link{predict.boostmtree}} (\command{predict})

    Used for prediction.  Predicted values are obtained by dropping the
    user supplied test data down the grow forest.  The resulting object
    has class \code{(rfsrc, predict)}.

  }
}
\author{
  Hemant Ishwaran, Amol Pande and Udaya B. Kogalur
}
\references{
  Friedman J.H. (2001). Greedy function approximation: a gradient
  boosting machine, \emph{Ann. of Statist.}, 5:1189-1232.
  
  Friedman J.H. (2002). Stochastic gradient boosting.
  \emph{Comp. Statist. Data Anal.}, 38(4):367--378.

  Pande A., Li L., Rajeswaran J., Ehrlinger J., Kogalur U.B.,
  Blackstone E.H., Ishwaran H. (2017).  Boosted multivariate trees for
  longitudinal data, \emph{Machine Learning}, 106(2): 277--305. 
}
\seealso{
  \command{\link{partialPlot}},
  \command{\link{plot.boostmtree}},
  \command{\link{predict.boostmtree}},
  \command{\link{print.boostmtree}},
  \command{\link{simLong}}
}
\keyword{package}


