\name{accuracy.me}
\alias{accuracy.me}

\title{
Computes accuracy
}
\description{
For a given observation and prediction this function computes the accuracy of the prediction.
}
\usage{
accuracy.me(obs, predict, thres = 0.5)
}
\arguments{
  \item{obs}{
The observations
}
  \item{predict}{
The predictions for the observations
}
  \item{thres}{
A threshold up to which a prediction is class 0 or 1. A value from 0 to 1. 
}
}
\value{
Returns a 1 x 3 matrix with the percentage of observations with class zero, with class one and last the accuracy of the prediction.
}
\author{
Georg Steinbuss
}
\seealso{
\link{confusion}
}
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
