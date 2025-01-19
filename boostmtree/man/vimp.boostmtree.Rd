\name{vimp.boostmtree}
\alias{vimp.boostmtree}
\title{Variable Importance}
\description{
  Calculate VIMP score for each of the individual covariates or a joint VIMP
  of multiple covariates.
}
\usage{vimp.boostmtree(object,
                x.names = NULL,
                joint = FALSE)}
\arguments{
  \item{object}{A boosting object of class \code{(boostmtree, grow)} or class \code{(boostmtree, predict)}.}
  \item{x.names}{Names of the x-variables for which VIMP is requested. If NULL, VIMP
  is calcuated for all the covariates}
  \item{joint}{Estimate individual VIMP for each covariate from \code{x.names} or a joint VIMP
  for all covariates combine.}
}
\details{
  Variable Importance (VIMP) is calcuated for each of the covariates individually or a joint
  VIMP is calulated for all the covariates specfied in \code{x.names}.
}
\author{
  Hemant Ishwaran, Amol Pande and Udaya B. Kogalur
}
\references{
  Friedman J.H. Greedy function approximation: a gradient
  boosting machine, \emph{Ann. of Statist.}, 5:1189-1232, 2001.
}
\examples{
\dontrun{
##------------------------------------------------------------
## Synthetic example (Response is continuous)
## VIMP is based on in-sample CV using out of bag data
##-------------------------------------------------------------
#simulate the data
dta <- simLong(n = 50, N = 5, rho =.80, model = 2,family = "Continuous")$dtaL

#basic boosting call
boost.grow <- boostmtree(dta$features, dta$time, dta$id, dta$y,
              family = "Continuous", M = 300,cv.flag = TRUE)
vimp.grow <- vimp.boostmtree(object = boost.grow,x.names=c("x1","x2"),joint = FALSE)
vimp.joint.grow <- vimp.boostmtree(object = boost.grow,x.names=c("x1","x2"),joint = TRUE)

##------------------------------------------------------------
## Synthetic example (Response is continuous)
## VIMP is based on test data
##-------------------------------------------------------------
#simulate the data
dtaO <- simLong(n = 100, ntest = 100, N = 5, rho =.80, model = 2, family = "Continuous")

## save the data as both a list and data frame
dtaL <- dtaO$dtaL
dta <- dtaO$dta

## get the training data
trn <- dtaO$trn

#basic boosting call
boost.grow <- boostmtree(dtaL$features[trn,], dtaL$time[trn], dtaL$id[trn], dtaL$y[trn],
              family = "Continuous", M = 300)
boost.pred <- predict(boost.grow,dtaL$features[-trn,], dtaL$time[-trn], dtaL$id[-trn],
              dtaL$y[-trn])
vimp.pred <- vimp.boostmtree(object = boost.pred,x.names=c("x1","x2"),joint = FALSE)
vimp.joint.pred <- vimp.boostmtree(object = boost.pred,x.names=c("x1","x2"),joint = TRUE)

}
}
\keyword{plot}
