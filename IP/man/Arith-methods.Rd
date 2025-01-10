%%
\name{Arithmetic}
%%
\alias{Arith-methods}
%%
\docType{methods}
%%
%%
%%
\alias{+}
\alias{+-method}
%%
\alias{-}
\alias{--method}
%%
\alias{+,IPv4,IPv4-method}
\alias{+,IPv4,integer-method}
\alias{+,IPv4,logical-method}
\alias{+,IPv4,numeric-method}
%%
\alias{-,IPv4,missing-method}
\alias{-,IPv4,IPv4-method}
\alias{-,IPv4,integer-method}
\alias{-,IPv4,numeric-method}
%%
\alias{+,IPv6,IPv6-method}
\alias{+,IPv6,integer-method}
\alias{+,IPv6,numeric-method}
\alias{+,IPv6,logical-method}
%%
\alias{-,IPv6,missing-method}
\alias{-,IPv6,IPv6-method}
\alias{-,IPv6,integer-method}
\alias{-,IPv6,numeric-method}
%%
\alias{Arith,IP,missing-method}
\alias{Arith,IP,IP-method}
\alias{Arith,IP,.__intFP__.-method}
%%
%%
%%
% \alias{+,IPv4r,IPv4r-method}
% \alias{+,IPv4r,IPv4-method}
\alias{+,IPv4r,integer-method}
%%
%%
\title{ Methods for IP arithmetic }
%%
\description{
  Methods for unary and binary IP arithmetic 
}
  % \S4method{+}{IPv4,IPv4}(e1,e2)
  % \S4method{+}{IPv6,IPv6}(e1,e2)
  % \S4method{+}{IP,IP}(e1,e2)
%%
\usage{
  -e1
  e1 + e2
  e1 - e2
}
%%
\arguments{
  \item{e1}{an object of either an 'IPv4', 'IPv6' or 'IP' class}
  \item{e2}{either a corresponding object of class 'IPv4', 'IPv6', 'IP' or an integer or a numerical vector }
}
%%
\value{
  an object of either an 'IPv4', 'IPv6' or 'IP' class
}
%%
\details{
  %% 
  Both IPv4 and v6 sets are represented as unsigned integers and are closed under addition and subtraction. An operation resulting in a negative number (or an overflow) is marked as NA. %%
  %% 
  %% 
  Operations are currently not always commutative. IP*-IP* are but those involving integers or floats are not. %%
  Thus, adding (or subtracting) an integer or a float to an IP* object will work but the reverse (adding (or subtracting) an IP* to an integer or a float) will raise an error (see example below and the caveat section in the package description). 
  In addition multiplication and division are not implemented and will raise an error. 
  %% loss of precision
  %%
  Arithmetic operations involving IP* are better done using methods provided.%%, especially for IPv6 addresses. %%
  Both IPv4 and IPv6 addresses are represented as unsigned integers but \R only works with 32 bits signed integers.
  In addition, double precision numbers cannot represent all integers in the 0-(2^128-1) range. Therefore, converting an IPv6 object to numeric may cause a loss of precision and the same applies to arithmetic operations on IPv6 represented as floating point numbers.
  
  %% This is not a bug. Mantissa is 52 bits long.
}
%%
%%
%%
\examples{
##
ipv4("192.0.0.1") + 1
ipv6("fd00::1") + 1
ip(c("192.0.0.1", "fd00::1")) + 1

##
## Prohibited Arith operations
##
## this raises an error 
tryCatch(1L - ipv4("192.0.0.1"), error=function(e) e )
## and so will 
tryCatch(1 + ipv6("fd00::1"), error=function(e) e )
## as well as
tryCatch(ipv4("192.0.0.1") * 2, error=function(e) e )

##
## Loss of precision in arithmetical operations
##
(2^52 +1)- 2^52
(2^53 +1)- 2^53
##
identical((2^64 +1)- 2^64  , 0 )
## ...and so on
( (2^64 + 2^11 ) - (2^64))
## next representable number with IEEE 754 double precision floats; mind the gap
( (2^64 + 2^12 ) - (2^64))
% ##
% ( (2^64 + (2^12-1) )- (2^64))
## OTH,
((ipv6('::1') \%<<\% 53L) + ipv6('::1')) - (ipv6('::1') \%<<\% 53L)
##
(x <- ( ( ipv6('::1') \%<<\% 64L ) + ( ipv6('::1') \%<<\% 11L ) ) - ( ipv6('::1') \%<<\% 64L ) )
log2(as.numeric(x))
}

