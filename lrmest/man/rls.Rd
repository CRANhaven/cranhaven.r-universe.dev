\name{rls}
\alias{rls}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Restricted Least Square Estimator
}
\description{
This function can be used to find the Restricted Least Square Estimated values and corresponding scalar Mean Square Error (MSE) value.
}
\usage{
rls(formula, r, R, delt, data, na.action, ...)
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

In order to find the results of Restricted Least Square Estimator, prior information should be specified.
}
\value{
\code{rls} returns the Restricted Least Square Estimated values, standard error values, t statistic values,p value and corresponding scalar MSE value.
}
\references{
Hubert, M.H. and Wijekoon, P. (2006) \emph{Improvement of the Liu estimator in the linear regression medel}, Chapter (4-8)
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
delt<-c(0,0,0)
rls(Y~X1+X2+X3+X4-1,r,R,delt,data=pcd)    # Model without the intercept is considered.
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
