\name{TeachNet}
\alias{TeachNet}

\title{
Fits the neural network
}
\description{
The function TeachNet trains the neural network for a two class classification and also does some testing at the end. The class attribute os assumed to be the first column and coded as 1. Data gets scaled with Z-scores before training. It's also possible to get the final weights returned.
}
\usage{
TeachNet(data, hidden.structure = -1, threshold.TotalError = 0.1, stepMax = 100,
learning.rate = 0.9, acc.fct = "logistic", err.fct = "sse", startWeights = NULL, 
decay = 0, sameSample = FALSE, sampleLength = 0.7, all = FALSE, eval = TRUE)
}
\arguments{
  \item{data}{
A data frame. The first column must be the class (0,1), the others the input variables (just numerical).
}
  \item{hidden.structure}{
The number of hidden neurons. A vector for two hidden layers. Default, -1 means that the automatic rule is applied (number of hidden neurons = number of variables divided by two, one hidden layer).
}
  \item{threshold.TotalError}{
Algorithm stops if total error falls below this threshold
}
  \item{stepMax}{
The maximum steps the algorithm does. One step is equal to one update of the weights (one cycle through the training set) for that he has to calculate the gradient of the total error. 
}
  \item{learning.rate}{
Multiplicative factor by which the actual learning rate is iteratively reduced until the new error is smaller than the old one
}
  \item{acc.fct}{
The activation function that is used. In this version only "logistic" possible.
}
  \item{err.fct}{
The error function that is used. You can choose "sse" for sum squared error, or "ce" for cross entropy.
}
  \item{startWeights}{
This is where you can give TeachNet weights to start with. 
}
  \item{decay}{
The factor for the weight decay.
}
  \item{sameSample}{
If TRUE the training and test data will be a data set with nearly same number of class 0 and 1. Randomly chosen out of the data.
}
  \item{sampleLength}{
Ratio that implies rows of the training data set depending on the full data set. Should be a number greater than 0 and less than 1. Test data set has size (1 - sampleLenght). 
}
  \item{all}{
If TRUE training data is the whole dataset (test data is training data). 
}
  \item{eval}{
If TRUE evaluation is computed.
}
}
\details{
In the beginning the weights are initialized with a standard normal distribution. But this package is due to its very slow code just to understand the backpropagation algorithm. A good package for real training of neural networks is for example 'nnet'.
}
\value{
TeachNet returns a S4 class object Weights for one hidden layer or Weights2  for two hidden layer. In addition if 'all' is FALSE, it prints an Evaluation. First part is the best found Threshold and V (V=True Positive - False Positive) for the prediction on the test Dataset. Then a confusion matrix and the accuracy of the model compared to the percentage of observation with class zero and one. 
}
\author{
Georg Steinbuss
}
\seealso{
 \link{Weights-class},
 \link{Weights2-class},
 \link{predict.Weights}
 \link{predict.Weights2}
}
\examples{
df <- sample(c(rep(1,20),rep(0,20))) 
income <- c(rnorm(40,mean=1000,sd=10)) 
debt <- rnorm(40,mean=0.5,sd=0.1)
data <- data.frame(df, income, debt)

weights <- TeachNet(data,sameSample=TRUE,sampleLength=0.9,stepMax=2)

}

