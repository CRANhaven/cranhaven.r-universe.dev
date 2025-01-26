\name{soap}
\alias{soap}
\docType{data}
\title{Sperm Precedence Data from the Soapberry Bug}
\description{Offspring counts and proportional paternity by mating order for a breeding experiment of the soapberry bug conducted by SP Carroll (1991).}
\usage{data(soap)}
\format{
  A data frame with 18 observations on the following 4 variables.
  \describe{
    \item{\code{Female}}{a numeric vector to identify females.}
    \item{\code{P2}}{proportional paternity of the second male.}
    \item{\code{Total_Offspring}}{total number of offspring for the female.}
    \item{\code{No_2nd_Male}}{number of offspring sired by the second male.}
  }
}

\source{S. P. Carroll (1991) The adaptive significance of mate guarding in the soapberry bug, \emph{Jadera haematoloma} (Hemiptera: Rhopalidae), \emph{Journal of Insect Behavior}, \bold{4}, 509-530.}

\examples{
#Fit soapberry bug data to the normal distribution and test goodness of fit.
data(soap)
fit_dist_norm(soap$Total_Offspring)
}
\keyword{datasets}
