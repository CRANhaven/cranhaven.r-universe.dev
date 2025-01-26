\name{pack}
\alias{pack}
\title{
serialize data to MessagePack format
}
\description{
Serialize data to MessagePack format
}
\usage{
pack(data)
}
\arguments{
  \item{data}{data that you want to serialize, e.g. c(1,2,3)}
}

\value{
serialized data to MessagePack format
}

\author{
Mikiya TANIZAWA \email{1970mix@gmail.com}
}
\seealso{
\code{\link{unpack}},
\code{\link{msgpack.writeResult}}
}
\examples{
pack(c(1,2,3))
#[1] 93 01 02 03
mat <- matrix(c(1:6), nrow=2); colnames(mat) <- c("A","B","C"); pack(mat);
#[1] 92 83 a1 41 01 a1 42 03 a1 43 05 83 a1 41 02 a1 42 04 a1 43 06
}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
