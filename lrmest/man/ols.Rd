\name{ols}
\alias{ols}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Ordinary Least Square Estimators
}
\description{
\code{ols} can be used to calculate the values of Ordinary Least Square Estimated values and corresponding scaler Mean Square Error (MSE) value.
}
\usage{
ols(formula, data, na.action, ...)
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

If there is any dependence present among the independent variables (multicollinearity) then it will be indicated as a warning massage. In case of multicollinearity Ordinary Least Square Estimators are not the best estimators.
}
\value{
\code{ols} returns the Ordinary Least Square Estimated values, standard error values, t statistic values,p value and corresponding scalar MSE value. In addition if the dataset contains multicollinearity then it will be indicated as a warning massage.
}
\references{
Nagler, J. (Updated 2011) Notes on Ordinary Least Square Estimators.
}
\author{
P.Wijekoon, A.Dissanayake
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{checkm}}
}
\examples{
## Portland cement data set is used.
data(pcd)
ols(Y~X1+X2+X3+X4-1,data=pcd)    # Model without the intercept is considered.
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
