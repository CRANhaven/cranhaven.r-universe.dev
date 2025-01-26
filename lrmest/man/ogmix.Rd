\name{ogmix}
\alias{ogmix}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Ordinary Generalized Mixed Regression Estimator
}
\description{
\code{ogmix} can be used to obtain the Mixed Regression Estimated values and corresponding scalar Mean Square Error (MSE) value.
}
\usage{
ogmix(formula, r, R, dpn, delt, data, na.action, ...)
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

In order to calculate the Ordinary Generalized Mixed Regression Estimator the prior information are required. Therefore those prior information should be mentioned within the function.
}
\value{
\code{ogmix} returns the Ordinary Generalized Mixed Regression Estimated values, standard error values, t statistic values,p value and corresponding scalar MSE value.
}
\references{
Arumairajan, S. and Wijekoon, P. (2015) ] \emph{Optimal Generalized Biased Estimator in Linear Regression Model} in \emph{Open Journal of Statistics}, pp. 403--411\cr

Theil, H. and Goldberger, A.S. (1961) \emph{On pure and mixed statistical estimation in economics} in \emph{International Economic review}, volume \bold{2}, pp. 65--78
}
\author{
P.Wijekoon, A.Dissanayake
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%}
\examples{
## Portland cement data set is used.
data(pcd)
r<-c(2.1930,1.1533,0.75850)
R<-c(1,0,0,0,0,1,0,0,0,0,1,0)
dpn<-c(0.0439,0.0029,0.0325)
delt<-c(0,0,0)
ogmix(Y~X1+X2+X3+X4-1,r,R,dpn,delt,data=pcd)  
# Model without the intercept is considered.
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
