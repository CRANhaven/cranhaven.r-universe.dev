\name{multilaterals}
\alias{multilaterals-package}
\alias{multilaterals}
\docType{package}
\title{
\packageTitle{multilaterals}
}
\description{
\packageDescription{multilaterals}
}
\details{

The DESCRIPTION file:
\packageDESCRIPTION{Computing transitive (and non-transitive) index numbers (Coelli et al., 2005) for cross-sections and panel data. For the calculation of transitive indexes, the EKS (Coelli et al., 2005; Ball et al. 2010) and Minimum spanning tree (Hill, 2004) methods are implemented. Traditional fixed-base and chained indexes, and their growth rates, can also be derived using the Paasche, Laspeyres, Fisher and Tornqvist formulas.}
\packageIndices{multilaterals}
}
\author{
\packageAuthor{multilaterals}

Maintainer: \packageMaintainer{multilaterals}
}
\references{
 T. J. Coelli, D. S. Prasada Rao, C. J. O'Donnel, and G. E. Battese. \emph{An introduction to Efficiency and Productivity Analysis}, 2nd edition. Springer Science + Business Media, New York, 2005.
 
 R. J. Hill. \emph{Constructing price indexes across space and time: The case of the European Union}. The American Economic Review, 94(5):1379-1410, 2004.
 
Rao D.S.P., O'Donnell C.J., Ball V.E., 2002. \emph{Transitive Multilateral Comparisons of Agricultural Output, Input, and Productivity: A Nonparametric Approach}. In: Ball V.E., Norton G.W. Agricultural Productivity. Studies in Productivity and Efficiency, vol 2. Springer, Boston, MA.
}

\keyword{ package }
%%\seealso{
%%
%% \code{\link[plyr]{plyr}}
%%}

\examples{

data('multil_data')

## From 'An introduction to Efficiency and
##  Productivity Analysis' (Coelli et al., 2005), page 124-126.
inputIndx = multilateral(data.x=billy_inp_q,data.y=billy_inp_p,var.agg='year',
 idx='fisher',PAR=FALSE,transitivity='eks',bench=2000,period=NULL )
outputIndx = multilateral(data.x=billy_out_q,data.y=billy_out_p, var.agg='year',
 PAR=FALSE,transitivity='mst',bench=2000,period=NULL )
tfpIndx = outputIndx/inputIndx



}
