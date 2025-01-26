\name{geneSetDetail}
\alias{geneSetDetail}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
Gain insight into the detail of the genes in a certain pathway
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
Gain insight into the detail of the genes in a certain pathway, inculding the ranks, weights and cummulative running scores of each gene.
}
\usage{
geneSetDetail(Result, Name)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Result}{
%%     ~~Describe \code{Result} here~~
	A lncPath object come from the lncPath function.
}
  \item{Name}{
%%     ~~Describe \code{Name} here~~
	A string, the name of the pathway to be print.
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
List all the genes of pathways ranked by the weights. The table also contains the gene name, the rank of genes in the whole gene list, the cumulative ES score and whether the gene is in the core gene sets which contribute to the score of the pathway.
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
A data frame, the rows are gene names and the columns are detail of genes including gene name, rank, weight, cumulative ES score and core erichment.
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
Detail <- geneSetDetail(Result, "KEGG_RIBOSOME")
head(Detail)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
