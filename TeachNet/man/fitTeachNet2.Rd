\name{fitTeachNet2}
\alias{fitTeachNet2}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
One step in backpropagation
}
\description{
One step in the backpropagation algorithm for a two hidden layers network
}
\usage{
fitTeachNet2(data, weights, hidden.structure, learning.rate, f, f_d, decay, m_f, er)
}

\arguments{
  \item{data}{
the data set
}
  \item{weights}{
current weights
}
  \item{hidden.structure}{
vector with first element the number of hidden neurons in the first hidden layer second element for the second hidden layer
}
  \item{learning.rate}{
rate by which factor for backpropagation gets smaller
}
  \item{f}{
activation function
}
  \item{f_d}{
derivative of activation function
}
  \item{decay}{
value of weight decay
}
  \item{m_f}{
interim value m
}
  \item{er}{
error function
}
}

\value{
returns the new weight after gradient update 
}

\author{
Georg Steinbuss
}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
