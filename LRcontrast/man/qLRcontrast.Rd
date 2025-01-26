\name{qLRcontrast}
\alias{qLRcontrast}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Simulate quantiles of LR contrast tests in regression models with a lack of identifiability.
}
\description{
The function simulates the desired quantiles of the distribution of LR contrast tests. The competing models can be specified 
by the argument 'models' (see \code{\link[DoseFinding]{drmodels}}). The argument 'dose' is the vector of the different unique 
dose-levels and 'weight' specifies the weight proportion of each dose group. By 'nsim' you can specify how many simulation should 
be done. It is recommended to do about 10000 but notice that the simulation can take some time. If the parameter 'info' is set 
'TRUE', information of the progress will be shown.
}
\usage{
qLRcontrast(dose, probs, models, weight = rep(1/length(dose), length(dose)), 
            off = 0.01 * max(dose), scal = 1.2 * max(dose), nsim = 10000, info = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dose}{
A vector which contains the unique dose-levels.
}
  \item{probs}{
A vector of probabilities with values in \eqn{[0,1]} specifying which quantiles should be calculated.
}
  \item{models}{
A subvector of c("linear", "emax", "exponential", "linlog", "sigEmax", "quadratic", "betaMod", "logistic") (see \code{\link[DoseFinding]{drmodels}})
which specifies the competing models.
}
  \item{weight}{
A vector with values in \eqn{[0,1]} with 'sum(weight) = 1'. The i-th entry specifies the weight proportion of the i-th dose group.
}
  \item{off}{
Positive and fixed offset parameter in the 'linlog' model (see \code{\link[DoseFinding]{drmodels}}).
}
  \item{scal}{
Positive and fixed dose scaling parameter in the 'betaMod' with '\eqn{scal\ge} max(dose)' (see \code{\link[DoseFinding]{drmodels}}).
}
  \item{nsim}{
A positive integer which specifies the number of simulations that should be done.
}
  \item{info}{
Logical value which indicates whether progress information should be shown.
}
}
\value{
A matrix containing the different quantiles for one model in each row. The last row contains the quantiles of the maximum statistic.
}
\references{
Dette, H., Titoff, S., Volgushev, S. and Bretz, F. (2015), Dose
response signal detection under model uncertainty. Biometrics. doi:
10.1111/biom.12357
}
\author{
Kevin Kokot
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link[DoseFinding:DoseFinding-package]{DoseFinding}}
}
\examples{
# Simulate the 90%, 95% and 99% quantiles of the LR contrast tests where the specified 
# models are competing against each other.
# The size of each dose group is equal in this case. 

qLRcontrast(dose = c(0, 0.05, 0.2, 0.6, 1), probs = c(0.9, 0.95, 0.99), 
            weight = c(0.2, 0.2, 0.2, 0.2, 0.2), models = c("linear", "emax", 
            "exponential", "linlog"), nsim = 10)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
