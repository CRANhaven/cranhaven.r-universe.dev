\name{scanCRAN}
\alias{scanCRAN}
\title{High throughput  phenotyping using scanCRAN}
\description{
This function is the core of the GiNA package which is in charge of reading the pictures find in the folder provided and perform the image segmentation in order to find the objects in the picture (i.e. fruits) and measure parameters such as area, perimeter, shape, volume, gray color, red, green and blue color. 
}
\usage{
scanCRAN(folder, cutoffvalue=NULL, minArea = NULL, 
        cores = 1, gray = TRUE, stand = c(0, 0), 
        fact = 0.25)
}
\arguments{
  \item{folder}{A path where the pictures are located}
  \item{cutoffvalue}{A scalar value (0-1) where the fruits are distinguishable from the background in the color scale handled by R which is 0-1. if not passed the function will determine the color of the background and assign the value of 0.08 if black and 0.6 if white. We highly recommend to use the \code{\link{cutoff}} function to find the optimum segmentation value which will determine the success of your experiment.}
  \item{minArea}{A scalar number indicating the minimum size in pixels for a real object in the picture to avoid the program to confuse some little trash with an object. The function \code{\link{cutoff}} can provide an idea of the sizes of real objects and noise. If not passed the argument uses minArea=(length/40)*(width/40), where length and width refers to the dimensions of the picture}
  \item{cores}{A scalar value indicating the number of cores that you want to use for parallelizing the function}
  \item{gray}{a TRUE/FALSE value indicating if the user want the color to bereturned in grayscale besides the RGB color}
  \item{stand}{a vector with 2 scalar values for width and length of your references}
  \item{fact}{a scalar value between 0-1 indicating at what extent the picture should be reduced in size in order to make computations faster, by default the pictures are sized at the 25 percent of their original size. If no reduction is required the user should set the argument to 1.}
}
\details{
In order to exploit the advantages of this function we highly recommend the users to determine the best cutoff value with the use of the \code{\link{cutoff}} function to achieve a good segmentation of the objects. The package is sensitive to the prescense of shades in the picture, for that reason we highly recommend the use of black background and reference circles in a clear color (i.e. white).

This is a rough idea of how you should take the pictures, where the circles are your references and the dots are your fruits. Your fruits shouldn't block the references and YOUR REFERENCES SHOULD BE ALWAYS ON THE SIDES OF YOUR PICTURE. 

O    . .  .    .  O

O  .  .  .  .  . O

O   .  .  . .  . O

For additional information such as tutorials and most recent releases 
please visit our website http://cggl.horticulture.wisc.edu/software/. 

}
\value{
If parameters are indicated correctly the function returns:
\describe{
\item{$x3}{a list of dataframes, one for each picture provided. The dataframe contains the measurements for each object (rows) found in the puncture for the variables (columns) area, perimeter, length, width, shape (ratio of length/width), volume and red, green, blue, grey color.}
}
}
\references{
We have spent valuable time developing this package, please cite it in your publication:

Diaz-Garcia L, Covarrubias-Pazaran G, Schlautman B, Zalapa J. GiNA: A flexible high throughput phenotyping tool. http://horticulture.wisc.edu/cggl/ZalapaLab/People.html. 2015.
}
\examples{

library(GiNA)
data(GINA.sample) # RUN
writeImage(GINA.sample, "gina_cran.JPG") # RUN
folder <- getwd()
mydata <- scanCRAN(folder,cutoffvalue=0.5,cores=1, fact = 1) # RUN!!!

}