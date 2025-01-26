\name{seridits}
\alias{seridits}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Compute standard errors of mean ridits of multiple groups
%%  ~~function to do ... ~~
}
\description{
Takes the same data as \code{meanridits()}, bui returns standard errors rather than means.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
seridits(x, margin, ref = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
  same as for \code{meanridits()}, but must be counts rather than proportions
%%     ~~Describe \code{x} here~~
}
  \item{margin}{
  same as for \code{meanridits()}
%%     ~~Describe \code{margin} here~~
}
  \item{ref}{
  same as for \code{meanridits()}
%%     ~~Describe \code{ref} here~~
}
}
\details{
note that if the results include the reference group, its standard error will
not be meaningful; by definition its mean ridit will be exactly 0.5
%%  ~~ If necessary, more details than the description above ~~
}
\value{
a vector of standard errors for each group's mean ridits
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\author{
Eric Bohlman
%%  ~~who you are~~
}
%%\note{
%%  ~~further notes~~
%%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{meanridits}}
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
(meanridits(semiauto, 2, 1) - 0.5) / seridits(semiauto, 2, 1)

## The function is currently defined as
function (x, margin, ref = NULL)
{
    apply(x, margin, se.ridit, riditsrefgroup(x, margin, ref))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
