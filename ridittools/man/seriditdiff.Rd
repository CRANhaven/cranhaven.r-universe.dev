\name{seritdiff}
\alias{seriditdiff}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Compute standard error of difference between two mean ridits
%%  ~~function to do ... ~~
}
\description{
Computes the approximate standard error of the difference between the mean ridits of
two groups. This does not depend on the reference group the mean ridits are relative to, only on the sizes of the two groups.
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
seriditdiff(g1, g2)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{g1}{
  vector of counts (not ridits) for first group
%%     ~~Describe \code{x} here~~
}
\item{g2}{
  vector of counts (not ridits) for second group
%%     ~~Describe \code{x} here~~
}
}
\details{
the order of the two groups doesn't matter.
%%  ~~ If necessary, more details than the description above ~~
}
\value{
approximate standard error of difference between mean ridits
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
Fleiss, J.,L., (1981), Statistical Methods for Rates and Proportions. New York: John Wiley & Sons., p. 155
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
seriditdiff(semiauto[ , "Ind"], semiauto[ , "Rep"])

## The function is currently defined as
function(g1, g2) {
  sqrt(sum(g1) + sum(g2)) / (2 * sqrt(3 * sum(g1) * sum(g2)))
}
}