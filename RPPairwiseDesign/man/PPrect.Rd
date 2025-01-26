\name{PPrect}
\alias{PPrect}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Rectangular RPPBD.
}
\description{
The configuration of rectangular RPPBD obtained by applying the (ASC-RPPBD) method on a rectangular association scheme.
}
\usage{
PPrect(n, l)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n}{
Number of lines of the association schemes array
}
  \item{l}{
Number of columns of the association schemes array
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
Vartak M.N.1955. On an application of Kronecker product of Matrices to Statistical designs. Ann. Math. Stat.,26(420_438).

Imane Rezgui M.LAIB and Z.Gheribi-Aoulmi NEW SERIES OF RESOLVABLE PARTIALLY PAIRWISE BALANCED DESIGNS AND THEIR ASSOCIATED SPACE FILLING DESIGNS; accepted Proceeding on  Afrika Statistika.

Imane Rezgui and Z.Gheribi-Aoulmi New Series of Resolvable Partially Pairwise Balanced and Space Filling Designs via Association Schemes submitted.
}
\author{
Mohamed Laib, Imane Rezgui and Zoubida Gheribi-Aoulmi
}
\examples{
n<-3
l<-3
PPrect(n, l)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
