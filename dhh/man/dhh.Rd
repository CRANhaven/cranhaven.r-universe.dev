\name{dhh}
\alias{dhh}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Density Function Of The Heavy-Headed Distribution
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
This function gives the values of the density of the heavy-headed distribution.
}
\usage{
dhh(x, a=0, b=1, alpha=0.1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
%%     ~~Describe \code{x} here~~
x is a vector of real values, at which the values of the density will be calculated.
}
  \item{a,b}{The interval (a,b) is the support of the distribution. The default values for a and b are 0 and 1, respectively.}
  \item{alpha}{It is a positive parameter of the distribution. Its default value is set to be 0.1. When alpha = 1, the distribution is uniform. When alpha > 1, the density at a is zero.}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
See the references.
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
It returns the values of the density at x.
}
\references{
%% ~put references to the literature/web site here ~
Runlong Tang (2018) A Note On Finite Moments, Rediscovery Of The Pareto Distribution and Distributions With Heavy Tails and Heads
(v1) \url{https://sites.google.com/site/tangrunlong/notes-on-finance}
}
\author{
%%  ~~who you are~~
Runlong Tang
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
\code{\link{phh}} \code{\link{qhh}} \code{\link{rhh}}
}
\examples{
dhh(0.5)

dhh(0.5, 0, 1, 0.1)

dhh(c(0.5, 0.7))

curve(dhh, -1, 2)

curve(dhh(x, a=0, b=1, alpha=0.1), -1, 2)

curve(dhh(x, a=0, b=10, alpha=0.1), -1, 11)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
