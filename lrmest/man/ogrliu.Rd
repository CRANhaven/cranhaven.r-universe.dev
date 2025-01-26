\name{ogrliu}
\alias{ogrliu}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Ordinary Generalized Restricted Liu Estimator
}
\description{
This function can be used to find the Ordinary Generalized Restricted Liu Estimated values and corresponding scalar Mean Square Error (MSE) value. Further the variation of MSE can be shown graphically.
}
\usage{
ogrliu(formula, r, R, delt, d, data = NULL, na.action, ...)
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
  \item{delt}{
values of \eqn{E(r) - R\beta} and that should be given as either a \code{vector} or a \code{matrix}. See \sQuote{Examples}.
}
  \item{d}{
a single numeric value or a vector of set of numeric values. See \sQuote{Example}.
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
If \code{d} is a single numeric values then \code{rliu} returns the Restricted Liu Estimated values, standard error values, t statistic values, p value and corresponding scalar MSE value.\cr

If \code{d} is a vector of set of numeric values then \code{ogrliu} returns all the scalar MSE values and corresponding parameter values of Ordinary Generalized Restricted Liu Estimator.\cr
}
\references{
Arumairajan, S. and Wijekoon, P. (2015) ] \emph{Optimal Generalized Biased Estimator in Linear Regression Model} in \emph{Open Journal of Statistics}, pp. 403--411\cr

Hubert, M.H. and Wijekoon, P. (2006) \emph{Improvement of the Liu estimator in the linear regression medel}, Chapter (4-8)
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
data(pcd)
d<-0.05
r<-c(2.1930,1.1533,0.75850)
R<-c(1,0,0,0,0,1,0,0,0,0,1,0)
delt<-c(0,0,0)
ogrliu(Y~X1+X2+X3+X4-1,r,R,delt,d,data=pcd)    
# Model without the intercept is considered.
 
## To obtain the variation of MSE of 
# Ordinary Generalized Resticted Liu Estimator.
data(pcd)
d<-c(0:10/10)
r<-c(2.1930,1.1533,0.75850)
R<-c(1,0,0,0,0,1,0,0,0,0,1,0)
delt<-c(0,0,0)
plot(ogrliu(Y~X1+X2+X3+X4-1,r,R,delt,d,data=pcd),
main=c("Plot of MSE of Ordinary Generalized Restricted Liu 
Estimator"),type="b",cex.lab=0.6,adj=1,cex.axis=0.6,cex.main=1,las=1,lty=3,cex=0.6)
mseval<-data.frame(ogrliu(Y~X1+X2+X3+X4-1,r,R,delt,d,data=pcd))
smse<-mseval[order(mseval[,2]),]
points(smse[1,],pch=16,cex=0.6)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
