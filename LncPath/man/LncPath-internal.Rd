
\name{LncPath-internal}
\alias{initializeLncPathEnvir}
\alias{Getenvir}
\alias{rw}
\alias{RandomWalk2igraph}
\alias{lncPath.HeatMapPlot}
\alias{lncPath.EnrichmentScore}
\alias{lncPath.EnrichmentScore2}
\alias{ESNorm}
\alias{calT}
\alias{calFD}

\title{LncPath internal functions}
\description{
  These functions internally called by other functions in the package \code{LncPath} and not meant to be called by the user.
}

\usage{

    initializeLncPathEnvir()
    rw(W, p0, gamma)
    RandomWalk2igraph(igraphM, VertexWeight, EdgeWeight = TRUE, gamma = 0.7)
    lncPath.HeatMapPlot(V, row.names = F, col.labels, col.classes, 
	col.names = F, main = " ", xlab = " ", ylab = " ")
    lncPath.EnrichmentScore(gene.list, gene.set, weighted.score.type = 1, 
	correl.vector = NULL)
    lncPath.EnrichmentScore2(gene.list, gene.set, weighted.score.type = 1, 
	correl.vector = NULL)
    ESNorm(ESs)
    calT(inData, classLabel)
    calFD(inData, classLabel)

}

\author{Junwei Han <hanjunwei1981@163.com>, Zeguo Sun <zeguo.sun@163.com>} 

\keyword{internal}

