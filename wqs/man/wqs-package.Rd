\name{wqs-package}
\alias{wqs-package}
\alias{wqs}
\docType{package}
\title{
\packageTitle{wqs}
}
\description{
\packageDescription{wqs}
}
\details{

The DESCRIPTION file:
\packageDESCRIPTION{wqs}
\packageIndices{wqs}
This package performs weighted quantile sum (WQS) regression, by fitting a WQS regression model for a continuous outcome variable. The components (e.g. chemicals) to be combined into an index are scored into quantiles and then used in the estimation of empirically derived weights and a final WQS index through bootstrap sampling. The weights are constrained to sum to 1 and be between 0 and 1, and can be used to identify important (highly weighted) components and those with no association with outcome (components recieving zero or negligable weight). Inference is constrained in a single direction and the index is interpretable as a measure of the mixture effect. 
}
\author{
\packageAuthor{wqs}

Maintainer: \packageMaintainer{wqs}
}
\references{
Carrico C, Gennings C, Wheeler D, Factor-Litvak P. Characterization of a
weighted quantile sum regression for highly correlated data in a risk analysis
setting. J Biol Agricul Environ Stat. 2014:1-21. ISSN: 1085-7117. DOI: 10.1007/
s13253-014-0180-3. http://dx.doi.org/10.1007/s13253-014-0180-3.

Czarnota J, Gennings C, Colt JS, De Roos AJ, Cerhan JR, Severson RK, Hartge P, 
Ward MH, Wheeler D. 2015. Analysis of environmental chemical mixtures and 
non-Hodgkin lymphoma risk in the NCI-SEER NHL study. 
Environmental Health Perspectives, DOI:10.1289/ehp.1408630.

Czarnota J, Gennings C, Wheeler D. 2015. Assessment of weighted quantile sum 
regression for modeling chemical mixtures and cancer risk. Cancer Informatics, 
2015:14(S2) 159-171 DOI: 10.4137/CIN.S17295
}

\keyword{package}

\examples{
data(WQSdata)
y.train <- WQSdata[,'y']
x.train <- WQSdata[,-10]
output <- wqs.est(y.train, x.train, B = 10)
}
