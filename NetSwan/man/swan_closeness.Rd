\name{swan_closeness}
\alias{swan_closeness}
\title{
Impact on closeness when a node is removed
}
\description{
Swan_closeness measures the change in the sum of the inverse of distances between all node pairs when excluding that node.
}
\usage{
swan_closeness(g)
}
\arguments{
  \item{g}{The graph to analyze. Graph builds with igraph.
}
}
\details{
Components can be disconnected when a node is removed from a network.
Closenness can defined as the inverse of farness, which in turn, is the sum of distances to all other nodes. 
Nevertheless, as the distance between nodes in disconnected components of a network is infinite, this measure cannot be applied to networks with disconnected components (indeed the sum of distances to all other nodes is infinite).
Thus it is possible to define the closeness equation as the sum of inversed distances to all other nodes (instead of the inversed of the sum of distances to all other nodes).
So swan_closeness measures the change in the sum of the inverse of distances between all node pairs when excluding that node.
}
\value{
Numeric vector with the swan_closeness values of all the vertices.
}
\references{
Lhomme S., 2015, Analyse spatiale de la structure des reseaux techniques dans un contexte de risques, Cybergeo : European Journal of Geography.
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