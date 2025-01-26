\name{findSigGenes}
\alias{findSigGenes}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Find genes significantly differentially expressed between two conditions.
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
For a given expression profile of two conditions, find the genes differencially expressed using T-test, fold change or SAM algorithm.
}
\usage{
findSigGenes(Expr, Label, Method = "tTest", Directed = TRUE, 
	FdrCut = 0.01, FDCut = 1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Expr}{
%%     ~~Describe \code{Expr} here~~
	A data frame, the expression profile to find differentially expressed genes, the rownames should be the ID of genes.
}
  \item{Label}{
%%     ~~Describe \code{Label} here~~
	A vector of 0/1s, indicating the class of samples in the expression profile, 0 represents case, 1 represents control.
}
  \item{Method}{
%%     ~~Describe \code{Method} here~~
	A string, specifying the method to calculate the differentially expressed genes, should be one of the "tTest"or"foldChange".
}
  \item{Directed}{
%%     ~~Describe \code{Directed} here~~
	Logical, if the the up or down regulated set should be distinguished.
}
  \item{FdrCut}{
%%     ~~Describe \code{FdrCut} here~~
	Numeric, the fdr cutoff for T test, can be ignored if not using t-test.
}
  \item{FDCut}{
%%     ~~Describe \code{FDCut} here~~
	Numeric, the cutoff for fold change, can be ignored if not using fold change.
}
 

}
\details{
%%  ~~ If necessary, more details than the description above ~~
For a given expression profile of two conditions, lncPath package provide two method to find differentially expressed genes: t-text and fold change. The row of the expression profile should be gene IDs and the column of the expression profile should be names of samples. Samples should be under two conditions and the label should be given as 0 and 1. For t-test, fold change and SAM, different threshold can be set for significant differentially expressed genes.  
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
A vector of strings, the IDs of differentially expressed genes.
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
Profile <- getExampleData("Profile")
Labels <- getExampleData("Labels")

SigGenes <- findSigGenes(Profile, Labels)
head(SigGenes)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
