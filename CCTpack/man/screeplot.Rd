\name{screeplot}
\alias{screeplot}
\title{
Generate a scree plot
}
\description{
Screeplot method for CCTpack data, or a cctfit object of class 'cct';  equivalent to function cctscree().
}
\usage{
screeplot(x, ...)
}
\arguments{
  \item{x}{a 2-dimensional matrix or dataframe, missing values should be input as NA, or a cctfit object of class 'cct'.}
  \item{...}{Additional arguments: \code{polych=T} (for ordinal data only), to use the polychoric correlations rather than Pearson correlations.}
}
\details{
The scree plot is generated from the respondent by respondent correlation (Pearson) matrix.
}
\examples{
data(hotcold)
screeplot(hotcold)
## With this example data, a scree plot with 2 substantial factors 
##               (suggesting two cultures) is produced. 
}

