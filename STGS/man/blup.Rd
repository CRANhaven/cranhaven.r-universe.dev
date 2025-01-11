\name{STGS.blup}
\alias{STGS.blup}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Genomic Selection using Best Linear Unbiased Prediction (BLUP).
}
\description{
Calculates the Genomic Estimated Breeding Value based on BLUP.
}
\usage{STGS.blup(X, Y, r)
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

$Vu variance of random effect i.e. u

$Ve error variance

$beta estimate of fixed effects i.e. BLUE

$u estimate of random effects i.e. BLUP(u)

$LL maximized log-likelihood

$Pred GEBVs for genotype under study

$Accuracy model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value

}
\details{
This function fits model by dividing data into two part i.e. training sets and testing sets. Former one is used to build the models and later one for performance evaluation. The performance of model is evaluated by calculating model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value. Whole procedures is repeated 25 times and accuracy is averaged.

}
\references{

Endelman, J.B. 2011. Ridge regression and other kernels for genomic selection with R package rrBLUP. Plant Genome 4:250-255.

Searle, S.R., G. Casella and C.E. McCulloch. 1992. Variance Components. John Wiley, Hoboken.
}

\examples{

library(STGS)

data(wheat_data)

X<-wheat_data[,1:100]

Y<-as.data.frame(wheat_data[,101])

r<-0.25

STGS.blup(X,Y,r)

}
