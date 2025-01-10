
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
  "initialize"
  ##
  , signature(.Object="IPv6") 
  ##
  , function(.Object, ipstring=NULL){
# cat("init IPv6\n")
    ##
    if(is.null(ipstring)) return(.Object)
    ##
    if( typeof( ipstring )!='character' ){
      ##
      stop('ip should be of type character: ', class(ipstring) )
    }
    ##
    if ( length(ipstring) ){
      ##
      .Object <- .Call(
        'Rip_ipv6_init_0' ##
        ##
        , .Object
        , ipstring
      )
    }
    ##
    if( is.null(.Object@ipv6) ){
      .Object@ipv6 <- matrix(0.,nrow=0,ncol=2)
    }
    ##.Object <- IP_setId( .Object, names( ipstring ) )
    ##
    .Object
  }
)
##
##
##
setValidity(
  "IPv6"
  , function(object){
# cat("IPv6: valid\n")
    ##
    if( 
      is.null(object@ipv6) | is.null(object@length) 
    ) return( "NULL ip6 slot")
#     if( 
#       ##is.null(object@ipv6)!=is.null(object@length) 
#       ##
#       xor( null0 <- is.null(object@ipv6),is.null(object@length) )
#     ) return( "both slots should NULL or set")
    ##
    if(
      !null0 & (nrow(object@ipv6)==object@length )
    ) T
    else{
      paste("unequal length")
    }
  }
)
##
##
##
setMethod(
  "ipv6"
  , "missing"
  , function(object,...) new('IPv6', ...)
)
##
setMethod(
  "ipv6"
  , "character"
  ##
  , function(object,...) new('IPv6', object,...)
)
##
setMethod(
  "ipv6"
  , signature(object ="integer")
  ##
  , function(object,...){
    ##
    ip6 <- .Call('Rip_ipv6_cvt_input_int32_0',object)
    ## TODO !null(@ipv6) en C
    ## is.null
#     if( !length(ip6@ipv6) ) ip6@ipv6 <- matrix(0.,nrow=0,ncol=2)
    ##
    ip6
  }
)
##
setMethod(
  "ipv6"
  , signature(object ="logical")
  ##
  , function(object,...){
    ## CHK
#     if(!all(is.na(object)) ) stop("cannot create IPv6 objects from logical")
    ipv6(as.integer(object))
  }
)
##________________________________________________________________________________________________________________________
##
##
##
##
##
setMethod(
  "initialize"
  ##
  , signature(.Object="IPv6r") ##
  ##
  , function(.Object, ipstring=NULL, ipv6=NULL, lo=NULL,hi=NULL,nip=NULL){
# cat("init IPv6r\n")
# print(str(.Object)); 
    ##
    if(is.null(ipstring)){
      ##
      if(
#         class( lo )=='IPv6' & ( class( nip  ) %in% c('integer','numeric') )
        inherits( lo, 'IPv6' ) & inherits( nip, c('integer','numeric') )
      ){
        ##
        hi <- lo + nip
        ## FIXME: NA dans nip
#         if( ( (nlo <- length(lo))==1) & ( (nhi <- length(hi))>1) ) lo <- rep(lo, nhi)
#         else if( ( nlo>1) & (nhi ==1) ) hi <- rep(hi, nlo)
      ##
      }else if( !is.null(ipv6) ) {
        lo <- ipv6[[1]] 
        hi <- ipv6[[2]] 
      }
      ##
      if( 
        (
#           class( lo )=='IPv6' & class( hi  )=='IPv6'
          inherits(lo, 'IPv6') & inherits(hi, 'IPv6' )
        ) 
      ){
        ##
        if( ( nip<-length(lo@.Data) ) !=length(hi@.Data) ) stop( "ipv6s should have the same length")
        else if(nip==0) return(ipv6r())
        ## CHK
        if( any( is.na(lo@.Data)!=is.na(hi@.Data), na.rm = T ) ) stop( "ipv6s should have the same NA")
        ##
#         if( any( lo@.Data!=hi@.Data, na.rm = T ) ) stop( "ipv6s should have the same NA")
        ##
        if( any(lo > hi, na.rm = T) ) stop( "lo > hi")
        ##
# print(str(lo));print(str(hi) )   
        ##
        ## | is.na(hi)
        nna <- !( is.na(lo)  )
# print(table(nna)); 
        ## CHK
        idx           <- cumsum(nna) - 1L
        .Object@.Data <- ifelse(nna, idx, NA_integer_)
# print(table(is.na(.Object@.Data))); 
        ##!is.null | length(lo@ipv6 )
        if( length(lo@ipv6) ){ 
          ##
          .Object@ipr    <- cbind(lo@ipv6,hi@ipv6) ## cbind(lo@ipv6[nna],hi@ipv6[nna])
          ##
          .Object@length <- nrow(.Object@ipr)
        }## FIXME? NULL
        else .Object@length <- 0L
        ##!is.null
        .Object@id <- if(length(lo@id) ) lo@id else if( length(hi@id) ) hi@id else character(0)
      }
# print(str(.Object));      
      ##
      return(.Object)
    }
    ##
    if( typeof( ipstring )!='character' ){
      ##
      stop('ip should be of type character')
    }
    ##
    if ( length(ipstring) ){
      ##
      .Object <- .Call(
        'Rip_ipv6r_init_0'##
        , .Object
        , ipstring
      )
      ##print(is.matrix( .Object@ipr ) )
    }
    ##
    if( is.null(.Object@ipr) ){
      .Object@ipr <- matrix(0.,nrow=0,ncol=4)
    }
    ##
    if( is.null(.Object@id) ){
      .Object@id <- character()
    }
    ##
    .Object
  }
)
##
setMethod(
  "ipv6r"
  , signature(e1="missing", e2="missing")
  , function(e1,e2,...) new('IPv6r', ...)
)
##
setMethod(
  "ipv6r"
  , signature(e1="character", e2="missing")
  , function(e1,e2,...) new('IPv6r', e1,...)
)
##
setMethod(
  "ipv6r"
  , signature(e1="character", e2="character")
  , function(e1,e2,...) new('IPv6r', lo=ipv6(e1), hi=ipv6(e2),...)
)
##
setMethod(
  "ipv6r"
  , signature(e1="character", e2=".__intFP__.")
  , function(e1,e2,...) new('IPv6r', lo=ipv6(e1), nip=e2,...)
)
##
setMethod(
  "ipv6r"
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2,...) new('IPv6r', lo=e1,hi=e2,...)
)
##
setMethod(
  "ipv6r"
  , signature(e1 = "IPv6", e2 = ".__intFP__.")
  , function(e1,e2,...) new('IPv6r', lo=e1,nip=e2,...)
)
##
setMethod(
  "ipv6r"
  , signature(e1="list",e2="missing")
  , function(e1,e2,...) new('IPv6r', ipv6=e1,...)
)
## CHK: cf [<- NA
setMethod(
  "ipv6r"
  , signature(e1 ="logical",e2="missing")
  , function(e1,...){
    ## CHK
    new('IPv6r', lo=ipv4(as.integer(e1)), hi=ipv4(as.integer(e1)),...)
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
  "lo"
  , "IPv6r"
  , function(e1,...){
# cat("IPv6r: lo\n")
    ##
    lo <- ipv6()
    ##
    lo@.Data <- e1@.Data
    ## FIXME : if( length( e1@ipr ) )
    lo@ipv6 <- matrix( e1@ipr[,1:2], ncol=2) ## 
    ##
    lo@length <- e1@length
    ##!is.null
    lo@id <- if( length(e1@id) ){
       e1@id
    } else character(0)
    ##
# print(str(lo))    
    ##
    lo
  }
)
##
##
##
setMethod(
  "hi"
  , "IPv6r"
  , function(e1,...){
    ##print("ipv6")
    hi <- ipv6()
    ##
    hi@.Data <- e1@.Data
    ## need to coerce to matrix when nr==1
    hi@ipv6 <- matrix( e1@ipr[,3:4], ncol=2) ## 
    ##!is.null
    hi@id <- if( length(e1@id) ){
       e1@id
    } else character(0)
    ##
    hi@length <- e1@length
    ##
    hi
  }
)
##
##
##
setMethod(
  "ipv6"
  , "IPv6r"
  , function(object,...){
    ##print("ipv6")
    ip1 <-ip2 <- ipv6()
    ##
    ip1@.Data <- ip2@.Data <- object@.Data
    ## need to coerce to matrix when nr==1
    ip1@ipv6 <- matrix( object@ipr[,1:2], ncol=2) ## matrix(matrix(object@ipr,ncol=4)[,1:2],ncol=2)
    ip2@ipv6 <- matrix( object@ipr[,3:4], ncol=2) ## matrix(matrix(object@ipr,ncol=4)[,3:4],ncol=2)
    ##!is.null
    ip1@id <- ip2@id <- if( length(object@id) ){
      object@id
    } else character(0)
    ##
    ip1@length <- ip2@length <- object@length
    ##
    list(lo=ip1,hi=ip2)
  }
)
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
  "length"
  , "IPv6"
  ##
  , function(x) length(x@.Data)
)
##
##
##
##
setMethod(
  "is.numeric"
  , signature(x = "IPv6")
  ## 
  , function(x) FALSE
)
##
##
##
##
setMethod(
  "is.na"
  , "IPv6"
  ##
  , function(x) is.na(x@.Data)
)
##
##
##
##
setMethod(
  "print"
  , "IPv6"
  ##
  , function(x,...){
      ##
      ip.strings <- .Call("Rip_ipv6_as_character_0",x)
      ##names(ip.strings) <- names(x)
      print(ip.strings)
      x
  }
)
##
setMethod(
  "show"
  , "IPv6"
  , function(object){
    ##
    print(object)
    ##
    invisible()
  }
)
##
##
##
##
setMethod(
  "as.character"
  , "IPv6"
  , function(x) .Call("Rip_ipv6_as_character_0", x)
)
## utile ?
setAs("IPv6", "character", function(from) .Call("Rip_ipv6_as_character_0", from)) 
##
## 
##
format.IPv6 <- function(x
  , trim = FALSE, digits = NULL, nsmall =0L, justify = c("left","right", "centre", "none"), width = NULL, na.encode = TRUE,scientific = NA, big.mark = "", big.interval = 3L
  , small.mark = "", small.interval = 5L, decimal.mark = ".", zero.print = NULL, drop0trailing = FALSE
  , ...){
  ##
  .Call("Rip_ipv6_as_character_0", x) 
} 
##
toString.IPv6 <- function(x,...){
  ##
  .Call("Rip_ipv6_as_character_0", x)
} 
##
##
##
setMethod(
  "as.integer"
  , "IPv6"
  , function(x) stop("not implemented") ## .Call("Rip_ipv4_cvtfl64_0", x)
)
##
##
##
setMethod(
  "as.numeric"
  , "IPv6"
  , function(x) .Call('Rip_ipv6_cvtfl64_0', x)
)
##
## table -> factor -> unique + match
##
unique.IPv6 <- function(
  x,...
){
  ##
  htb.sz  <- as.integer(length(x)*1.63)+1L
  ## 
  idx <- .Call("Rip_h_ipv6_h128dblh_lemire_hash_0_0", x, c(htb.sz = htb.sz, M2 = 7L))
  ##
  x[idx]
}
##
##
##
##
##________________________________________________________________________________________________________________________
##
##
##
# setMethod(
#   "length"
#   , "IPv6r"
#   , function(x) length(x@.Data)
# )
##
##
##
# setMethod(
#   "is.na"
#   , "IPv6r"
#   , function(x) is.na(x@.Data)
# )
##
##
##
setMethod(
  "is.numeric"
  ## 
  , signature(x = "IPv6r")
  , function(x) FALSE
)
##
##
##
##
setMethod(
  "print"
  , "IPv6r"
  , function(x,...){
      ##
      ip.strings <- .Call("Rip_ipv6r_as_character_0",x)
      ##
      print(ip.strings)
      ##
      x
  }
)
##
setMethod(
  "show"
  , "IPv6r"
  , function(object){
    ##
    print(object)
    ##
    invisible()
  }
)
##
##
##
format.IPv6r <- function(x
,...) .Call("Rip_ipv6r_as_character_0", x) ## 
##
toString.IPv6r <- function(x,...) .Call("Rip_ipv6r_as_character_0", x) ##as.character(x,...)
##
##
##
# setMethod(
#   "ipv6r"
#   , "character"
#   , function(object=NULL,...) new('IPv6r', object,...)
# )
##
setMethod(
  "as.character"
  , "IPv6r"
  , function(x) .Call("Rip_ipv6r_as_character_0", x)
)
##
##
##
setMethod(
  "as.integer"
  , "IPv6r"
  , function(x) stop("not implemented") ## .Call("Rip_ipv4_cvtfl64_0", x)
)
##
##
##
setMethod(
  "as.numeric"
  , "IPv6r"
  , function(x) .Call('Rip_ipv6r_cvtfl64_0', x)
)
##
## 
## 
setMethod(
  "ip.range"
  ## 
  , "IPv6r"
  , function(ipr){
     .Call('Rip_ipv6r_range_0', ipr)
  }
)
##
## !!!TODO!!! hash
##
unique.IPv6r <- function(
  x,...
){
  ##
  new('IPv6r', unique(.Call("Rip_ipv6r_as_character_0", x)) )
  ## IP_uniq(x,...)
}
##________________________________________________________________________________________________________________________
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
setMethod(
  "["
  ## 
  , signature(x = "IPv6", i='.__subscript__.' )
  ##
  , function(x, i, ...) {  
    ##
    ip <- new("IPv6")
    ##
    ip@.Data <- x@.Data[i]
    ##
    if( 
      any( nna <- !is.na(ip@.Data) ) 
    ){
      ##
# cat("IPv6 xpd\n")
      ## CHK
      ip@ipv6 <- matrix(x@ipv6[ (ip@.Data[nna]+1L) ,,drop=F], ncol=2) 
# print(str(ip@ipv6))      
      ##
#       ip@ipv6 <- x@ipv6[which( nna ),,drop=F]
      ## re-idx
      idx           <- cumsum(nna) - 1L
      ip@.Data[nna] <- idx[nna]
      ##
      ip@length     <-nrow(ip@ipv6)
    }else{
      ## FIXME: NULL
      ip@ipv6 <- matrix(numeric(),ncol=2)
      ip@length <- 0L
    }
    ##!is.null
    ip@id <- if( length(x@id) ) x@id[i] else character(0)
    ##
    ip
  }
)
##
##
##
setMethod(
  "[<-"
  , "IPv6"
  , function (x, i, j, ..., value){
    ## mv
#     if( class(value)!='IPv6' ) value <- ipv6(value) ## 
    ##
    ipv6 <- if(nrow(x@ipv6)) matrix(x@ipv6, ncol=2)[(x@.Data+1),,drop=F] else x@ipv6
# print(str(ipv6))
    ##
    v.na <- is.na(value)
    ##
    if (all(v.na==T)){
      x@.Data[i] <- NA
    }else{
      ##
#       if( class(value)!='IPv6' ) value <- ipv6(value) ##
      if( !inherits(value, 'IPv6') ) value <- ipv6(value) ##
      ## 
      mx <- max(i)
      ##
      if( (nr <- nrow(x@ipv6)) ){
        ## grow matrix if necesary
        if( 
          ( d <- mx - nr )>0
        ){
          ipv6 <- rbind(ipv6, matrix(NA_real_, nrow(ipv6)+d, ncol=2))
        }
        ## replace
        ##
        ipv6[i,]     <- as.matrix(value@ipv6, ncol=2)[value@.Data+1,, drop=F]
        ## cp
        x@.Data[i]   <- value@.Data
        ## FIXME: NULL ipv6 table
      }else{ ## empty IP table
        ipv6        <- matrix(NA_real_, nrow= mx, ncol=2)
        ipv6[i,]    <- value@ipv6
        x@.Data[i] <- value@.Data
      }
    }
    ## re-idx
    nna          <- !is.na(x@.Data)
    ## rm NA
    x@ipv6       <- matrix(ipv6[which(nna),],ncol=2)
    ##
    idx          <- cumsum(nna) - 1L
    x@.Data[nna] <- idx[nna]
    ##
    x@length <- nrow(x@ipv6)
    ##
    ## replace_setId
    ##
    x <- IP_setId_replace(x,i,value)
    ##
    x
  }
)
##
##
##
`c.IPv6` <- function(...) IP_concat(...)
##
`c.IPv6r` <- function(...) IP_concat(...)
##
## rbind2
##
setMethod(
  "rbind2"
  , signature(x = "IPv6", y="IPv6")
  , function(x, y, ...){
    ##
    x@.Data  <- c( x@.Data, y@.Data+nrow( x@ipv6 ) )
    ## FIXME: NULL
    x@ipv6   <- rbind(x@ipv6, y@ipv6)
    ##
    x@length <- nrow(x@ipv6)
    ## FIXME: NULL !is.null + IP_setId_rbind
    if( length( x@id ) ){
      ##!is.null
      if( length( y@id ) ) x@id <- c( x@id , y@id  )
      else x@id <- c( x@id , rep("",length(y) ) )
    }else if( length( y@id ) ) x@id <- c( rep("",length(x) ) , y@id  )
    ##
    x
  }
)
##
##
##
setMethod(
  "id"
  , signature(x = "IPv6")
  , function(x)  ip.get.id (x)
)
##
setMethod(
  "id<-"
  , signature(x = "IPv6")
  , function(x,value) ip.set.id(x,value) 
)
##
names.IPv6 <- function(x) ip.get.id(x)
##
'names<-.IPv6' <- function(x,value){ 
  ip.set.id(x,value)
}
##________________________________________________________________________________________________________________________
##
## 
## 
setMethod(
  "["
  ## 
  , signature(x = "IPv6r", i='.__subscript__.' )
  ##
  , function(x, i, ...) {  
# cat("[ IPv6r\n")   
# print(str(x)) 
    ##
    ip <- new("IPv6r")
    ##
    ip@.Data <- x@.Data[i]
    ##
    if( 
      any( nna <- !is.na(ip@.Data) ) 
      ##!all( is.na(ip@.Data) ) 
    ){
      ##
#       nna      <- !is.na(ip@.Data)
      ##
  #     ip@ipr   <- x@ipr[ (ip@.Data[nna]+1L),,drop=F]
      ##
      ip@ipr        <- matrix(x@ipr[ (ip@.Data[nna]+1L) ,],ncol=4)
      ## re-idx
      idx           <- cumsum(nna) - 1L
      ip@.Data[nna] <- idx[nna]
      ##
      ip@length     <- nrow(ip@ipr)
    }else{
      ip@ipr        <- matrix(numeric(),nrow=0 , ncol=4)
      ip@length <- 0L
    }
    ##!is.null
    ip@id <- if( length(x@id) ) x@id[i] else character(0) 
# print(str(ip)) 
    ##
    ip
  }
)
##
## ??? fix nna ???
##
setMethod(
  "[<-"
  , "IPv6r"
  , function (x, i, j, ..., value){
    ## mv
#     if( class(value)!='IPv6r' ) value <- ipv6r(value) ## new('IPv6r', as.character(value))
    ## xpd
    ipr     <- if(nrow(x@ipr)) as.matrix(x@ipr, ncol=4)[x@.Data+1,] else x@ipr
    ##
    v.na <- is.na(value)
    ##
    if (all(v.na==T)){
      ##
      x@.Data[i] <- NA
      
    }else{ 
      ## 
#       if( class(value)!='IPv6r' ) value <- ipv6r(value) 
      if( !inherits(value, 'IPv6r') ) value <- ipv6(value) ##
      ## 
      mx <- max(i)
      ## replace
      if(nrow(x@ipr)){
        ## grow table if necessary
        if( 
          ( d <- mx - nrow(ipr) )>0
        ){
          ipr <- rbind(ipr, matrix(NA_real_, nrow(ipr)+d, ncol=4))
        }
        ##
        ipr[i,]    <- matrix(value@ipr, ncol=4)[value@.Data+1,]
        ## cp
        x@.Data[i] <- value@.Data
      }else{ ## empty IP table
        ipr        <- matrix(NA_real_, nrow= mx, ncol=4)
        ipr[i,]    <- value@ipr
        x@.Data[i] <- value@.Data
      }
    }
    ## re-idx
    nna          <- !is.na(x@.Data)
# print( str(x@ipr)  )  
# print( which(nna))    
# print( ipr[which(nna),])    
    ## FIXME: objets vides (l==0)
    idx <- which(nna)
    x@ipr        <- if( length(idx) ) matrix(ipr[idx,],ncol=4) else matrix(0., nrow=0, ncol=4)
    ##
    idx          <- cumsum(nna) - 1L
    x@.Data[nna] <- idx[nna]
    ##
    x@length     <- nrow(x@ipr)
    ##
    x <- IP_setId_replace(x,i,value)
    ##
    x
  }
)
##
## 
##
setMethod(
  "rbind2"
  , signature(x = "IPv6r", y="IPv6r")
  , function(x, y, ...){
# cat("rbind2 IPv6r\n")    
    ##
    x@.Data  <- c( x@.Data, y@.Data+nrow( x@ipr ) )
    ##
    x@ipr  <- rbind(x@ipr, y@ipr)
    ##
    x@length <- nrow(x@ipr)
    ## FIXME: IP_setId_rbind
    if( length( x@id ) ){
      ##
      if( length( y@id ) ) x@id <- c( x@id , y@id  )
      else x@id <- c( x@id , rep("",length(y) ) )
    }else if( length( y@id ) ) x@id <- c( rep("",length(x) ) , y@id  )
# print(str(x))
    ##
    x
  }
)
##
##
##
setMethod(
  "id"
  , signature(x = "IPv6r")
  , function(x)  ip.get.id (x)
)
##
setMethod(
  "id<-"
  , signature(x = "IPv6r")
  , function(x,value) ip.set.id(x,value) 
)
##
##
##
names.IPv6r <- function(x) ip.get.id(x)
##
'names<-.IPv6r' <- function(x,value){ 
  ip.set.id(x,value)
}
##________________________________________________________________________________________________________________________


##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
##
##
setMethod(
  "=="
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6_op2_bool_eq_2", e1, e2 ) else .Call("Rip_ipv6_op2_bool_eq_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "!="
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6_op2_bool_neq_2", e1, e2 ) else .Call("Rip_ipv6_op2_bool_neq_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "<"
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6_op2_bool_lt_2", e1, e2 ) else .Call("Rip_ipv6_op2_bool_lt_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "<="
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6_op2_bool_le_2", e1, e2 ) else .Call("Rip_ipv6_op2_bool_le_0", e1, e2 )
  }
)
##
##
##
setMethod(
  ">"
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6_op2_bool_gt_2", e1, e2 ) else .Call("Rip_ipv6_op2_bool_gt_0", e1, e2 )
  }
)
##
##
##
setMethod(
  ">="
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6_op2_bool_ge_2", e1, e2 ) else .Call("Rip_ipv6_op2_bool_ge_0", e1, e2 )
  }
)
##________________________________________________________________________________________________________________________
##
##
##
##
setMethod(
  "=="
  ## 
  , signature(e1 = "IPv6r", e2 = "IPv6r")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6r_op2_bool_eq_2", e1, e2 ) else .Call("Rip_ipv6r_op2_bool_eq_0", e1, e2 )
  }
)
##
setMethod(
  "!="
  ## 
  , signature(e1 = "IPv6r", e2 = "IPv6r")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6r_op2_bool_neq_2", e1, e2 ) else .Call("Rip_ipv6r_op2_bool_neq_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "<"
  ## 
  , signature(e1 = "IPv6r", e2 = "IPv6r")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6r_op2_bool_lt_2", e1, e2 ) else .Call("Rip_ipv6r_op2_bool_lt_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "<="
  ## 
  , signature(e1 = "IPv6r", e2 = "IPv6r")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6r_op2_bool_le_2", e1, e2 ) else .Call("Rip_ipv6r_op2_bool_le_0", e1, e2 )
  }
)
##
##
##
setMethod(
  ">"
  ## 
  , signature(e1 = "IPv6r", e2 = "IPv6r")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6r_op2_bool_gt_2", e1, e2 ) else .Call("Rip_ipv6r_op2_bool_gt_0", e1, e2 )
  }
)
##
##
##
setMethod(
  ">="
  ## 
  , signature(e1 = "IPv6r", e2 = "IPv6r")
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv6r_op2_bool_ge_2", e1, e2 ) else .Call("Rip_ipv6r_op2_bool_ge_0", e1, e2 )
  }
)
##
## ? IPv6-IP
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
setMethod(
  "+"
  ## 
  , signature(e1 = "IPv6", e2 = "integer")
  , function(e1,e2){
    ##
    .Call(
      "Rip_ipv6_op2_arith_add32_0"
      , e1, e2
    )
  }
)
##
setMethod(
  "+"
  ## 
  , signature(e1 = "IPv6", e2 = "logical")
  , function(e1,e2){
    ##
    .Call(
      "Rip_ipv6_op2_arith_add32_0"
      , e1, as.integer(e2)
    )
  }
)
##
##
setMethod(
  "+"
  ## 
  , signature(e1 = "IPv6", e2 = "numeric")
  , function(e1,e2){
    .Call(
      "Rip_ipv6_op2_arith_addfl64_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "+"
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    .Call(
      "Rip_ipv6_op2_arith_addv6_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "-"
  ## 
  , signature(e1 = "IPv6", e2='missing')
  , function(e1){
    .Call(
      "Rip_ipv6_op1_arith_neg_0"
      , e1
    )
  }
)
##
##
##
setMethod(
  "-"
  ## 
  , signature(e1 = "IPv6", e2 = "integer")
  , function(e1,e2){
    .Call(
      "Rip_ipv6_op2_arith_sub32_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "-"
  ## 
  , signature(e1 = "IPv6", e2 = "numeric")
  , function(e1,e2){
    .Call(
      "Rip_ipv6_op2_arith_subfl64_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "-"
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    .Call(
      "Rip_ipv6_op2_arith_subv6_0"
      , e1, e2
    )
  }
)
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
  "&"
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    .Call(
      "Rip_ipv6_op2_mask_and_0"
      , e1, e2
    )
  }
)
##
setMethod(
  "|"
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1,e2){
    .Call(
      "Rip_ipv6_op2_mask_or_0"
      , e1, e2
    )
  }
)
## 
setMethod(
  "!"
  ## 
  , signature(x = "IPv6")
  ##
  , function(x){
    ## 
    ##
    .Call(
      "Rip_ipv6_op1_arith_not_0"
      , x
    )
  }
)
##
setMethod(
  "ip.xor"
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1, e2){
    .Call(
      "Rip_ipv6_op2_mask_xor_0"
      , e1, e2
    )
  }
)
##
setMethod(
  "^"
  ## 
  , signature(e1 = "IPv6", e2 = "IPv6")
  , function(e1, e2){
    .Call(
      "Rip_ipv6_op2_mask_xor_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "%>>%"
  , signature(e1='IPv6', e2='integer')
  , function(e1, e2){
    .Call(
      "Rip_ipv6_op2_arith_rshift_0"
      , e1, e2
    )
  }
)
##
setMethod(
  "%<<%"
  , signature(e1='IPv6', e2='integer')
  , function(e1, e2){
    .Call(
      "Rip_ipv6_op2_arith_lshift_0"
      , e1, e2
    )
  }
)
##
## 
## 
##
ipv6.netmask <- function(n){
  ##
  n <- as.integer(n)
  ##
  .Call(
    "Rip_ipv6_mask_netmask_0"
    , n
  )
}
##
ipv6.hostmask <- function(n){
  ##
  n <- as.integer(n)
  ##
  .Call(
    "Rip_ipv6_mask_hostmask_0"
    , n
  )
}
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
if( T ){
  ##
  setMethod(
      "ip.order"
    , "IPv6"
    ##  
    , function(x, na.last = TRUE, decreasing = FALSE){
      ##
      order(x, na.last=na.last, decreasing=decreasing)
    }
  )
##
# setMethod(
#   "ip.order"
#   ## 
#   , "IPv6"
#   ##  
#   , IP_order
# )
  
}else{
##
setMethod(
  "ip.order"
  ## 
  , "IPv6"
  ##
  , function(x, na.last = TRUE, decreasing = FALSE){
    ##
    ##
    idx <- .Call(
      ##
      "Rip_ipv6_qsort0"
      , if( na <- anyNA(x) ) x[ !(naidx <- is.na(x)) ] else x
      , decreasing ## 
    )+1L
    ##
    if(!na) return(x)
    ##
#     idx <- .Call(
#       "Rip_ipv6_qsort_1"
#       , x[ !(naidx <- is.na(x)) ]
#     )+1L
    ##
    if( is.na(na.last) ) idx 
    else{
      idx <- ((1:length(x))[!naidx])[idx]
      if(na.last)       c(idx         , which(naidx) )
      else if(!na.last) c(which(naidx), idx          )
    }
  }
)
}
##________________________________________________________________________________________________________________________
## 
##
setMethod(
    "ip.order"
  , "IPv6r"
  ##  
  , function(x, na.last = TRUE, decreasing = FALSE){
    ##
    order(x, na.last=na.last, decreasing=decreasing)
  }
)
## 
# setMethod(
#   "ip.order"
#   ## 
#   , "IPv6r"
#   ##  
#   , IP_order
# )
##
## !!!NA!!!
##
setMethod(
  "xtfrm"
  ## 
  , "IPv6"
  , function(x){
    ##
#     cat("IPv6:xtfrm\n")
    ##
    y <- .Call("Rip_ipv6_cvtfl64nx4_0", x)
    ## 
    idx <- order( 
       y[,1], y[,2], y[,3], y[,4]
    ) 
    ##
    res      <- integer(length(x))
    res[idx] <- seq.int(length(x))
    if( anyNA(x)) res[ is.na(x) ]  <- NA
    ##
    res
  }
)
##________________________________________________________________________________________________________________________
##
## !!! CHK !!! 
## 
##
setMethod(
  "xtfrm"
  ## 
  , "IPv6r"
  , function(x){
    ##
#     cat("IPv6r:xtfrm\n")
    ##
    xlo <- .Call("Rip_ipv6_cvtfl64nx4_0", lo(x))
    xhi <- .Call("Rip_ipv6_cvtfl64nx4_0", hi(x))
    ## 
    idx <- order(
      xlo[,1], xlo[,2], xlo[,3], xlo[,4] 
      , xhi[,1], xhi[,2], xhi[,3], xhi[,4] 
    ) 
    ##
    res      <- integer(length(x))
    res[idx] <- seq.int(length(x))
    if( anyNA(x)) res[ is.na(x) ]  <- NA
    ##
    res
  }
)
##________________________________________________________________________________________________________________________


##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
##
##
setMethod(
  "match"
  ##
  , signature(x = "IPv6", table = "IPv6")
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ## 
    match(as.character(x),as.character(table),nomatch,incomparables)
  }
)
##
##
##
setMethod(
  "ip.match"
  ##
  , signature(x = "IPv6", table = "IPv6")
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##
    if(  is.null(attr(table@ipv6,"htb")) ) {
      htb.sz  <- as.integer(length(table)*1.63)+1L
      ## FIXME: htb.sz==M2
      .Call("Rip_h_ipv6_h128dblh_lemire_hash_0_0", table, c(htb.sz = htb.sz, M2 = 7L))
    }
    ##
    .Call("Rip_h_ipv6_h128dblh_lemire_lookup_0_0", x, table, nomatch)
  }
)
##
##
##
setMethod(
  "ip.index"
  ## 
  , signature(table = "IPv6r")
  ##
  , function(table, overlap=FALSE,...){
    ##
    bsearch <- function(x=NULL, nomatch=NA_integer_, value=F,...){
      ##
      if( is.null(x) ) x <- table
      ##
      ## "polymorphisme"
      ##
      tb.clnm <- tolower(class(table))
      ##
      x.clnm <- if( ( kl <-class(x)) %in% c('IPv6', 'IPv6r' ) ){
        tolower(kl)
      }else stop('bsearch not implemented for object of class ', kl , ' and table ', class(table))
      ##
      midx <- .Call(
          ## "dispatch"
          sprintf('Rip_bsearch_%s_in_%s_0', x.clnm, tb.clnm)
          ##
          , x 
          , table
          , idx
          , nomatch
      )+1L
      ##
      if( value ) return(table[midx]) ## return(x[midx])## 
      ##
      midx
    }
    ##
    bsearch.overlap <- function(x=NULL,nomatch=NA_integer_,value=F,...){  
      ##
      nullx <- if( is.null(x) ){x <- table; T} else F
      ##
      ## "polymorphisme"
      ##
      ##
      x.clnm <- if( ( kl <-class(x)) %in% c('IPv6', 'IPv6r' ) ){
        tolower(kl)
      }else stop('bsearch with overlap not implemented for object of class ', kl , ' and table ', class(table))    
      ##
      m <- .Call(
          ## "dispatch"
          if( x.clnm=='ipv6') "Rip_bsearch_intvTree_ipv6_in_ipv6r_0" else "Rip_bsearch_intvTree_ipv6r_overlap_ipv6r_0"
          ## 
          , x 
          , table[idx+1L]
          , idx
          , minmxIdx
          , NA_integer_
      )
      ## 
      if( value ){
        ##
        return(
          data.frame(
            rep(m, diff(attr(m, 'ptr')))
            , table[attr(m, 'midx')+1L]
          ) |> `colnames<-`(c(
              if(!nullx) deparse(substitute(x)) else "table"
              , "m"
            )
          )
        )
      }
      ##
      attr(m, "midx") <- attr(m, "midx") + 1L
      ##
      m
    }
    ## 
    if( !length(table) ) stop("empty table")
    ##
    table <- table[!(na<-is.na(table))]
    ##
    if( (na <- sum(na) ) ) warning("removing ", na, " NA from table")
    ## 
    idx <- order( ## ip.order
      table 
      ##, na.last= NA ## rm ?
    ) - 1L
    ##
    minmxIdx <- if(overlap){
      ##
      .Call(
        "Rip_bsearch_intvTree_ipv6r_index_0"
        , table[idx+1L]
        , idx
      )
    } 
    ##
    return(
      if( !overlap ) bsearch else bsearch.overlap
    )
  }
)
##
##
##
setMethod(
  "match"
  ## 
  , signature(x = "IPv6", table = "IPv6r", nomatch='ANY', incomparables='ANY')
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##
    ip.index(table)(x, nomatch, incomparables)
  }
)
##
##
##
setMethod(
  "ip.match"
  ## 
  , signature(x = "IPv6", table = "IPv6r")
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##
    ip.index(table)(x, nomatch, incomparables)
  }
)
##
##
##
setMethod(
  "match"
  ## 
  , signature(x = "IPv6r", table = "IPv6r", nomatch='ANY', incomparables='ANY')
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ## 
    match(as.character(x),as.character(table),nomatch,incomparables)
  }
)
##
## ¡¡¡ TODO : hash256 !!!
##
setMethod(
  "ip.match"
  ## 
  , signature(x = "IPv6r", table = "IPv6r")
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##
    match(as.character(x),as.character(table),nomatch,incomparables)
#     ip.index(table)(x, nomatch, incomparables)
  }
)
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
##
##
ipv6.addr.space <- function() ipv6.addrspace.ipr
## 
ipv6.reserved <- function() ipv6.reserved.ipr
##
ipv6.unicast <- function() ipv6.unicast.ipr
##
ipv6.rir <- function() ipv6.unicast.ipr
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

##________________________________________________________________________________________________________________________


