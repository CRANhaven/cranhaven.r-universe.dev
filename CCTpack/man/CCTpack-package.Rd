\name{CCTpack-package}
\alias{CCTpack-package}
\alias{CCTpack}
\docType{package}
\title{
CCTpack: Consensus Analysis, Model-Based Clustering, and Cultural Consensus Theory Applications
}
\description{
An R package for advanced model-based analyses of questionnaire data. These models can detect
the consensus answers of the respondents, and perform a model-based clustering of the respondents.
The methods can detect latent subgroups in the data, their differing consensuses, the expertise
of each respondent, their response biases, and the difficulty of each question. The ability to
parse the variance of the data, by these factors, results in sophisticated analyses of the 
consensus answers, the clusters, and the respondent knowledge/expertise. These are advanced models 
that are fit using hierarchical Bayesian inferential methods. Bayesian sampling routines are currently 
handled with JAGS (please install beforehand: mcmc-jags.sourceforge.net/). The package can currently handle
data from questionnaires of binary responses, ordered categorical, or continuous responses. If not already in
this format, your data might be appropriately transformed to one of these scales to be fit by these models. 
The models are based on mathematical publications in the domain of Cultural Consensus Theory 
(CCT): the General Condorcet Model (GCM), the Latent Truth Rater Model (LTRM), and the Continuous Response 
Model (CRM). See the relevant literature listed in the reference manual for more information about these CCT models 
and methods. Respectively, these models are applicable to dichotomous/binary (0,1), ordinal (1, 2, ...), 
and continuous data. In addition, there is functionality for component analyses/scree plots of the data, 
automatic plots of the model results, diagnostics for quality of fit, and exporting these plots/results.   
}
\details{
\tabular{ll}{
Package: \tab CCTpack\cr
Type: \tab Package\cr
Version: \tab 1.5.2 \cr
Date: \tab 2017-10-10\cr
License: \tab GPL (>= 2) \cr
}
1. Make sure you have JAGS installed \cr
2. To install CCTpack use command: install.packages("CCTpack",dependencies=TRUE) \cr
3. To load CCTpack use command:    library(CCTpack) \cr
4. Type ?cctapply to get a walkthrough with example data
5. For more information on the models and methods used, see the References section. \cr
}
\author{
Royce Anders

Maintainer: Royce Anders <andersr@uci.edu>
}
\references{
Anders, R., Oravecz, Z., & Batchelder, W. H. (2014). Cultural consensus theory for continuous responses: A latent appraisal model for information pooling. Journal of Mathematical Psychology, 61, 1-13. \cr \cr
Anders, R., & Batchelder, W. H. (2015). Cultural consensus theory for the ordinal data case. Psychometrika, 1-31. \cr \cr
Anders, R., & Batchelder, W. H. (2012). Cultural consensus theory for multiple consensus truths. Journal for Mathematical Psychology, 56, 452-469. \cr \cr
Batchelder, W. H., & Anders, R. (2012). Cultural consensus theory: comparing different concepts of cultural truth. Journal of Mathematical Psychology, 56,
316-332. \cr \cr
Oravecz, Z., Anders, R. & Batchelder, W. H. (2015). Test theory without an answer key in a Bayesian hierarchical modeling framework. Psychometrika, 1-24.\cr \cr
}
%\keyword{
%}
\seealso{
To install JAGS, see:    mcmc-jags.sourceforge.net/
}
%\examples{
%}
