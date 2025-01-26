\name{oglt3}
\alias{oglt3}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Ordinary Generalized Type (3) Liu Estimator
}
\description{
This function can be used to find the Ordinary Generalized Type (3) Liu Estimated values, corresponding scalar Mean Square Error (MSE) value in the linear model. Further the variation of MSE values can be shown graphically.
}
\usage{
oglt3(formula, k, d, data = NULL, na.action, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{formula}{
in this section interested model should be given. This should be given as a \code{\link{formula}}.
}
  \item{k}{
a single numeric value or a vector of set of numeric values. See \sQuote{Example}.
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

Use \code{\link{matplot}} so as to obtain the variation of scalar MSE values graphically. See \sQuote{Examples}
}
\value{
If \code{k} and \code{d} are single numeric values then \code{oglt3} returns the Ordinary Generalized Type (3) Liu Estimated values, standard error values, t statistic values, p value, corresponding scalar MSE value.\cr

If \code{k} and \code{d} are vector of set of numeric values then \code{oglt3} returns the matrix of scalar MSE values of Ordinary Generalized Type (3) Liu Estimator by representing \code{k} and \code{d} as column names and row names respectively.\cr
}
\references{
Arumairajan, S. and Wijekoon, P. (2015) ] \emph{Optimal Generalized Biased Estimator in Linear Regression Model} in \emph{Open Journal of Statistics}, pp. 403--411\cr

Rong,Jian-Ying (2010) \emph{Adjustive Liu Type Estimators in linear regression models} in \emph{communication in statistics-simulation and computation}, volume \bold{39} DOI:10.1080/03610918.2010.484120
}
\author{
P.Wijekoon, A.Dissanayake
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{matplot}}
}
\examples{
## Portland cement data set is used.
data(pcd)
k<-0.1650
d<--0.1300
oglt3(Y~X1+X2+X3+X4-1,k,d,data=pcd)    
# Model without the intercept is considered.

## To obtain the variation of MSE of Ordinary Generalized Type (3) 
# Liu Estimator.
data(pcd)
k<-c(0:5/10)
d<-c(-440:-420/10)
msemat<-oglt3(Y~X1+X2+X3+X4-1,k,d,data=pcd)
matplot(d,oglt3(Y~X1+X2+X3+X4-1,k,d,data=pcd),type="l",ylab=c("MSE"),
main=c("Plot of MSE of Ordinary Generalized Type (3) Liu Estimator"),
cex.lab=0.6,adj=1,cex.axis=0.6,cex.main=1,las=1,lty=3)
text(y=msemat[1,],x=d[1],labels=c(paste0("k=",k)),pos=4,cex=0.6)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
