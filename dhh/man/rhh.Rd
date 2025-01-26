\name{rhh}
\alias{rhh}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Random Variables of Of The Heavy-Headed Distribution
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
This function generate i.i.d. random variables following the heavy-headed distribution.
}
\usage{
rhh(n, a = 0, b = 1, alpha = 0.1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n}{
%%     ~~Describe \code{n} here~~
It is the number of the random variables.
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
It returns a vector of n random varialbes following the heavy-headed distribution.
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
\code{\link{dhh}} \code{\link{phh}} \code{\link{qhh}}
}
\examples{
rhh(1)

rhh(2)

hist(rhh(10000), freq=FALSE)

curve(dhh, add = TRUE, col = 2)

dhh(c(0.1, 0.01, 0.001, 0.0001, 0.00001))
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
