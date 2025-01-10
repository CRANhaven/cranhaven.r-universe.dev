\name{shoshsite}
\docType{data}
\alias{shoshsite}
\title{Site Data for the Shoshone National Forest, Wyoming, USA}
\description{
The coniferous forests of the Shoshone National Forest range from lower
elevation woodlands dominated by \emph{Pinus flexilis}, through forests of \emph{
Pseudotsuga menziesii, Pinus contorta, Picea engelmannii, Abies lasiocarpa} and
\emph{Pinus albicaulis} with increasing elevation (Steele et al. 1983).  One
hundred and fifty sample plots were chosen at random from a larger set for this
data set; the larger set was stratified by elevation, exposure, surficial
geology, and geographic distribution.}

\usage{data(shoshsite)}
\format{A data.frame with sample plots as rows, and site variable as columns.  Variables
comprise:
\tabular{ll}{
elevation \tab elevation above sea level in meters\cr
aspect \tab compass orientation of the site in degrees\cr
slope \tab slope steepness in percent\cr
av \tab aspect value:  (cosd(aspect-30)+1)/2\cr
swb \tab site water balance: a tipping bucket model of water-year soil water\cr
sprppt \tab spring precipitation in cm\cr
sumppt \tab summer precipitation in cm\cr
autppt \tab autumn precipitation in cm\cr
winppt \tab winter precipitation in cm\cr
sprtmp \tab spring mean temperature degrees C\cr
sumtmp \tab summer mean temperature degrees C\cr 
auttmp \tab autumn mean temperature degrees C\cr
winppt \tab winter mean temperature degrees C\cr
sprpet \tab spring potential evapotranspiration in cm\cr
sumpet \tab summer potential evapotranspiration in cm\cr
autpet \tab autumn potential evapotranspiration in cm\cr
winpet \tab winter potential evapotranspiration in cm\cr
sprrad \tab spring direct and diffuse solar radiation (correcting for topographic
shading)\cr
sumrad \tab summer direct and diffuse solar radiation (correcting for topographic
shading)\cr
autrad \tab autumn direct and diffuse solar radiation (correcting for topographic
shading)\cr
win \tab winter direct and diffuse solar radiation (correcting for topographic
shading)\cr
ffd \tab frost free days\cr
dday \tab degree days heat sum\cr
tcol \tab mean monthly temperature of the coldest month\cr
}
}

\note{The data were derived from a multi-year effort by numerous scientists and
field technicians.  The project was directed by Kent Houston, Soil Scientist and
Ecologist, Shoshone National Forest.  The site data were calculated primarily
by Dr. Niklaus Zimmermann, WSL, Birmensdorf, Switzerland 
\url{http://www.wsl.ch/staff/niklaus.zimmermann/biophys.html}
}
\source{Roberts, D.W.  2008.  Statistical Analysis of Multidimensional
Fuzzy Set Ordinations.  Ecology 89:1246-1260}
\keyword{datasets}

