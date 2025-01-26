\name{plotRunningES}
\alias{plotRunningES}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Visualize the Kolmogorov-Smirnov running score of pathway
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
Visualize the Kolmogorov-Smirnov running score of each gene of a certain pathway
}
\usage{
plotRunningES(Result, Name)
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
}
\details{
%%  ~~ If necessary, more details than the description above ~~
Plot the KS-statistic running score of certain pathway. The plot has three sections, the top section is a curve describes the cumulative ES score of pathway through all coding genes. The middle section contains signals telling which gene is in the pathway. The bottom section describes the weight distribution of genes. 
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

Result <- getExampleData("Result")
plotRunningES(Result, "KEGG_RIBOSOME")

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
