\name{STGS.svm}
\alias{STGS.svm}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Genomic Selection using Support Vector Machine (SVM)
}
\description{
Calculates the Genomic Estimated Breeding Value based on SVM method.
}
\usage{STGS.svm(X, Y, r)
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


$fit    List various coeffecient associated with SVM model fitting

$Pred   GEBV's for genotype under study

$Accuracy model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value

}
\details{
This function fits model by dividing data into two part i.e. training sets and testing sets. Former one is used to build the models and later one for performance evaluation. The performance of model is evaluated by calculating model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value. Whole procedures is repeated 25 times and accuracy is averaged.

}
\references{

Vapnik, V., 1995. The Nature of Statistical Learning Theory, Ed. 2. Springer, New York.

Vapnik, V., and A. Vashist, 2009. A new learning paradigm: Learning using privileged information. Neural Networks 22: 544–557.

Alexandros Karatzoglou, Alex Smola, Kurt Hornik, Achim Zeileis (2004). kernlab - An S4 Package for Kernel Methods in R. Journal of Statistical Software 11(9), 1-20. URL http://www.jstatsoft.org/v11/i09/ .


}


\examples{

library(STGS)

data(wheat_data)

X<-wheat_data[,1:100]

Y<-as.data.frame(wheat_data[,101])

r<-0.25

STGS.svm(X,Y,r)

}
