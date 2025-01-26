\name{liu}
\alias{liu}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Liu Estimator
}
\description{
\code{liu} can be used to find the Liu Estimated values and corresponding scalar Mean Square Error (MSE) value in the linear model. Further the variation of MSE can be shown graphically.
}
\usage{
liu(formula, d, data = NULL, na.action, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{formula}{
in this section interested model should be given. This should be given as a \code{\link{formula}}.
}
  \item{d}{
a single numeric value or a vector of set of numeric values. See \sQuote{Examples}.
}
  \item{data}{
an optional data frame, list or environment containing the variables in the model. If not found in \code{data}, the variables are taken from \code{environment(formula)}, typically the environment from which the function is called.
}
  \item{na.action}{
if the dataset contain \code{NA} values, then \code{\link{na.action}} indicate what should happen to those \code{NA} values.
}
  \item{\dots}{
currently disregarded.
}
}
\details{
Since formula has an implied intercept term, use either \code{y ~ x - 1} or \code{y ~ 0 + x} to remove the intercept.\cr

Use \code{\link{plot}} so as to obtain the variation of scalar MSE values graphically. See \sQuote{Examples}.
}
\value{
If \code{d} is a single numeric values then \code{liu} returns the Liu Estimated values, standard error values, t statistic values, p value and corresponding scalar MSE value.\cr

If \code{d} is a vector of set of numeric values then \code{liu} returns all the scalar MSE values and corresponding parameter values of Liu Estimator.\cr 
}
\references{
Liu, K. (1993) \emph{A new class of biased estimate in linear regression} in \emph{Communications in Statistics-Theory and Methods} \bold{22}, pp. 393--402.
}
\author{
P.Wijekoon, A.Dissanayake
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{plot}}
}
\examples{
## Portland cement data set is used.
data(pcd)
d<-0.05
liu(Y~X1+X2+X3+X4-1,d,data=pcd)   # Model without the intercept is considered.

## To obtain the variation of MSE of Liu Estimator.
data(pcd)
d<-c(0:10/10)
plot(liu(Y~X1+X2+X3+X4-1,d,data=pcd),main=c("Plot of MSE of Liu Estimator"),
type="b",cex.lab=0.6,adj=1,cex.axis=0.6,cex.main=1,las=1,lty=3,cex=0.6)
mseval<-data.frame(liu(Y~X1+X2+X3+X4-1,d,data=pcd))
smse<-mseval[order(mseval[,2]),]
points(smse[1,],pch=16,cex=0.6)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
