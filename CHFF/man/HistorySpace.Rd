\name{historyslopes}
\alias{historyslopes}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
History of Slopes
}
\description{
Extracts the history space for a given time series
}
\usage{
historyslopes(x,y,step,ave)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
x values for the time series
}
  \item{y}{
y values for the time series
}


  \item{step}{
The lags in past slopes used in the given history
}
  \item{ave}{
Then number of time step the slope are averaged over. We recomend 1 or step which is the lags in the slopes.
}
}
\value{
Returns the history space in matrix form 16X(datalength-7*step), with the most recent history at the bottom.
}
\references{
Caudle, KA, Fleming, PS, Frey, MR and Brubaker, N. "Next Generation of Flow Field Forecasting", Proceedings of the Joint Statistical Meetings of the American Statistical Association, Seattle, WA., 8 August-13 August (2015).

Frey, Michael R., and Kyle A. Caudle. "Flow field forecasting for univariate time series." Statistical Analysis and Data Mining (2013).
}
\author{
Patrick Fleming
}


%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
data(tsdata) # Load time series data int R
CHFF(tsdata,10,3)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
