\name{rrre}
\alias{rrre}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Restricted Ridge Regression Estimator
}
\description{
This function can be used to find the Restricted Ridge Regression Estimated values and corresponding scalar Mean Square Error (MSE) value. Further the variation of MSE can be shown graphically.
}
\usage{
rrre(formula, r, R, dpn, delt, k, data = NULL, na.action, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{formula}{
in this section interested model should be given. This should be given as a \code{\link{formula}}.
}
  \item{r}{
is a \eqn{j} by \eqn{1} matrix of linear restriction, \eqn{r = R\beta + \delta + \nu}. Values for \code{r} should be given as either a \code{\link{vector}} or a \code{\link{matrix}}. See \sQuote{Examples}.
}
  \item{R}{
is a \eqn{j} by \eqn{p} of full row rank \eqn{j \le p} matrix of linear restriction, \eqn{r = R\beta + \delta + \nu}. Values for \code{R} should be given as either a \code{vector} or a \code{matrix}. See \sQuote{Examples}.
}
  \item{dpn}{
dispersion matrix of vector of disturbances of linear restricted model, \eqn{r = R\beta + \delta + \nu}. Values for \code{dpn} should be given as either a \code{vector} (only the diagonal elements) or a \code{matrix}. See \sQuote{Examples}.
}
  \item{delt}{
values of \eqn{E(r) - R\beta} and that should be given as either a \code{vector} or a \code{matrix}. See \sQuote{Examples}.
}
  \item{k}{
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
If \code{k} is a single numeric values then \code{rrre} returns the Restricted Ridge Regression Estimated values, standard error values, t statistic values, p value and corresponding scalar MSE value.\cr

If \code{k} is a vector of set of numeric values then \code{rrre} returns all the scalar MSE values and corresponding parameter values of Restricted Ridge Regression Estimator.\cr
}
\references{
Sarkara, N. (1992), \emph{A new estimator combining the ridge regression and the restricted least squares methods of estimation} in \emph{Communications in Statistics - Theory and Methods}, volume \bold{21}, pp. 1987--2000. DOI:10.1080/03610929208830893 
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
k<-0.05
r<-c(2.1930,1.1533,0.75850)
R<-c(1,0,0,0,0,1,0,0,0,0,1,0)
dpn<-c(0.0439,0.0029,0.0325)
delt<-c(0,0,0)
rrre(Y~X1+X2+X3+X4-1,r,R,dpn,delt,k,data=pcd)
 # Model without the intercept is considered.

## To obtain variation of MSE of Restricted Ridge Regression Estimator.
data(pcd)
k<-c(0:10/10)
r<-c(2.1930,1.1533,0.75850)
R<-c(1,0,0,0,0,1,0,0,0,0,1,0)
dpn<-c(0.0439,0.0029,0.0325)
delt<-c(0,0,0)
plot(rrre(Y~X1+X2+X3+X4-1,r,R,dpn,delt,k,data=pcd),
main=c("Plot of MSE of Restricted Ridge Regression Estimator"),
type="b",cex.lab=0.6,adj=1,cex.axis=0.6,cex.main=1,las=1,lty=3,cex=0.6)
mseval<-data.frame(rrre(Y~X1+X2+X3+X4-1,r,R,dpn,delt,k,data=pcd))
smse<-mseval[order(mseval[,2]),]
points(smse[1,],pch=16,cex=0.6)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
