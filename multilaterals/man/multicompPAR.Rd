\name{multicompPAR}
\alias{multicompPAR}

\title{
   multicompPAR
}
\description{
  This function computes transitive index numbers for cross-sections and panel data using either the EKS or the Minimum-spannin-tree method. It can distribute workload accross multiple CPUs.
}
\usage{
multicompPAR(data.x, data.y, idx, transitivity, var.agg, bench, period,
 plotting = FALSE, Cores)
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
    The time and id variables of the data frames. In the case of panel data this should be a vector of two elements where the first element is the name of the column (of data.x and data.y) that contains the time dimension, while the second element is the name of the column that contains the spatial dimension.
}
  \item{bench}{
    The id of the benchmark unit.
}
  \item{period}{
     The benchmark period. For cross-sectional data it should be set to NULL. 
}
  \item{plotting}{
    If set to TRUE, it plots the minimum-spanning-tree. It is not available for transitivity='eks'.
}
  \item{Cores}{
     Numbers of CPUs to be used for the calculations.
}
}
\details{
The function uses the function makePSOCKcluster from the parallel package to set up the cluster. No other parallel package is included yet.
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
library(parallel)

data('multil_data')
multicompPAR(dat.q,dat.p,transitivity='mst',var.agg=c('year','region'),
 bench=1,period=2010,idx='fisher',Cores=1,plotting=FALSE)
}
