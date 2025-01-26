\name{checkm}
\alias{checkm}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Check the degree of multicollinearity present in the dataset
}
\description{
Degree of multicollinearity present in the dataset can be determined by using two type of indicators, called VIF and Condition Number.
}
\usage{
checkm(formula, data, na.action, ...)
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
If all the values of VIF > 10 implies that multicollinearity present.\cr
If condition number < 10 ; There is not multicollinearity.\cr
30 < condition number < 100 ; There is a multicollinearity.\cr
condition number >100 ; Severe multicollinearity.\cr
}
\value{
\code{checkm} returns the values of two multicllinearity indicators VIF and Condition Number.
}
%\references{
%% ~put references to the literature/web site here ~
%}
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
checkm(Y~X1+X2+X3+X4,data=pcd)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
