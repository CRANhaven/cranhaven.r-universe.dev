\name{msgpack.writeResult}
\alias{msgpack.writeResult}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
the function to save serialized data to file
}
\description{
Save serialized data to file.
}
\usage{
msgpack.writeResult(filename, result)
}
\arguments{
  \item{filename}{filename that you want to save as}
  \item{result}{serialized data that you want to save}
}

\author{
Mikiya TANIZAWA \email{1970mix@gmail.com}
}

\seealso{
\code{\link{pack}}
}
\examples{
(data <- c(1,2,3))
#[1] 1 2 3
(d <- pack(data))
#[1] 93 01 02 03
msgpack.writeResult("test.txt", d)
}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
