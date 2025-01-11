\name{STGS.lasso}
\alias{STGS.lasso}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Genomic Selection using Least Absolute Shrinkage and
Selection Operator (LASSO)
}
\description{
Calculates the Genomic Estimated Breeding Value using LASSO method.
}
\usage{STGS.lasso(X, Y, r)
}

\arguments{
  \item{X}{
X is a design matrix of marker genotype of size n×p where n are no of            Individuals under study (i.e. genotype, lines) and p are no of markers.
}
\item{Y}{Y is a vector of individuals of size n×1.}
\item{r}{fraction of testing data (ranges from (0-1)) used during model fitting
 (suppose if one want to use 75\% of data for model training and remaining
 25\% for model testing so one has to define r=0.25).}

}
\value{

$fit    Lists various coeffecient assocaited to LASSO model fitting

$Pred   GEBV's for genotype under study

$Accuracy model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value

}
\details{
This function fits model by dividing data into two part i.e. training sets and testing sets. Former one is used to build the models and later one for performance evaluation. The performance of model is evaluated by calculating model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value. Whole procedures is repeated 25 times and accuracy is averaged.

}
\references{

Tibshirani, R. 1996. Regression shrinkage and selection via the lasso. J. R. Stat. Soc. Series B (Methodological). 267–288.

Searle, S.R., G. Casella and C.E. McCulloch. 1992. Variance Components. John Wiley, Hoboken.

Friedman, J., Hastie, T. and Tibshirani, R. (2008) Regularization Paths for Generalized Linear Models via Coordinate Descent, https://web.stanford.edu/~hastie/Papers/glmnet.pdf Journal of Statistical Software, Vol. 33(1), 1-22 Feb 2010 http://www.jstatsoft.org/v33/i01/.

Jerome Friedman, Trevor Hastie, Robert Tibshirani (2010). Regularization Paths for Generalized Linear Models via Coordinate Descent. Journal of Statistical Software, 33(1), 1-22. URL http://www.jstatsoft.org/v33/i01/ .

}

\examples{

library(STGS)

data(wheat_data)

X<-wheat_data[,1:100]

Y<-as.data.frame(wheat_data[,101])

r<-0.25

STGS.lasso(X,Y,r)

}
