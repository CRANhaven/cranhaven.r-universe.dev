\name{fungus}
\alias{fungus}
\docType{data}
\title{Sperm Precedence Data from the Fungus Beetle}
\description{Offspring counts and proportional paternity by mating order for a breeding experiment of the fungus beetle conducted by JK Conner (1995).}
\usage{data(fungus)}
\format{
  A data frame with 12 observations on the following 4 variables.
  \describe{
    \item{\code{Female}}{a numeric vector to identify females.}
    \item{\code{P2}}{proportional paternity of the second male.}
    \item{\code{Total_Offspring}}{total number of offspring for the female.}
    \item{\code{No_2nd_Male}}{number of offspring sired by the second male.}
  }
}

\source{J. K. Conner (1995) Extreme variability in sperm precedence in the fungus beetle, \emph{Bolitotherus cornutus} (Coleoptera Tenebrionidae), \emph{Ethology Ecology & Evolution} \bold{7}, 277-280.}

\examples{
#Fit fungus beetle data to the normal distribution and test goodness of fit.
data(fungus)
fit_dist_norm(fungus$Total_Offspring)

}
\keyword{datasets}
