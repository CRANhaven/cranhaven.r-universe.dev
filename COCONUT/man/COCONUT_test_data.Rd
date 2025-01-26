\name{GSEs.test}
\alias{GSEs.test}
\docType{data}
\title{
COCONUT test data
}
\description{
A list of lists, specifically, a list of three data objects (GSEs) from the NIH GEO repository. Each has been converted from a probe matrix to a gene matrix, and subsetted to have only 10 samples (5 healthy and 5 diseased) with only 2000 genes.
}
\usage{data(GSEs.test)}
\format{
  A list of lists. Within the list, each named object consists of:
  \describe{
    \item{\code{genes}}{a numeric matrix, gene names in rows and sample IDs in columns.}
    \item{\code{pheno}}{a data.frame, with sample IDs in rows and phenotype variables in columns.}
  }
}
\details{
The data all come from the NIH GEO repository, and are subsets of their respective GSE IDs.
}
\source{
http://www.ncbi.nlm.nih.gov/geo/
}
\examples{
## see help(COCONUT) for further example
data(GSEs.test)
str(GSEs.test)
}
\keyword{datasets}
