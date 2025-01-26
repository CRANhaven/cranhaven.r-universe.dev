\name{Weights-class}
  \docType{class}
  \alias{Weights-class}
  \alias{-,Weights,Weights-method}
  \alias{*,numeric,Weights-method}
  \alias{+,Weights,Weights-method}

  \title{Weights objects}
  \description{
  Contains the weights for a one hidden layer neural network in TeachNet the here cold "Arguments" are the slots in the S4 class Weights
}
\arguments{
  \item{alpha}{
Intercept from output layer
}
  \item{alpha_h}{
Intercept from hidden layer
}
  \item{w_h}{
Weights from hidden layer to output layer
}
  \item{w_ih}{
Weights from input layer to hidden layer 
}
}
\author{Georg Steinbuss}
  \seealso{
  \code{\link{Weights2-class}}
}
\examples{

H <- 3 # number of neurons in hidden layer
I <- 6 # number of inputs

random_weights <- new("Weights", alpha = rnorm(1), alpha_h = rnorm(H), w_h = rnorm(H), 
                      w_ih = matrix(nrow=I,ncol=H, data=rnorm(I*H)))

}
