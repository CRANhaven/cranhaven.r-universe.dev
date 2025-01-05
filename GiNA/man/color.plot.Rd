\name{color.plot}
\alias{color.plot}
\title{Analyzing the digital color of objects}
\description{
This function was design to assess the color output of the \code{\link{scanCRAN}} function by drawing the digital color detected by the program in a way that the user can assess the colors that the computer is detecting for each object in the picture.
}
\usage{
color.plot(x, cex.axis = 0.7, cex = 5)
}
\arguments{
  \item{x}{the data to be used for plotting, should be the output from the `scanCRAN function.}
  \item{cex.axis}{the size of the dots in the plot}
  \item{cex}{the size of the font of the x labels}
}
\value{
If parameters are indicated correctly the function returns:
\describe{
\item{$plot}{a plot showing the digital color detected by the program for each of the objects found in the picture.}
}
}
\references{
We have spent valuable time developing this package, please cite it in your publication:

Diaz-Garcia L, Covarrubias-Pazaran G, Schlautman B, Zalapa J. GiNA: A flexible high throughput phenotyping tool. http://horticulture.wisc.edu/cggl/ZalapaLab/People.html. 2015.
}
\examples{
## x <- ScanCran(folder=0.8,minArea=6000)
## color.plot(x, cex.axis = 0.7, cex = 5)
}