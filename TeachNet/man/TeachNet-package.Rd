\name{TeachNet-package}
\alias{TeachNet-package}
\docType{package}
\title{
Fit neural networks with up to 2 hidden layers and one output neuron
}
\description{
Can fit neural networks with up to two hidden layers and two different error functions. But just able to compute one output neuron. Also able to handle a weight decay.
}
\details{
\tabular{ll}{
Package: \tab TeachNet\cr
Type: \tab Package\cr
Version: \tab 0.7\cr
Date: \tab 2013-11-20\cr
License: \tab GPL (>= 2)\cr
}
The function TeachNet trains the neural network and also does some testing at the end. It's also possible to get the final weights returned. In the beginning the weights are initialized with a standard normal distribution. But this package is due to its very slow code just to understand the backpropagation algorithm. A good package for real training of neural networks is for example 'nnet'. 
}
\author{
Georg Steinbuss

Maintainer: Who to complain to <gspam@steinbuss.de>
}
\references{
Predicting credit default using neural networks, Georg Steinbuss 2013
}

