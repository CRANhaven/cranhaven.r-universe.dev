%%
%%
%%
\name{Varia}
%%
\docType{methods}
%%
%%
%%
\alias{length}
\alias{length,IPv4-method}
\alias{length,IPv4r-method}
\alias{length,IPv6-method}
\alias{length,IPv6r-method}
%%
%%
%%
\alias{is.na}
\alias{is.na,IPv4-method}
\alias{is.na,IPv4r-method}
\alias{is.na,IPv6-method}
\alias{is.na,IPv6r-method}
%%
%%
%%
\alias{anyNA}
\alias{anyNA,.__ipvr__.-method}
\alias{anyNA,IPv4-method}
\alias{anyNA,IPv4r-method}
\alias{anyNA,IPv6-method}
\alias{anyNA,IPv6r-method}
%%
%%
%%
% \alias{is.numeric}
% \alias{is.numeric,IPv4-method}
% \alias{is.numeric,IPv6-method}
%%
%%
%%
%%
%%
\alias{unique}
%%
\alias{unique.IPv4}
\alias{unique.IPv6}
\alias{unique.IPv4r}
\alias{unique.IPv6r}
\alias{unique.IP}
%%
%%
%%
\alias{xtfrm}
\alias{xtfrm-methods}
%%
\alias{xtfrm,IPv4-method}
\alias{xtfrm,IPv4r-method}
%%
\alias{xtfrm,IPv6r-method}
\alias{xtfrm,IPv6-method}
%%
%%
%%
\alias{ip.order}
\alias{ip.order-method}
\alias{ip.order,IPv4-method}
\alias{ip.order,IPv6-method}
\alias{ip.order,IPv4r-method}
\alias{ip.order,IPv6r-method}
%%
%%
%%
\alias{match}
\alias{match-methods}
%%
\alias{match,IPv4,IPv4-method}
\alias{match,IPv4,IPv4r-method}
\alias{match,IPv4r,IPv4r-method}
%%
\alias{match,IPv6,IPv6-method}
\alias{match,IPv6,IPv6r-method}
\alias{match,IPv6r,IPv6r-method}
%%
\alias{ip.match}
\alias{ip.match-method}
%%
\alias{ip.match,IPv4,IPv4-method}
\alias{ip.match,IPv4,IPv4r-method}
\alias{ip.match,IPv4r,IPv4r-method}
%%
\alias{ip.match,IPv6,IPv6-method}
\alias{ip.match,IPv6,IPv6r-method}
\alias{ip.match,IPv6r,IPv6r-method}
%%
%%
%%
\alias{getIdx}
%%
\alias{ip.index}
\alias{ip.index-method}
\alias{ip.index,IPv4r-method}
\alias{ip.index,IPv6r-method}
%%
%%
%%
\alias{ip.setequal}
\alias{ip.setequal-method}
\alias{ip.setequal,.__IPvr__.,.__IPvr__.-method}
%%
\alias{ip.union}
\alias{ip.union-method}
\alias{ip.union,.__IPvr__.,.__IPvr__.-method}
%%
\alias{ip.intersect}
\alias{ip.intersect-method}
\alias{ip.intersect,.__IPvr__.,.__IPvr__.-method}
%%
\alias{ip.setdiff}
\alias{ip.setdiff-method}
\alias{ip.setdiff,.__IPvr__.,.__IPvr__.-method}
%%
\alias{ip.symdiff}
\alias{ip.symdiff-method}
\alias{ip.symdiff,.__IPvr__.,.__IPvr__.-method}
%%
%%
%%
\title{Miscellaneous methods and functions for IP classes}
%%
%% 
%%
\description{
  %%
  Mostly IP counterparts of base \R methods and functions for atomic vectors. Namely,
  %%
  \itemize{
    %%
    \item length(), is.na(), anyNA()
    %%
    \item unique()
    %%
    \item sorting : xtfrm() %% ip.order(), 
    %%
    \item matching : match(), ip.match(), ip.index()
    %%
    \item set operations : ip.setequal(), ip.union(), ip.intersect(), ip.setdiff(), ip.symdiff()
  }
}
%%
%% TODO 
%%
% \usage{
  % unique(x,\ldots)
% }
%%
\details{  
%%
\subsection{Sorting}{
  
  IP object may be efficiently sorted through call to \R generic functions \code{order()} and \code{sort()} thanks to the \code{\link{xtfrm}} generic function. The IP package also provides the \code{ip.order()} which falls back to the default order method at the moment. %% methods for ordering IP which may be faster than \code{order()} call depending on various settings.
}
%%
\subsection{Lookup}{
  
  This part is still \bold{experimental} and might be subject to change in the future.
  
  \code{match()} and \code{ip.match()} do IP lookup like base \code{match()} while \code{ip.index()} can be used for range queries. The IP package make \code{match()} generic to avoid unwanted effects of method dispatch in code using the package. But note that, unfortunately, this won't change the behaviour of \code{match()} in other packages (see caveat section in the package description).

  \code{match()} and \code{ip.match()} behave differently according to their signature. When table is of class IPv4 or IPv6, \code{ip.match()} does a table lookup like base \code{match()}. But when table is an IP range and the x argument is not, both look for the range x lies into. If you want to test whether an IP range lies within another range, use the function returned by the \code{ip.index()} method (see example). 
  
  When arguments are of the same class, \code{match()} simply call base \code{match()} on the character representation while \code{ip.match()} uses hash tables. Range search uses a binary search tree. Beware that binary search can only handle non overlapping IP* ranges by default. Use \code{ip.index()} with \code{overlap=TRUE} to allow for overlap. Note that this also allows for multiple matches. As a consequence, result vector might be longer that input vector and therefore needs specialized data structures and access methods inspired by the compressed column storage of sparse matrices. See the example section for testing for overlap and lookup.
  
  \code{ip.index()} returns a function. Calling this function with the value argument set to TRUE returns the matched value and the indices of the matches otherwise. 
  When both overlap and value are TRUE, the function returns a two--columns \code{data.frame}with x and the matching values in the table.
  
  %% By default, the hash table is dropped after the look up is completed. Use the keep.hash=T argument to keep it so that the addresses need not be re-hashed every time \code{ip.match()} is called on the object.
  
  Also, the incomparable argument for \code{match()} or \code{unique()} is not implemented yet.
  
}
%% TODO
% \subsection{Set Operations}{
 % \R base set functions operate on the character representation of the IP addresses
% }
}
%%
%%
%%
\examples{
## 
x  <- ipv4(0L) + sample.int(10)
x[order(x)]
sort(x)

##
## matching the address space of a wifi interface on a GNU/Linux box 
## that uses Predictable Network Interface Names
## notes: the name of the interface might change depending on the distribution 
##       you're using among other things and the localhost.ip() function 
##       only works for POSIX platforms at the moment
## 
\donttest{
  ipv4.reserved()[match(ipv4(localhost.ip())['wlp2s0'], ipv4.reserved() )]
  ## alternatively, if tables has to be looked up several time
  m <- ip.index(ipv4.reserved())
  m(ipv4(localhost.ip())['wlp2s0'])
}

##
## ip.match() and ip.index() comparison
##
##
## index the table
bidx <- ip.index(ipv4.reserved())
## "169.254.0.0/16"
x <- ipv4.reserved()['Link Local']
## match
ip.match(x, ipv4.reserved() )
## match
ipv4.reserved()[bidx(x)]
## a range that lies within "169.254.0.0/16"
x <- ipv4r("169.254.0.0/24")
## no match ("169.254.0.0/24"!="169.254.0.0/16")
ip.match(x, ipv4.reserved() )
## match ("169.254.0.0/24" \in "169.254.0.0/16")
ipv4.reserved()[bidx(x)]

##
## overlap
## 
## this demonstrates that ranges in ipv4.reserved() overlap
##
## range match
m <- (
  ip.index(ipv4.reserved())
)(value=TRUE)
## FALSE because there are overlapping ranges and, in this case,
## the query returns the first matching range
all(m==ipv4.reserved())
## OTH match works as expected
all(ipv4.reserved()[ip.match(ipv4.reserved(),ipv4.reserved())]==ipv4.reserved())
##
## Find overlapping IPv4 ranges (pure R)
##
ipr.overlaps <- function(x, y, rm.diag  = FALSE){
  overlaps <- function(x,y) ( lo(x) <= hi(y) ) & ( hi(x) >= lo( y))
  x <- x[!is.na(x)]
  y <- if( missing(y) ) x else y[!is.na(y)]
  rv <- outer( x , y, overlaps)
  if( rm.diag) diag(rv) <- 0
  ij <- which(rv>0,arr.ind = TRUE)
  data.frame(nm=names(x)[ij[,1]], x=x[ij[,1]], y=y[ij[,2]])
}
##
ipr.overlaps(ipv4.reserved(),rm.diag=TRUE)
##
## Find overlapping IPv4 ranges (IP package)
##
bsearch <- ip.index(ipv4.reserved(), overlap=TRUE)
##
m <- bsearch()
## get the indices
idx <- getIdx(m)
## matches indices
midx <- idx$midx
## start indices for each address in the midx vector
## (diff(ptr) gives the number of matches per address)
ptr <- idx$ptr
##
subset(
  data.frame(
       nm  = names(ipv4.reserved()[midx])
     , x   = rep(m, diff(ptr))
     , tbl = ipv4.reserved()[midx]
     , n   = rep(diff(ptr), diff(ptr))
  )
  , n>1 & x!=tbl
)
##
## Same thing for IPv6r
##
ip.index(ipv6.reserved(), overlap=TRUE)(value=TRUE)
}

