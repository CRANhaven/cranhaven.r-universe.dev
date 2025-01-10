\name{confus}
\alias{confus}
\alias{fuzconfus}
\title{(Fuzzy) Confusion Matrix}
\description{A confusion matrix is a cross-tabulation of actual class
membership with memberships predicted by a discriminant function,
classification tree, or other predictive model.
A fuzzy confusion
matrix is a confusion matrix that corrects for \sQuote{near misses}
in prediction by comparing the similarity of the predicted type to
the actual type and giving credit for the similarity.}
\usage{confus(clustering,model,diss=NULL)}
\arguments{
    \item{clustering}{an object of class \sQuote{clustering} or
a vector of (integer or factor) class membership values}
    \item{model}{a predictive model of class \sQuote{tree} or \sQuote{randomForest}}
    \item{diss}{optionally, a dissimilarity object of class \sQuote{dist} from
    \sQuote{dist}, \sQuote{dsvdis}, or \sQuote{vegdist}}
}
\details{Cross-classifies each sample by actual class membership and
predicted membership, computing overall accuracy, and the Kappa
statistic of agreement.  If a dissimilarity matrix is passed, calculates a 
fuzzy confusion matrix.
In this case, correct predictions are assigned values of 1.0, and other predictions are given the value of the
similarity of the two types an placed on the diagonal.  The dissimilarity of the two types is added off
the diagonal as fuzzy error.



}

\value{produces a list with elements
\item{matrix}{the (fuzzy) cross-tabulation matrix as a data.frame}
\item{correct}{the fraction of (fuzzily) correctly predicted samples}
\item{kappa}{the value of the Kappa statistic}
\item{legend}{the text legend for the cross-tabulation matrix}
}
\references{\url{http://ecology.msu.montana.edu/labdsv/R}}
\note{Confusion matrices are commonly computed in remote sensing
applications, but are equally suited to the evaluation of any
predictive methods of class membership or factors.}
\author{
    David W. Roberts
    \email{droberts@montana.edu}
    \url{http://ecology.msu.montana.edu/labdsv/R}
}
\examples{
data(shoshveg) # returns a data frame of vegetation data
data(shoshsite) # returns a data frame of site data
dis.bc <- dsvdis(shoshveg,'bray')
opt.5 <- optpart(5,dis.bc)
library(tree)
mod <- tree(factor(opt.5$clustering)~ elevation+slope+av,
            data=shoshsite)
confus(opt.5,mod)
confus(opt.5,mod,dis.bc)
}
\keyword{htest}
