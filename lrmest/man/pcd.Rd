\name{pcd}
\alias{pcd}
\docType{data}
\title{
Portland Cement Dataset
}
\description{
These data come from an experiment investigation of the heat evolved during the setting and hardening of Portland cements of varied composition and the dependence of this heat on the percentages of four components in the clinkers from which the cement was produced.    
}
\usage{data(pcd)}
\format{
  A data frame with 13 observations on the following 5 variables.
  \describe{
    \item{\code{Y}}{The heat evolved after 180 days of caring. (Calories per gram)}
    \item{\code{X1}}{Tricalcium Aluminate.}
    \item{\code{X2}}{Tricalcium Silicate.}
    \item{\code{X3}}{Tetracalcium Aluminoferrite.}
    \item{\code{X4}}{\eqn{\beta} Dicalcium Silicate.}
  }
}
%\details{
%%  ~~ If necessary, more details than the __description__ above ~~
%}
%source{
%%  ~~ reference to a publication or URL from which the data were obtained ~~
%}
\references{
Mishra, S.K. (2004) \emph{Estimation under Multicollinearity: Application of Restricted Liu and Maximum Entropy Estimators to the Portland Cement Dataset},North-Eastern Hill University (NEHU).
}
\examples{
data(pcd)
}
\keyword{datasets}
