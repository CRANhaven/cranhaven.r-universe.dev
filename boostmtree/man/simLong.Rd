\name{simLong}
\alias{simLong}
\title{Simulate longitudinal data}
\description{
  Simulates longitudinal data with continuous or binary response 
  from models with increasing complexity of
  covariate-time interactions.
}
\usage{simLong(n,
        ntest = 0,
        N = 5,
        rho = 0.8,
        type = c("corCompSym", "corAR1", "corSymm", "iid"),
        model = c(0, 1, 2, 3),
        family = c("Continuous","Binary"),
        phi = 1,
        q = 0,
        ...)}
\arguments{
  \item{n}{Requested training sample size.}
  \item{ntest}{Requested test sample size.}
  \item{N}{Parameter controlling number of time points per subject.}
  \item{rho}{Correlation parameter.}
  \item{type}{Type of correlation matrix.}
  \item{model}{Requested simulation model.}
  \item{family}{Family of response \code{y}. Use any one from \{"Continuous", "Binary"\} based on the scale of \code{y}.} 
  \item{phi}{Variance of measurement error.}
  \item{q}{Number of zero-signal variables (i.e., variables unrelated to y).}
  \item{...}{Further arguments passed to or from other methods.}
}
\details{
  Simulates longitudinal data with 3 main effects and (possibly) a covariate-time
  interaction.  Complexity of the model is specified using the option \code{model}:
  \enumerate{
    \item \emph{\code{model=0}:} Linear with no covariate-time interactions.
    \item \emph{\code{model=1}:} Linear covariate-time interaction.
    \item \emph{\code{model=2}:} Quadratic time-quadratic covariate
    interaction.
    \item \emph{\code{model=3}:} Quadratic time-quadratic two-way
    covariate interaction.
  }
  For details see Pande et al. (2017).
}
\value{
  An invisible list with the following components:
  \item{dtaL}{List containing the simulated data in the following order:
    \code{features}, \code{time}, \code{id} and \code{y}.}
  \item{dta}{Simulated data given as a data frame.}
  \item{trn}{Index of \code{id} values identifying the training data.}
  \item{f.true}{Formula of the simulation model.}
}
\author{
  Hemant Ishwaran, Amol Pande and Udaya B. Kogalur
}
\references{
  Pande A., Li L., Rajeswaran J., Ehrlinger J., Kogalur U.B.,
  Blackstone E.H., Ishwaran H. (2017).  Boosted multivariate trees for
  longitudinal data, \emph{Machine Learning}, 106(2): 277--305. 
}
\examples{
\dontrun{
##------------------------------------------------------------
##  Response is continuous
##----------------------------------------------------------------------------

## set the number of boosting iterations
M <- 500

## simulation 0: only main effects (x1, x3, x4)
dta <- simLong(n = 100, ntest = 100, model = 0, family = "Continuous", q = 5)
trn <- dta$trn
dtaL <- dta$dtaL
dta <- dta$dta
obj.0 <-  boostmtree(dtaL$features[trn, ], dtaL$time[trn], dtaL$id[trn], dtaL$y[trn], 
          family = "Continuous", M = M)
pred.0 <- predict(obj.0, dtaL$features[-trn, ], dtaL$time[-trn], dtaL$id[-trn], dtaL$y[-trn])



##------------------------------------------------------------
##  Response is binary
##----------------------------------------------------------------------------

## set the number of boosting iterations
M <- 500

## simulation 0: only main effects (x1, x3, x4)
dta <- simLong(n = 100, ntest = 100, model = 0, family = "Binary", q = 5)
trn <- dta$trn
dtaL <- dta$dtaL
dta <- dta$dta
obj.0 <-  boostmtree(dtaL$features[trn, ], dtaL$time[trn], dtaL$id[trn], dtaL$y[trn], 
          family = "Binary", M = M)
pred.0 <- predict(obj.0, dtaL$features[-trn, ], dtaL$time[-trn], dtaL$id[-trn], dtaL$y[-trn])
}
}
\keyword{simulation}
\keyword{variable selection}
