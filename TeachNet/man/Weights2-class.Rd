\name{Weights2-class}
  \docType{class}
  \alias{Weights2-class}
  \alias{-,Weights2,Weights2-method}
  \alias{*,numeric,Weights2-method}
  \alias{+,Weights2,Weights2-method}
  
  \title{Weights2 objects}
  \description{
  Contains the weights for a two hidden layer neural network in TeachNet the here cold "Arguments" are the slots in the S4 class Weights2
}
\arguments{
  \item{alpha}{
Intercept from output layer
}
  \item{alpha_1m}{
Intercept from hidden layer
}
  \item{alpha_2h}{
Intercept from second hidden layer
}
  \item{w_h}{
Weights from second hidden layer to output layer
}
 \item{q_mh}{
Weights from first hidden layer to second hidden layer
}
 \item{w_im}{
Weights from input layer to first hidden layer 
}
}
\author{Georg Steinbuss}
  \seealso{
  \code{\link{Weights-class}}
}

\examples{

M <- 3 # number of neurons in first hidden layer
H <- 3 # number of neurons in second hidden layer
I <- 6 # number of inputs

random_weights <- new("Weights2", alpha = rnorm(1), alpha_1m = rnorm(M), alpha_2h = rnorm(H), 
                      w_h = rnorm(H), q_mh = matrix(nrow=M,ncol=H, data=rnorm(M*H)),
                      w_im = matrix(nrow=I,ncol=M, data=rnorm(I*M)))
}
