\name{cutoff}
\alias{cutoff}
\title{Finding the optimal cutoff value for segmentation}
\description{
This function reads the picture provided in a path and performs image segmentation in a gray scale version of the picture at different values of color between 0 and 1 depending of the background color. If the background is black the function will segment the picture at values of 0.01 to 0.12 and if a white background is used values 0.5 to 0.8 will be used in order to determine the optimal value of segmentation, such values can be modified by the user in the argument `prefs`. The resulting images at different cutoff values will be stored in a folder created with the name `cutoff_vals` in the same folder provided by the user.  
}
\usage{
cutoff(folder, cores = 1, prefs = NULL)
}
\arguments{
  \item{folder}{A path where the sample pictures are located.}
  \item{cores}{A scalar value indicating the number of cores that you want to use for parallelizing the function, default is 1}
  \item{prefs}{a vector containing the values of the cutoffvalues to be used in the analysis.}
}
\details{
In image analysis segmentation can be done based on different parameters, the most common way to do it is by maximizing the contrast of a background with the object of study (i.e. fruits). Most software uses white or black backgrounds to maximize the contrast with the objects, but a cuttoff value needs to be set in order to get accurate estimates of the objects in the pictures. GiNA has been optimized to be used with any background but an initial cutoff value needs to be provided to the core function \code{\link{scanCRAN}}. The purpose of this function is to try different cutoff values and decide the optimal.
}
\value{
If parameters are indicated correctly the function returns:
\describe{
\item{$pics}{pictures in a folder named "cutoff_vals" with different values for segmentation to help the user define the optimum cutoff value for the crop.}
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
?cutoff
cutoff(folder, cores=1) # RUN

}
