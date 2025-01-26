\name{computeGrad1}
\alias{computeGrad1}

\title{
Computes a gradient
}
\description{
This function computes the gradient for a one hidden layer network.
}
\usage{
computeGrad1(x, y, I, H, weights, f, f_d, m_f)
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
  \item{H}{
numbers of hidden neurons
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
A Weights class with the gradient parts
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
