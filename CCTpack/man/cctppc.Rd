\name{cctppc}
\alias{cctppc}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Calculate or Plot the Posterior Predictive Model Checks
}
\description{
Plots (and calculates if not calculated already), the posterior predictive model checks for the cctfit object
}
\usage{
cctppc(cctfit, polych = FALSE, doplot = TRUE)
}
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
  \item{polych}{used for ordinal data only, if the polychoric correlations, rather than Pearson correlations, should be used (for the posterior predictive checks) -- these take a long time to calculate but are more precise in the ordinal data case.}
  \item{doplot}{If the diagnostics should be plotted.}
}
\details{
Generates 500 posterior predictive data sets that are randomly sampled from the posterior predictive data; it uses these to calculate 2 posterior predictive checks that respectively pertain to fitting the consensus structure of the data (the number of latent cultures), and if heterogeneous item difficulty should be used.
}
\value{
returns the cctfit object with the posterior predictive data and checks saved. 
}
\examples{
data(hotcold)
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# cctfit <- cctppc(cctfit)
}
