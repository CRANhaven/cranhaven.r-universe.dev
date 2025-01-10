%%
%%
%%
\name{IP classes}
%%
%%
%%
\docType{class}
%%
\keyword{classes}
%%
%%
%%
\alias{IPv4-class}
\alias{IPv6-class}
\alias{IP-class}
%%
%%
%% ,character-method,IPv4r-method,IP-method
\alias{ipv4}
\alias{ipv4-method}
%%
\alias{ipv4,missing-method}
\alias{ipv4,character-method}
\alias{ipv4,integer-method}
\alias{ipv4,logical-method}
%%
\alias{ipv4,IP-method}
%%
%%
%%
\alias{ipv6}
\alias{ipv6-method}
%%
\alias{ipv6,missing-method}
\alias{ipv6,character-method}
\alias{ipv6,integer-method}
\alias{ipv6,logical-method}
%%
\alias{ipv6,IP-method}
%%
%%
%%
\alias{ip}
%% ???
\alias{ip-method}
\alias{ip,character-method}
\alias{ip,list-method}
%%
\alias{ip,missing,missing-method}
\alias{ip,IPv4,IPv6-method}
\alias{ip,IPv4,missing-method}
\alias{ip,IPv6,missing-method}
\alias{ip,character,missing-method}
\alias{ip,integer,missing-method}
\alias{ip,list,missing-method}
\alias{ip,logical,missing-method}
%%
\alias{ip,IPr,missing-method}
\alias{ip,host,missing-method}
%%
%%
%%
\alias{ip.version}
\alias{ip.version-methods}
\alias{ip.version,IPv4-method}
\alias{ip.version,IP-method}
%%
%%
%% 
%%
\alias{[-method}
%%
\alias{[,IPv4,.__subscript__.-method}
\alias{[,IPv6,.__subscript__.-method}
\alias{[,IP,.__subscript__.-method}
%%
%% 
%%
\alias{[<--method}
%%
\alias{[<-,IPv4,.__subscript__.-method}
\alias{[<-,IPv6,.__subscript__.-method}
%%
\alias{[<-,IP,ANY,ANY,ANY-method}
\alias{[<-,IP,.__subscript__.-method}
\alias{[<-,IP,.__subscript__.,ANY,IPv4-method}
\alias{[<-,IP,.__subscript__.,ANY,IPv6-method}
\alias{[<-,IP,.__subscript__.,ANY,logical-method}
%%
%%
%% is.cdr
%%
%%
%%
\alias{print-methods}
\alias{print,IP-method}
\alias{print,IPv4-method}
\alias{print,IPv6-method}
%%
%%
%%
\alias{show-methods}
\alias{show,IPv4-method}
\alias{show,IPv6-method}
\alias{show,IP-method}
%%
%%
%%
\alias{[,IPv4,.__subscript__.-method}
\alias{[<-,IP,.__subscript__.,ANY,IPv4-method}
\alias{[<-,IPv4,ANY,ANY,ANY-method}
%%
\alias{[,IPv6,.__subscript__.-method}
\alias{[<-,IPv6,ANY,ANY,ANY-method}
%%
\alias{[<-,IP,.__subscript__.,ANY,IP-method}
\alias{[<-,IP,.__subscript__.,ANY,ANY-method}
%%
%%
%%
\alias{[[-method}
%%
\alias{[[,.__IPvr__.,.__subscript__.-method}
% \alias{IP-class}
% \alias{[,IP,subset.idx-method}
% \alias{[<-,IP,subset.idx,ANY,IPv4-method}
% \alias{Arith,IP,intfl-method}
% \alias{as.character,IP-method}
% \alias{Compare,IP,IP-method}
% \alias{initialize,IP-method}
% \alias{ip.version,IP-method}
% \alias{ipv4,IP-method}
% \alias{Logic,IP,IP-method}
% \alias{print,IP-method}
% \alias{show,IP-method}
%%
%% 
%%
% \alias{names}
%%
\alias{names.IPv4}
\alias{names.IPv6}
\alias{names.IP}
%%
% \alias{names<-}
%%
\alias{names<-.IPv4}
\alias{names<-.IPv6}
\alias{names<-.IP}
%%
%% TODO: mv to Conversion
%%
\alias{as.data.frame-method}
%%
\alias{as.data.frame.IPv4}
\alias{as.data.frame.IPv6}
\alias{as.data.frame.IP}
%%
%% c
%%
% \alias{c}
%%
\alias{c.IPv4}
\alias{c.IPv6}
\alias{c.IP}
%%
%% rbind2
%%
\alias{rbind2-method}
%%
\alias{rbind2,IPv4,IPv4-method}
\alias{rbind2,IPv6,IPv6-method}
\alias{rbind2,IP,IP-method}
%%
%%
%%
\alias{rep.IPv4}
\alias{rep.IPv6}
\alias{rep.IP}
%%
%%
%%
%%\alias{is.numeric}
\alias{is.numeric-method}
%%
\alias{is.numeric,IPv4-method}
\alias{is.numeric,IPv6-method}
\alias{is.numeric,IP-method}
%%
%%
%%
\title{IPv4, IPv6 and IP classes}
%%
\description{classes for IPv4 and IPv6 addresses}
%%
%% \keyword{ classes }
%%
%% names(x) % 
%%
\usage{
  ipv4(object,\ldots)
  ipv6(object,\ldots)
  ip(e1,e2,\ldots)
  %%\method{name}(x) 
  % print(x,\ldots)
  % show(object)
  %% c rbind2 as.data.frame
  %%c(\ldots) %%\method{c}{}(\ldots)
}
%%
\arguments{
  %%
  \item{object}{a vector of IPv4 or IPv6 strings. If missing, returns an empty IPv4 or IPv6 object}
  %%
  \item{e1, e2}{either e1= a vector of IPv4 or IPv6 strings (and e2 missing) or objects of class e1 = an object of class IPv4' and e2 = an object of class 'IPv6}
  %%
  % \item{x}{an object of either class 'IPv4', 'IPv6'or 'IP'}
  %%
  \item{\ldots}{for \code{c}, zero or more objects objects of either class 'IPv4' or 'IPv6'or 'IP' exclusively}
}
%%
% \section{Methods}{
  % \describe{
    % %%
    % \item{%
      % \S4method{ipv4}{character}(object)%
    % }
    % %%
    % \item{%
      % \S4method{ipv4}{IPv4r}(object)%
    % }
    % %%
    % \item{
      % \S4method{ipv4}{IP}(object)
    % }
    % %%
    % %%
    % %%
    % \item{
      % \S4method{ipv4r}{list}(object)
    % }
    % %%
    % %%
    % %%
    % \item{
      % \S4method{ipv6}{character}(object)
    % }
    % %%
    % \item{
      % \S4method{ipv6}{IP}(object)
    % }
    % %%
    % \item{
      % \S4method{ipv6}{IPv6r}(object)
    % }
    % %%
    % %%
    % %%
    % \item{
      % \S4method{ipv6r}{list}(object)
    % }
    % %%
    % \item{
      % \S4method{ip}{character}(object)
    % }
    % %%
    % \item{
      % \S4method{ip}{list,boolean}(object,append)
    % }
  % }
% }%%
\details{
  %%
  IPv4 and IPv6 objects are created either from either character strings or integer vectors through \code{ipv4()} and \code{ipv6()} calls.
  
  %%
  IP objects store both IPv4 and IPv6 addresses. IP are created either from a character string or from IPv4 and IPv6 objects through \code{ip()} calls. 
  %%
  Since the IPv4 and IPv6 protocols use a different address representation, IP objects store both IPv4 and IPv6 addresses but do not mix them. The i-th element of an IP object can only an IPv4 or an IPv6 address but not both. So, if the i-th IPv4 is set, the corresponding i-th IPv6 must be NA and vice-versa.
  
  %%
  in addition to object creation, he \code{ipv4()} and \code{ipv6()} methods also extract the IPv4 and IPv6 addresses from an IP object and return an object with the same length. Use the drop argument to remove all NA values.
  
  %%
  Like atomic base R vectors, IPv4, IPv6 and IP objects elements can be subsetted (\code{[}) and replaced (\code{[<-}) and named (\code{name<-}). Objects can also be concatenated (\code{c()} or \code{rbind2()}) or stored in a \code{data.frame}.
  
  %%
  Note that in order to avoid undesirable side-effects, \code{is.numeric()} returns \code{FALSE}
}
%%
\note{
  \code{ipv4()} uses the SIMD SSE instructions set to input IPv4 addresses if the IP package was compiled with the \code{"--enable-avx2"} flag.
}
%%
\examples{
##
ipv4("0.0.0.0")==ipv4(0L)
##
ipv6("::")==ipv6(0L)
## create an empty object
ip0    <- ip()
## grow it
ip0[3] <- ipv4(3L)
ip0[5] <- ipv6(5L)
ip0
## same thing with NA
ip0    <- ip()
ip0[2] <- NA
ip0
## private networks
ip.strings <- c(v4 = "192.0.0.1", v6 = "fd00::1" )
##
(ip4 <- ipv4(ip.strings))
##
(ip6 <- ipv6(ip.strings))
##
(ip <- ip(ip.strings))
##
all(ip==ip(ip4, ip6))
##
pnet0 <- data.frame(
  ip 
  , v = ip.version(ip)
)
##
pnet1 <- rbind(
  pnet0
  , within(pnet0, ip <- ip+1L)
)
##
pnet0==pnet1[1:2,] 
## fails (why?): 
identical(pnet0,pnet1[1:2,])
##
ip(ip4[1],ip6[2],append=TRUE)
##
## IPv6 transition mechanism
##
## IPv4-mapped Address
(ip6 <- ipv6("::ffff:c000:0280"))==ipv6("::ffff:192.0.2.128")
##
ipv6.reserved()[ip.index(ipv6.reserved())(ip6)]
## NAT64 IPv4-IPv6 translation
(ip6 <- ipv6("64:ff9b::c000:201") ) & ipv6.hostmask(96)
##
ipv6.reserved()[ip.index(ipv6.reserved())(ip6)]
}

