##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
##
##
##
##
##
##
setMethod(
  "initialize"
  ##
  , signature(.Object="IP") 
  ## ipv4=NULL, ipv6=NULL
  , function(.Object, ipstrings=NULL,ip=NULL,ip4=NULL,ip6=NULL,append=FALSE){
    ##
# cat("IP: init\n")
    ##
    ## Quick return
    ##
    if( 
        is.null(ipstrings) 
      & ( ip.null <-is.null(ip) ) & ( ip4.null <- is.null(ip4) & ( ip6.null <- is.null(ip6) ) ) ## 
    ){
      ##
      return(.Object)
    } 
##
# cat("IP: init\n")
# print(str(ip4));print(str(ip6))   
    ##
    ## Input from strings
    ##
    if ( length(ipstrings) ){  
##
# cat("IP: init\n")  
      ##
      if( typeof( ipstrings )!='character' ){
        ##
        stop('ip should be of type character')
      }
      ##
      suppressWarnings(
        .Object@ipv4 <- new('IPv4', ipstrings )
      )
      ##
      suppressWarnings(
        .Object@ipv6 <- new('IPv6', ipstrings )
      )
      ##
      .Object@.Data <- ifelse(
        !is.na(.Object@ipv4)
        , 4L
        , ifelse(
          !is.na(.Object@ipv6)
          , 6L
          , NA_integer_
        )
      )
    ##
    }else{
##
# cat("IP: init\n")
      ##
      ##
      ##
      if( 
        !is.null(ip) ## !ip.null ## 
      ){
        ##
        if( !ip4.null ) stop('both ip & ip4 args are set' )
        ##
        if( !is.null(ip6) ) stop('both ip & ip6 args are set' )
        ## !is.list(ip) stop('ip should be a list' )
        ip4 <- ip[['ipv4']] 
        ip6 <- ip[['ipv6']]
        ##
#           print(ip4);print(ip6)
      }
      ##
      ## 
      ##
      if(
        ( 
#           class( ip4  )=='IPv4' | class( ip6 )=='IPv6'
          inherits(ip4, 'IPv4') | inherits(ip6, 'IPv6' )
        )
      ){
##
# cat("IP: init from ipv*\n")
        ##
        ## 
        ##
        if( append==F ){
##
# cat("IP: init !append\n")
          ##
          nip4 <- length( ip4 ) 
          nip6 <- length( ip6 ) 
          ##is.null
          ip4 <- if( !length(ip4) ) ipv4(rep(NA_character_, nip6)) else ip4
          ##is.null
          ip6 <- if( !length(ip6) ) ipv6(rep(NA_character_, nip4)) else ip6
          ##
          nip4 <- length( ip4 ) 
          nip6 <- length( ip6 ) 
##
# cat("IP: init ip\n")
# print(str(ip4));print(str(ip6))   
          ##
          if( nip4 != nip6  ){
            stop("non matching ip length: ", nip4, " ", nip6)
          }
          ## CHK
          if(any(
            any(! is.na(ip4@.Data ) & !is.na( ip6@.Data ))
#             (is.na(ip4@.Data )!=!is.na( ip6@.Data ))
          )){
            stop("Mixed IP families. Set append to TRUE to concatenate.")
          }
##
# cat("IP: init data\n")
# print(!is.na(.Object@ipv4))
# print(!is.na(.Object@ipv6))
          ##
          .Object@.Data <- ifelse(
            !is.na(ip4)
            , 4L
            , ifelse(
              !is.na(ip6)
              , 6L
              , NA_integer_
            )
          )
        }else{
# cat("IP: init append\n")
          ##
          nip4 <- length(ip4)
          nip6 <- length(ip6)
# print(ip6)
# print(str(ip6));
          ## CHK: NULL
          ip4 <- if( nip4 ) ip4[c(1:nip4, rep(NA_integer_, length(ip6) ) )] else ipv4( rep(NA_integer_, nip6) )
          ##
          ip6 <- if( nip6 ) ip6[c( rep(NA_integer_, nip4), 1:nip6 )] else ipv6( rep(NA_integer_, nip4) )
          ##
# print(str(ip4)); print(str(ip6));
# print(ip6)
          ##
          ##
          .Object@.Data <- rep(c(4L,6L), c(nip4, nip6) )
        }
        ##
        .Object@ipv4 <- ip4
        ##
        .Object@ipv6 <- ip6
      ##
      }else{
        ##
        stop('malformed ip arg')
      }
    } ## !ipstrings
    ## 
    ## ¿ no warnings ?
    ## 
    if( na <-length(which(is.na(.Object@.Data) ) ) )warning( length(.Object@.Data) - ( na ) )
##
# cat("IP: init exit\n")
    ##
    .Object    

  }
)
## TODO
setValidity(
  "IP"
  , function(object){
#     cat("IP: valid\n")
    T
  }
)
##
setMethod(
  "ip"
  , signature(e1="missing",e2="missing")
  , function(e1,e2,...) new('IP', ...)
)
##
##
##
setMethod(
  "ip"
  , signature(e1 ="character", e2="missing")
  , function(e1, e2,...) new('IP', ipstrings=e1,...)
)
##
## CHK Hein ?
##
if( F ) setMethod(
  "ip"
  , signature(e1 ="integer", e2="missing")
  , function(e1, e2,...){
    ip <- new('IP', ...)
    ##
    suppressWarnings(
      ip@ipv4  <- ipv4(e1)
    )
    ##
    suppressWarnings(
      ip@ipv6  <- ipv6(e1)
    )
    ##print(str(e1@ipv6))
    ip@.Data <- ifelse(
      is.na(ip@ipv4) 
      ##
      , ifelse(
          is.na(ip@ipv6)
        , NA_integer_
        , 6L
      )
      , 4L
    )
    ##
    ip
  }
)
##
##
##
setMethod(
  "ip"
  , signature(e1 ="IPv4", e2="IPv6")
  , function(e1, e2,...) new('IP', ip4=e1,ip6=e2,...)
)
##
## CHK
##,ip6=ipv6()
setMethod(
  "ip"
  , signature(e1 ="IPv4", e2="missing")
  , function(e1, e2,...) new('IP', ip4=e1,...)
)
setMethod(
  "ip"
  , signature(e1 ="IPv6", e2="missing")
  , function(e1, e2,...) new('IP', ip6=e1,...)
)
##
##
##
setMethod(
  "ip"
  , signature(e1 ="list", e2="missing")
  , function(e1, e2,...) new('IP', ip=e1,...)
)
##
setMethod(
  "ip"
  , signature(e1="logical",e2="missing")
  , function(e1,...) {
##cat("ip logical\n")
    ## CHK
    if( !all(is.na(e1)) ) stop("cannot create IP objects from logical")
    ip        <- ip()
    ip@.Data  <- rep(NA_integer_,length(e1))
    ip@ipv4   <- ipv4(e1)
    ip@ipv6   <- ipv6(e1)
    ip
  }
)
##
##
##
setMethod(
  "ipv4"
  , signature(object ="IP")
  , function(object, drop=F,...){
    ## CHK
    if( drop==F ) object@ipv4 else object@ipv4[object@.Data==4L ]
#     ##
#     idx <- ifelse( drop==F, rep(T,length(object)), object@.Data==4L )
#     ##
#     object@ipv4[idx]
  }
)
##
##
##
setMethod(
  "ipv6"
  , signature(object ="IP")
  , function(object, drop=F,...){
    ## CHK
    if( drop==F ) object@ipv6 else object@ipv6[object@.Data==6L ]
#     ##
#     idx <- if( drop==F) rep(T,length(object)) else object@.Data==6L 
#     ##
#     object@ipv6[idx]
  }
)
##
##
##
##
setMethod(
  "ip.version"
  , "IP"
  , function(ip,...) ip@.Data
)
##
##
##
setMethod(
  "is.numeric"
  ## 
  , signature(x = "IP")
  , function(x) FALSE
)
##
##
##
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
##
##
##
##
setMethod(
  "initialize"
  ##
  , signature(.Object="IPr") ## 
  ##
  , function(.Object, ipstrings=NULL,ipr=NULL,ip4r=NULL,ip6r=NULL,lo=NULL, hi = NULL, nip=NULL,append=FALSE){
    ##
# cat("IPr init \n")    
    ##
    if( 
    is.null(ipstrings) & is.null(ipr) & ( is.null(ip4r) & is.null(ip6r) ) & is.null(lo)
#       is.null(ipstrings) & is.null(ipr) & is.null(ip4r) & is.null(lo) 
    ){
# cat("quick return\n") 
      ##
      return(.Object)
    } 
    ##
    ##
    ##
    if ( length(ipstrings) ){    
      ##
      if( typeof( ipstrings )!='character' ){
        ##
        stop('ip should be of type character')
      }
      ##
      suppressWarnings(
        .Object@ipv4r <- new('IPv4r', ipstrings )
      )
      ##
      suppressWarnings(
        .Object@ipv6r <- new('IPv6r', ipstrings )
      )
      
    }else {
      ##
#         print(c(class( ip4r ), class( ip6r )))
      ## 
      ##
      if(
#         class( lo )=='IP' & ( class( nip  ) %in% c('integer','numeric') )
          inherits( lo, 'IP' ) & inherits( nip, c('integer','numeric') )
      ){
# cat("IPr nip\n")
        ##
        hi <- lo + nip
        ##print(hi)
        ## TODO: new('IPr', lo=lp,hi=hi,...)
        return( ipr(lo,hi) )
        
      } else if(
        ( 
#           class( lo )=='IP' & class( hi )=='IP'
          inherits(lo, 'IP') & inherits(hi, 'IP' )
        )
      ){
        ##
#cat("lo-hi\n")
# print(str(lo));print(str(hi));
        ##
        ip4r <- ipv4r(ipv4(lo),ipv4(hi))
        ##
        ip6r <- ipv6r(ipv6(lo),ipv6(hi))
# print(str(ip4r));print(str(ip6r));
        
      }else if( !is.null(ipr) ) {
        ##
        ip4r <- ipr[[1]] 
        ip6r <- ipr[[2]] 
      }
      ##
      ## 
      ##
      if(
        (## ip4r or ip6r can be NULL
#         (class( ip4r )=='IPv4r') | (class( ip6r )=='IPv6r')
          inherits(ip4r, 'IPv4r') | inherits(ip6r, 'IPv6r' )
        )
      ){
        ##
# cat("IPr ip4-6r\n")
# print(str(ip4r));print(str(ip6r));
        ## 
        ##
        if( append==F ){
          ##
          nip4r <- length( ip4r ) 
          nip6r <- length( ip6r ) 
          ## FIXME:  ipr(ipv4r(ipv4(0L), 0:5L))
# print(is.null(ip6r));          
# print(str(ipv6r(rep(NA_character_, nip4r ))));          
          ## !!!ipV*!!!
          ipv4r <- if( !length(ip4r) ) ipv4r(rep(NA_character_, nip6r )) else ip4r
          ipv6r <- if( !length(ip6r) ) ipv6r(rep(NA_character_, nip4r )) else ip6r
# print(str(ip4r));print(str(ip6r));
          ##
          nip4r <- length( ipv4r ) 
          nip6r <- length( ipv6r ) 
          ##
          if( nip4r != nip6r  ){
            stop("non matching ip length: ", nip4r, " ", nip6r)
          }
          ## CHK
          if(
            any(! is.na(ip4r@.Data ) & !is.na( ip6r@.Data ))
          ){
            stop("Mixed IP families. Set append to TRUE to concatenate.")
          }
          
        }else{
          ##
          nip4r <- length(ip4r)
          nip6r <- length(ip6r)
          ##  CHK: NULL + FIXME: ipv4r(NA) ipv6r(NA)
          ipv4r <- if( nip4r ) ip4r[c(1:nip4r, rep(NA_integer_, nip6r ) )] else ipv4r( rep(NA_integer_, nip6r) )
          ##
          ipv6r <- if( nip6r ) ip6r[c( rep(NA_integer_, nip4r), 1:nip6r )] else ipv6r( rep(NA_integer_, nip4r) )
        }
        ##
        .Object@ipv4r <- ipv4r
        ##
        .Object@ipv6r <- ipv6r
# print(str(ip4r));print(str(ip6r));print(str(.Object));
      }else{
        ##
        stop('malformed ip arg')
      }
    }
    ##
    ##
    ##
    .Object@.Data <- ifelse(
      !is.na(.Object@ipv4r)
      , 4L
      , ifelse(
        !is.na(.Object@ipv6r)
        , 6L
        , NA_integer_
      )
    )
    ## 
    if( na <-length(which(is.na(.Object@.Data) ) ) )warning( length(.Object@.Data) - ( na ) )
    ##
    .Object    
    
  }
)
##
##
##
setMethod(
  "ipr"
  , signature(e1="missing",e2="missing")
  , function(e1,e2,...){
    new('IPr', ...)
  }
)
##
setMethod(
  "ipr"
  , signature(e1="character",e2="missing")
  , function(e1,e2,...) new('IPr', ipstrings=e1,...)
)
##
setMethod(
  "ipr"
  , signature(e1="character",e2="character")
  , function(e1,e2,...) new('IPr', lo=ip(e1), hi=ip(e2),...)
)
##
setMethod(
  "ipr"
  , signature(e1="character",e2=".__intFP__.")
  , function(e1,e2,...) new('IPr', lo=ip(e1), nip=e2,...)
)
##
setMethod(
  "ipr"
  , signature(e1="IPv4r",e2="IPv6r")
  , function(e1,e2,...) new('IPr', ip4r=e1,ip6r=e2,...)
)
##
setMethod(
  "ipr"
  , signature(e1 ="IPv4r", e2="missing")
  , function(e1, e2,...) new('IPr', ip4=e1,...)
)
##
setMethod(
  "ipr"
  , signature(e1 ="IPv6r", e2="missing")
  , function(e1, e2,...) new('IPr', ip6=e1,...)
)
##
setMethod(
  "ipr"
  , signature(e1="IP",e2="IP")
  , function(e1,e2,...) new('IPr', lo=e1,hi=e2,...)
)
##
setMethod(
  "ipr"
  , signature(e1="IP",e2=".__intFP__.")
  , function(e1,e2,...) new('IPr', lo=e1,nip=e2,...)
)
##
setMethod(
  "ipr"
  , signature(e1="list",e2="missing")
  , function(e1,e2,...) new('IPr', ipr=e1,...)
)
##
## FIXME!!! comment attribuer e à v4 et v6 ?
##
setMethod(
  "ipr"
  , signature(e1="logical",e2="missing")
  , function(e1,...) {
##cat("ipr logical\n")
    ## CHK
    if( !all(is.na(e1)) ) stop("cannot create IPr objects from logical")
    ipr        <- ipr()
    ipr@.Data  <- rep(NA_integer_,length(e1))
    ipr@ipv4r  <- ipv4r(e1)
    ipr@ipv6r  <- ipv6r(e1)
    ipr
  }
)
##
##
##
setMethod(
  "ip"
  , signature(e1 ="IPr",e2="missing")
  , function(e1,...){
    ##
    ipv4 <- ipv4(e1@ipv4r)
    ipv6 <- ipv6(e1@ipv6r)
    ##
    lo <- ip(
      list(ipv4=ipv4[[1]], ipv6=ipv6[[1]])##,append=F
    )
    hi <- ip(
      list(ipv4=ipv4[[2]], ipv6=ipv6[[2]])##,append=F
    )
    ##
    list(lo=lo,hi=hi)
  }
)
##  
##  
##
setMethod(
  "lo"
  , "IPr"
  , function(e1,...){
#cat("IPr: lo\n")
    ##
    ip(
      ip4=lo(e1@ipv4r), ip6=lo(e1@ipv6r)
    )
  }
)
##  
##  
##
setMethod(
  "hi"
  , "IPr"
  , function(e1,...){
    ##
    ip(
      ip4=hi(e1@ipv4r,...), ip6=hi(e1@ipv6r,...)
    )
  }
)
##
## CHK: e1@.Data==4 | is.na(e1) & !drop
##
setMethod(
  "ipv4r"
  , signature(e1="IPr",e2="missing")
  , function(e1,e2,drop=F,...){
    ##
    idx <- ifelse( rep(drop==F,length(e1)), T, e1@.Data==4 )
    ##
    e1@ipv4r[idx]
  } 
)
##
## CHK
##
setMethod(
  "ipv6r"
  , signature(e1="IPr",e2="missing")
  , function(e1,e2,drop=F,...){
    ##
    idx <- ifelse( rep(drop==F,length(e1)), T, e1@.Data==6 )
    ##
    e1@ipv6r[idx]
  } 
)
##
##
##
##
setMethod(
  "ip.version"
  , "IPr"
  , function(ip,...) ip@.Data
)
##
##
##
setMethod(
  "is.numeric"
  ## 
  , signature(x = "IPr")
  , function(x) FALSE
)
## TODO
# setMethod(
#   "ip.range"
#   ## 
#   , "IPr"
#   , function(ipr){
#      
#   }
# )
##
##
##
##
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
##
## 
##
##
# setMethod(
#   "ip"
#   , "character"
#   , function(ip) new('IP', ip)
# )
##________________________________________________________________________________________________________________________
##
## 
## 
setMethod(
  "["
  , signature(x="IP", i='.__subscript__.')
  , function(x, i, ...){
    ## FIXME: NULL else integer(0) else matrix(0.,ncol=2)
    ## !is.null
    if( length(x@ipv4@ipv4 )) x@ipv4  <- x@ipv4[i]
    if( length(x@ipv6@ipv6 )) x@ipv6  <- x@ipv6[i]
    x@.Data <- x@.Data[i]
    x
  }
)
##
##
##
## 
##
## 
## 
setMethod(
  "[<-"
  , signature(x="IP", i='ANY', value='ANY')
  , function(x, i, j, ..., value){
    stop("unimplemented assign method for IP object")
  }
)
## 
setMethod(
  "[<-"
  , signature(x="IP", i=".__subscript__.", value='IP')
  ## 
  , function(x, i, j, ..., value){
    ##
    x@ipv4[i] <- value@ipv4
    ##
    x@ipv6[i] <- value@ipv6
    ##
    x@.Data <- ifelse(
      !is.na(x@ipv4)
      , 4L
      , ifelse(
        !is.na(x@ipv6)
        , 6L
        , NA_integer_
      )
    )
    ##
    x
  }
)
##
## !!!FIXME!!!
## 
if(F)setMethod(
  "[<-"
  , signature(x="IP", i='.__subscript__.', value='IPv4')
  ## x, i, value
  , function(x, i, j, ..., value){
    ##
    x@ipv4[i] <- value
    ##
    idx <- x@ipv6@.Data[i] ## is.na(x@ipv6@.Data[i]) 
    ##
    if( any(!is.na(idx) ) ){
      ##
      ## x@ipv6[idx] <- NA
      ##
      x@ipv6@ipv6   <- matrix(x@ipv6@ipv6,ncol=2 )[-(idx+1), ]
      ##
      x@ipv6@length <- nrow(x@ipv6@ipv6)
      ##
      x@ipv6@.Data[ i ] <- NA
      ##
      ## 
      nna <- !is.na(x@ipv6@.Data)
      ##
      x@ipv6@.Data[(nna)] <- (cumsum( nna[nna] )) - 1L
#       ##idx <- (1:length(x@ipv6@.Data)) >max(i)
#       ##x@ipv6@.Data[ idx ] <- x@ipv6@.Data[ idx ]-1L
      ##
      x@.Data[i] <- ifelse(!is.na(value),4,NA)
    }
    ##
    x
  }
)
##
# setGeneric("ipv4<-", function(x,i,value){
#     standardGeneric("ipv4<-")
# })
## CHK
setMethod(
  "[<-"
  , signature(x="IP", i='.__subscript__.', value='IPv4')
  , function(x, i, j, ..., value){
    ##
    x@.Data[i] <- ifelse( !is.na(value) , 4L, NA_integer_)
    ##
    x@ipv4[i] <- value
    ##
    x@ipv6[i] <- NA
    ##
    x
  }
)
## CHK
setMethod(
  "[<-"
  , signature(x="IP", i='.__subscript__.', value='IPv6')
  , function(x, i, j, ..., value){
    ##
    x@.Data[i] <- ifelse( !is.na(value) , 6L, NA_integer_)
    ##
    x@ipv6[i] <- value
    ##
    x@ipv4[i] <- NA
    ##
    x
  }
)
## CHK
setMethod(
  "[<-"
  , signature(x="IP", i='.__subscript__.', value='logical')
  , function(x, i, j, ..., value){
    ## CHK
    if( !all(is.na(value)) ) stop("cannot assign logical to IP object")
    ##
    x@.Data[i] <- NA_integer_
    ##
    x@ipv6[i] <- NA
    ##
    x@ipv4[i] <- NA
    ##
    x
  }
)

##
##
##
setMethod(
  "id"
  , signature(x = "IP")
  , function(x){
    ##
    ifelse(ip.version(x)==4L, id(x@ipv4), id(x@ipv6))
  }
)
##
setMethod(
  "id<-"
  , signature(x = "IP")
  , function(x,value){
    ##
    id( x@ipv4) <- ifelse(ip.version(x)==4L, value, NA)
    ##
    id( x@ipv6) <- ifelse(ip.version(x)==6L, value, NA)
    ##
    x
  }
)
##
##
##
names.IP <- function(x){
  ##is.null FIXME: IP_getId
  if( 
    !length( ip4.nm <- ip.get.id(x@ipv4) ) &  !length( ip6.nm <- ip.get.id(x@ipv6)) 
  ) return(NULL)
  ##is.null
  nm <- if( length( ip4.nm ) ) rep("", length(x)) else ip4.nm
  ##
#   print(ip.version(x))
  ##
  ifelse(
    ip.version(x)==6
    , ip6.nm ## !!!CHK!!! if( is.null( ip6.nm ) ) rep(NA_character_, length(x)) else ip6.nm
    , ip4.nm ## nm
  )
#   ##
#   if( is.null(x@ipv4@id) &  is.null(x@ipv6@id) ) return(NULL)
#   ##
#   nm <- if( is.null(x@ipv4@id) ) rep(NA_character_, length(x)) else ip.get.id(x@ipv4)
#   ##
#   ifelse(
#     ip.version(x)==6
#     , if( is.null(x@ipv6@id) ) rep(NA_character_, length(x)) else ip.get.id(x@ipv6)
#     , nm
#   )
} 
##ip.set.id
'names<-.IP' <- function(x,value){ 
  x@ipv4 <- IP_setId(x@ipv4,value)
  x@ipv6 <- IP_setId(x@ipv6,value)
  x
}
##________________________________________________________________________________________________________________________
##
##
##
setMethod(
  "[<-"
  , signature(x="IPr", i='ANY', value='ANY')
  , function(x, i, j, ..., value){
    stop("unimplemented assign method for IPr object")
  }
)
##
## 
## 
setMethod(
  "["
  , signature(x="IPr", i='.__subscript__.')
  , function(x, i, ...){
    ## FIXME: NULL
    ## !is.null
    if( length( x@ipv4r@ipr ) ) x@ipv4r  <- x@ipv4r[i]
    if( length( x@ipv6r@ipr )) x@ipv6r  <- x@ipv6r[i]
    x@.Data <- x@.Data[i]
    x
  }
)
##
##
##
setMethod(
  "[<-"
  , signature(x="IPr", i='.__subscript__.', value='IPr')
  , function(x, i, j, ..., value){
    ##
    x@ipv4r[i]   <- value@ipv4r
    ##
    x@ipv6r[i]   <- value@ipv6r
    ##
    x@.Data <- ifelse(
      !is.na(x@ipv4r)
      , 4L
      , ifelse(
        !is.na(x@ipv6r)
        , 6L
        , NA_integer_
      )
    )
    ##
    x
  }
)
## CHK
setMethod(
  "[<-"
  , signature(x="IPr", i='.__subscript__.', value='IPv4r')
  , function(x, i, j, ..., value){
    ##
    x@.Data[i] <- ifelse( !is.na(value) , 4L, NA_integer_)
    ##
    x@ipv4r[i] <- value
    ##
    x@ipv6r[i] <- NA
    ##
    x
  }
)
## CHK
setMethod(
  "[<-"
  , signature(x="IPr", i='.__subscript__.', value='IPv6r')
  , function(x, i, j, ..., value){
    ##
    x@.Data[i] <- ifelse( !is.na(value) , 6L, NA_integer_)
    ##
    x@ipv6r[i] <- value
    ##
    x@ipv4r[i] <- NA
    ##
    x
  }
)
## CHK
setMethod(
  "[<-"
  , signature(x="IPr", i='.__subscript__.', value='logical')
  , function(x, i, j, ..., value){
    ## CHK
#     if( !all(is.na(value)) ) stop("cannot assign logical to IPr object")
    ##
    x@.Data[i] <- NA_integer_
    ##
    x@ipv6r[i] <- NA
    ##
    x@ipv4r[i] <- NA
    ##
    x
  }
)
##____________________________________________________________________________________________________________________

##____________________________________________________________________________________________________________________
##
##
##
setMethod(
  "rbind2"
  , signature(x = "IP", y="IP")
  , function(x, y, ...){  
    ##
    x@ipv4   <- rbind2(x@ipv4, y@ipv4)
    ##
    x@ipv6   <- rbind2(x@ipv6, y@ipv6)
    ##
    x@.Data <- ifelse(
        !is.na(x@ipv4)
        , 4L
        , ifelse(
          !is.na(x@ipv6)
          , 6L
          , NA_integer_
        )
      )
    ##
    x
  }
)
##
##
## 
`c.IP` <- function(...) {
  ##
  x   <- list(...)
  ##
  ip <- ip()
  ##
  ip@ipv4 <- do.call( `c`, lapply(x,ipv4))
  ##
  ip@ipv6 <- do.call( `c`, lapply(x,ipv6))
  ##
  ip@.Data <- ifelse(
      !is.na(ip@ipv4)
      , 4L
      , ifelse(
        !is.na(ip@ipv6)
        , 6L
        , NA_integer_
      )
    )
  ##
  ip
}
##
##
## 
`c.IPr` <- function(...) {
  ##
  x   <- list(...)
  ##
  ip <- ipr()
  ##
  ip@ipv4r <- do.call( `c`, lapply(x,ipv4r))
  ##
  ip@ipv6r <- do.call( `c`, lapply(x,ipv6r))
  ##
  ip@.Data <- ifelse(
      !is.na(ip@ipv4r)
      , 4L
      , ifelse(
        !is.na(ip@ipv6r)
        , 6L
        , NA_integer_
      )
    )
  ##
  ip
}
##____________________________________________________________________________________________________________________

##____________________________________________________________________________________________________________________
##
##
##
##
##________________________________________________________________________________________________________________________
##
##
##
setMethod(
  "id"
  , signature(x = "IPr")
  , function(x){
    ##
    ifelse(ip.version(x)==4L, id(x@ipv4r), id(x@ipv6r))
  }
)
##
setMethod(
  "id<-"
  , signature(x = "IPr")
  , function(x,value){
    ##
    id( x@ipv4r) <- ifelse(ip.version(x)==4L, value, NA)
    ##
    id( x@ipv6r) <- ifelse(ip.version(x)==6L, value, NA)
    ##
    x
  }
)
##
##
##
##
names.IPr <- function(x){
  ## is.null
  if( 
    !length( ip4.nm <- IP_getId(x@ipv4r) ) & !length( ip6.nm <- IP_getId(x@ipv6r)) 
  ) return(NULL)
  ##
#   nm <- if( length( ip4.nm ) ) rep("", length(x)) else ip4.nm
  ##
  ifelse(
    ip.version(x)==6
    , if( length( ip6.nm ) ) rep("", length(x)) else ip6.nm
    , if( length( ip4.nm ) ) rep("", length(x)) else ip4.nm ## nm
  )
} 
##
'names<-.IPr' <- function(x,value){ 
  x@ipv4r <- ip.set.id(x@ipv4r,value)
  x@ipv6r <- ip.set.id(x@ipv6r,value)
  x
}
##
##
##
setMethod(
  "rbind2"
  , signature(x = "IPr", y="IPr")
  , function(x, y, ...){
# cat("rbind2 IPr\n")
    ##
    x@ipv4r   <- rbind2(x@ipv4r, y@ipv4r)
    ##
    x@ipv6r   <- rbind2(x@ipv6r, y@ipv6r)
    ##
    x@.Data <- ifelse(
        !is.na(x@ipv4r)
        , 4L
        , ifelse(
          !is.na(x@ipv6r)
          , 6L
          , NA_integer_
        )
      )
    ##
    x
  }
)
## 
# rbind.IPr <- function(..., deparse.level = 1, make.row.names = TRUE, stringsAsFactors = default.stringsAsFactors()){
#   ##
#   cat("s3:rbind\n")
#   args <- list(...)
#   rbind2(args[[1]],args[[2]])
# }
##
##
## TODO: `c.IPr`
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
##
##
##
setMethod(
  "as.character"
  , "IP"
  , function(x,...){
    ## 
    res <- rep( NA_character_, length(x) ) ## 
    ## !is.null
    if(length(x@ipv4@ipv4 )){
      idx      <- which(x@.Data==4L)
      res[idx] <- as.character(x@ipv4)[idx]
    }
    ##!is.null
    if(length(x@ipv6@ipv6 )){
      idx      <- which(x@.Data==6L)
      res[idx] <- as.character(x@ipv6)[idx]
    }
    ##
    ##!is.null
    if( length( nm <- names(x) ) ) names(res) <- nm
    ##
    res
  } 
)
##
##
##
##
setMethod(
  "print"
  , "IP"
  , function(x,...){
    ##
    print(as.character(x,...))
    ##
    invisible(x)
  }
)
##
setMethod(
  "show"
  , "IP"
  , function(object){
     ##
     print(object)
     invisible()
  }
)
##
## 
##
format.IP <- function(x
  , trim = FALSE, digits = NULL, nsmall =0L, justify = c("left","right", "centre", "none"), width = NULL, na.encode = TRUE,scientific = NA, big.mark = "", big.interval = 3L
  , small.mark = "", small.interval = 5L, decimal.mark = ".", zero.print = NULL, drop0trailing = FALSE
  , ...) as.character(x,...) ##
##
toString.IP <- function(x,...) as.character(x,...) ##
##
##
##
setMethod(
  "as.numeric"
  , "IP"
  , function(x){
    ##
     ifelse( ip.version(x)==4, as.numeric(x@ipv4), as.numeric(x@ipv6))
  }
)
##
##
##
unique.IP <- function(
  x,...
){
  ##
  new('IP', unique(as.character(x),...))
  ## IP_uniq(x,...)
}
##
##
##
# setMethod(
#   "ipv4"
#   , "IP"
#   , function(ip) ip@ipv4
# )
##________________________________________________________________________________________________________________________
##
##
##
##
##
##
##
setMethod(
  "as.character"
  , "IPr"
  , function(x,...){
    ## 
    res <- rep( NA_character_, length(x) ) ## 
    ## !is.null
    if( length(x@ipv4r@ipr )){
      idx      <- which(x@.Data==4L)
      res[idx] <- as.character(x@ipv4r)[idx]
    }
    ##!is.null
    if( length(x@ipv6r@ipr )){
      idx      <- which(x@.Data==6L)
      res[idx] <- as.character(x@ipv6r)[idx]
    }
    ##!is.null
    if( length( nm <- names(x) ) ) names(res) <- nm
    ##
    res
  } 
)
##
##
##
##
setMethod(
  "show"
  , "IPr"
  , function(object){
    ##
    print(as.character(object))
    ##
    invisible()
  }
)
##
setMethod(
  "print"
  , "IPr"
  , function(x,...){
    ##
    print(as.character(x,...))##
    ##
    invisible(x)
  }
)
##
## 
##
format.IPr <- function(x, ...) as.character(x,...) ##
##
toString.IPr <- function(x,...) as.character(x,...) ##
##
##
##
##
unique.IPr <- function(
  x,...
){
  ##
  new('IPr', unique(as.character(x),...))
  ## IP_uniq(x,...)
}
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
## ?`group generic`
##
##
setMethod(
  "Arith"
  ##
  , signature(e1 = "IP" , e2 = ".__intFP__.")
  , function(e1,e2){
    ##print(.Generic)
    ##
    if(
      .Generic %in% c(  "*",   "^",   "%%",  "%/%", "/" )
    ){
      ##
      stop( .Generic, " invalid operator for ip class" )
    }
    ##
    suppressWarnings(
      e1@ipv4  <- callGeneric(e1@ipv4, e2)
    )
    ##
    suppressWarnings(
      e1@ipv6  <- callGeneric(e1@ipv6, e2)
    )
    ##
    e1@.Data <- ( ifelse(
      (is.na(e1@ipv4) & is.na(e1@ipv6)) 
      , NA_integer_
      , e1@.Data
    ))
    ##
    e1
  }
)
setMethod(
  "Arith"
  ## 
  , signature(e1 = "IP", e2 = "IP")
  , function(e1, e2){
    ##print(.Generic)
    ##
    if(
      .Generic %in% c(  "*",   "^",   "%%",  "%/%", "/" )
    ){
      ##
      stop( .Generic, " invalid operator for ip class" )
    }
    ##CHK: assert ip family
    if(## 
      any( ( !is.na(e1@.Data) & !is.na(e2@.Data) ) & e1@.Data!=e2@.Data )
#       ##any( e1@.Data[idx]!=e2@.Data[idx] )
    ){
      stop(.Generic, " mixed ip family")
    }
    ##
    suppressWarnings(
      e1@ipv4  <- callGeneric(e1@ipv4, e2@ipv4)
    )
    ##
    suppressWarnings(
      e1@ipv6  <- callGeneric(e1@ipv6, e2@ipv6)
    )
    ##
    e1@.Data <- ( ifelse(
      (is.na(e1@ipv4) & is.na(e1@ipv6)) 
      , NA_integer_
      , e1@.Data
    ))
    ##
    e1
  }
)
setMethod(
  "Arith"
  ## 
  , signature(e1 = "IP", e2 = "missing")
  , function(e1,e2){
    ##print(.Generic)
    ## "^", 
    if(
      .Generic %in% c(  "*",    "%%",  "%/%", "/" )
    ){
      ##
      stop( .Generic, " invalid operator for ip class" )
    }
    ##
    suppressWarnings(
      e1@ipv4  <- callGeneric(e1@ipv4)
    )
    ##
    suppressWarnings(
      e1@ipv6  <- callGeneric(e1@ipv6)
    )
    ##
    e1@.Data <- ( ifelse(
      (is.na(e1@ipv4) & is.na(e1@ipv6)) 
      , NA_integer_
      , e1@.Data
    ))
    ##
    e1
  }
)
##
##
# getGroupMembers("Compare")
# "==" ">"  "<"  "!=" "<=" ">="
##
## all(ipsign.ip.0==ipsign.ip.app.0)
##
setMethod(
  "Compare"
  ## 
  , signature(e1 = "IP", e2 = "IP")
  , function(e1,e2){
    ##print(.Generic)
    ##
    ##
    if(## CHK
      any( ( !is.na(e1@.Data) & !is.na(e2@.Data) ) & e1@.Data!=e2@.Data )
#       ##any( e1@.Data[idx]!=e2@.Data[idx] )
    ){
      stop(.Generic, " mixed ip family")
    }
    ##
    suppressWarnings(
      v4 <- callGeneric(e1@ipv4, e2@ipv4)
    )
    ##
    suppressWarnings(
      v6  <- callGeneric(e1@ipv6, e2@ipv6)
    )
    ##
    res <- ifelse( ip.version(e1)==4, v4, v6) ## v4|v6
    ##
    res
  }
)
##
##
#  getGroupMembers("Logic")
# "&" "|"
##
## où est "!" ? d'après la doc avec Logic (?groupGeneric, ce qui n'est pas...hmmm, logique) mais getGroup('!') ne retourne rien
## getGroup("!") : list()
## 
setMethod(
  "Logic"
  ##
  , signature(e1 = "IP" , e2 = "IP")
  , function(e1,e2){
    ##print(.Generic)
    ##
    idx <- which( !is.na(e1@ipv4) | !is.na(e2@ipv4) )
    ##FIXME? cf. "Compare"
    if(
      any( e1@ipv4@.Data[idx]!=e2@ipv4@.Data[idx] )
    ){
      stop(.Generic, "mixed ip family")
    }
    ##
    suppressWarnings(
      e1@ipv4  <- callGeneric(e1@ipv4, e2@ipv4)
    )
    ##print(e1@ipv4)
    suppressWarnings(
      e1@ipv6  <- callGeneric(e1@ipv6, e2@ipv6)
    )
    ##print(str(e1@ipv6))
    e1@.Data <- ( ifelse(
      (is.na(e1@ipv4) & is.na(e1@ipv6)) 
      , NA_integer_
      , e1@.Data
    ))
    ##
    e1
  }
)
##________________________________________________________________________________________________________________________
##
setMethod(
  "Compare"
  ## 
  , signature(e1 = "IPr", e2 = "IPr")
  , function(e1,e2){
    ##print(.Generic)
    ##
    if(## CHK
      any( ( !is.na(e1@.Data) & !is.na(e2@.Data) ) & e1@.Data!=e2@.Data )
#       ##any( e1@.Data[idx]!=e2@.Data[idx] )
    ){
      stop(.Generic, " mixed ip family")
    }
    ##
    suppressWarnings(
      v4 <- callGeneric(e1@ipv4r, e2@ipv4r)
    )
    ##
    suppressWarnings(
      v6  <- callGeneric(e1@ipv6r, e2@ipv6r)
    )
    ##
    res <- ifelse( ip.version(e1)==4, v4, v6) ## v4|v6
    ##
    res
  }
)
##________________________________________________________________________________________________________________________
