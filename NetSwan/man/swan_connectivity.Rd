\name{swan_connectivity}
\alias{swan_connectivity}
\title{
Impact on connectivity when a node is removed
}
\description{
Swan_connectivity measures the loss of connectivity when excluding a node.
}
\usage{
swan_connectivity(g)
}
\arguments{
  \item{g}{The graph to analyze. Graph builds with igraph.
}
}
\details{
Connectivity loss indices quantify the decrease in the number of relationships between each node when one or several components are removed.
Swan_connectivty measures the loss of connectivity when excluding a node.
}
\value{
Numeric vector with the swan_connectivity values of all the vertices.
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

f3<-swan_connectivity(gra)
}
