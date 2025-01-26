\name{swan_efficiency}
\alias{swan_efficiency}
\title{
Impact on fareness when a node is removed
}
\description{
Swan_efficiency measures the change in the sum of distances between all node pairs when excluding that node.
}
\usage{
swan_efficiency(g)
}
\arguments{
  \item{g}{The graph to analyze. Graph builds with igraph.
}
}
\details{
The easiest way for studying network vulnerability and identifying most critical components is to assess network disruptions due to a single component breakdown without taking into account cascading failures. 
This kind of measures can be used to determine the importance of nodes or edges in a graph and may be considered as centrality indices. 
In this context, one indicator is chosen to assess global network performance. 
For instance, two common indices are used to assess transportation network performance: closeness accessibility and geographic accessibility.
Swan_efficiency is based on geographic accessibility. 
So, swan_efficiency measures the change in the sum of distances between all node pairs when excluding that node.
}
\value{
Numeric vector with the swan_efficiency values of all the vertices.
}
\references{
Lhomme S., 2015, Analyse spatiale de la structure des reseaux techniques dans un contexte de risques, Cybergeo : European Journal of Geography 
}
\author{
Serge Lhomme
}

\examples{
library(igraph)
library(NetSwan)
elec <- matrix(nc=2, byrow=TRUE, c(11,1, 11,10, 1,2, 2,3, 2,9, 
3,4, 3,8, 4,5, 5,6, 5,7, 6,7, 7,8, 8,9, 9,10))
gra<-graph.edgelist(elec, directed=FALSE)

f2<-swan_closeness(gra)
bet<-betweenness(gra)
reg<-lm(bet~f2)
summary(reg)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
