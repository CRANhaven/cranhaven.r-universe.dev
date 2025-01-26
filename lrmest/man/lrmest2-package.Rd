\name{lrmest-package}
\alias{lrmest-package}
\alias{lrmest}
\docType{package}
\title{
Estimation of varies types of estimators in the linear model
}
\description{
To combat multicollinearity several estimators have been introduced. By using this package some of those estimators and corresponding scalar Mean Square Error (MSE) values and Prediction Sum of Square (PRESS) values (Only for some estimators) can be found easily. In addition graphical methods are available to determine the variation of MSE values of those estimators and the variation of PRESS values of some of the estimators.
}
\details{
\tabular{ll}{
Package: \tab lrmest\cr
Type: \tab Package\cr
Version: \tab 3.0\cr
Date: \tab 2016-05-13\cr
License: \tab GPL-2 | GPL-3\cr
}
In this package functions have been written for several types of estimators in the linear model. By using those functions relevant estimators can be found.
}
\author{
P.Wijekoon, A.Dissanayake

Maintainer: Ajith Dissanayake <sudeera333@gmail.com>
}
\references{
Akdeniz, F. and Erol, H. (2003) \emph{Mean Squared Error Matrix Comparisons of Some Biased Estimators in Linear Regression} in \emph{Communications in Statistics - Theory and Methods}, volume \bold{32} DOI:10.1081/STA-120025385\cr 

Arumairajan, S. and Wijekoon, P. (2015) ] \emph{Optimal Generalized Biased Estimator in Linear Regression Model} in \emph{Open Journal of Statistics}, pp. 403--411\cr  

Hubert, M.H. and Wijekoon, P. (2006) \emph{Improvement of the Liu estimator in the linear regression medel}, Chapter (4-8)\cr 

Liu, K. (1993) \emph{A new class of biased estimate in linear regression} in \emph{Communications in Statistics-Theory and Methods} \bold{22}, pp. 393--402\cr

Nagler, J. (Updated 2011) Notes on Ordinary Least Square Estimators\cr

Theil, H. and Goldberger, A.S. (1961) \emph{On pure and mixed statistical estimation in economics} in \emph{International Economic review} \bold{2}, pp. 65--78\cr 

Revan, M. (2009) \emph{A stochastic restricted ridge regression estimator} in \emph{Journal of Multivariate Analysis}, volume \bold{100}, issue 8, pp. 1706--1716\cr

Rong,Jian-Ying (2010) \emph{Adjustive Liu Type Estimators in linear regression models} in \emph{communication in statistics-simulation and computation}, volume \bold{39} DOI:10.1080/03610918.2010.484120\cr

Sarkara, N. (1992), \emph{A new estimator combining the ridge regression and the restricted least squares methods of estimation} in \emph{Communications in Statistics - Theory and Methods}, volume \bold{21}, pp. 1987--2000. DOI:10.1080/03610929208830893\cr
}
%~~ Optionally other standard keywords, one per line, from file KEYWORDS in ~~
%~~ the R documentation directory ~~
\keyword{ package }
\seealso{
\code{\link{optimum}}, \code{\link{pcd}}
}
\examples{
## Portland cement dataset is used.
data(pcd)
attach(pcd)
k<-c(0:3/10)
d<-c(-3:3/10)
r<-c(2.1930,1.1533,0.75850)
R<-c(1,0,0,0,0,1,0,0,0,0,1,0)
dpn<-c(0.0439,0.0029,0.0325)
delt<-c(0,0,0)
aa1<-c(0.958451,1.021155,0.857821,1.040296)
aa2<-c(0.345454,1.387888,0.866466,1.354454)
aa3<-c(0.344841,1.344723,0.318451,1.523316)
optimum(Y~X1+X2+X3+X4-1,r,R,dpn,delt,aa1,aa2,aa3,k,d,data=pcd)   
 # Model without the intercept is considered.
 ## Use "press=TRUE" to get the optimum PRESS values only for some of 
# the estimators.
}
