\name{eulerian-package}
\alias{eulerian-package}
\docType{package}
\title{
	eulerian: A package to handle eulerian paths from graphs
}
\description{
	An eulerian path is a path in a graph which visits every edge exactly once. This package provides methods to handle eulerian paths or cycles.
}

\keyword{ package }
\keyword{ graph }
\keyword{ euler }
\keyword{ eulerian }
\examples{
	require(graph)
	require(eulerian)
	g <- new("graphNEL", nodes=LETTERS[1:4], edgemode="directed")
	g <- addEdge(graph=g, from=LETTERS[1:4], to=LETTERS[c(2:4,1)])
	if(hasEulerianCycle(g)){
		ecycle <- eulerian(g)
		writeLines(paste(ecycle, collapse=" -> "))
	}
}
