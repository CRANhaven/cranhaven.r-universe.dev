\name{ridittools-package}
\alias{ridittools-package}
\alias{ridittools}
\docType{package}
\title{
\packageTitle{ridittools}
}
\description{
\packageDescription{ridittools}
}
\details{

The DESCRIPTION file:
\packageDESCRIPTION{ridittools}
\packageIndices{ridittools}
}
\author{
\packageAuthor{ridittools}

Maintainer: \packageMaintainer{ridittools}
}
\references{
Fleiss, Joseph L., (1981), Statistical Methods for Rates and Proportions. New York: John Wiley & Sons.
}
\keyword{ package }
%%\seealso{
%%}
\examples{
ref <- acc[ , 1]
toridit(ref)
g <- acc[ , 2]
meanridit(g, ref)
seridit(g, ref)
meanridits(flu.age, 2, "H3")
meanridits(flu.age, 2) # Uses group totals as reference
seridits(handgun, 2, 1)
}
