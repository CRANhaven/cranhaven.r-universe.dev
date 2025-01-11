\name{STGS.ann}
\alias{STGS.ann}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Genomic Selection using Artificial Neural Networks(ANN)
}
\description{
Calculates the Genomic Estimated Breeding Value based on ANN method.
}
\usage{STGS.ann(X, Y, r)
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

$fit    meta-data of ANN model fitting

$Pred   GEBV's for genotype under study

$Accuracy model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value
}

\details{
This function fits model by dividing data into two part i.e. training sets and testing sets. Former one is used to build the models and later one for performance evaluation. The performance of model is evaluated by calculating model accuracy i.e. pearson correlation coefficient between actual phenotypic value and predicted phenotypic value. Whole procedures is repeated 25 times and accuracy is averaged.

}

\references{

Foresee, F. D., and M. T. Hagan. 1997. "Gauss-Newton approximation to Bayesian regularization", Proceedings of the 1997 International Joint Conference on Neural Networks.

MacKay, D. J. C. 1992. "Bayesian interpolation", Neural Computation, vol. 4, no. 3, pp. 415-447.

Nguyen, D. and Widrow, B. 1990. "Improving the learning speed of 2-layer neural networks by choosing initial values of the adaptive weights", Proceedings of the IJCNN, vol. 3, pp. 21-26.

Paulino Perez Rodriguez and Daniel Gianola (2018). brnn: Bayesian Regularization for Feed-Forward Neural Networks. R package version 0.7. https://CRAN.R-project.org/package=brnn.

}

\examples{

library(STGS)

data(wheat_data)

X<-wheat_data[,1:100]

Y<-as.data.frame(wheat_data[,101])

r<-0.25

STGS.ann(X,Y,r)

}
