\name{cctcat}
\alias{cctcat}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Accessor function for the model-estimated category boundaries (obtained from the model applied to the data). Applicable for the LTRM model only. 
}
\description{
Outputs a table read out of the category boundary parameters of the model inference, as well as their credible intervals (posterior highest density intervals, HDIs), for each cluster.
}
\usage{
cctcat(cctfit)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cctfit}{The \code{cctfit} object as obtained from the \code{cctapply()} function.}
}
\examples{
data(raterdata)
# cctfit <- cctapply(data = raterdata, clusters = 1, itemdiff = TRUE, samples = 10000, 
#                     chains = 3, burnin = 2000, runchecks = FALSE)
# cctcat(cctfit)
}
