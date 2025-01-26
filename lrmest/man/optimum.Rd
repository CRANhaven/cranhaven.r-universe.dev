\name{optimum}
\alias{optimum}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Summary of optimum scalar Mean Square Error values of all estimators and optimum Prediction Sum of Square values of some of the estimators
}
\description{
\code{optimum} can be used to obtain the optimal scalar Mean Square Error (MSE) values and its corresponding parameter values (\code{k} and/or \code{d}) of all estimators and the optimum Prediction Sum of Square (PRESS) values and its corresponding parameter values \code{k} and \code{d} of some of the estimators considered in this package.
}
\usage{
optimum(formula , r, R, dpn, delt, aa1, aa2, aa3, k, d, 
        press = FALSE, data = NULL, na.action, ...)                     
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
  \item{aa1}{
adjusted parameters of Type (1) Adjusted Liu Estimators and that should be a set of scalars belongs to real number system. Values for \dQuote{aa1} should be given as a \code{\link{vector}}, format. See \sQuote{Details}.
}
  \item{aa2}{
adjusted parameters of Type (2) Adjusted Liu Estimators and that should be a set of scalars belongs to real number system. Values for \dQuote{aa2} should be given as a \code{\link{vector}}, format. See \sQuote{Details}.
}
  \item{aa3}{
adjusted parameters of Type (3) Adjusted Liu Estimators and that should be a set of scalars belongs to real number system. Values for \dQuote{aa3} should be given as a \code{\link{vector}}, format. See \sQuote{Details}.
}
  \item{k}{
a vector of set of numeric values. See \sQuote{Examples}.
}
  \item{d}{
a vector of set of numeric values. See \sQuote{Examples}.
}
  \item{press}{
an optional object specifying the PRESS values. That is, if \dQuote{press=TRUE} then summary of PRESS of some of the estimators are returned with corresponding \code{k} and \code{d} values. Otherwise summary of scalar MSE of all estimators are returned with corresponding \code{k} and/or \code{d} values.
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

Optimum scalar MSE values of all estimators can be found for a given range of parameters. Hence the best estimator can be found based on the MSE criteria. Further prior information should be given in order to obtained the results.\cr

The way of finding \code{aa1}, \code{aa2} and \code{aa3} can be determined from Rong,Jian-Ying, (2010), \emph{Adjustive Liu Type Estimators in linear regression models} in \emph{communication in statistics-simulation and computation}, volume \bold{39}\cr
}
\value{
By default, \code{optimum} returns the optimum scalar MSE values and corresponding parameter values of all estimators. If \dQuote{press=TRUE} then \code{optimum} return the optimum PRESS values and corresponding parameter values of some of the estimators.
}
%\references{
%% ~put references to the literature/web site here ~
%}
\author{
P.Wijekoon, A.Dissanayake
}
\note{
Conversion of estimators and corresponding \code{k} and/or \code{d} values are given below.\cr

\code{SRRE     =     MIXE     k=0}\cr
\code{OGSRRE     =     MIXE     k=0}\cr
\code{RE       =     OLS      k=0}\cr
\code{OGRE       =     OLS      k=0}\cr
\code{RLE      =     RLS      d=1}\cr
\code{OGRLE      =     RLS      d=1}\cr
\code{LE       =     OLS      d=1}\cr
\code{OGLE     =     OLS     d=1}\cr
\code{RRRE     =     RLS      k=0}\cr
\code{OGRRRE     =     RLS      k=0}\cr  
\code{SRLE     =     MIXE     d=1}\cr   
\code{OGSRLE     =     MIXE     d=1}\cr  
\code{AURE     =     OLS      k=0}\cr
\code{OGAURE     =     OLS      k=0}\cr
\code{AULE     =     OLS      d=1}\cr
\code{OGAULE     =     OLS      d=1}\cr
\code{LTE1     =     RE       d=0}\cr
\code{OGLTE1     =     RE       d=0}\cr
\code{LTE1     =     OLS      k=0 and d=0}\cr
\code{OGLTE1     =     OLS      k=0 and d=0}\cr
\code{LTE2     =     RE       d=0}\cr
\code{OGLTE2     =     RE       d=0}\cr
\code{LTE2     =     OLS      k=0 and d=0}\cr
\code{OGLTE2     =     OLS      k=0 and d=0}\cr
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%}
\examples{
## portland cement data set is used.
data(pcd)
attach(pcd)
k<-c(0:3/10)
d<-c(-3:3/10)
r<-c(2.1930,1.1533,0.75850)
R<-c(1,0,0,0,0,1,0,0,0,0,1,0)
dpn<-c(0.0439,0.0029,0.0325)
delt<-c(0,0,0)
aa1<-c(0.958451,1.021155,0.857821,1.040296)
aa2<-c(0.345454,1.387888,0.866466,1.354454)
aa3<-c(0.344841,1.344723,0.318451,1.523316)
optimum(Y~X1+X2+X3+X4-1,r,R,dpn,delt,aa1,aa2,aa3,k,d,data=pcd)   
 # Model without the intercept is considered.
    ## Use "press=TRUE" to get the optimum PRESS values only for some of the estimators.
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
