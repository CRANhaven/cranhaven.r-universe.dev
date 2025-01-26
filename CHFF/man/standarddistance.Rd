\name{standarddistance}
\alias{standarddistance}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Calculates Standard Distance Score
}
\description{
For each history we calculate the standard distance score between the current history and all histories
}
\usage{
standarddistance(char,History,hlength)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{char}{
The number iof characteristics to consider when searching for the ''closest'' history. 16 is the complete set of possible characters, 14 leaves off the x and y posistions on uses 7 x slopes and 7 y slopes only.
}
  \item{History}{
The history space
}
  \item{hlength}{
The length of the history space.
}
}

\value{
Returns the winning Score, the structures used in the winning score, and the winning history

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
