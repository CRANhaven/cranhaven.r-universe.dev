\name{computeGrad2}
\alias{computeGrad2}

\title{
Computes a gradient
}
\description{
This function computes the gradient for a two hidden layer network.
}
\usage{
computeGrad2(x, y, I, M, H, weights, f, f_d, m_f)
}
\arguments{
  \item{x}{
properties of observation
}
  \item{y}{
characteristic of observation (zero or one)
}
  \item{I}{
numbers of input neurons
}
  \item{M}{
number of neurons in first hidden layer
}
  \item{H}{
number of neurons in second hidden layer
}
  \item{weights}{
the weights with that the gradient should be computed
}
  \item{f}{
the activation function of the neural network
}
  \item{f_d}{
the derivative of the activation function 
}
  \item{m_f}{
the function for the interim value m. It is two times the output of the network minus the observed characteristic.
}
}
\value{
A Weights2 class with the gradient parts
}
\author{
Georg Steinbuss
}

\seealso{
\link{Weights-class}
\link{computeGrad2}
}
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
