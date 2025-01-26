\name{SpaceFilling}
\alias{SpaceFilling}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Space-Filling design
}
\description{
The application of the (ASC-SF) algorithm on some association schemes to obtain new series of Space-filling Design.
}
\usage{
SpaceFilling(asch)
}

\arguments{
  \item{asch}{
"character" contain the type of the association scheme used to obtain the Space Filling design, the association scheme used are :

"Div" : Group divisible association scheme.

"Rect" :Rectangular association scheme.

"Nestdiv" : Nested group divisible association scheme.

"RightAng" : Right angular association scheme.

"GrectRightAng4" : Generalized rectangular right angular association scheme(4).

"GrectRightAng5" : Generalized rectangular right angular association scheme(5).

"GrectRightAng7" : Generalized rectangular right angular association scheme(7).
}
}
\value{
A LIST :
\item{SFDesign}{The configuration of the Space Filling design.}
\item{Runs}{Number of runs in the Space-Filling design.}
\item{Factors}{Number of factors.}
\item{Levels}{Levels of factors.}
}
\references{
Imane Rezgui and Z.Gheribi-Aoulmi New Series of Resolvable Partially Pairwise Balanced and Space Filling Designs via Association Schemes submitted.
}
\author{
Mohamed Laib, Imane Rezgui and Zoubida Gheribi-Aoulmi
}

\examples{
#### Space Filling obtain via Group divisible association scheme.
# SpaceFilling("PPdiv")
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
