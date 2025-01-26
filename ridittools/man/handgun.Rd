\name{handgun}
\alias{handgun}
\docType{data}
\title{
Favorability of handgun ban by party
%%   ~~ data name/kind ... ~~
}
\description{
Likert ratings of American favorability toward a handgun ban, cross-tabulated by political party identification.
%%  ~~ A concise (1-5 lines) description of the dataset. ~~
}
\usage{handgun}
\format{
5x4 matrix of counts; rows are ratings, first column is total responses,
remaining columns are Democrats, independents, and Republicans.
}
\details{
These data were originally specified as proportions and were derived by multiplication by
sample sizes. As such, the first column slightly differs, due to rounding error, from the row sums of the remaining columns.
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
YouGov poll of 1500 adult Americans, Feb. 25-27 2018
%%  ~~ reference to a publication or URL from which the data were obtained ~~
}
\examples{
handgun
}
\keyword{datasets}
