\name{ogols}
\alias{ogols}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Ordinary Generalized Ordinary Least Square Estimators
}
\description{
\code{ogols} can be used to calculate the values of Ordinary Generalized Ordinary Least Square Estimated values and corresponding scaler Mean Square Error (MSE) value.
}
\usage{
ogols(formula, data, na.action, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{formula}{
in this section interested model should be given. This should be given as a \code{\link{formula}}.
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
}
\value{
\code{ogols} returns the Ordinary Generalized Ordinary Least Square Estimated values, standard error values, t statistic values,p value and corresponding scalar MSE value. 
}
\references{
Arumairajan, S. and Wijekoon, P. (2015) ] \emph{Optimal Generalized Biased Estimator in Linear Regression Model} in \emph{Open Journal of Statistics}, pp. 403--411\cr

Nagler, J. (Updated 2011) Notes on Ordinary Least Square Estimators.
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
ogols(Y~X1+X2+X3+X4-1,data=pcd)     
# Model without the intercept is considered.
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
