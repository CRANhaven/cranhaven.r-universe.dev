\name{pco-package}
\alias{pco-package}
\alias{pco}
\docType{package}
\title{
Panel Cointegration Tests 
}
\description{
Computation of the Pedroni (1999) panel cointegration test statistics.  Reported are the empirical values and the standardized values (as suggested in Pedroni, 1999).  
}
\details{
\tabular{ll}{
Package: \tab pco\cr
Type: \tab Package\cr
Version: \tab 1.0.1\cr
Date: \tab 2015-07-26\cr
License: \tab GPL-2\cr
}
Computation of the Pedroni (1999) panel cointegration test statistics.  Reported are the empirical and the standardized values (as suggested in Pedroni, 1999).  

The package includes two functions:  
'pedroni99' is for the bivariate case (one Y, one X, no NA values), data must be in matrices (easier for use);  
'pedroni99m' is for the multivariate case (one Y, multiple X, no NA values), data must be in an array of all variables.  
}
\author{
Georgi Marinov
Maintainer: Georgi Marinov <georgi.marinov@ue-varna.bg>
}
\references{
Newey, Whitney K.; West, Kenneth D. (1994). "Automatic lag selection in covariance matrix estimation". Review of Economic Studies 61 (4): 631-654.  

Pedroni, Peter, 1999. "Critical Values for Cointegration Tests in Heterogeneous Panels with Multiple Regressors," Oxford Bulletin of Economics and Statistics, Department of Economics, University of Oxford, vol. 61(0), pages 653-70, Special I.  
}
\keyword{ package }
\seealso{
\code{\link{pedroni99}} 

\code{\link{pedroni99m}}
}
\examples{
data(gdi)
data(gds)
pedroni99(gdi, gds)

xx<-array(cumsum(rnorm(10000)),dim=c(100,20,5))
pedroni99m(xx)
}
