\name{rove}
\alias{rove}
\docType{data}
\title{Sperm Precedence Data from the Rove Beetle}
\description{Offspring counts and proportional paternity by mating order for a breeding experiment of the rove beetle conducted by T Benken et al., (1999).}
\usage{data(rove)}
\format{
  A data frame with 17 observations on the following 4 variables.
  \describe{
    \item{\code{Female}}{a numeric vector to identify females.}
    \item{\code{Total_Offspring}}{total number of offspring for the female.}
    \item{\code{P2}}{proportional paternity of the second male.}
    \item{\code{No_2nd_Male}}{number of offspring sired by the second male.}
  }
}

\source{T. Benken, A. Knaak, C. Gack, M. Eberle, and K. Peschke (1999) Variation of sperm precedence in the rove beetle, \emph{Aleochara curtula} (Coleoptera: Staphylinidae), \emph{Behaviour} \bold{136}, 1065-1077.}

\examples{
#Fit rove beetle data to the normal distribution and test goodness of fit.
data(rove)
fit_dist_norm(rove$Total_Offspring) 
}
\keyword{datasets}
