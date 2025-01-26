\name{exampleData}
\alias{exampleData}
\docType{data}
\title{
A simulated toy dataset that includes 2 data matrices (about 2 related tasks).
}
\description{
A simulated toy dataset that includes 2 data matrices (from 2 related tasks). Each data matrix is about 100 features observed in 200 samples. The two data matrices are about exactly the same set of 100 features. This multi-task dataset is generated from two related random graphs. Please run demo(fasjem) to learn the basic functions provided by this package.  For further details, please read the original paper:  <http://proceedings.mlr.press/v54/wang17e/wang17e.pdf>.
}
\usage{data(exampleData)}
\format{
  The format is:
List of 2 matrices
 $ : num [1:200, 1:100] -0.0982 -0.2417 -1.704 0.4 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : NULL
  .. ..$ : NULL
 $ : num [1:200, 1:100] -0.161 0.41 0.17 0. ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : NULL
  .. ..$ : NULL
}

\examples{
data(exampleData)
}
\keyword{datasets}
