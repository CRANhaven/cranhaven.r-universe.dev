\name{predict.Weights}
\alias{predict.Weights}

\title{
Computes prediction
}
\description{
This function computes for a given data set and weights of a one hidden layer network, a prediction from a TeachNet neural network.
}
\usage{
\method{predict}{Weights}(object, newdata, delete.firstColumn=TRUE, ...)
}
\arguments{
   \item{object}{
The Weights object TeachNet returned after training.
}
 \item{newdata}{
The data set you which to predict. Has to have the same variables as the used training data set (except for the class variable) and has to be scaled (Z-Scores)!
}
  \item{delete.firstColumn}{
When class variable is first column, set to TRUE 
}

\item{...}{
additional arguments affecting the predictions produced
}
}
\value{
returns a vector with the predictions of TeachNet
}
\author{
Georg Steinbuss
}

\seealso{
 \link{predict.Weights2},
 \link{Weights-class},
 \link{Weights2-class}
}
