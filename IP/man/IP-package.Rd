%%
\name{IP-package}
%%
\docType{package}
%%
\keyword{ package }
%%
\alias{IP-package}
%%
\alias{IP}
%%
%%
%%
\title{Classes and methods for IP addresses}
%%
\description{
  Classes and methods for IP addresses
}
%%
\details{
  %%
  The IP package provides vector-like classes and methods for Internet Protocol (IP) addresses. %%
  It is based on the ip4r PostgreSQL extension available at \url{https://github.com/RhodiumToad/ip4r}.
  
  An IP address is a numerical label assigned to each device connected to a computer network that uses the Internet Protocol for communication. %
  The Internet Protocol uses those labels to identify nodes such as host or network interface for relaying datagrams between them across network boundaries.

  Internet Protocol version 4 (IPv4) defines an IP address as an unsigned 32-bit number. However, because of the growth of the Internet and the depletion of available IPv4 addresses, a new version of IP (IPv6) using 128 bits for the IP address was developed from 1995 on. IPv6 deployment has been ongoing since the mid-2000s. Note that there is no IPv5 address. In addition, IPv4 and IPv6 protocols differ in many respects besides IP addresses representation.

  IP addresses are usually written and displayed in human-readable notations, such as "192.168.0.1" in IPv4, and "fe80::3b13:cff7:1013:d2e7" in IPv6. %%
  Ranges can be represented using two IP addresses separated by a dash or using the Classless Inter-Domain Routing (CIDR) notation. CIDR suffixes an address with he size of the routing prefix of the address which is the number of significant bits. For instance, "192.168.0.0/16" is a private network with subnet mask "255.255.0.0" and is equivalent to "192.168.0.0-192.168.255.255". 
  %%
  Currently, the IP package supports the following object types implemented using S4 classes :
  %%
  \itemize{
    %%
    \item the \code{IPv4} class stores IP version 4 addresses
    %%
    \item the \code{IPv4r} class stores IP version 4 addresses ranges
    %%
    \item the \code{IPv6} class stores IP version 6 addresses
    %%
    \item the \code{IPv6r} class stores IP version 6 addresses ranges
    %%
    \item the \code{IP} class stores both IPv4 and IPv6 addresses
    %%
    \item the \code{IPr} class stores both IPv4r and IPv6r addresses
    %%
    \item the (still experimental) \code{host} class holds the result of DNS lookup
  }%%
  The IP package also provides methods for arithmetic, comparison and bitwise unary and binary operations in addition to sorting and lookup and querying information about IP addresses and domain names. %% 
  All operators are not available for all classes mostly by design but a few are still missing because they have not been implemented yet. IP objects can also be subseted or stored in a \code{data.frame} and serialized. 
  
  The IP and IPr classes are only convenience containers for instances when addresses must be created from vectors mixing both protocols. %%
  The IPv4 and IPv6 protocols and their corresponding IP representation are indeed very different in many respects so only a subset of methods are available for them. In addition, methods for those containers tend to run slower because, at the moment, they need to make two passes (one for IPv4* and one for IPv6* objects). %%
  Use the \code{ipv4(IP)} (resp. \code{ipv4r(IPr)}) and \code{ipv6(IP)} (resp. \code{ipv6r(IP)}) getters to work with v4 and v6 objects separately.
  
%%
\subsection{Design considerations}{
  %%
  IP objects were designed to behave as much as possible like base R atomic vectors. 
  Therefore many R base functions such as \code{table()} or \code{factor()} or merging two \code{data.frame} using IP objects as keys work.
  
  But there are a few caveats when using functions or methods not provided by the IP package in which case you \bold{may have to convert to the character representation of the addresses}.
  
  IP objects are S4 objects that all inherit from the integer class 
  and because of this there are instances where function calls will operate on the inherited integer \code{.Data} part of the object only. 
  As of writing, this is for example the case for the \code{nchar} function which returns the number of characters of the .Data vector only. But \code{grep} works because the x argument to the function is explicitly coerced to character before further processing.
  
  The .Data slot does not hold the addresses but an index to the addresses. 
  When calling a non-IP method, \R will first look for a method for this particular object. If none is found, it will try to find one for the class this object inherits from. Hence, the call will operate on the index, and not on the object as a hole. 
  This is why some operations are explicitly blacklisted such as multiplication. Since there are no \code{`*`} for IP objects, multiplying an IP with a number would otherwise fall back to multiplying the index by this number, thus badly damaging the object.
  
  %% Much care has been taken to avoid this sort of situation. XXX
  
  Reasons for using an index are twofold. First, each IP address space use the entire 32 (resp. 128) bits integer range. Thus, no value can be used for NA. %%
  For instance, R defines \code{NA_integer_} as \eqn{2^{31}} which a perfectly valid IP v4 address ("128.0.0.0"). %%
  Second reason is IP words size. An IPv4 address uses 32 bits and thus can be stored using an integer vector (and IPv4 address ranges uses 64 bits and could be stored using a numeric vector). But an IP v6 address uses 128 bits and an IP v6 address range uses 256 bits and currently no \R built-in atomic vectors are wide enough to hold them. IP addresses other than IPv4 have to be stored in a separate matrix and the index is used to retrieve their value.
  
  Therefore, each IP* object has an index which either points to the IP location in a table or mark the value as NA. %%
  This way \R believes it is dealing with a regular vector but at the cost of increased memory consumption. %%
  The memory footprint is a function of the number of NA.
  
  On the other end, this design makes it easy to know if there are any NA and, if none, skip NA checking which makes things faster.
}
%%
\subsection{SIMD support}{

  The IP package provides an experimental support for AVX2 vectorized operations for IP comparison and arithmetic and SSE vectorized operations for IPv4 addresses input. 
  To enable SIMD support, please pass the \code{"--enable-avx2"} \code{configure.args} argument to the \code{install.packages()} function. 
}
%%
\subsection{Data protection}{
  
  One last caveat. In certain countries such as EU member countries, IP addresses are considered personal data (see Article 29 Working Party Opinion 4/2007 and ECJ ruling dated 19 October 2016 --ref.: C582/14). IP processing must therefore be done in accordance to the applicable laws and regulations.
}

} %% /subsection
