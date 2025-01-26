\name{CHFF}
\alias{CHFF}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Closest History Flow Field Forecasting for Bivariate Time Series
}
\description{
Matches the current history with the ``closest'' history for a given time series.  A forecast will be based on what happened after the ``closest'' history was observed.
}
\usage{
CHFF(data,num,step)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{
Time series data
}
  \item{num}{
Number of forecasts produced
}


  \item{step}{
Step size (or lag) in past slopes used in the history structure
}

}

\value{
Prints the (x,y) forecast values and provides a plot
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
\keyword{Time Series }
\keyword{Forecasting }% __ONLY ONE__ keyword per line
