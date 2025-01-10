\name{msBP.test}
\alias{msBP.test}
\title{
Multiscale testing of group differences}
\description{
Performs multiscale hypothesis testing of difference in the distribution of two groups using msBP prior.
}
\usage{
msBP.test(y, a, b, group, priorH0 = 0.5,
		mcmc, maxScale = 5, plot.it = FALSE, ...)
}
\arguments{
  \item{y}{The pooled sample of observations}
  \item{a,b}{Parameters of the msBP prior}
  \item{group}{Vector of size \code{length(y)} with 0 and 1 denoting the group membership.}
  \item{priorH0}{Prior gues for the probability of H0}
  \item{mcmc}{a list giving the MCMC parameters. It must include the
          following integers: \code{nb} giving the number of burn-in iterations, \code{nrep} giving
          the total number of iterations (including \code{nb})., and \code{ndisplay} giving
          the multiple of iterations to be displayed on screen while the MCMC is running (a message will be printed every \code{ndisplay} iterations).} 
  \item{maxScale}{maximum scale of the binary trees.}
  \item{plot.it}{logical. If TRUE a plot of the posterior mean probability of H0 is produced}
  \item{\dots}{additional arguments to be passed.}
}
\value{
a list containing
\item{Ps}{a matrix with \code{maxScale} rows and \code{mcmc$nrep} columns with the MCMC draws of posterior probabilities of H0 for each scale}
\item{Ps}{the posterior mean probabilities of H0 for each scale.}
}
\references{
Canale, A. and Dunson, D. B. (2016), "Multiscale Bernstein polynomials for densities", Statistica Sinica, 26(3), 1175-1195.

Canale, A. (2017), "msBP: An R Package to Perform Bayesian Nonparametric Inference Using Multiscale Bernstein Polynomials Mixtures". Journal of Statistical Software, 78(6), 1-19. }
\examples{
set.seed(1)
y <- runif(100)
g <- c(rep(0,50), rep(1,50))
mcmc <- list(nrep = 5000, nb = 1000, ndisplay = 500)
\dontrun{
test.res <- msBP.test(y, 5, 1, g, mcmc=mcmc, plot.it = TRUE)
}
}
\keyword{ multiscale testing }
