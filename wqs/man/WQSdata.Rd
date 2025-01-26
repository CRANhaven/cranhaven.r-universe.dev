\name{WQSdata}
\alias{WQSdata}
\docType{data}
\title{Simulated data to test WQS}
\description{Correlation and concentration patterns were loosely based on NHL data.}
\usage{data("WQSdata")}
\format{
  A data frame with 1000 observations on the following 10 variables.
  \describe{
    \item{\code{X1}}{a numeric vector}
    \item{\code{X2}}{a numeric vector}
    \item{\code{X3}}{a numeric vector}
    \item{\code{X4}}{a numeric vector}
    \item{\code{X5}}{a numeric vector}
    \item{\code{X6}}{a numeric vector}
    \item{\code{X7}}{a numeric vector}
    \item{\code{X8}}{a numeric vector}
    \item{\code{X9}}{a numeric vector}
    \item{\code{y}}{a numeric vector; the outcome variable}
  }
}
\details{Correlation and concentration patterns were loosely based on NHL data.}
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
          
\examples{
data(WQSdata)
}
\keyword{datasets}
