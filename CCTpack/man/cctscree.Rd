\name{cctscree}
\alias{cctscree}
\title{
Generate a scree plot
}
\description{
Creates a screeplot of the data, providing the first 8 factors and their magnitudes.
}
\usage{
cctscree(data, polych = FALSE)
}
\arguments{
  \item{data}{a 2-dimensional matrix or array, missing values should be input as NA.}
  \item{polych}{used for ordinal data only, if the polychoric correlations, rather than Pearson correlations, should be used}
}
\details{
The scree plot is generated from the respondent by respondent correlation (Pearson) matrix.
}
\examples{
data(hotcold)
cctscree(data = hotcold)
## With this example data, a scree plot with 2 substantial factors 
##               (suggesting two cultures) is produced. 
}

