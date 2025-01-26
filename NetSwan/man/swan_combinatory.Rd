\name{swan_combinatory}
\alias{swan_combinatory}
\title{Error and attack tolerance of complex networks
}
\description{
Swan_combinatory assesses networks vulnerability, resistance of networks to the removal of nodes, due either to random breakdowns or to intentional attacks. 
}
\usage{
swan_combinatory(g, k)
}
\arguments{
  \item{g}{The graph to analyze. Graph builds with igraph.
}
  \item{k}{Number of iterations for assessing random error. 
}
}
\details{
Many complex systems display a surprising degree of tolerance against errors. 
However, error tolerance comes at a high price in that these networks are extremely vulnerable to attacks (that is, to the selection and removal of a few nodes that play a vital role in maintaining the network's connectivity).
Swan_combinatory removes nodes one by one, first randomly, then in the decreasing order of their degree or load (betweenness).
Finally, swan_combinatory uses a cascading scenario, where the loads (betweenness) are recalculated after each node removed.
}
\value{
Matrices corresponding to the loss of connectivity for different strategies. First column corresponds to the fraction of nodes removed. Second column corresponds to the loss of connectivity induced by betweenness based attack. 
Third column corresponds to the loss of connectivity induced by degree based attack. Fourth column corresponds to the loss of connectivity induced by cascading attack.
Fifth column corresponds to the loss of connectivity induced by random error.
}
\references{
Albert R., Jeong H., Barabasi A., 2000, Error and attack tolerance of complex networks, Nature, 406(6794), pp. 378-382. 
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

f4<-swan_combinatory(gra,10)
plot(f4[,1],f4[,5], type='o', col='yellow',xlab="Fraction of nodes removed",
       ylab="Connectivity loss")
lines(f4[,1],f4[,3], type='o', col='red')
lines(f4[,1],f4[,4], type='o', col='orange')
lines(f4[,1],f4[,2], type='o', col='blue')
legend('bottomright',c("Random", "Betweenness", "Degree", "Cascading"), 
           lty=c(1,1,1,1), pch=c(1,1,1,1), 
           col=c("yellow","blue","red", "orange"))
}
