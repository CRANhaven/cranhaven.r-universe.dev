\name{multilateral}
\alias{multilateral}
\title{
  multilateral: generate transitive index numbers for cross-sections and panel data 
}
\description{
  This function computes transitive index numbers for cross-sections and panel data using either the EKS or the Minimum-spannin-tree method. The workload can be distributed across multiple CPUs. The function is a wrapper for the multicomp and multicompPAR functions.
}
\usage{
multilateral(data.x, data.y, idx = "fisher", transitivity = "mst",
var.agg, bench, period, PAR = TRUE, plotting = FALSE, Cores)
}
\arguments{
  \item{data.x}{
      A data frame containing data on prices or quantites. To get a quantity index, data.x should contain information on quantities. To get a price index, data.x should contain info on prices corresponding to the quantities in data.y. Each column should represent an item of the basket. Temporal and spatial dimensions are represented by row, as in 'long' formats. Id and/or time variables must be included among the columns.
}
  \item{data.y}{
      A data frame containing data on prices or quantites. It represents the set of weights to be used in weighting data contained in data.x. To get a quantity index, data.y should contain information on prices corresponding to quantities in data.x. To get a price index, data.y should contain info on quantities. Each column should represent an item of the basket. Temporal and spatial dimensions are represented by row, as in 'long' formats. Id and/or time variables should be included among the columns.
}
  \item{idx}{
    Index number formula to be used. It should be either 'paasche', 'laspeyres', 'fisher' or 'tornqvist'. 
}
  \item{transitivity}{
   The transitivization method to be used. It should be either 'eks' or 'mst'.
}
  \item{var.agg}{
     The time and id variables of the data frames. In the case of panel data it should be a vector of two elements where the first element is the name of the column of data.x (and data.y) that contains the time dimension, while the second element is the name of the column that contains the spatial dimension.
}
  \item{bench}{
    The id of the benchmark unit.
}
  \item{period}{
     The benchmark period. For cross-sectional data it should be set to NULL. 
}
  \item{PAR}{
     If set to TRUE the indexes will be computed in parallel.
}
  \item{plotting}{
     If TRUE the plot of the minium-spanning-tree is plotted. It works only if transitivization is set to 'mst'.
}
  \item{Cores}{
     Number of CPUs to be used in the parallel calculation procedure. It works only if PAR is set to TRUE.
}
}
\details{
  It is a wrapper for the multicomp and multicompPAR functions. The function uses the function makePSOCKcluster from the parallel package to set up the cluster. No other parallel package is included yet.
}
\value{
  It returns the vector of transitive index numbers.
}
\references{
 T. J. Coelli, D. S. Prasada Rao, C. J. O'Donnell, and G. E. Battese. \emph{An introduction to Efficiency and Productivity Analysis}, 2nd edition. Springer Science + Business Media, New York, 2005.

 R. J. Hill. \emph{Constructing price indexes across space and time: The case of the European Union}. The American Economic Review, 94(5):1379-1410, 2004.

Rao D.S.P., O'Donnell C.J., Ball V.E., 2002. \emph{Transitive Multilateral Comparisons of Agricultural Output, Input, and Productivity: A Nonparametric Approach}. In: Ball V.E., Norton G.W. Agricultural Productivity. Studies in Productivity and Efficiency, vol 2. Springer, Boston, MA.
}
 
\author{
  Edoardo Baldoni
}

\examples{

library(igraph)
library(ape)
library(lattice)
library(parallel)

data('multil_data')


## Compare eks method with the mst method.
indx.mst = multilateral(dat.q,dat.p,
  idx='fisher', transitivity='mst',
   var.agg=c('year','region'),bench='1',
   period=2010,
   PAR=FALSE,
   plotting=FALSE,Cores=2)
indx.mst = as.data.frame(do.call('cbind',list(indx.mst)))
names(indx.mst) = 'mst'
indx.eks = multilateral(dat.q,dat.p,
  idx='fisher', transitivity='eks',
   var.agg=c('year','region'),bench='1',
   period=2010,
   PAR=FALSE,
   plotting=FALSE)
indx.eks = as.data.frame(do.call('cbind',list(indx.eks)))
names(indx.eks) = 'eks'
indx = cbind(indx.mst,indx.eks)
indx$year = as.numeric(substr(rownames(indx),
 start=nchar(rownames(indx))-3,stop=nchar(rownames(indx))))
indx$region = substr(rownames(indx),
 start=nchar(rownames(indx))-6,stop=nchar(rownames(indx))-5)

xyplot(mst+eks ~ year|region,indx,type='l')
   

}
