\name{newt}
\alias{newt}
\docType{data}
\title{Sperm Precedence Data from the Rough-Skinned Newt}
\description{Offspring counts from two clutches and proportional paternity by mating order for a breeding experiment of the rough-skinned newt conducted by Jones et al., (2002)}
\usage{data(newt)}
\format{
  A data frame with 10 observations on the following 10 variables.
  \describe{
    \item{\code{Female}}{a numeric code to identify females.}
    \item{\code{No_1st_Clutch}}{total offspring in the first clutch.}
    \item{\code{P2_1}}{proportional paternity of the second male for the first clutch.}
    \item{\code{No_2nd_Male_1st_Clutch}}{total offspring sired by the second male from the first clutch.}
    \item{\code{No_2nd_Clutch}}{total offspring in the second clutch.}
    \item{\code{P2_2}}{proportional paternity of the second male for the second clutch.}
    \item{\code{No_2nd_Male_2nd_Clutch}}{total offspring sired by the second male from the second clutch.}
    \item{\code{Total_2nd_Male}}{total offspring sired by the second male from both clutches.}
    \item{\code{Total_Offspring}}{total offspring for both clutches.}
    \item{\code{Total_P2}}{total overall proportional paternity of the second male for both clutches.}
  }
}

\source{A. G. Jones, E. M. Adams, and S. J. Arnold (2002) A mechanism of first-male precedence in a vertebrate. \emph{Proceedings of the National Academy of Sciences of the United States of America} \bold{99}, 2078-2081.}

\examples{
#Fit newt data to the Poisson distribution and test goodness of fit.
data(newt)
fit_dist_pois(newt$Total_Offspring)
}
\keyword{datasets}
