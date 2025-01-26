\name{meanridits}
\alias{meanridits}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Compute mean ridits of multiple groups
%%  ~~function to do ... ~~
}
\description{
Computes mean ridits of multiple groups in a crosstab matrix. Groups can be either rows or columns,
with the other dimension representing the response categories.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
meanridits(x, margin, ref = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
  matrix of cross-tabulated counts or proportions
%%     ~~Describe \code{x} here~~
}
  \item{margin}{
  1 for groups in rows, 2 for groups in columns
%%     ~~Describe \code{margin} here~~
}
  \item{ref}{
    if omitted, use totals across groups as reference group
  
  if vector of counts (or proportions), use as reference group
  
  otherwise, number (or name if it exists) of group to use as reference

%%     ~~Describe \code{ref} here~~
}
}
%%\details{
%%  ~~ If necessary, more details than the description above ~~
%%}
\value{
vector of mean ridits
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
\note{
using group totals as reference will not give meaningful results if data are proportions
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

%%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%%}
\examples{
meanridits(flu.age, 2)
meanridits(flu.age, 2, "H3")
meanridits(handgun, 2, 1)
meanridits(handgun, 2, rowSums(handgun[ , 2:4]))

## The function is currently defined as
function (x, margin, ref = NULL)
{
    apply(x, margin, meanridit, riditsrefgroup(x, margin, ref))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
