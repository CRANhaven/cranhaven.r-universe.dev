\name{ABC_P2_norm}
\alias{ABC_P2_norm}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ABC Extimation of P2 for Normal Distribution}
\description{This function fits offspring data to a special case of the normal distribution, in which zero and negative values of offspring are excluded, and estimates P2 based on that distribution and the specificed priors.}
\usage{
ABC_P2_norm(n, ObsMean, M_Lo, M_Hi, SD_Lo, SD_Hi, delta, iter)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n}{number of observations.}
  \item{ObsMean}{the observed mean number of offspring sired by the second male.}
  \item{M_Lo}{minimum mean value for the distribution.}
  \item{M_Hi}{maximum mean value for the distribution.}
  \item{SD_Lo}{minimum standard deviation value for the distribution.}
  \item{SD_Hi}{maximum standard deviation value for the distribution.}
  \item{delta}{maximum allowed difference between the estimated mean and observed mean number of offspring produced by the second male.}
  \item{iter}{number of iterations used to build the posterior.}
}

\value{
	\item{posterior}{Posterior distribution of P2 values.}
	\item{Avg}{Vector of values for the mean parameter.}
	\item{Std}{Vector of values for the standard deviation parameter.}
	}

\author{M. Catherine Duryea, Andrew D. Kern, Robert M. Cox, and Ryan Calsbeek}


%% ~Make other sections like Warning with \section{Warning }{....} ~


\examples{
#Fit the Mean and Standard Deviation hyperpriors to a distribution of offspring. 

data(fungus)
fit_dist_norm(fungus$Total_Offspring)

#Use hyperiors and priors calculated from the data to estimate P2. 
#Plot the saved distributions for the Mean and Standard Deviation parameters.
#Adjust, if necessary.

fungus_P2<-ABC_P2_norm(12, 9.9, 11.35, 17.31, 8.22, 12.44, 0.1, 100)
hist(fungus_P2$posterior)
hist(fungus_P2$Avg)
hist(fungus_P2$Std)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
