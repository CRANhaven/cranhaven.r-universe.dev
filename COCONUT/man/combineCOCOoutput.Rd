
\name{combineCOCOoutput}
\alias{combineCOCOoutput}

\title{
Combine COCONUT output from multiple objects into a single object
}
\description{
Combine COCONUT output from multiple objects into a single object. Makes pooled analysis of COCONUT-co-normalized data easier. 
}
\usage{
combineCOCOoutput(COCONUT.out)
}
\arguments{
  \item{COCONUT.out}{
Output from a call to COCONUT().
}
}
\details{
The output from COCONUT() can be a bit daunting, and the separate dataobjects remain separated by input cohort, plus are separated into control and diseased components. 

}
\value{
This function will knit all data together into a list with three parts: 
\item{gene}{
contains a single matrix with all COCONUT-conormalized data (both control and disease)
}
\item{pheno}{
contains a single data.frame with all phenotype info from the input samples, but ONLY from those columns whose colnames are same across all cohorts
}
\item{class.cntl0.dis1}{
a binary vector that contains control/disease assignment for all columns in $genes.
}
}
\references{
Sweeney TE et al., "Robust classification of bacterial and viral infections via integrated host gene expression diagnostics", 2016
}
\author{
Timothy E Sweeney, MD, PhD (tes17 [at] stanford [dot] edu)
}

\examples{
data(GSEs.test)

## apply COCONUT to a very small test case
## (3 datasets with 10 patients and 2000 genes)
GSEs.COCONUT <- COCONUT(GSEs=GSEs.test,
                        control.0.col="Healthy0.Sepsis1",
                        byPlatform=FALSE)

## combine output
GSEs.COCO.combined <- combineCOCOoutput(GSEs.COCONUT)
str(GSEs.COCO.combined)

}

