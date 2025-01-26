\name{meanridit}
\alias{meanridit}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Compute mean ridit of group given reference group
%%  ~~function to do ... ~~
}
\description{
Compute mean ridit for a group given a reference group
}
\usage{
meanridit(v, ref)
}
\arguments{
  \item{v}{
Vector of counts or proportions
}
  \item{ref}{
Vector of counts or proportions to use as reference group
}
}
%%\details{
%%  ~~ If necessary, more details than the description above ~~
%%}
\value{
The group's mean ridit
}
\references{
Fleiss, J.,L., (1981), Statistical Methods for Rates and Proportions. New York: John Wiley & Sons., p.153
%% ~put references to the literature/web site here ~
}
\author{
Eric Bohlman
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
# Probability that a random Trump statement is at least as truthful as a random Obama statement
meanridit(trump, obama)

## The function is currently defined as
function (v, ref)
{
    sum(to.ridit(ref) * v)/sum(v)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
