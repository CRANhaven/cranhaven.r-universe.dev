\name{indexes}
\alias{indexes}

\title{
  indexes: create fixed-base or chained index numbers
}
\description{
  It computes fixed-base or chained index numbers from a set of numerical variables. It computes the Laspeyres, Paasche, Fisher and Tornqvist indexes together with the Paasche-Laspeyres spreads and the matrix of factor shares.
}
\usage{
indexes(data.x, data.y, type = "fixed-base")
}
\arguments{
  \item{data.x}{
     A data frame containing data on prices or quantites. To get a quantity index, data.x should contain information on quantities. To get a price index, data.x should contain info on prices. Each column should represent an item of the basket. Temporal and spatial dimensions are represented by row, as in 'long' formats. Neither id nor time variables should be included among the columns.
}
  \item{data.y}{
  A data frame containing data on prices or quantites. It represents the weights to be used in weighting data contained in data.x. To get a quantity index, data.y should contain information on prices. To get a price index, data.y should contain info on quantities. Each column should represent an item of the basket. Temporal and spatial dimensions are represented by row, as in 'long' formats. Neither id nor time variables should be included among the columns.
}
  \item{type}{
  Type of index: 'chained' or 'fixed-base'. 
}
}

\value{
  It returns a list of two elements. The first element of the list is a data frame containing the index numbers and the Paasche-Laspeyres spreads. The second element is a matrix containing the factor shares used to compute the indexes.
}
\references{
 T. J. Coelli, D. S. Prasada Rao, C. J. O'Donnell, and G. E. Battese. \emph{An introduction to Efficiency and Productivity Analysis}, 2nd edition. Springer Science + Business Media, New York, 2005.
}
\author{
  Edoardo Baldoni
}

\examples{

# From An Introduction to Efficiency and Productivity Analysis (Coelli et al., 2005), pag. 127-130
data('multil_data')
indexes(rail_out_q,rail_out_p,'chained')$indexes
}

