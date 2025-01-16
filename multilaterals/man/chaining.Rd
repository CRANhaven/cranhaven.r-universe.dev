\name{chaining}
\alias{chaining}

\title{
Generate chained index numbers
}
\description{
This function computes chained index numbers using the Laspyeres, Paasche, Fisher and Tornqvist formulas. It also provides the Paasche-Laspeyres spreads.
}
\usage{
chaining(data.x, data.y)
}
\arguments{
  \item{data.x}{
   A data frame containing data on prices or quantites. To get a quantity index, data.x should contain information on quantities. To get a price index, data.x should contain info on prices. Each column should represent an item of the basket. Temporal and spatial dimensions are represented by row, as in 'long' formats. Neither id nor time variables should be included among the columns.
}
  \item{data.y}{
  A data frame containing data on prices or quantites. It represents the weights to be used in weighting data contained in data.x. To get a quantity index, data.y should contain information on prices. To get a price index, data.y should contain info on quantities. Each column should represent an item of the basket. Temporal and spatial dimensions are represented by row, as in 'long' formats. Neither id nor time variables should be included among the columns.
}
}

\value{
It returns the data frame containing the chained indexes and the Paasche-Laspeyres spreads. 
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
chaining(rail_out_q,rail_out_p)

}