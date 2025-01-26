\name{SI.SPM}
\alias{SI.SPM}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Stochastic Point Method
%%  ~~function to do ... ~~
}
\description{Stochastic Point Method
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
SI.SPM(h, from, to, M, N)
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
  \item{M}{
%%     ~~Describe \code{M} here~~
The upper bound of h(x) in [from,to]
}
  \item{N}{
%%     ~~Describe \code{N} here~~
The number of trials
}
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
\item{I }{Approximated integration}
\item{Var }{Estimated variance}
%% ...
}
\examples{
## To integrate exp(x) from -1 to 1
set.seed(0)
h <- function(x){
    exp(x)
}
N <- 100000
SPMresult <- SI.SPM(h,-1,1,exp(1),N)
I1 <- SPMresult[[1]]
VarI1 <- SPMresult[[2]]
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ SPM }% use one of  RShowDoc("KEYWORDS")
