\name{hasEulerianCycle}
\alias{hasEulerianCycle}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
	Method for checking whether an eulerian cycle exists.
}
\description{
	An eulerian cycle is a path in a graph which visits every edge exactly once, and starts and ends at the same node.
}
\usage{
	hasEulerianCycle(graph)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{graph}{
	a \code{graphNEL} object.
}
}
\details{
	A graph will have an euler cycle if and only if every node has same number of edges entering into and going out of it.
}
\value{
	\code{TRUE}, if graph has an auler cycle. \code{FALSE}, otherwise.
}

\author{
Ashis Saha
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
	require(graph)
	require(eulerian)
	g <- new("graphNEL", nodes=LETTERS[1:4], edgemode="directed")
	g <- addEdge(graph=g, from=LETTERS[1:4], to=LETTERS[c(2:4,1)])
	hasEulerianCycle(g)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
