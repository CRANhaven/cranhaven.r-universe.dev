\name{seridit}
\alias{seridit}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Compute standard error of mean ridit for group given reference group
%%  ~~function to do ... ~~
}
\description{
Given a vector of counts for a group and a vector of counts for a reference group, computes the
standard error of the mean ridit for the group.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
seridit(v, ref)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{v}{
  same as \code{meanridit()}, but must be counts
%%     ~~Describe \code{v} here~~
}
  \item{ref}{
  same as \code{meanridit()}, but must be counts
%%     ~~Describe \code{ref} here~~
}
}
%%\details{
%%  ~~ If necessary, more details than the description above ~~
%%}
\value{
standard error of mean ridit
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
Fleiss, J.,L., (1981), Statistical Methods for Rates and Proportions. New York: John Wiley & Sons, p. 154
%% ~put references to the literature/web site here ~
}
\author{
Eric Bohlman
%%  ~~who you are~~
}
%%\note{
%%  ~~further notes~~
%%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

%%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%%}
\examples{
# PolitiFact ratings in order of increasing truthfulness (8 Mar 2018)
obama <- c(9, 71, 70, 161, 165, 123)
trump <- c(77, 169, 114, 78, 60, 24)
# Result is approximately standard normal
(meanridit(trump, obama) - 0.5) / seridit(trump, obama)

## The function is currently defined as
function (v, ref)
{
    N <- sum(ref)
    n <- sum(v)
    term1 <- (n + 1)/N
    term2 <- 1/(N * (N + n - 1))
    term3 <- sum((ref + v)^3)/(N * (N + n) * (N + n - 1))
    (1/(2 * sqrt(3 * n))) * sqrt(1 + term1 + term2 - term3)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
