\name{STGS.rf}
\alias{STGS.rf}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Genomic Selection using Random Forest
}
\description{
Calculates the Genomic Estimated Breeding Value by using Random Forest method.
}
\usage{STGS.rf(X, Y, r)
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

$Pred   GEBV's for genotype under study

$Accuracy model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value

}
\details{
This function fits model by dividing data into two part i.e. training sets and testing sets. Former one is used to build the models and later one for performance evaluation. The performance of model is evaluated by calculating model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value. Whole procedures is repeated 25 times and accuracy is averaged.

}
\references{

Breiman, L. (2001), Random Forests, Machine Learning 45(1), 5-32.

Breiman, L (2002), “Manual On Setting Up, Using, And Understanding Random Forests V3.1”,https://www.stat.berkeley.edu/~breiman/Using_random_forests_V3.1.pdf.

A. Liaw and M. Wiener (2002). Classification and Regression by randomForest. R News 2(3), 18-22


}

\examples{

library(STGS)

data(wheat_data)

X<-wheat_data[,1:100]

Y<-as.data.frame(wheat_data[,101])

r<-0.25

STGS.rf(X,Y,r)

}
