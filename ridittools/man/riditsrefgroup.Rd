\name{riditsrefgroup}
\alias{riditsrefgroup}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Utility to determine reference group. Primarily for internal use/
%%  ~~function to do ... ~~
}
\description{
For internal use.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
riditsrefgroup(x, margin, ref = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
  matrix of counts or proportions
%%     ~~Describe \code{x} here~~
}
  \item{margin}{
  margin that represents groups. 1 for rows, 2 for columns
%%     ~~Describe \code{margin} here~~
}
  \item{ref}{
  group to use as reference. if omitted, use totals across groups. if a vector, use it. otherwise
  use the group with its number (or name if available)
%%     ~~Describe \code{ref} here~~
}
}
\value{
vector of counts/proportions to use as reference group
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

%% ~Make other sections like Warning with \section{Warning }{....} ~

%%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%%}
\examples{
## The function is currently defined as
function (x, margin, ref = NULL)
{
    if (length(ref) > 1) {
        refgroup <- ref
    }
    else if (length(ref) == 1) {
        if (margin == 1) {
            refgroup <- x[ref, ]
        }
        else {
            refgroup <- x[, ref]
        }
    }
    else {
        refgroup <- apply(x, 3 - margin, sum)
    }
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
