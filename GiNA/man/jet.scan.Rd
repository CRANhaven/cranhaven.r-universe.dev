\name{jet.scan}
\alias{jet.scan}
\title{Assessing variability for measurements using jet plot}
\description{
Same than \code{\link{color.plot}} function, this function was designed to assess the results from the \code{\link{scanCRAN}} function by providing the output of such function and draw plots showing the variation found in the objects measured in each object.
}
\usage{
jet.scan(mydata, var = 1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{mydata}{the data to be used for drawing the jet plot, is the output from the \code{\link{scanCRAN}} function}
  \item{var}{the variable to be plotted from several variables measured by the scanCRAN function.}
}
\value{
If parameters are indicated correctly the function returns:
\describe{
\item{$plot}{a plot showing the digital representation for the variable selected using a plot with jet colors to emphasize the variability within pictures.}
}
}
\references{
We have spent valuable time developing this package, please cite it in your publication:

Diaz-Garcia L, Covarrubias-Pazaran G, Schlautman B, Zalapa J. GiNA: A flexible high throughput phenotyping tool. http://horticulture.wisc.edu/cggl/ZalapaLab/People.html. 2015.
}
\examples{
## x <- scanCran(folder=0.8,minArea=6000)
## jet.scan(x, var = 1)
}