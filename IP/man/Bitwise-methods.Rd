%% 
\name{Bitwise-methods}
%%
\docType{methods}
%%
%%
%%
\alias{Logic-methods}
%%
\alias{Logic,IP,IP-method}
%%
%%
\alias{!}
\alias{!-method}
%%
\alias{!,IPv4-method}
\alias{!,IPv6-method}
%%
%%
%%
\alias{&}
\alias{&-method}
%%
\alias{&,IPv4,IPv4-method}
\alias{&,IPv6,IPv6-method}
\alias{&,IP,IP-method}
%%
%%
%%
\alias{|}
\alias{|-method}
%%
\alias{|,IPv4,IPv4-method}
\alias{|,IPv6,IPv6-method}
\alias{|,IP,IP-method}
%%
%% xor
%%
%%
\alias{^}
\alias{^-methods}
%%
\alias{^,IPv4,IPv4-method}
%%
\alias{^,IPv6,IPv6-method}
%%
\alias{^,IP,IP-method}
%%
\alias{ip.xor}
\alias{ip.xor-methods}
%%
\alias{ip.xor,IPv4,IPv4-method}
%%
\alias{ip.xor,IPv6,IPv6-method}
%%
\alias{ip.xor,IP,IP-method}
%%
%%
%%
\alias{\%>>\%}
\alias{\%>>\%-method}
%%
\alias{\%<<\%}
\alias{\%<<\%-method}
%%
\alias{\%>>\%,IPv4,integer-method}
\alias{\%<<\%,IPv4,integer-method}
%%
\alias{\%>>\%,IPv6,integer-method}
\alias{\%<<\%,IPv6,integer-method}
%%
%%
%%
\alias{ipv4.netmask}
\alias{ipv6.netmask}
\alias{ipv4.hostmask}
\alias{ipv6.hostmask}
%%
%%
%%
\title{ Bitwise operations }
%%
\description{
  Methods for IP bitwise operations
  %%\itemize{
    %%\item 
    \code{!e1} %% 
    %%\item 
    \code{e1 & e2} %% 
    %%\item 
    \code{e1 | e2}
    %%\item 
    \code{e1 \%>>\% e2}
    %%\item 
    \code{e1 \%<<\% e2}
    %%\item 
    \code{e1 ^ e2 }
    %%\item 
    \code{ip.xor(e1 , e2 )}
    %%\item 
    \code{ipv4.netmask(n)}
    %%\item 
    \code{ipv6.netmask(n)}
    %%\item 
    \code{ipv4.hostmask(n)}
    %%\item 
    \code{ipv6.hostmask(n)}
  %%}
}
%%
%%\S4method{!}{IPv4,IPv6, IP}(e1) %% 
%%% \method{&}(e1 , e2)
% \usage{
  % !e1 %% 
  % e1 & e2 %% \S4method{&}{IPv4,IPv6,IP}(e1,e2) %%
  % e1 | e2
  % e1 \%>>\% e2
  % e1 \%<<\% e2
  % ip.xor(e1 , e2 )
  % %% mask.len
  % ipv4.netmask(n)
  % ipv6.netmask(n)
  % ipv4.hostmask(n)
  % ipv6.hostmask(n)
% }
% \section{Methods}{
  % \describe{
    % \item{!x  }{ }
    % \item{x & y }{ }
    % \item{x | y }{ }
    % \item{x \%\>\>\% n }{ }
    % \item{x \%\<\<\% n }{ }
    % \item{ipv4.netmask(n) }{ }
    % \item{ipv6.netmask(n) }{ }
    % \item{ipv4.hostmask(n) }{ }
    % \item{ipv6.hostmask(n) }{ }
  % }
% }
%%
\arguments{
  %%
  \item{e1}{
    an object of either an 'IPv4', 'IPv6' or 'IP' class  %%
  }
  %%
  \item{e2}{
    an object of either an 'IPv4', 'IPv6' or 'IP' class except for shifts where e2 is like 'n' %%
  }
  %%
  \item{n}{
    an integer in the range (0,32) for IPv4 or in the (0,128) for IPv6 for masking methods
  }
}
%%
\value{
  an object of either an 'IPv4', 'IPv6' or 'IP' class
}
%%
\details{
  %%
  The \code{&}, \code{|} and \code{!} operators behave differently from their base R counterparts in that they perform bitwise operation much like in the C language.
  %%
  \itemize{
    %%
    \item \code{&} : bitwise AND
    %%
    \item \code{|} : bitwise non exclusive OR
    %%
    \item \code{!} : bitwise NOT
  }
  %%
  \code{ip.xor()} provides a faster alternative to base \code{xor()}.
  
  %%
  \code{\%>>\%} and \code{\%<<\%} perform left (binary division) and right shift (binary multiplication) respectively.
  
  %%
  The \code{*.netmask()} and \code{*.hostmask()} functions return the net and host mask of specified length \code{n}.
}
%%
%%
%%
\examples{
##
private.network <- ipv4r("192.0.0.0/16")
##
(mask.len <- ceiling(log2(ip.range(private.network))))
##
ip <- ipv4("192.168.1.1") 
##
(netmask <- ipv4.netmask(mask.len))
##
ip & netmask
##
(hostmask <- ipv4.hostmask(mask.len))
##
ip & hostmask
##
((ip & netmask) | (ip & hostmask) )==ip
## 2 complement
((!ip) + 1L)==-ip
##
ipv4('0.0.0.2') \%>>\% 1L
##
ipv4('0.0.0.2') \%<<\% 1L
##
## branchless swap
##
ipv4.ifelse <- function(test, yes, no){
  ## 
  if( ( class(yes)!='IPv4' ) | ( class(no)!='IPv4' ) ){
    stop('both arguments should be of class IPv4')
  }
  ##
  ip.xor(
    no
    , ip.xor(
      no, yes
    ) & -(ipv4(test)) ## mask
  )
}
##
x <- ipv4('192.168.0.0') + 1:5
## recycling without warning (yet)
y <- x + c(1,-1)
##
test <- x < y
##
data.frame(
  x, y, test, res= ipv4.ifelse(test , x,y)
)
##
##
##
ip6 <- ipv6("2606:2800:220:1:248:1893:25c8:1946")
## Unicast addresses global routing prefix
ip6 & ipv6.netmask(48)
## Subnet ID
ip6 & (ipv6.hostmask(128-16) \%<<\% 64L)
## Interface ID 
ip6 & ipv6.hostmask(64)
}
