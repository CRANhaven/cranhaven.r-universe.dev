\name{pixArea}
\alias{pixArea}
\title{
Finding the average area in pixels for objects
}
\description{
Even not required, the average value area in pixels for the objects analyzed is a parameter of interest when the objects to be analyzed are particularly small such as seeds or extremely small fruits. Therefore, the use of this function provides a plot of the are in pixels for all the objects in the picture for a given cutoff value provided. Once the value has determined this can be provided to the \code{\link{scanCRAN}} function in the argument `minArea` to make the function perform faster.
}
\usage{
pixArea(folder, cutoffvalue = 0.5, cores = 1, square = 10, fact = 0.25)
}
\arguments{
  \item{folder}{A path where the pictures are located}
  \item{cutoffvalue}{A scalar value where the fruits are distinguishable from the background in the color scale handled by R which is 0-1}
  \item{cores}{A scalar value indicating the number of cores that you want to use for parallelizing the function}
  \item{square}{size of the square to brush smaller objects from the picture}
  \item{fact}{a scalar value between 0-1 indicating at what extent the picture should be reduced in size in order to make computations faster, by default the pictures are sized at the 25 percent of their original size. If no reduction is required the user should set the argument to 1.}
}
\value{
If parameters are indicated correctly the function returns:
\describe{
\item{$plot}{a plot showing the size of different objects in the picture in number of pixels.}
}
}
\references{
We have spent valuable time developing this package, please cite it in your publication:

Diaz-Garcia L, Covarrubias-Pazaran G, Schlautman B, Zalapa J. GiNA: A flexible high throughput phenotyping tool. http://horticulture.wisc.edu/cggl/ZalapaLab/People.html. 2015.
}
\examples{
library(GiNA)
data(GINA.sample) # RUN
display(GINA.sample)
writeImage(GINA.sample, "gina_cran.JPG") # RUN
folder <- getwd() # RUN
area <- pixArea(folder,cutoffvalue=0.5,cores=1) # RUN!!!
}