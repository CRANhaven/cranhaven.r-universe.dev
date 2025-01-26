\name{getExampleData}
\alias{getExampleData}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Get the example data
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
Get the example data of LncPath package for litte trials.
}
\usage{
getExampleData(ExampleData)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{ExampleData}{
%%     ~~Describe \code{ExampleData} here~~
	A character, should be one of "SigLncs", "ExampleNet", "Labels", "Profile", "Result" and "Table".
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
	The function getExampleData(ExampleData = "SigLncs") obtains a vector of lncRNAs confirmed to be related with breast cancer.
	The function getExampleData(ExampleData = "Profile") obtains the expression profile as a data frame.
	The function getExampleData(ExampleData = "Labels") obtains a vector of 0/1s describing the class of samples in the expression profile.
	The function getExampleData(ExampleData = "Result") obtains a lncPath object come from the lncPath function.
	The function getExampleData(ExampleData = "Table") obtains a data frame as the summary of lncPath object.
	The function getExampleData(ExampleData = "ExampleNet") obtains a data frame as the edges of lncRNA-mRNA interaction net.
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


% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
