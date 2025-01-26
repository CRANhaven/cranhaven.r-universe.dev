\name{lncPath}
\alias{lncPath}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Identify pathways synergisticly regulated by lncRNA sets.
}
\description{
Identify pathways synergisticly regulated by lncRNA sets by combining the random walk strategy and weighted Kolmogorov-Smirnov statistic based on a huge lncRNA-mRNA interaction network.
}
\usage{
lncPath(LncRNAList, Network, Weighted = TRUE, PathwayDataSet = "KEGG", 
	minPathSize = 15, maxPathSize = 500, nperm = 1000)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{LncRNAList}{
%%     ~~Describe \code{LncRNAList} here~~
	A character vector, contains the user interested lncRNAs, the ID of lncRNAs should be the Ensembl ID .
}
\item{Network}{
%%     ~~Describe \code{Network} here~~
	A dataframe with two columns, describing the edges of the network to perform the random walk.
}
  \item{Weighted}{
%%     ~~Describe \code{Weighted} here~~
	Logical, tell if a weighted analysis to be performed, see detail.
}
  \item{PathwayDataSet}{
%%     ~~Describe \code{PathwayDataSet} here~~
	A character, tells which pathway database is to be used, should be one of "KEGG", "Reactome" and "BioCarta".
}
  \item{minPathSize}{
%%     ~~Describe \code{minPathSize} here~~
	An integer, the lower limit of the mapped genes in pathway.
}
  \item{maxPathSize}{
%%     ~~Describe \code{maxPathSize} here~~
	An integer, the upper limit of the mapped genes in pathway.
}
  \item{nperm}{
%%     ~~Describe \code{nperm} here~~
	An integer, how manny times of perturbation to be performed in the perturbation analysis.
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
	lncPath is the main function of lncPath package, it takes a list of interested lncRNAs and a lncRNA-mRNA interaction network as input. Then it maps the lncRNAs into the lncRNA-mRNA interaction network as seed nodes and performs a random walk strategy to evaluate the rate of noedes effected by the seed nodes. A weighted Kolmogorov-Smirnov statistic was finnally used to evaluate the pathways related to the lncRNA sets.
	If the Weighted parameter is set to TRUE, the scores of mRNAs generated from random walk will be treated as the weight in Kolmogorov-Smirnov statistic.If the Weighted parameter is set to FALSE, only the ranks of mRNAs will be taken into consideration.
	Now three pathway data sets are surpported, includeing the KEGG, Reactome and BioCarta. And pathways with number of genes out of the limit will be filtered.
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
A lncPath object, containing the details of each pathways: pathway ID, pathway name, number of genes, gene names, score of genes etc.
It can be summarized by function by function lncPath2Table and can be visualized by function plotRunningES.

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
## get example data
SigLncs <- getExampleData("SigLncs")
head(SigLncs)

ExampleNet <- getExampleData("ExampleNet")
head(ExampleNet)

##run lncPath
Result <- lncPath(SigLncs, ExampleNet,  Weighted = TRUE, PathwayDataSet = "KEGG", nperm = 100,
 minPathSize = 0, maxPathSize = 500)

## Print to table
Table <- lncPath2Table(Result)
head(Table)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
