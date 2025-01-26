\name{msgpack.matrix}
\alias{msgpack.matrix}
\title{
transfer list format to matrix format
}
\description{
Transfer list format to matrix format
}
\usage{
msgpack.matrix(data)
}
\arguments{
  \item{data}{a list format data that is made from unpack function}
}
\value{
matrix format data
}
\author{
Mikiya TANIZAWA \email{1970mix@gmail.com}
}
\seealso{
\code{\link{unpack}}
}
\examples{
(mat <- matrix(1:6, 2))
#     [,1] [,2] [,3]
#[1,]    1    3    5
#[2,]    2    4    6
(m <- pack(mat))
# [1] 92 93 01 03 05 93 02 04 06
unpack(m)
#[[1]]
#[1] 1 3 5
#
#[[2]]
#[1] 2 4 6
msgpack.matrix(unpack(m))
#     [,1] [,2] [,3]
#[1,] 1    3    5   
#[2,] 2    4    6   

colnames(mat) <- c("A","B","C")
mat
#     A B C
#[1,] 1 3 5
#[2,] 2 4 6
(m <- pack(mat))  # <= if data has colname, serialize to "map"
#[1] 92 83 a1 41 01 a1 42 03 a1 43 05 83 a1 41 02 a1 42 04 a1 43 06
unpack(m)
#[[1]]
#A B C 
#1 3 5 
#
#[[2]]
#A B C 
#2 4 6 
msgpack.matrix(unpack(m))
#     A B C
#[1,] 1 3 5
#[2,] 2 4 6

}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
