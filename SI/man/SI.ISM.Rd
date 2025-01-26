\name{SI.ISM}
\alias{SI.ISM}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Important Sampling Method
%%  ~~function to do ... ~~
}
\description{
Important Sampling Method
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
SI.ISM(h, g, G_inv, N, min_G = 0, max_G = 1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{h}{
Density function to be integrated
%%     ~~Describe \code{h} here~~
}
  \item{g}{
Sampling density function
%%     ~~Describe \code{g} here~~
}
  \item{G_inv}{
%%     ~~Describe \code{G_inv} here~~
The inverse function of sampling distribution function
}
  \item{N}{
%%     ~~Describe \code{N} here~~
The number of trials
}
  \item{min_G}{
%%     ~~Describe \code{min_G} here~~
The min value of G
}
  \item{max_G}{
%%     ~~Describe \code{max_G} here~~
The max value of G
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
## Use the sampling density (3/2+x)/3
set.seed(0)
h <- function(x){
    exp(x)
}
N <- 100000
g <- function(x){return((3/2+x)/3)}
G_inv <- function(y){return(sqrt(6*y+1/4)-3/2)}
ISMresult <- SI.ISM(h,g,G_inv,N)
I3 <- ISMresult[[1]]
VarI3 <- ISMresult[[2]]
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ISM }% use one of  RShowDoc("KEYWORDS")
