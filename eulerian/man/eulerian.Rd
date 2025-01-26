\name{eulerian}
\alias{eulerian}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
	Method for finding an eulerian path or cycle.
}
\description{
	An eulerian path is a path in a graph which visits every edge exactly once. This function returns an eulerian path from a graph (if there is any). It works for both directed and undirected graphs. 
}
\usage{
	eulerian(graph, start = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{graph}{
	a \code{graphNEL} object.
}
  \item{start}{
	\code{character} or \code{NULL}. The name of the start node of an eulerian path.
}
}
\details{
	If \code{start} is not \code{NULL}, then eulerian returns a path starting from it. Otherwise, the start node is automatically selected.
}
\value{
	A character vector representing an eulerian path/cycle in \code{graph}. Each entry in the vector represents the name of a node in the graph.
}

\author{
Ashis Saha
}
%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
	require(graph)
	require(eulerian)
	g <- new("graphNEL", nodes=LETTERS[1:4], edgemode="uirected")
	g <- addEdge(graph=g, from=LETTERS[1:3], to=LETTERS[2:4])
	ep <- eulerian(g)
	
	g <- new("graphNEL", nodes=as.character(1:10), edgemode="directed")
	g <- addEdge(graph=g, from=c("1","2","2","3","4","5","6","6","7","8","9","10"), 
			to=c("10","1","6","2","2","4","5","8","9","7","6","3"))
	ep <- eulerian(g, "6")
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
