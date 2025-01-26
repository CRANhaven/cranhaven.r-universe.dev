\name{PPrightAng}
\alias{PPrightAng}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ 
Right angular RPPBD
}
\description{
The configuration of right angular RPPBD obtained by applying the (ASC-RPPBD) method on a right angular association scheme.
}
\usage{
PPrightAng(n, l, w)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n}{
Number of lines of association schemes array.
}
  \item{l}{
Number of columns of association schemes array.
}
  \item{w}{
Number of the association scheme arrays.
}
 
}
\value{
A LIST :
\item{RPPBD}{The configuration of the RPPBD}
\item{v}{Number of treatments}
\item{b}{Number of blocs}
\item{r}{The repeatition of each treatments}
\item{k}{A vector of the different bloc's size}
\item{lamda}{A vector of the different values of lamda(i) (i=1,..,m)}

}
\references{
Imane Rezgui M.LAIB and Z.Gheribi-Aoulmi NEW SERIES OF RESOLVABLE PARTIALLY PAIRWISE BALANCED DESIGNS AND THEIR ASSOCIATED SPACE FILLING DESIGNS; accepted Proceeding on  Afrika Statistika.

Imane Rezgui and Z.Gheribi-Aoulmi New Series of Resolvable Partially Pairwise Balanced and Space Filling Designs via Association Schemes submitted.

S. K. Tharthare, Right angular designs, Ann. Math. Statist. 36 (1963), 1057-1067.
}
\author{
Mohamed Laib, Imane Rezgui and Zoubida Gheribi-Aoulmi
}
\examples{
n<-3
l<-3
w<-3
PPrightAng(n, l, w)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
