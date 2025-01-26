\name{cctgui}
\alias{cctgui}
\title{
The CCT GUI
}
\description{
There is a graphical user interfance available, though it is deprecated / being phased out -- it is not compatible with all operating systems. 

Instructions how to use the GUI:
1. Type 'cctgui()' in the R command prompt to start the CCT GUI \cr
2. Click "Load data" (data must be in csv format as a .csv or .txt file) \cr
      data format: respondents (rows) by items (columns), csv format, no row/column names necessary \cr
	               the models can handle missing data, missing data should be input as NA \cr
3. Verify that the number of respondents, items, and data type the GUI detects is correct. \cr
4. Check the number of significant factors in the scree plot \cr 
5. Use this as "the number of cultures to assume," and select an item difficulty option \cr
6. Click "Apply CCT Model" \cr
7. Check inference results (if the number of Rhats is appropriate); \cr if not, one could try running more samples, or a different number of cultures \cr 
8. Click "Run Checks" to run the posterior predictive checks, and verify if they are satisfied. \cr Note: the CCT method suggests 
that the fewest number of cultures to pass the checks should be the model used. \cr
9. Click "Plot Results" to see the posterior results \cr
10. Click "Export Results" to save the model fit and plots. \cr
}
\usage{
cctgui()
}
%\details{
%}
\value{
All information will be saved in the 'cctfit' object. This is in the same structure as the 'jagsfit' object returned by the function jags(), which utilizes the 'rjags' and 'R2jags' packages. 
}
%\references{
%}
\author{
Royce Anders
}
%\note{
%}
\examples{
#First visit  'mcmc-jags.sourceforge.net/' to install JAGS (Plummer, 2003) if it's not installed

####################
#Instructions for Using the GUI
####################

#1) Convert your data into a .csv file
### Or use our example data such as with the following commands: 

data(hotcold); 
write.csv(x=hotcold, file="hotcold.csv",row.names=FALSE)

#2) Invoke the GUI 

cctgui()

#Click "Load Data" then find and select "hotcold.csv"
#Note that 23 respondents, 27 items are detected, 
#      and that it is Dichotomous (binary) data, which the GCM is applicable for
#      the GUI detects that there are 14 missing data values in the matrix
#Click "Scree Plot"  Note that there are 2 apparent significant factors, 
#      thus we assume 2 cultures in the data, click "yes" to estimate item difficulty
#Click "Apply CCT Model" and wait for the inference to finish
#Take note of the Number of Rhats above 1.1 (if too many, perhaps run more samples)
#Click "Run Checks" to run the posterior predictive checks, wait for the checks to complete
#Note that the model satisfies both checks in the plots shown
#Proceed to inspect the inference results by clicking "Plot Results"
#type 'cctfit$MVest' to view the model estimates of the 14 missing data values
#Click "Export Results" to save the plot and the inference results
#The Inference results are included in the object 'cctfit'
#Type 'cctfit' in the R prompt to see the summary, 
#   type 'str(cctfit)' to see what the object contains

####################
#2) Instructions for Using the Command Prompt
####################

#The corollary to the GUI instructions above, for the command line, is below

data(hotcold);   #for an ordinal data example, use data(raterdata)

#Loads data and provides the Scree Plot
# cctscree(data = hotcold)

#Loads data and Runs the Inference    			
# cctfit <- cctapply(data = hotcold,clusters=2,itemdiff=TRUE,samples=10000,
#                     chains=3,burnin=2000,runchecks=FALSE)  

#Calculates and Plots Posterior Predictive Checks
# cctfit <- cctppc(cctfit)

#Show Missing Value Model Estimates if there was missing data
# cctfit$MVest

#Plots Posterior Results
# cctresults(cctfit) 		  

#Exports Results
# cctexport(cctfit,filename="CCTpackdata.Rdata") 

##Note: if an insufficient memory message occurs, you can increase the
##memory allocation by the command 'memory.limit(25000)'  (or as high as needed)
}
