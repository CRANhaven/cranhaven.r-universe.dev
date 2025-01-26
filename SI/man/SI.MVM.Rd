\name{SI.MVM}
\alias{SI.MVM}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Mean Value Method
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
Mean Value Method
}
\usage{
SI.MVM(h, from, to, N)
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
MVMresult <- SI.MVM(h,-1,1,N)
I2 <- MVMresult[[1]]
VarI2 <- MVMresult[[2]]
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ MVM }% use one of  RShowDoc("KEYWORDS")
