\name{drawAHeatMap}
\alias{drawAHeatMap}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Draw a heatmap for the genes of a pathway
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
Draw a heatmap for the genes of a certain pathway based on the expression profile user specified.
}


\usage{
drawAHeatMap(Result, Name, PCExpr, Labels)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Result}{
%%     ~~Describe \code{Result} here~~
	A lncPath object come from the lncPath function.
}
  \item{Name}{
%%     ~~Describe \code{Name} here~~
	A string, the name of the pathway to be plot.
}
  \item{PCExpr}{
%%     ~~Describe \code{PCExpr} here~~
	A data frame, the expression profile to be plotted.
}
  \item{Labels}{
%%     ~~Describe \code{Labels} here~~
	A vector of 0 and 1, 0 indicates control and 1 indicates case.
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
Draw a heatmap of the genes of a pathway based on the expression profile. The rows of heatmap are genes ranked by their weights and the columns of heatmap are samples ordered the same as the expression profile. 
}
\references{
%% ~put references to the literature/web site here ~
Subramanian, A., Tamayo, P., Mootha, V.K., Mukherjee, S., Ebert, B.L., Gillette, M.A., Paulovich, A., Pomeroy, S.L., Golub, T.R., Lander, E.S. et al. (2005) Gene set enrichment analysis: a knowledgebased approach for interpreting genome-wide expression profiles. Proc Natl Acad Sci U S A, 102, 15545-15550.
}
\author{
%%  ~~who you are~~
Junwei Han <hanjunwei1981@163.com>, Zeguo Sun <zeguo.sun@163.com>
}

\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

Result <- getExampleData("Result")
Profile <- getExampleData("Profile")
Labels <- getExampleData("Labels")
drawAHeatMap(Result, "KEGG_RIBOSOME", Profile, Labels)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
