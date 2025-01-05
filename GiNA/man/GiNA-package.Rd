\name{GiNA-package}
\alias{GiNA}
\docType{package}
\author{
Luis Diaz-Garcia, Giovanny Covarrubias-Pazaran, Brandon Schlautman, Juan Zalapa.
}
\title{Software for high throughput phenotyping of fruit crops}
\description{GiNA is a package designed for automatic highthoroughput phenotyping analysis of images. The program was conceived to read files with .JPG and .TIFF extensions (which stands for Joint Picture Experts Group) and uses image segmentation based on the \code{\link{EBImage}} package in order to recognize fruits and compute its features such as area, perimeter, color (in 3 channels), shape and volume to be used for GWAS, QTL or descriptive studies. The core of the package relays in 3 functions; 1) \code{\link{cutoff}} is the function in charge of determining the best cut off value for segmentation, the color scale in R goes from 0 to 1 and in other siftwares from 0 to 265, the function detects the color of the background (black or white) and returns several pictures of segmentation at different cutoff values in order to pick the most suitable for your crop, 2) \code{\link{pixArea}} reads the pictures and returns a plot with the pixel area for each object in the picture in order to provide an estimate of the minimum value to use in the real analysis, the value obtained from this function should be passed to the \code{\link{scanCRAN}} function as the minArea to discard all noise from the picture, 3) \code{\link{scanCRAN}} is the core of the package and performs image analysis for all pictures stored in the folder path provided at the cutoff value selected. The output from the \code{\link{scanCRAN}} function is a list structure with each element of the list being a dataframe with all measurements for the fruits or objects found in the picture.

Additional plotting functions to visualize the data have been provided such as \code{\link{color.plot}} which displays the digital color detected by the computer for each picture, the input of this function is the output of the scanCRAN function. The function \code{\link{jet.scan}} returns a heat.map of the variability found in the pictures and takes the same input than `color.plot` function. For additional information such as tutorials and most recent releases please visit our website http://cggl.horticulture.wisc.edu/software/. 

We have spent valuable time developing this package, please cite it in your publication:

Diaz-Garcia L, Covarrubias-Pazaran G, Schlautman B, Zalapa J. GiNA: A flexible high throughput phenotyping tool. http://horticulture.wisc.edu/cggl/ZalapaLab/People.html. 2015.
}

\references{
Diaz-Garcia L, Covarrubias-Pazaran G, Schlautman B, Salazar W, Zalapa J. (2015) GiNA: A flexible high throughput phenotyping tool. http://horticulture.wisc.edu/cggl/ZalapaLab/People.html. 2015.

Ben Hui Liu. 1998. Statistical Genomics. CRC Press LLC. ISBN 0-8493-3166-8.
}
\keyword{ package }
\seealso{
http://cggl.horticulture.wisc.edu/software/
}
\examples{
####=========================================####
#### For CRAN time limitations most lines in the 
#### examples are silenced with one '#' mark, 
#### remove them and run the examples
####=========================================####

###########################################
###            GiNA package            ####
###########################################

# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #
###########################################
### call library 
library(GiNA)

### XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #
###########################################
### EXPLORE YOUR DATA FIRST TO DETERMINE THE 'minArea' AND 'cutoff' VALUES
### indicate folder where sample pictures are, i.e.
### folder <- "C:/Users/zalapalab/Desktop/examp"

### for demonstration purposes we will call a sample picture
### included in the package, run the following 4 lines

data(GINA.sample) # RUN
display(GINA.sample)
writeImage(GINA.sample, "gina_cran.JPG") # RUN
folder <- getwd() # RUN

### XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #
############################################
### check the best cutoff values for your pictures

?cutoff
cutoff(folder, cores=1) # RUN

### go to your working directory and analyze the segmentation
### results, you will agree with us than 0.5 is the best value
### for segmentation in the 'cutoff_vals' folder FOR THIS SAMPLE PICTURE

### XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #
############################################
### check the best minimum area (in pixels) 
### to get rid of little trashes in the picture
### can be provided to the scanCRAN function if 
### you don't like the default

?pixArea
#area <- pixArea(folder,cutoffvalue=0.5,cores=1) # RUN!!!

### XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #
###########################################
### RUN the scanCRAN function providing your
### cutoff and minimum area values found previously

?scanCRAN
#folder <- getwd()
#mydata <- scanCRAN(folder,cutoffvalue=0.5,cores=1, fact = 1) # RUN!!!
#str(mydata) # RUN!!!

### XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #
###########################################
### see colors of your fruits in each picture

#color.plot(mydata) # RUN!!!
#jet.scan(mydata, var=3) # RUN!!!

### XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #
###########################################

}