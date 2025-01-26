\name{fitTeachNet1}
\alias{fitTeachNet1}

\title{
One step in backpropagation
}
\description{
One step in the backpropagation algorithm for a one hidden layer network
}
\usage{
fitTeachNet1(data, weights, hidden.structure, learning.rate, f, f_d, decay, m_f, er)
}

\arguments{
  \item{data}{
the data set
}
  \item{weights}{
current weights
}
  \item{hidden.structure}{
the number of neurons in the hidden layer
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
returns new the weight after gradient update 
}

\author{
Georg Steinbuss
}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
