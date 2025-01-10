The IP package provides vectorized classes and methods to work with IP addresses in R. Both IPv4 and IPv6 are supported as well as arbitrary IP ranges. It is based on the [ip4r](https://github.com/RhodiumToad/ip4r) PostgreSQL extension. The IP package defines vectors-like objects that provides for

 - IP addresses and range parsing and validation
 - vectorized operations such as arithmetic, logical and bitwise operations
 - IP matching and efficient lookup
 - (reverse) DNS lookup and whois databases query

## Quick start

The following code snippet shows how to create IPv4 addresses and ranges in addition to arithmetic, compare and bit manipulation methods usage as well as address lookup :

``` r
##
library(IP)
##  low part of the range
l <- ipv4("192.168.0.0")
##  high part of the range
h <- l + (2^16 -1)
## range
pn <-ipv4r(l, h)
## build range using CIDR notation
pn==ipv4r("192.168.0.0/16")
## build range using dash notation
pn==ipv4r("192.168.0.0-192.168.255.255")
## build h from l with the appropriate mask using bitwise OR
pn==ipv4r( l, l | ipv4.hostmask( ceiling(log2(ip.range(pn))) ) )
## same thing as l + (2^16 -1) using left shift bitwise operator
pn==ipv4r( l, l + ( ipv4(1L) %<<% 16L ) - 1)
##
## IP lookup
##
## \in
ipv4.reserved()[ ip.index(ipv4.reserved())( l + 0:9 )]
## ==
ipv4.reserved()[ ip.match(pn, ipv4.reserved() ) ]
## \in
ipv4.reserved()[ip.index(ipv4.reserved())(
  ipv4r("192.168.0.0/24")
)]
```

The same will work IPv6 address and IPv6 ranges. Simply substitute ipv4 with ipv6 and change the address to, eg, "fe80::/10" (`ipv6r("fe80::/10")`) and host mask (`hi(ipv6r("fe80::/10"))==(ipv6("fe80::")|ipv6.hostmask(10))`). Also use `ip()` and `ipr()` to mix both protocols.

What follows shows how to get (confusing) informations about hosts (note : the host() is still experimental under Windows and localhost.ip() is not yet avalaible)

``` r
## DNS lookup
rhost     <- host('r-project.org')
## Reverse DNS lookup : "cran.wu-wien.ac.at"
rhost.hnm <- host.info(ipv4(rhost))
## primary domain : "ac.at"
fqdn(rhost.hnm)
## RIR : ARIN (echt?)
ipv4.rir()[ip.match(ipv4(rhost), ipv4.rir())]
## address was not recovered
ip.match(ipv4(rhost), ipv4.recovered())
## domain name info 
rdom.whois   <- whois('r-project.org', output=1)
## "AT" (Österreich, alles klar)
rdom.whois[['r-project.org']]['Registrant Country']
## host info
rhost.whois <- whois(ipv4(rhost),verbose = 2, output=1)
## "RIPE Network Coordination Centre (RIPE)" 
rhost.whois[['r-project.org']]['Organization']
```

The results of those queries may look a little bit confusing at first. The whois queries tells us that r-project.org site is hosted by the Wirtschaftsuniversität Wien in Austria (and so does the extension of the primary domain  &mdash; ".at") and that its address is accordingly managed by the RIPE-NCC. But RIR lookup on the address of the server tells us that its address falls within a range managed by ARIN which serves North America.  What's happening here is that some address ranges were assigned by ARIN in the 80's to European organizations such as universities before RIPE NCC began its operations in 1992. Those ranges were later transferred to the RIPE NCC as shown by

``` r
## "Early Registrations, Transferred to RIPE NCC"
rhost.whois[['r-project.org']]['NetType']
```

but this range still belongs to the ARIN address space.

## Further reading

Please look [here](https://numa.hypotheses.org/?p=2694) for more examples.
