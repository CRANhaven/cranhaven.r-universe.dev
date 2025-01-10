##____________________________________________________________________________________________________________
##
##
##
##____________________________________________________________________________________________________________
##
## TODO: as.host(ip4,ip6) as.host(ip)
##
## 
##
setMethod(
  "initialize"
  ##
  , signature(.Object="host") 
  ##
  , function(.Object, hostname=NULL, host.info=F){
    ##
    if(is.null(hostname)) return(.Object)
    ##
    if(!is.character( hostname ) ) stop("hostname should be of type character")
    ##
    hn <- unique(hostname)
    ##
    hn <- hn[!is.na(hn)]
    ##
    .Object = .Call("Rip_getaddrinfo_0", hn)
    ##
    .Object@hostname <- hn
    ##
    .Object@.Data = match(hostname, hn)
    ##
#     print(str(.Object))
#     cat('len:', length( .Object@ipv4 ), nrow( .Object@ipv4 ) , '\n')
    ## ipv4.hptr
    if( (len <- .Object@ipv4@length )>0 ) .Object@ipv4@.Data <- 0:(len-1)
#     if( length( .Object@ipv4@ipv4 ) ){
#       len <- .Object@ipv4@length ##<- length(.Object@ipv4@ipv4)
#       if(len>0) .Object@ipv4@.Data <- 0:(len-1)
#     }
    ## 
    if( (len<-.Object@ipv6@length)>0 ) .Object@ipv6@.Data <- 0:(len-1)
#     if( nrow( .Object@ipv6 @ipv6) ){
#       len <- .Object@ipv6@length ## <- nrow(.Object@ipv6@ipv6)
#       if(len>0) .Object@ipv6@.Data <- 0:(len-1)
#     }
    ##
    ## !!!
    ##
    if( host.info ){
      .Object@ipv4.hostinfo <- host.info(.Object@ipv4)
    }
    ##
    .Object
  }
)
##
##
##
# host <- function(object=NULL,...) new('host', object,...)
##
setMethod(
  "host"
  , "character"
  , function(host,...){
    new('host', host,...)
  }
)
##____________________________________________________________________________________________________________
##
##
##
setMethod(
  "as.character"
  , "host"
  , function(x){
    hip <- sapply(
      x@.Data
      , function(i){
        ## !NA
        if(!is.na(x@hostname[i])){
          ##
          lo <- x@ipv4.hptr[c(i)]
          hi <- x@ipv4.hptr[c(i+1)]
          ip4 <- if( m4 <- lo!=hi) paste( as.character( x@ipv4[ (lo+1):hi ] ) , collapse = ",") else ""
          ## 
          lo <- x@ipv6.hptr[c(i)]
          hi <- x@ipv6.hptr[c(i+1)]
          ip6 <- if( m6 <- lo!=hi) paste( as.character( x@ipv6[ (lo+1):hi ] ) , collapse = ",")  else ""
          ##
          if( m4|m6 ) paste(ip4, ip6, sep=ifelse( ip4!="" & ip6!="", "--" , "") ) else NA_character_##
        }else NA_character_##
      }
    )
    ##
    names(hip) <- x@hostname[x@.Data]
    ##
    hip
  }
)
##
setMethod(
  "show"
  , "host"
  , function(object) print(as.character(object))
)
##
format.host <- function(x
  , trim = FALSE, digits = NULL, nsmall =0L, justify = c("left","right", "centre", "none"), width = NULL, na.encode = TRUE,scientific = NA, big.mark = "", big.interval = 3L
  , small.mark = "", small.interval = 5L, decimal.mark = ".", zero.print = NULL, drop0trailing = FALSE
  , ...) as.character(x,...)
##
toString.host <- function(x,...){
  ##
  as.character(x)
} 
##
names.host <- function(x) x@hostname
##____________________________________________________________________________________________________________
##
##
##
setMethod(
  "ipv4"
  , "host"
  , function(object,...){
    ##
    nip1 <- nip <- object@ipv4.hptr[-1] - object@ipv4.hptr[-length(object@ipv4.hptr)]
    ##
    nip1[nip==0] <- 1
    ##
    i <- rep(1:length(nip), nip1)
    ##
    i[match(which(nip==0), i)] <- 0
    ##
    i1 <- rep(rep(1,length(nip)), nip1)
    ##
    i1[i==0] <- 0
    ##
    i1 <- cumsum(i1)
    ##
    i1[i==0] <- NA
    ##
    ip <- object@ipv4[i1]
    ##
    names(ip) <- rep(object@hostname, nip1)
    ##
    ip
#     ##
#     ip <- object@ipv4
#     ##
#     nip <- object@ipv4.hptr[-1] - object@ipv4.hptr[-length(object@ipv4.hptr)]
#     ##
#     names(ip) <- object@hostname[
#       rep(1:length(object@hostname) , nip)
#       ]
#     ##
#     ip
  }
)
##
##
##
setMethod(
  "ipv6"
  , "host"
  , function(object,...){
    ##
    nip1 <- nip <- object@ipv6.hptr[-1] - object@ipv6.hptr[-length(object@ipv6.hptr)]
    ##
    nip1[nip==0] <- 1
    ##
    i <- rep(1:length(nip), nip1)
    ##
    i[match(which(nip==0), i)] <- 0
    ##
    i1 <- rep(rep(1,length(nip)), nip1)
    ##
    i1[i==0] <- 0
    ##
    i1 <- cumsum(i1)
    ##
    i1[i==0] <- NA
    ##
    ip <- object@ipv6[i1]
    ##
    names(ip) <- rep(object@hostname, nip1)
    ##
#     print(object@hostname)
#     print(str(ip))
    ##
    ip
    #     ##
#     ip <- object@ipv6
#     ##
#     nip <- object@ipv6.hptr[-1] - object@ipv6.hptr[-length(object@ipv6.hptr)]
#     ##
#     names(ip) <- object@hostname[
#       rep(1:length(object@hostname) , nip)
#       ]
#     ##
#     ip
  }
)
##
##
##
setMethod(
  "ip"
  , signature(e1="host",e2="missing")
  , function(e1,...){
# cat("ip:host\n")
    ##ip(list(ipv4=ipv4(e1),ipv6=ipv6(e1)),append=T)
    ##
    ip(ipv4(e1),ipv6(e1),append=T)
  }
)
##____________________________________________________________________________________________________________

##____________________________________________________________________________________________________________
##
## id(host) <- host.name
##
hostbyIPv4 <- function(host){
    ##
    if( length(host@ipv4)==0 ) return(NA_character_)
    ##
    ip        <- unique(host[!is.na(host)])
    ##
    host.name <- .Call("Rip_ipv4_gethostbyaddr_0", ip )
    ##
    host.name <- host.name[match(host, ip)]
    ##
    ## TODO: names(host.name) <- if( length(host@id) ) host@id else as.character(host)
    ##
    if( length(host@id) ) names( host.name ) <- host@id
    ## 
    host.name
  }
##
setMethod(
  "host"
  ## 
  , signature(host = "IPv4")
  ##
  , function(host) hostbyIPv4(host)
)
##
setMethod(
  "host.info"
  ## 
  , signature(host = "IPv4")
  ##
  , function(host) hostbyIPv4(host)
)
##____________________________________________________________________________________________________________
##
## id(host) <- host.name
hostbyIPv6 <- function(host){
    ##
    if( length(host@ipv6)==0 ) return(NA_character_)
    ##
    ip        <- unique(host[!is.na(host)])
    ##
    host.name <- .Call("Rip_ipv6_gethostbyaddr_0", ip )
    ##
    host.name <- host.name[match(host, ip)]
    ##!is.null
    if( length(host@id) ) names( host.name ) <- host@id
    ## 
    host.name
  }
##
setMethod(
  "host"
  ## 
  , signature(host = "IPv6")
  ##
  , function(host) hostbyIPv6(host)
)
##
setMethod(
  "host.info"
  ## 
  , signature(host = "IPv6")
  ##
  , function(host) hostbyIPv6(host)
)
##____________________________________________________________________________________________________________
##
##
##
setMethod(
  "host"
  ## 
  , signature(host = "IP")
  ##
  , function(host){
    ##
    ip4 <- callGeneric(host@ipv4)
    ##
    ip6 <- callGeneric(host@ipv6)
    ##
    host.name <- ifelse(ip.version(host)==4, ip4, ip6)
    ##
    names( host.name ) <- names(host)
    ##
    host.name
  }
)
##
## !!!: fixme !!! Pq ?
##
setMethod(
  "host.info"
  ## 
  , signature(host = "IP")
  ##
  , function(host){
    ##
    ip4 <- callGeneric(host@ipv4)
    ##
    ip6 <- callGeneric(host@ipv6)
    ##
    host.name <- ifelse(ip.version(host)==4, ip4, ip6)
    ##
    names( host.name ) <- names(host)
    ##
    host.name
  }
)
##____________________________________________________________________________________________________________
##
##
## 
##
setMethod(
  "host.info"
  ## 
  , signature(host = "host")
  ##
  , function(host){
    ##
    host.info(ip(host))
  }
)
##_____________________________________________________________________________________________________________
##
##
##
localhost.ip <- function(...){
  ##
  ip <- .Call('Rip_ifaddrs_0')
  ## 
  ip@.Data = (ifelse(
    !is.na(ip@ipv4)
    , 4L
    , ifelse(!is.na(ip@ipv6), 6L, NA)
  ))
  ##
  ip
}
##_____________________________________________________________________________________________________________

##_____________________________________________________________________________________________________________
##
## 
## variables are set at startup if libidn is available
##
IDNA_DEFAULT <- IDNA_ALLOW_UNASSIGNED <- IDNA_USE_STD3_ASCII_RULES <- NA_integer_
##
## TODO: remplacer par IP_IDN
##
IdnaFlags <- NULL
##
## 
##
match.IdnaFlags <- function(flags){
# print(flags)
# print(IdnaFlags)
  if( !IP_IDN ) stop("Idna support not available")
  ##
  i <- match( flags, names(IdnaFlags))
  ##
  if( any( na <- is.na(i) ) ) stop("unknown Idna flag :", flags[na] ) else if( any( na <- is.na(rv <- IdnaFlags[i]) ) ) stop("undefined Idna values", rv[na] ) else rv
}
##
##
##
toIdna <- function(domain, flags="IDNA_DEFAULT"){
  ##
  nv <- length(domain)
  nf <- length(flags)
  ##
  flags <- match.IdnaFlags(flags)
  ## TODO: bitwAnd
  rv <- .Call("Rip_idn_idna_encode_0", domain, flags)
  ##
  names(rv) <- if( nf > nv ) rep(domain, nf%/%nv ) else domain 
  ##
  rv
}
##
##
##
fromIdna <- function(domain, flags="IDNA_DEFAULT"){
  ##
  nv <- length(domain)
  nf <- length(flags)
  ##
  flags <- match.IdnaFlags(flags)
  ## TODO: bitwAnd
  rv <- .Call("Rip_idn_idna_decode_0", domain, flags)
  ##
  names(rv) <- if( nf > nv ) rep(domain, nf%/%nv ) else domain 
  ##
  rv
}
##_____________________________________________________________________________________________________________

##____________________________________________________________________________________________________________
##
##
##
##
##____________________________________________________________________________________________________________
##
##
##
whois <- function(domain, refer=NA, output=1,verbose=0){
  ##
  whoisQuery <- function(domain, refer){
    ##
    tryCatch({
      ##
      domain <-as.character(domain) ##  domain ## 
      ##
      if(verbose>0) cat('whois:', domain, (refer),"\n")
      ##
      resp0 <- ""
      ##
      if( is.na(refer) ){
        ##
        ianaCo <- socketConnection(
          host="whois.iana.org", port = 43, blocking=TRUE, server=FALSE, open="r+"
        )
        ##
        on.exit(close(ianaCo))
        ##
        writeLines(
          c( domain, '\r\n')
          , ianaCo
          , sep =""
        )
        ##
        resp0 <- readLines(ianaCo)
        ##
        if(verbose>2){
          cat("resp:", resp0, "\n")
        }
        ##
        refer <- stringi::stri_match(resp0, regex="(refer|whois):\\W*([\\w\\.\\-]+)")
        ##
        refer <- refer[refer[,2] %in% c("refer", "whois"), 3]
        ##
      }
      ## queries do not necessarily returns a refer, cf. 'org'
      if( all(is.na(refer)) ){
        ##
        if(verbose>1) cat("no refer found", "\n")
        ##
        resp1 <- resp0
      } 
      else{
        ##
        if(verbose>1) cat("refer:'", refer, "'\n")
        ##
        refer <- refer[
          which( !is.na(refer) )[1]
        ]      
        ##
        if(verbose>0) cat("refer:'", refer, "'\n", sep='')
        ##
        co <- socketConnection(
          host=refer, port = 43, blocking=TRUE, server=FALSE, open="r+"
        )
        ##
        on.exit(close(co))
        ##  
        qr <- if( refer=='whois.arin.net') c("n + ", domain, '\r\n') else if(refer=='whois.ripe.net') c('-V Md5.2 ', domain, '\r\n') else c( domain, '\r\n') ##
        ##
        if(verbose>1) cat("query:'", qr, "'\n")
        ##
        writeLines(
          qr
          , co
          , sep =""
        )
        ##
        resp1 <- readLines(co)
      }
      ##
      if(!output) return(resp1)
      ##
      ## ¡¡¡ multibyte string !!!
      ##
      ## rm comments
      resp1 <- resp1[!grepl("^#", resp1)]
      ## key-val
      kv <- stringi::stri_match(resp1[nchar(resp1)>0] , regex="^([A-Za-z\\s]+)\\s*:\\s+(.+)$")
      ## no keys
      res <- ifelse( is.na(kv[,3]), kv[,1], kv[,3])
      ##
      names(res) <- kv[,2]
      ##
      res[!is.na(res)]
    }
    , error = function(e){
      e
    })
  }
  ##
  mapply(whoisQuery, as.character(domain), as.character(refer), SIMPLIFY = F)
}
##_____________________________________________________________________________________________________________
