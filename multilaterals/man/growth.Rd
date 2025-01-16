\name{growth}
\alias{growth}
\title{
Compute growth rates of indexes
}
\description{
This function computes growth rates of variables for panel data sets.
}
\usage{
growth(dataset, var.agg)
}
\arguments{
  \item{dataset}{
 A data frame containing numerical data, id and time variables. The panel should be arranged in long format. 
}
  \item{var.agg}{
   The name of id variables contained in the dataset. The temporal dimension should be the first element while the spatial should be the second one.
}
}

\value{
It returns the data frame of growth rates indexed by time and id.
}

\author{
Edoardo Baldoni
}

\examples{

library(parallel)
library(igraph)
library(ape)

data('multil_data')
indx = multilateral(dat.q,dat.p,var.agg=c('year','region'),
 transitivity = 'mst', bench = 1, period =2010,
 idx = 'fisher', PAR= FALSE, Cores = detectCores(),plotting= FALSE)
 
indx = as.data.frame(do.call('cbind',list(indx)))
names(indx) = 'indx'
## try
indx$year = substr(rownames(indx),start=nchar(rownames(indx))-3,stop=nchar(rownames(indx)))
indx$region = substr(rownames(indx),start=nchar(rownames(indx))-6,stop=nchar(rownames(indx))-5)

growth(indx, var.agg=c('year','region'))

}
