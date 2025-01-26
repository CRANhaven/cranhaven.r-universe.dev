\name{cctapply}
\alias{cctapply}
\title{
Primary function to perform model-based consensus analysis: loads the data and fits the consensus model. Allows for model-based clustering based on the numbers of "clusters" specified.  Options are also available to run diagnostics on the fit, and to export the results to saved files. Based on cultural consensus theory (CCT) models for data matrices of binary, ordered categorical, or continuous response data. 
}
\description{
loads the data, fits the appropriate model, runs the posterior predictive checks, and optionally exports results 
}
\usage{
cctapply(data, clusters = 1, itemdiff = FALSE, biases = TRUE, samples = 10000, chains = 3,
         burnin = 2000, thinning = 1, runchecks = FALSE, exportfilename = "",
         polych = FALSE, parallel = FALSE, seed = NULL,plotr=FALSE)
}
\arguments{
  \item{data}{a 2-dimensional matrix or array, missing values should be input as NA.}
  \item{clusters}{The number of possible clusters (cultures) to use}
  \item{itemdiff}{Whether item difficulty should be measured and accounted for}
  \item{biases}{Whether response biases should be measured and accounted for}
  \item{samples}{The number of samples for the inference}
  \item{chains}{The number of chains for the inference}
  \item{burnin}{The number of burn-in for the inference}
  \item{thinning}{The amount of thinning in the inference}
  \item{runchecks}{If the posterior predictive checks should be calculated after the inference}
  \item{exportfilename}{If you'd like to export: specify a filename and optionally its location. Ex: \code{exportfilename = "C:/CCTpack/CCTpackdata.Rdata"}}
  \item{polych}{used for ordinal data only, if the polychoric correlations, rather than Pearson correlations, should be used (for the posterior predictive checks) -- these take a long time to calculate but are more precise in the ordinal data case.}
  \item{parallel}{Whether the inference should be computed in parallel (1 chain per logical processor)}
  \item{seed}{Set the random number seed here (to reproduce results as before). If not specified, the seed is randomly generated.}
    \item{plotr}{Whether to plot the posterior mean results for each parameter. Note: \code{runchecks = TRUE} will plot the posterior predictive checks after the posterior mean results. The posterior mean results plot can be later called via \code{cctresults()}.}
}
\details{
This is the main function to fit the consensus models. The function fits the model using hierarchical Bayesian inference. The Bayesian sampling is performed using JAGS.
}
\value{
\code{cctfit} is returned, which has the structure of a 'jagsfit' object as in Rjags, but has additional data included.
}
\examples{
# Load Data (here binary responses, 1/0 for yes/no)
data(hotcold)

# Calculate scree plot to decide how many clusters to run, looks like 2 clusters here
dat <-  cctscree(hotcold)

# Retrieve factors from the scree plot
cctfac(dat)    # dat$factors

# Fit the Model  
# cctfit <- cctapply(data = hotcold, clusters = 2, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, seed = 1, runchecks = FALSE)

# Calculate Fit Diagnostics (Posterior Predictive Checks)
# cctfit <- cctppc(cctfit)

# Plot Parameter Results
# cctresults(cctfit) 		  

# Tables of Subject and Item Parameter Values and Credible Intervals
# cctsubj(cctfit)      # cctfit$subj
# cctsubjhdi(cctfit)   # cctfit$subjhdi
# cctitem(cctfit)      # cctfit$item
# cctitemhdi(cctfit)   # cctfit$itemhdi

# Show Missing Value Model Estimates if there was missing data
# cctmvest(cctfit)

# Export Results (saves data and plots)
# cctexport(cctfit,filename="CCTpackdata.Rdata") 

# Load and Fit Example Data for ordered categorical or continuous responses
# data(raterdata)

# cctfit <- cctapply(data = raterdata, clusters = 1, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, seed = 1, runchecks = FALSE)

# data(continuousdata)
# cctfit <- cctapply(data = continuousdata, clusters = 1, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, seed = 1, runchecks = FALSE)

##Note: if an insufficient memory message occurs, you can increase the
##memory allocation by the command 'memory.limit(25000)'  (or as high as needed)
}

