\name{PPdiv}
\alias{PPdiv}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Group divisible RPPBD
}
\description{
The configuration of group divisible RPPBD obtained by applying the (ASC-RPPBD) method on a group divisible association scheme.
}
\usage{
PPdiv(n, l)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n}{
Number of lines of the association schemes.
}
  \item{l}{
Number of columns of the association schemes.
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

Lokesh Dwivedi. Partially balanced Incomplete block designs. M.Sc. (Agricultural Statistics), Roll No. 4491, I.A.S.R.I., Library Avenue, New Delhi -110 012.
}
\author{
Mohamed Laib, Imane Rezgui and Zoubida Gheribi-Aoulmi
}

\examples{
n<-3
l<-3
PPdiv(n,l)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
