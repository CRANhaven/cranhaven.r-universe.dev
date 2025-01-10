%%
\name{Hostinfo}
%% methods
\docType{class}
%%
\keyword{classes}
%%
%%
%%
\alias{host-class}
\alias{idn}
%%
%%
%%
\alias{host}
\alias{host-methods}
%%
\alias{host,character-method}
%%
\alias{host,IPv4-method}
\alias{host,IPv6-method}
\alias{host,IP-method}
%% 
\alias{show,host-method}
%% 
\alias{names.host}
%%
%%
%%
\alias{host.info}
\alias{host.info-methods}
%%
\alias{host.info,IPv4-method}
\alias{host.info,IPv6-method}
\alias{host.info,IP-method}
\alias{host.info,host-method}
%%
% \alias{ipv4-method}
\alias{ipv4,host-method}
%%
% \alias{ipv6-method}
\alias{ipv6,host-method}
%%
%%
%%
\alias{localhost.ip}
%%
%%
%%
\alias{toIdna}
\alias{fromIdna}
%%
%%
%%
\alias{fqdn}
%%
\alias{is.fqdn}
%%
%%
%%
\alias{rir.names}
%%
\alias{ipv4.rir}
\alias{ipv6.rir}
%% 
\alias{ipv4.addr.space}
\alias{ipv6.addr.space}
%%
\alias{ipv4.reserved}
\alias{ipv6.reserved}
%%
\alias{ipv4.recovered}
%%
\alias{ipv6.unicast}
%%
%%
%%
\alias{whois}
%%
%%
%%
%%
%%
%%
%%
\title{ host-info }
%%
\description{
  Methods for querying information about hosts (DNS) or IP (address spaces)
}
%%
%% 
%%
\usage{
  %% 
  host(host,\dots)
  %% 
  host(host,\dots)
  %% 
  host.info(host,\dots)
  %% 
  localhost.ip(\dots)
  %% 
  toIdna(domain, flags)
  %% 
  fromIdna(domain, flags)
  %% 
  fqdn(hostname) 
  %%
  is.fqdn(hostname)
  %%
  whois(domain, refer , output, verbose)
  %%  
  rir.names() 
  %%
  ipv4.rir() 
  %%
  ipv6.rir() 
  %%
  ipv4.addr.space()  
  %%
  ipv6.addr.space()
  %%
  ipv4.reserved()
  %%
  ipv6.reserved()
  %%
  ipv4.recovered()
  %%
  ipv6.unicast()
}
%%
\arguments{
  %%
  \item{host}{
     a vector of either or IPv4, IPv6, IP addresses
  }
  % \item{host.info}{
    % either a vector string or an IPv4, IPv6, IP address
  % }
  % \item{object}{
    % a character vector of domain names
  % }
  %%
  \item{\dots}{
    further arguments. Only host.info (default:FALSE) for host() at the moment
  }
  %%
  \item{hostname}{
    A character vector of host names
  }
  %%
  \item{domain}{
    A character vector of domain names
  }  
  %%
  \item{flags}{
    Flags for IDNA conversion. "IDNA_DEFAULT": default behavior, "IDNA_ALLOW_UNASSIGNED": allow processing of unassigned Unicode code points, "IDNA_USE_STD3_ASCII_RULES": check output to make sure it is a STD3 conforming host name.
  }  
  %%
  \item{refer}{
    An optional referrer to be queried
  } 
  %%
  \item{output}{
    An integer specifying whether to return the raw response from the referrer (0) or parse the response and return a key-value named vector (1). The latter is still experimental due to the heterogeneity of responses.
  } 
  %%
  \item{verbose}{
    An integer specifying the level of verbosity
  }
}
%%
%%
%%
\details{
  %%
  \subsection{Methods and functions for querying informations about hosts}{
  %%
  \itemize{
    %%
    \item \code{host()} takes a character vector of domain names as arguments for DNS lookup. Addresses can be extracted with the corresponding methods (ipv4(), ipv6(), ip()). 
    Also takes either IPv4, IPv6 or IP objects for reverse DNS lookup and returns the corresponding domain name (or NA if not found).
    %%
    \item \code{host.info()} (depreciated) takes either IPv4, IPv6 or IP objects for reverse DNS lookup and returns the corresponding domain name (or NA if not found)
    %%
    \item \code{localhost.ip()} retrieves the host's interfaces IP adresses
    %%
    \item \code{fqdn()} extracts the fully qualified name of a domain name, -eg to query \code{whois} databases
    %%
    \item \code{is.fqdn()} tests whether strings in a character vector qualify as fully qualified names
    %%
    \item \code{whois()} queries \code{whois} databases for a vector of fully qualified domain names. 
  }
  %%
  Since \code{localhost.ip()} needs OS specific system call ---as well as \code{host()} and \code{host.info()}---, this function is only available for \bold{POSIX compliant OS} at the moment. 
  Support of Internationalized Domain Names (IDN) also depends on the system's libraries. For instance, glibc supports IDN starting with version 2.3.4. Use the \code{toIdna()} function to ensure proper domain names encoding. Note that result may differ depdending on the flag argument as shown in the examples.
  %%
  In addition, the \code{host()} and \code{host.info()} methods are still \bold{very experimental} and might change in the future.
  
  %%
  \code{whois} databases typically contain information such as registrars' names \ldots %
  Note that responses are not standardized at all and may require an ad hoc parser. %  nuts-and-bolts unmaintainable 
  This is why the \code{whois()} function returns either a (still buggy at the moment) named vector of key-value pairs or the raw responses from the referrers.
  %%
  The relevant referrer \code{url} can be determined automatically (default) or passed as an argument.
  }
  %%
  %% bold
  %%2 - 
  \subsection{Functions returning IP addresses assignments from IANA registries}{
  %%
  \itemize{
  %%
  \item \code{ipv4.addr.space()} and \code{ipv6.addr.space()} : return the corresponding IP address space
  %%
  \item \code{ipv4.reserved()} and \code{ipv6.reserved()} : return the corresponding IP reserved address space 
  %%
  \item \code{ipv6.unicast()} : IPv6 unicast addresses
  %%
  \item \code{ipv4.recovered()} : pool of IPv4 addresses recovered by IANA from RIRs
  %%  \item \code{ipv6.unicast()} : .
  %%
  \item \code{ipv4.rir()} and \code{ipv6.rir()} : returns the RIRs IP address spaces
  %%
  \item \code{rir.names()} : Regional Internet Registry names
  }
  %%
  The IP address spaces is divided into many ranges with specific purposes. For instance, IP addresses can be assigned to organizations. Some addresses are otherwise reserved for special purposes such as loopback, subnetting, local communications within a private network, multicasting, broadcasting,\ldots
  %%
  The IP address space is managed globally by the Internet Assigned Numbers Authority (IANA), and locally by five regional Internet registries (RIRs) :  
  %%
  \itemize{
    %%
    \item The African Network Information Center (AFRINIC) serves Africa
    %%
    \item  The American Registry for Internet Numbers (ARIN) serves Antarctica, Canada, parts of the Caribbean, and the United States
    %%
    \item The Asia-Pacific Network Information Centre (APNIC) serves East Asia, Oceania, South Asia, and Southeast Asia
    %%
    \item The Latin America and Caribbean Network Information Centre (LACNIC) serves most of the Caribbean and all of Latin America
    %%
    \item The Réseaux IP Européens Network Coordination Centre (RIPE NCC) serves Europe, Central Asia, Russia, and West Asia
  }
  RIRs are responsible in their designated territories for assignment to end users and local Internet registries, such as Internet service providers. %%In addition to geographic or organisation assignments, various IP addresses are reserved for special purposes such as loopback, subnetting, local communications within a private network, multicasting, broadcasting,\ldots
  
  %%
  Note differences in ouptut between \code{ipv4.addr.space()} and \code{ipv6.addr.space()}. %%
  RIRs IPv4 and Ipv6 assignments are stored by IANA in tables with different naming scheme (corresponding to \code{ipv4.addr.space()} and \code{ipv6.unicast()}). %%
  In the early days of IPv4 deployment, addresses were assigned directly to end user organizations. Therefore, \code{ipv4.addr.space()} also mixes RIR and end user organizations assignments. %%
  To find the corresponding RIR, use \code{ipv4.rir()} and \code{ipv6.rir()} instead.
  %%In addition,
  Also note that some lookups may be misleading because some IPv4 ranges have been transferred from one RIR to an another (see example). For instance, some address ranges were assigned by ARIN in the 80's to European organizations such as universities before RIPE-NCC began its operations in 1992. Those ranges were later transferred to the RIPE NCC but still belong to the ARIN address space.
  %%
  Likewise, some IPv4 addresses have been recovered by IANA from RIRs in order to delay IPv4 pool exhaustion and were later reassigned to other RIRs (see \code{\link[=ipv4.recovered]{ipv4.recovered}}).
  }
}
%%
%%
%%
\value{
  %%
  \item{host}{an host object or a character vector}
  %%
  \item{host.info}{a character vector}
  %%
  \item{localhost.ip}{an IP}
}
%%
%%
%%
\examples{
##
\donttest{
host(
  ipv4(
    c("127.0.0.1")
  )
)
##
h <- host(c(
  "icann.org", "iana.org"
))
##
host(ipv4(h))
##
## Domain names internationalization
##
##
## results may vary according to the (POSIX) platform
host(c("bucher.de", "Bücher.de"))
}
##
if( ip.capabilities()["IDN"] ){
  ## 
  dn <- c( 
    enc2utf8("bücher.de") ## ensure UTF-8
    ## cannot input emoji with Latex 
    , "\U1f4a9" # or alternatively: rawToChar(as.raw(c(0xf0, 0x9f, 0x92, 0xa9, 0x2e, 0x6c, 0x61)))
  )
  ##
  Encoding(dn) <- "UTF-8"
  ##
  dn
  ## enforce internationalization with different options
  flags <-rep( c( "IDNA_DEFAULT" , "IDNA_ALLOW_UNASSIGNED"), each = length(dn))
  ##
  dni <- toIdna( dn, flags)
  ## convert back
  fromIdna(dni, flags)
\donttest{
  ##
  host(dni)
}
}
##
\donttest{
##
## French country-code top-level domains (ccTLD)
##
tld <- whois(
  c(
    "fr", "re", "tf", "wf", "pm", "yt"
    , "nc", "mq"##, "gp", "gf"
    , "pf"
  )
  , verbose = 1 ## be a little verbose
  , output = 1 ## output key-value pairs
)
##
sapply(tld, function(x) x[names(x)=="whois"])
##
## R related info
##
rhost     <- host('r-project.org')
## hostname       : "cran.wu-wien.ac.at"
rhost.hnm <- host.info(ipv4(rhost))
## primary domain : "ac.at"
fqdn(rhost.hnm)
## ARIN 
ipv4.rir()[ip.match(ipv4(rhost), ipv4.rir())]
##
ip.match(ipv4(rhost), ipv4.recovered())
## domain name info 
rdom.wh   <- whois('r-project.org', output=1)
## "AT"
rdom.wh[['r-project.org']]['Registrant Country']
## host
rhost.wh0 <- whois(ipv4(rhost),verbose = 2, output=1)
}
}
