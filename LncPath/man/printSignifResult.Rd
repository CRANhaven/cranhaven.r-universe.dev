\name{printSignifResult}
\alias{printSignifResult}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Output the details of significant pathways
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
Export all of the significant pathways into a specified location.
}
\usage{
printSignifResult(Result, Threshold = 0.01, Path = ".", HeatPlot = FALSE, 
	PCExpr = "", Labels = "", Top = 0)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Result}{
%%     ~~Describe \code{Result} here~~
	A lncPath object come from the lncPath function.
}
  \item{Threshold}{
%%     ~~Describe \code{Threshold} here~~
	Numeric, the FDR threshold for selecting signifcant pathways.
}
  \item{Path}{
%%     ~~Describe \code{Path} here~~
	String, the output directory.
}
  \item{HeatPlot}{
%%     ~~Describe \code{HeatPlot} here~~
	Logical, should the heatmaps be plotted.
}
  \item{PCExpr}{
%%     ~~Describe \code{PCExpr} here~~
	A data frame, represents the expression profile of genes, the rownames must be gene names, must be set if HeatPlot is TRUE.
}
  \item{Labels}{
%%     ~~Describe \code{Labels} here~~
	A vector of 0 and 1, 0 indicates control and 1 indicates case.
}
  \item{Top}{
%%     ~~Describe \code{Top} here~~
	An integer, indicates the number of the most significant pathways to be print, the Threshold will be ignored.
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
For a result from the lncPath function, pritSignifResult will output all the details of significant pathways. Significant pathways can be defined by the threshold user submit or by ranks. The detail of pathways contains the running score plot , the gene sets detail and the heatmap of each pathway. For heatmap plot , the corresponding expression profile is needed. Considering a lot of files will be output, the output directory can be specified.
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
\dontrun{
Result <- getExampleData("Result")
Profile <- getExampleData("Profile")
Labels <- getExampleData("Labels")
dir.create("Signif")
SignifReport(Result, Threshold = 0.01, Path = "Signif", HeatPlot = TRUE, Profile, Labels, Top = 30)
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
