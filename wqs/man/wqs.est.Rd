\name{wqs.est}
\alias{wqs.est}
\title{Weighted Quantile Sum Regression}
\description{This function fits a weighted quantile sum regression model.}
\usage{
wqs.est(y.train, x.train, z.train = NULL, y.valid = y.train, x.valid = x.train, 
z.valid = z.train, n.quantiles = 4, B = 100, b1.pos = TRUE)
}

\arguments{
  \item{y.train}{vector of the continuous explanatory variable from training data}
  \item{x.train}{matrix of explanatory variables (to be combined into an index) from training data}
  \item{z.train}{vector or matrix of covariates from training data}
  \item{y.valid}{vector of the continuous explanatory variable from validation data}
  \item{x.valid}{matrix of explanatory variables (to be combined into an index) from validation data}
  \item{z.valid}{vector or matrix of covariates from validation data}
  \item{n.quantiles}{number of quantiles to be used (needs to be between 2 and 10)}
  \item{B}{number of bootstrap samples to be used in estimation (needs to be greater than 1)}
  \item{b1.pos}{TRUE if the index is expected to be positively related to the outcome}
}
\value{
 A list with the following items:
  \item{q.train}{matrix of quantiles for training data}
  \item{q.valid}{matrix of quantiles for validation data}
  \item{wts.matrix}{matrix of estimated weights; each row corresponds to a bootstrap sample}
  \item{weights}{final estimated weights used in calculating the WQS index}
  \item{WQS}{weighted quantile sum estimate based on calculated weights}
  \item{fit}{WQS model fit to validation data}
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
\author{Jenna Czarnota, David Wheeler}


\examples{
data(WQSdata)
y.train <- WQSdata[,'y']
x.train <- WQSdata[,-10]
output <- wqs.est(y.train, x.train, B = 10)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
