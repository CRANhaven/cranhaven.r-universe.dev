\name{hasEulerianPath}
\alias{hasEulerianPath}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
	Method for checking whether an eulerian path exists.
}
\description{
	An eulerian path is a path in a graph which visits every edge exactly once.
}
\usage{
hasEulerianPath(graph, start = NULL)
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
	If \code{start} is \code{NULL}, this function returns whether there exists any eulerian path in \code{graph}. If \code{start} is not \code{NULL}, the function determines if there exists an eulerian path starting from \code{start}.
}
\value{
	\code{TRUE}, if there is an eulerian path. \code{FALSE}, otherwise.
}

\author{
Ashis Saha
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
	require(graph)
	require(eulerian)
	g <- new("graphNEL", nodes=LETTERS[1:4], edgemode="undirected")
	g <- addEdge(graph=g, from=LETTERS[c(1:4)], to=LETTERS[c(2:4,4)])
	hasEulerianPath(g)	#TRUE
	hasEulerianPath(g, "B")	#FALSE
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
