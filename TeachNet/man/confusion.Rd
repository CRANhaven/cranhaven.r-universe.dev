\name{confusion}
\alias{confusion}

\title{
Computes confusion matrix
}
\description{
Computes confusion matrix for a specific threshold
}
\usage{
confusion(pred, obs, threshold = 0.5)
}

\arguments{
  \item{pred}{
the prediction
}
  \item{obs}{
the observation
}
  \item{threshold}{
A threshold up to which a prediction is class 0 or 1. A value from 0 to 1
}
}
\value{
Returns a confusion matrix
}

\author{
Georg Steinbuss
}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
