\name{SI.SSM}
\alias{SI.SSM}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Stratified Sampling Method
%%  ~~function to do ... ~~
}
\description{
Stratified Sampling Method
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
SI.SSM(h, from, to, level, N)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{h}{
%%     ~~Describe \code{h} here~~
Density function to be integrated
}
  \item{from}{
%%     ~~Describe \code{from} here~~
The start point
}
  \item{to}{
%%     ~~Describe \code{to} here~~
The end point
}
  \item{level}{
%%     ~~Describe \code{level} here~~
Stratification, number of intervals
}
  \item{N}{
%%     ~~Describe \code{N} here~~
The number of trials
}
}
\value{
\item{I }{Approximated integration}
\item{Var }{Estimated variance}
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\examples{
## To integrate exp(x) from -1 to 1
set.seed(0)
h <- function(x){
    exp(x)
}
N <- 100000
SSMresult <- SI.SSM(h,-1,1,10,N)
I4 <- SSMresult[[1]]
VarI4 <- SSMresult[[2]]
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
