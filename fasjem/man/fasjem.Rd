\name{fasjem}
\alias{fasjem}
\title{A Fast and Scalable Joint Estimator for Learning Multiple Related Sparse Gaussian Graphical Models}
\usage{
fasjem(X, method="fasjem-g", lambda=0.1, epsilon=0.1, gamma=0.1, rho=0.05, iterMax=10)
}
\arguments{
\item{X}{A List of input matrices. They can be either data matrices or covariance matrices. If every matrix in the X is a symmetric matrix, the input matrices are assumed to be the covariance matrices from the multiple related tasks. }
\item{method}{By using two different regularization functions as the second norm in the objective, this package provides two different options for regularizing the sparsity pattern shared among multiple graphs. This parameter decides which function to use for the second regularization norm.

When \code{method = "fasjem-g"}, fasjem will use the group,2 norm as the second regularization function.

When \code{method = "fasjem-i"}, fasjem will choose the group,infinity norm as the second regularization function. The default value is "fasjem-g". Please check the paper for more details.  }
\item{lambda}{A positive number.  This hyperparameter controls the sparsity level of the matrices. The \eqn{\lambda_n} in the following section: Details.}
\item{epsilon}{A positive number. This hyperparameter represents the ratio between the l1 norm and the second group norm. The \eqn{\epsilon} in the following section: Details.}
\item{gamma}{A positive number. This hyperparameter is used in calculating each proximity during optimization. Please check the Algorithm 1 in our paper for more details.}
\item{rho}{A positive number. This hyperparameter controls the learning rate of the proximal gradient method. Please check the Algorithm 1 in our paper for more details.}
\item{iterMax}{An integer. The max number of iterations in the optimization of fasjem.}
}
\description{
The R implementation of the FASJEM method, which is introduced in the paper "A Fast and Scalable Joint Estimator for Learning Multiple Related Sparse Gaussian Graphical Models". Please run demo(fasjem) to learn the basic functions provided by this package. For more details, please see <http://proceedings.mlr.press/v54/wang17e/wang17e.pdf>. }
\value{
\item{Graphs}{A list of the estimated inverse covariance matrices.}
}
\references{
Beilun Wang, Ji Gao, Yanjun Qi (2017). A Fast and Scalable Joint Estimator for Learning Multiple Related Sparse Gaussian Graphical Models. <http://proceedings.mlr.press/v54/wang17e/wang17e.pdf>
}
\details{
  The FASJEM algorithm is a fast and scalable method to estimate multiple related sparse Gaussian Graphical models. It solves the following equation:
\deqn{
\min\limits_{\Omega_{tot}} ||\Omega_{tot}||_1 + \epsilon \mathcal{R}'(\Omega_{tot})
}
Subject to :
\deqn{
  ||\Omega_{tot} - inv(T_v(\hat{\Sigma}_{tot}))||_{\infty} \le \lambda_n
}
\deqn{
  \mathcal{R}'^*(\Omega_{tot} - inv(T_v(\hat{\Sigma}_{tot}))) \le \epsilon\lambda_n
}
More details are provided in the equation (3.1) of our original paper.

The \eqn{\lambda_n} in the above equation represents the hyperparameter \code{lambda} who controls the sparsity level of the target precision matrices.

The \eqn{\epsilon\lambda_n} in the above equation represents the regularization parameter of the second norm who controls how multiple graphs share a certain pattern. Here \eqn{\epsilon} represents the input parameter \code{epsilon}   whose  default value is 0.1.

Other parameters in the fasjem function are described in details by the Algorithm 1 in our paper.

When \code{method = "fasjem-g"}, \eqn{\mathcal{R}'(\cdot) = ||\cdot||_{\mathcal{G},2}}.

When \code{method = "fasjem-i"}, \eqn{\mathcal{R}'(\cdot) = ||\cdot||_{\mathcal{G},\infty}}.

Please run \code{demo(fasjem)} to learn the basic functions provided by this package. For more details, please see <http://proceedings.mlr.press/v54/wang17e/wang17e.pdf>.
}
\keyword{fasjem}
\examples{
data(exampleData)
fasjem(X = exampleData, method = "fasjem-g", 0.1, 0.1, 0.1, 0.05, 10)
fasjem(X = exampleData, method = "fasjem-i", 0.1, 0.1, 0.1, 0.05, 10)
}
