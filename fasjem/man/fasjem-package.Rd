\name{fasjem-package}
\alias{fasjem-package}
\docType{package}
\title{
A Fast and Scalable Joint Estimator for Learning Multiple Related Sparse Gaussian Graphical Models}
\description{
This is an R implementation of "A Fast and Scalable Joint Estimator for Learning Multiple Related Sparse Gaussian Graphical Models" (FASJEM). The FASJEM algorithm can be used to estimate multiple related precision matrices. For instance, it can identify context-specific gene networks from multi-context gene expression datasets. By performing data-driven network inference from high-dimensional and heterogenous data sets, this tool  can help users effectively translate aggregated data into knowledge that take the form of graphs among entities. For more details, please read <http://proceedings.mlr.press/v54/wang17e/wang17e.pdf>.
Assuming the multiple related graphs share a certain sparsity pattern, this package provides two different options for regularizing such sparsity patterns: (1) the group,2 norm (\code{method = "fasjem-g"}) and (2) the group,infinity norm (\code{method = "fasjem-i"}).
}
\details{
\tabular{ll}{
Package: \tab fasjem\cr
Type: \tab Package\cr
Version: \tab 1.1.2\cr
Date: \tab 2017-07-31\cr
License: \tab GPL (>= 2)\cr
}
Estimating multiple sparse Gaussian Graphical Models (sGGMs) jointly for many related tasks (large K) under a high-dimensional (large p) situation is an important task. Most previous studies for the joint estimation of multiple sGGMs rely on penalized log-likelihood estimators that involve expensive and difficult non-smooth optimizations. We propose a novel approach, FASJEM for FAst and Scalable Joint structure-Estimation of Multiple sGGMs at a large scale. As the first study of joint sGGM using the M-estimator framework, our work has three major contributions: (1) We solve FASJEM through an entry-wise manner which is parallelizable. (2) We choose a proximal algorithm to optimize FASJEM. This improves the computational efficiency from \eqn{O(Kp^3)} to \eqn{O(Kp^2)} and reduces the memory requirement from \eqn{O(Kp^2)} to \eqn{O(K)}. (3) We theoretically prove that FASJEM achieves a consistent estimation with a convergence rate of \eqn{O(log(Kp)/n_{tot})}. On several synthetic and four real-world datasets, FASJEM shows significant improvements over baselines on accuracy, computational complexity and memory costs.
}
\author{
Beilun Wang

Maintainer: Beilun Wang - bw4mw at virginia dot edu
}
\references{
Beilun Wang, Ji Gao, Yanjun Qi (2017). A Fast and Scalable Joint Estimator for Learning Multiple Related Sparse Gaussian Graphical Models. <http://proceedings.mlr.press/v54/wang17e/wang17e.pdf>
}
\keyword{ package }
\examples{
\dontrun{
data(exampleData)
fasjem(X = exampleData, method = "fasjem-g", 0.1, 0.1, 0.1, 0.05, 10)
demo(fasjem)
}
}
