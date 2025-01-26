\name{lncPath2Table}
\alias{lncPath2Table}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Simplify the lncPath object into table 
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
Simplify the LncPath object into a data frame, which discribes the detail imformation of each pathway.
}
\usage{
lncPath2Table(Result)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Result}{
%%     ~~Describe \code{Result} here~~
	The lncPath object come from the lncPath function.
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
The lncPath object come from the lncPath function may be too complicated for user to view. This function can simplify it into a data frame. Each row of the data frame describe the detail of one pathway, including informations of pathway name, number of genes in the pathway, enrichment scores, normalized enrichment scores, p value and false discovery rate.
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
A data frame, rows are pathways and columns are details of each pathway.
}
\references{
%% ~put references to the literature/web site here ~
Subramanian, A., Tamayo, P., Mootha, V.K., Mukherjee, S., Ebert, B.L., Gillette, M.A., Paulovich, A., Pomeroy, S.L., Golub, T.R., Lander, E.S. et al. (2005) Gene set enrichment analysis: a knowledgebased approach for interpreting genome-wide expression profiles. Proc Natl Acad Sci U S A, 102, 15545-15550.
}
\author{
%%  ~~who you are~~
Junwei Han <hanjunwei1981@163.com>, Zeguo Sun <zeguo.sun@163.com>
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
Result <- getExampleData("Result")
Table <- lncPath2Table(Result)
head(Table)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
