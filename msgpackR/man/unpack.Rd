\name{unpack}
\alias{unpack}
\title{
unserialize MessagePack format data
}
\description{
Unserialize MessagePack format data
}
\usage{
unpack(str)
}
\arguments{
  \item{str}{str is filename or array of raw data}
}
\value{
unserialized data from MessagePack format 
}
\author{
Mikiya TANIZAWA \email{1970mix@gmail.com}
}
\seealso{
\code{\link{pack}},
\code{\link{msgpack.writeResult}}
}
\examples{
unpack(pack(c(1,2,3)))
#[1] 1 2 3
(data <- c(1,2,3))
#[1] 1 2 3
(d <- pack(data))
#[1] 93 01 02 03
msgpack.writeResult("test.txt", d)
unpack("test.txt")  # <= unserialize from binary file
#[1] 1 2 3
unpack(d) # <= unserialize from binary bits
#[1] 1 2 3
}
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
