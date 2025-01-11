\name{STGS.rr}
\alias{STGS.rr}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Genomic Selection using Ridge Regression (RR)
}
\description{
  Calculates the Genomic Estimated Breeding Value using RR.
}
\usage{STGS.rr(X, Y, r)
}

\arguments{
  \item{X}{
    X is a design matrix of marker genotype of size n×p where n are no of            Individuals under study (i.e. genotype, lines) and p are no of markers.
  }
  \item{Y}{Y is a vector of individuals of size n×1.}
  \item{r}{fraction of testing data (ranges from (0-1)) used during model fitting
    (suppose if one want to use 75\% of data for model training and remaining
      25 for model testing so one has to define r=0.25).}

}
\value{

  $bhat   estimate of marker effects

  $Pred   GEBV's for genotype under study

  $Accuracy model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value

}
\details{
This function fits model by dividing data into two part i.e. training sets and testing sets. Former one is used to build the models and later one for performance evaluation. The performance of model is evaluated by calculating model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value. Whole procedures is repeated 25 times and accuracy is averaged.

}
\references{

de los Campos, G., and P. P. Rodriguez, 2010 BLR: Bayesian Linear Regression. R package version 1.2. http://CRAN.R-project.org/package=BLR.

de los Campos, G., H. Naya, D. Gianola, J. Crossa, A. Legarra et al., 2009 Predicting quantitative traits with regression models for dense molecular markers and pedigrees. Genetics 182(1): 375–385.

}

\examples{

library(STGS)

data(wheat_data)

X<-wheat_data[,1:100]

Y<-as.data.frame(wheat_data[,101])

r<-0.25

STGS.rr(X,Y,r)

}
