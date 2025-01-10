\name{msBP.Gibbs}
\alias{msBP.Gibbs}

\title{
Gibbs sampling for density estimation for msBP model
}
\description{
Gibbs sampling for Markov Chain Motecarlo sampling from the posterior distribution of an msBP model.
}
\usage{
msBP.Gibbs(x, a, b, g0 = "normal", g0par=c(0,1), mcmc, 
	grid = list(n.points=40, low=0.001, upp=0.999), state=NULL, hyper, 
	printing=0, maxScale=5, ...)
}
\arguments{
  \item{x}{
the observed sample
}
  \item{a}{
scalar a parameter
}
  \item{b}{
scalar b parameter
}
  \item{g0}{
prior guess for the density of \code{x}. Currently only "normal", "unif", "gamma", and "empirical" are supported. From version 1.1 random paramters are also allowed (only with \code{g0="normal"}).
}
\item{g0par}{
additional scalar parameters for \code{g0}. If "normal" corresponds to mean and standard deviation, if "uniform" to upper and lower bounds, if "gamma" to shape and rate parameters. If "empirical" this value is not used. From version 1.1 random paramters are also allowed (only with \code{g0="normal"}). 
}
  \item{mcmc}{a list giving the MCMC parameters. It must include the
          following integers: \code{nb} giving the number of burn-in iterations, \code{nrep} giving
          the total number of iterations (including \code{nb}), and \code{ndisplay} giving
          the multiple of iterations to be displayed on screen while the \code{C++} routine is running (a message will be printed every \code{ndisplay} iterations).}
  \item{grid}{
a list giving the parameters for plotting the posterior mean density over a finite grid. It must include the following values: \code{low} and \code{upp} giving the lower and upper bound respectively of the grid and \code{n.points}, an integer giving the number of points of the grid}
   \item{state}{a list giving the current value of the parameters. This list is used if the current analysis is the continuation of a
          previous analysis or if we want to start the MCMC algorithm from some particular value of the parameters.}
  \item{hyper}{a list containing the values of the hyperparameters for \code{a} and \code{b} or for the parameters of the prior guess (only if \code{g0="normal"}) . It must contains \code{hyperprior}, a list of three logical values determining if hyperpriors for \code{a}, \code{b} and \code{g0} are used (TRUE) or if \code{a}, \code{b}, or \code{g0} are fixed (FALSE), and \code{hyperpar} a list containing the hyperparameters for the hyperprior distributions: \code{beta}, \code{gamma}, \code{delta}, \code{lambda}, \code{mu0}, \code{kappa0}, \code{alpha0}, and \code{beta0}. See details. \code{gridB} is a grid of values for which the prior (and posterior) for \code{b} is evaluated with a Griddy Gibbs approach (Ritter and Tanner, 1992). See details.}
  \item{printing}{Vector of integers if the internal C++ function need to print what is doing}
  \item{maxScale}{maximum scale of the binary trees.}
  \item{...}{additional arguments.}
}
\details{
Before calling the proper C++ subrouting the function center the sample on an initial guess for the density of the data. If \code{g0 = 'empirical'} the data are transformed so that the expctation of the msBP prior is centered on the kernel density estimate of \code{x}.

The algorithm consists of two primary steps: (i) allocate each observation 
to a multiscale cluster, conditionally on the values of the weights (see also \code{msBP.postCluster}); 
(ii) update the weights, conditionally on the cluster allocations. 
All the procedure is written in C++ and additional R scripts are used to pre- and post-process the data and the output.

If \code{hyper$hyperpriors$a} or \code{hyper$hyperpriors$b} is true, additional hyperpriors for \code{a} and \code{b} are assumed. Specifically the algorithm implements \eqn{a \sim Ga(\beta,\gamma)}{a ~ Ga(\beta,\gamma)} and  \eqn{b \sim Ga(\delta, \lambda)}{b ~ Ga(\delta, \lambda)}. 
For the former parameter the full conditional posterior distribution is available in closed form, i.e.
\deqn{ a | -  \sim Ga\left(\beta + 2^{s'+1} - 1, \gamma - \sum_{s=0}^{s'} \sum_{h=1}^{2^s} \log(1-S_{s,h}) \right),}{%
       a | -  ~ Ga(\beta + 2^{s'+1} - 1, \gamma - \sum_{s=0}^{s'} \sum_{h=1}^{2^s} log(1-S_{s,h}) ),
}
while for the latter its full conditional posterior is proportional to 
\deqn{
	\frac{b^{\delta-1}}{B(b,b)^{2^{s+1}-1}} \exp \left\{b \left(
	\sum_{s=0}^{s'} \sum_{h=1}^{2^s} \log\{R_{s,h} (1 - R_{s,h} )\} - \lambda\right) \right\},
}{
	b^{\delta-1}/B(b,b)^{2^{s+1}-1} exp ( b ( \sum_{s=0}^{s'} \sum_{h=1}^{2^s} log(R_{s,h} (1 - R_{s,h} )) - \lambda ) ,
}
where \eqn{s'} is the maximum occupied scale and \eqn{B(p, q)} is the Beta function. To sample
from the latter distribution, a griddy Gibbs approach over the grid defined by \code{hyper$hyperpar$gridB} is used. See Ritter and Tanner (1992).
From Version 1.1, if \code{hyper$hyperpriors$base=TRUE} and \code{g0="normal"} additional hyperpriors for the parameter of the centering normal density are assumed. Specifically the model is
\deqn{
	y = \Phi(x; \mu, \sigma^2)
}{
	y = \Phi(x; \mu, \sigma^2)
}
\deqn{
	(\mu, \sigma^2) \sim N(\mu; \mu_0, \kappa_0\sigma^2)\mbox{I-Ga}(\sigma^2; \alpha_0, \beta_0)
}{
(\mu, \sigma^2) ~ N(\mu; \mu_0, \kappa_0\sigma^2)I-Ga(\sigma^2; \alpha_0, \beta_0)
}
and an addtional step simulating the values of \eqn{\mu} and \eqn{\sigma^2} from their conditional posterior distribution is added to the Gibbs sampler of Canale and Dunson (2016). Specifically, a Metropolis-Hastings step with proposal equal to the prior is implemented.
}
\value{
A list containing 
%mcmcsamples=list(dens=postDens, a=res$postA, b=res$postB, scale=scale, S=postS, R=postR, weights=postW, s=posts, h = posth),
%postmean = list(a=mean(res$postA), b=mean(res$postB), S=postMeanS, R=postMeanR, weights=postMeanW, scales=postMeanScale)
\item{density}{A list containing \code{postMeanDens}, the posterior mean density estimate evaluated over \code{xDens} and \code{postLowDens} and \code{postUppDens}, the lower and upper pointwise 95\% credible bands,}
\item{mcmc}{A list containing the MCMC chains: \code{dens} is a matrix (\code{nrep}-\code{nb}) times \code{n.grid}, \code{a} and \code{b} are the vectors with the MCMC chains for the two parameters (if \code{hyperprior} was TRUE), \code{scale} is a matix where each column is a MCMC chain of the total mass for each scale, \code{R} and \code{S}, are matrices where each column in the \code{tree2vec} form of the corresponding trees, \code{weights} is a matrix where each column is the \code{tree2vec} form of the corresponding tree of weights, \code{s} and \code{h} are matrices where each column is the MCMC chain for the node labels for a subject.}
\item{postmean}{A list containing posterior means over the MCMC samples of \code{a}, \code{b}, and of all binary trees}
\item{fit}{A list containing the LPML, mean and median of the log CPO.}
}
\references{
Canale, A. and Dunson, D. B. (2016), "Multiscale Bernstein polynomials for densities", Statistica Sinica, 26(3), 1175-1195.

Canale, A. (2017), "msBP: An R Package to Perform Bayesian Nonparametric Inference Using Multiscale Bernstein Polynomials Mixtures". Journal of Statistical Software, 78(6), 1-19. 

Ritter C., Tanner M. (1992). "Facilitating the Gibbs Sampler: the Gibbs Stopper and the Griddy-Gibbs Sampler." Journal of the American Statistical Association, 87, 861-868.
}
\seealso{
\code{\link{msBP.postCluster}}
}
\examples{
\dontrun{
data(galaxy)
galaxy <- data.frame(galaxy)
speeds <- galaxy$speed/1000
set.seed(1)
#with fixed g0 and random a, b
fit.msbp.1 <- msBP.Gibbs(speeds, a = 10, b = 5, g0 = "empirical", 
	mcmc=list(nrep = 10000, nb = 5000, ndisplay = 1000), 
	hyper=list(hyperprior=list(a = TRUE, b = TRUE, g0 = FALSE), 
	hyperpar=list(beta=5,gamma = 1,delta = 1,lambda = 1)), 
	printing = 0, maxS = 7, grid = list(n.points = 150, low = 5, upp = 38))

#with random a, b and hyperparameters of g0
fit.msbp.2 <- msBP.Gibbs(speeds, a = 10, b=5, g0 = "normal", 
	mcmc=list(nrep = 10000, nb = 5000, ndisplay = 1000), 
	hyper=list(hyperprior = list(a = TRUE, b = TRUE, g0 = TRUE), 
  hyperpar = list(beta = 50, gamma = 5, delta = 10, lambda = 1,
	gridB = seq(0, 20, length = 30),
	mu0 = 21, kappa0 = 0.1, alpha0 = 1, beta0 = 20)), 
	printing = 0, maxS = 7, grid = list(n.points = 150, lo w= 5, upp = 38))	

hist(speeds, prob=TRUE,br=10, ylim=c(0,0.23), main="", col='grey')
points(fit.msbp.1$density$postMeanDens~fit.msbp.1$density$xDens, ty='l', lwd=2)
points(fit.msbp.1$density$postUppDens~fit.msbp.1$density$xDens, ty='l',lty=2, lwd=2)
points(fit.msbp.1$density$postLowDens~fit.msbp.1$density$xDens, ty='l',lty=2, lwd=2)

hist(speeds, prob=TRUE,br=10, ylim=c(0,0.23), main="", col='grey')
points(fit.msbp.2$density$postMeanDens~fit.msbp.2$density$xDens, ty='l', lwd=2)
points(fit.msbp.2$density$postUppDens~fit.msbp.2$density$xDens, ty='l',lty=2, lwd=2)
points(fit.msbp.2$density$postLowDens~fit.msbp.2$density$xDens, ty='l',lty=2, lwd=2)

}
}
