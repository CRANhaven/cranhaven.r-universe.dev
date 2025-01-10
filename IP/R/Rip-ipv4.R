
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
  , signature(.Object="IPv4")
  ##
  , function(.Object, ipstring=NULL){
    ##
    if(is.null(ipstring)) return(.Object)
    ##
    if( typeof( ipstring )!='character' ){
      ##
      stop('ip should be of type character')
    }
    ##
    if ( length(ipstring) ){
      #
      .Object <- if( IP_AVX2 ) .Call(
        ##
        'Rip_ipv4_init28_lut_0'
        ##
        , .Object
        , ipstring
      ) else .Call(
        ##
        'Rip_ipv4_init_0'
        ##
        , .Object
        , ipstring
      )
    }
    ##
    if( is.null(.Object@ipv4) ){
      .Object@ipv4r <- integer(0) ## ¡ IPv4 !
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
## 
##
setValidity(
  "IPv4"
  , function(object){
    ##
    if( 
      ## FIXME : @ip ne doit pas être NULL
      xor( null0 <- is.null(object@ipv4),is.null(object@length) )
    ) return( "both slots should NULL or set")
    ##
    if(
      !null0 &  (length(object@ipv4)==object@length )
    ) T
    else{
      paste("unequal length")
    }
  }
)
##
## ¡¡¡FIXME: object@ipv4r <- integer(0) object@id <- character() !!!
##
setMethod(
  "ipv4"
  , signature(object ="missing")
  , function(object,...) new('IPv4', ...)
)
##
setMethod(
  "ipv4"
  , signature(object ="character")
  , function(object,...) new('IPv4', object,...)
)
##
## ¡¡¡ ipv4(<IPv4>) => ipv4(<i32>) !!!
##
setMethod(
  "ipv4"
  , signature(object ="integer")
  , function(object,...){
# cat("ipv4 integer\n");print(str(object))    
    ip4 <- new('IPv4', ...)
    if( any( object < 0 , na.rm=T ) ) warning('negative values')
    nna        <- !( na         <- is.na(object)  )
    if( any(nna) ){
      ip4@ipv4   <- object[nna]
      ip4@.Data  <- ifelse( nna, cumsum(nna) -1L, NA )
      ip4@length <- sum(nna)
    }else{
      ip4@.Data  <- object
      ip4@length <- 0L
    }
# print(str(ip4)) 
    ## !is.null(nm<-names(object))
    ip4@id <- if( length(nm<-names(object)) ) nm else character(0)
    ##
    ip4
  }
)
##
setMethod(
  "ipv4"
  , signature(object ="logical")
  , function(object,...){
    ## CHK
    ipv4(as.integer(object))
  }
)
##
##
##
# setMethod(
#   "ip.version"
#   , "IPv4"
#   , function(ip,...) ifelse(!is.na(ip@.Data), 4L, NA_integer_)
# )
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
##
setMethod(
  "initialize"
  ##
  , signature(.Object="IPv4r") 
  ## 
  , function(.Object, ipstring=NULL, ipv4=NULL, lo=NULL,hi=NULL,nip=NULL){
    ##
    if(is.null(ipstring)){
      ##
      if(
#         class( lo )=='IPv4' & ( class( nip  ) %in% c('integer','numeric') )
        inherits( lo, 'IPv4' ) & inherits( nip, c('integer','numeric') )
      ){
# print(str(lo));print(str(nip) )      
        ##
        hi <- lo + nip
        ## FIXME: NA dans nip
#         if( ( (nlo <- length(lo))==1) & ( (nhi <- length(hi))>1) ) lo <- rep(lo, nhi)

        ## names
        
      } else if( !is.null(ipv4) ) {
        lo <- ipv4[[1]] 
        hi <- ipv4[[2]] 
      }
      ##
      if( 
        (
#           class( lo )=='IPv4' & class( hi  )=='IPv4'
          inherits(lo, 'IPv4') & inherits(hi, 'IPv4' )
        ) 
      ){
        ##
        if( ( nip<-length(lo@.Data) )!=length(hi@.Data) ) stop( "ipv4s should have the same length")
        else if(nip==0) return(ipv4r())
        ## FIXME!!!
        if( any( lo@.Data!=hi@.Data, na.rm = T ) ) stop( "ipv4s should have the same NA")
        ##
        if( any(lo > hi, na.rm = T) ) stop( "lo > hi")
# print(str(lo));print(str(hi) ) 
        ##
        ##
        ## !!! nna !!! -see: IPv6r
        ##
        nna <- !( is.na(lo) )
        ## CHK
        idx           <- cumsum(nna) - 1L
        .Object@.Data <- ifelse(nna, idx, NA_integer_) 
# print(str(.Object@.Data));
        ## | !is.null(lo@ipv4 )
        if( !is.null(lo@ipv4) ){ 
          ##
          .Object@ipr    <- matrix(c(lo@ipv4,hi@ipv4),ncol=2)
          ##
          .Object@length <- nrow(.Object@ipr)
        }
        else .Object@length <- 0L
        ## !is.null(lo@id)
        if( length(lo@id) ) .Object@id <- lo@id
      }
      ## ?else: err -ie: manque un argument
      ##
      return(.Object)
    }
    ##
    if( typeof( ipstring )!='character' ){
      ##
      stop('ip should be of type character')
    }
    ##
    if ( !length(ipstring) ){
      ##
      return(.Object)
    }
    ##
    .Object <- .Call('Rip_ipv4r_init_0', .Object, ipstring)
    ##
    if( is.null(.Object@ipr) ){
      .Object@ipr <- matrix(0L,nrow=0,ncol=2)
    }
    ##
    if( is.null(.Object@id) ){
      .Object@id <- character()
    }
    ##
    .Object
  }
)
## !!! TODO !!!
# setValidity(
#   "IPv4"
#   , function(object){
#   }
# )
##
##
##
##
setMethod(
  "ipv4r"
  , signature(e1="missing",e2="missing")
  , function(e1,e2,...) new('IPv4r', ...)
)
##
setMethod(
  "ipv4r"
  , signature(e1="character",e2="missing")
  , function(e1,e2,...) new('IPv4r', e1,...)
)
##
setMethod(
  "ipv4r"
  , signature(e1="character", e2="character")
  , function(e1,e2,...) new('IPv4r', lo=ipv4(e1), hi=ipv4(e2),...)
)
##
setMethod(
  "ipv4r"
  , signature(e1="character", e2=".__intFP__.")
  , function(e1,e2,...) new('IPv4r', lo=ipv4(e1), nip=e2,...)
)
##
setMethod(
  "ipv4r"
  , signature(e1 = "IPv4", e2 = "IPv4")
  , function(e1,e2,...) new('IPv4r', lo=e1,hi=e2,...)
)
##
setMethod(
  "ipv4r"
  , signature(e1 = "IPv4", e2 = ".__intFP__.")
  , function(e1,e2,...) new('IPv4r', lo=e1,nip=e2,...)
)
##
setMethod(
  "ipv4r"
  , signature(e1="list",e2="missing")
  , function(e1,...) new('IPv4r', ipv4=e1,...)
)
## CHK: cf [<- NA
setMethod(
  "ipv4r"
  , signature(e1 ="logical",e2="missing")
  , function(e1,...){
    ##CHK
# cat("ipv4r logical\n")
    new('IPv4r', lo=ipv4(as.integer(e1)), hi=ipv4(as.integer(e1)),...)
  }
)
##  
##  
##
setMethod(
  "lo"
  , "IPv4r"
  ##
  , function(e1,...){
    ##
    lo <- ipv4()
    ##
    lo@.Data <- e1@.Data
    ## FIXME : if( length( e1@ipr ) ) matrix(e1@ipr,ncol=2)[,1] else integer(0)
    lo@ipv4 <- e1@ipr[,1] ## 
    ##
    lo@length <- e1@length
    ## !is.null(e1@id)
    lo@id <- if( length(e1@id) ){
      e1@id
    }else character(0)
    ##
    lo
  }
)
##  
##  
##
setMethod(
  "hi"
  , "IPv4r"
  ##
  , function(e1,...){
    ##
    hi <- ipv4()
    ##
    hi@.Data <- e1@.Data
    ## FIXME : if( length(lo@ipv4) ) lo@ipv4 else matrix(0L, ncol=2)
    hi@ipv4 <- e1@ipr[,2] ## matrix(e1@ipr[,2],ncol=2) ## au cas où
    ##
    if( length(e1@id) ){
      hi@id  <- e1@id
    }
    ##
    hi@length <- e1@length
    ##!is.null(e1@id)
    hi@id <- if( length(e1@id) ){
      e1@id
    }else character(0)
    ##
    hi
  }
)
##
## 
##
setMethod(
  "ipv4"
  , "IPv4r"
  , function(object,...){
    ##
    ip1 <-ip2 <- ipv4()
    ##
    ip1@.Data <- ip2@.Data <- object@.Data
    ## FIXME : NULL
    ip1@ipv4 <- object@ipr[,1] ## matrix(object@ipr,ncol=2)[,1]
    ip2@ipv4 <- object@ipr[,2] ## matrix(object@ipr,ncol=2)[,2]
    ## !is.null(object@id)
    ip1@id <- ip2@id <- if( length(object@id) ){
      object@id
    }else character(0)
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
  , "IPv4"
  , function(x) length(x@.Data)
)
##
##
##
##
# setMethod(
#   "is.integer"
#   ## 
#   , signature(x = "IPv4")
#   , function(x) FALSE
# )
##
setMethod(
  "is.numeric"
  ## 
  , signature(x = "IPv4")
  , function(x) FALSE
)
##
##
##
setMethod(
  "is.na"
  , "IPv4"
  , function(x) is.na(x@.Data)
)
##
##
##
setMethod(
  "print"
  , "IPv4"
  , function(x,...){
      ##
      ip.strings <- .Call("Rip_ipv4_as_character_0",x)
      ##names(ip.strings) <- names(x)
      print(ip.strings)
      invisible(x)
  }
)
##
setMethod(
  "show"
  , "IPv4"
  , function(object){
    ##
    print(object)
    invisible()
  }
)
##
## 
##
format.IPv4 <- function(x
  , trim = FALSE, digits = NULL, nsmall =0L, justify = c("left","right", "centre", "none"), width = NULL, na.encode = TRUE,scientific = NA, big.mark = "", big.interval = 3L
  , small.mark = "", small.interval = 5L, decimal.mark = ".", zero.print = NULL, drop0trailing = FALSE
  , ...) .Call("Rip_ipv4_as_character_0", x) ## as.character(x,...)
##
toString.IPv4 <- function(x,...) .Call("Rip_ipv4_as_character_0", x) ##as.character(x,...)
##
##
##
##
setMethod(
  "as.character"
  , "IPv4"
  , function(x) .Call("Rip_ipv4_as_character_0", x)
)
## utile ?
setAs("IPv4", "character", function(from) .Call("Rip_ipv4_as_character_0", from)) 
##
##
##
setMethod(
  "as.integer"
  , "IPv4"
  , function(x) stop("not implemented") ## .Call("Rip_ipv4_cvtfl64_0", x)
)
##
##
##
setMethod(
  "as.numeric"
  , "IPv4"
  , function(x) .Call("Rip_ipv4_cvtfl64_0", x)
)
##
## table <- factor <- unique + match
##
unique.IPv4 <- function(
  x,...
){
  ##
  htb.sz  <- as.integer(length(x)*1.63)+1L
  ## FIXME: htb.sz==M2
  idx <- .Call("Rip_h_ipv4_hash_0_0", x, c(htb.sz = htb.sz, M1 = htb.sz, M2 = 7L))
  ##
  x[idx]
}
##________________________________________________________________________________________________________________________
##
##
##
setMethod(
  "length"
  , "IPv4r"
  , function(x) length(x@.Data)
)
##
##
##
setMethod(
  "is.na"
  , "IPv4r"
  , function(x) is.na(x@.Data)
)
##
##
##
setMethod(
  "is.numeric"
  ## 
  , signature(x = "IPv4r")
  , function(x) FALSE
)
##
##
##
##
setMethod(
  "print"
  , "IPv4r"
  , function(x,...){
      ##
      ip.strings <- .Call("Rip_ipv4r_as_character_0",x)
      ##
      print(ip.strings)
      ##
      x
  }
)
##
setMethod(
  "show"
  , "IPv4r"
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
format.IPv4r <- function(x
  , trim = FALSE, digits = NULL, nsmall =0L, justify = c("left","right", "centre", "none"), width = NULL, na.encode = TRUE,scientific = NA, big.mark = "", big.interval = 3L
  , small.mark = "", small.interval = 5L, decimal.mark = ".", zero.print = NULL, drop0trailing = FALSE
  , ...) .Call("Rip_ipv4r_as_character_0", x) ## 
##
toString.IPv4r <- function(x,...) .Call("Rip_ipv4r_as_character_0", x) ##
##
##
##
##
setMethod(
  "as.character"
  , "IPv4r"
  , function(x) .Call("Rip_ipv4r_as_character_0", x)
)
##
##
##
setMethod(
  "as.integer"
  , "IPv4r"
  , function(x) stop("not implemented") ## .Call("Rip_ipv4_cvtfl64_0", x)
)
##
##
##
setMethod(
  "as.numeric"
  , "IPv4r"
  , function(x){
    ##
    .Call('Rip_ipv4r_cvtfl64_0', x)
  }
)
##
## table <- factor <- unique + match
##
## !!!TODO!!! hash
##
unique.IPv4r <- function(
  x,...
){
  ## IP_uniq(x,...)
  ##new('IPv4r', unique(.Call("Rip_ipv4r_as_character_0", x)) )
  ##
  htb.sz  <- as.integer(length(x)*1.63)+1L
  ## 
  idx <- .Call("Rip_h_ipv4r_h64dblh_lemire_hash_0_0", x, c(htb.sz = htb.sz, M2 = if( (htb.sz)>14L ) 7L else 1L ))
  ##
  x[idx]
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
  "["
  ## 
  , signature(x = "IPv4", i='.__subscript__.' )
  ##
  , function(x, i, ...) {  
    ##
    ip <- new("IPv4")
    ##
    ip@.Data <- x@.Data[i]
    ##
    if( 
      any( nna <- !is.na(ip@.Data) ) 
    ){
      ## 
      ip@ipv4 <- x@ipv4[ 
        (ip@.Data[
          which( nna )
        ]+1)
      ] 
      ## re-idx
      idx           <- cumsum(nna) - 1L
      ip@.Data[nna] <- idx[nna]
      ##
      ip@length <-length(ip@ipv4)
    }else{
      ip@ipv4  <- integer(0)
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
## !!!idx<=0
##
setMethod(
  "[<-"
  , "IPv4"
  , function (x, i, j, ..., value){
    ##
#     if( class(value)!='IPv4' ) value <- ipv4(value) ## 
    ## xpd
    ipv4    <- x@ipv4[x@.Data+1]
    ##
    v.na <- is.na(value)
    ## FIXME: NULL
    if (all(v.na==T)){
      x@.Data[i] <- NA
    }else{
      ##
#       if( class(value)!='IPv4' ) value <- ipv4(value) ##
      if( !inherits(value, 'IPv4') ) value <- ipv4(value) ##
      ## grow matrix if necesary
      if( 
        ( d <- max(i) - length(ipv4) )>0
      ){
        ipv4 <- c(ipv4, rep(NA_integer_, length(ipv4)+d, ncol=2))
      }
      ##
      ipv4[i]    <- value@ipv4[value@.Data+1]
      ##
      x@.Data[i] <- value@.Data
      ## FIXME: NULL ipv4 table
    }
    ## re-idx
    nna          <- !is.na(x@.Data)
    ##
    x@ipv4       <- ipv4[ nna ]
    ##
    idx          <- cumsum(nna) - 1L
    ##
    x@.Data[nna] <- idx[nna]
    ##
    x@length     <- length(x@ipv4)
    ##
    ## !!!
    ## replace_setId
    x <- IP_setId_replace(x,i,value)
    ##
    x
  }
)
##
## NAMES (infra)
##
##____________________________________________________________________________________________________________________
##
##
##
setMethod(
  "rbind2"
  , signature(x = "IPv4", y="IPv4")
  , function(x, y, ...){
    ##
    x@.Data  <- c( x@.Data, y@.Data+length( x@ipv4 ) )
    ## FIXME: NULL ?
    x@ipv4   <- c(x@ipv4, y@ipv4)
    ## FIXME: NULL IP_setId_rbind
    if( !is.null( x@id ) ){
      ##
      if( !is.null( y@id ) ) x@id <- c( x@id , y@id  )
      else x@id <- c( x@id , rep("",length(y) ) )
    }else if( !is.null( y@id ) ) x@id <- c( rep("",length(x) ) , y@id  )
    ##
    x@length <- length(x@ipv4)
    ##
    x
  }
)
##____________________________________________________________________________________________________________________
##
##
##
##
##
setMethod(
  "id"
  , signature(x = "IPv4")
  , function(x)  ip.get.id (x)
)
##
setMethod(
  "id<-"
  , signature(x = "IPv4")
  , function(x,value) ip.set.id(x,value) 
)
##
names.IPv4 <- function(x) ip.get.id(x)
##
'names<-.IPv4' <- function(x,value){ 
  ip.set.id(x,value)
}
##________________________________________________________________________________________________________________________
##
## 
## 
setMethod(
  "["
  ##  
  , signature(x = "IPv4r", i='.__subscript__.')
  ##
  , function(x, i, ...) {  
    ##
    ip <- new("IPv4r")
    ##
    ip@.Data <- x@.Data[i]
    ##
    nna <- !is.na(ip@.Data)
    ##
    if( 
      any( nna )
    ){
      ##
  #     ip@ipr <- x@ipr[which( nna ),,drop=F]
      ## TODO:
#       ip@ipr        <- matrix(x@ipr[ (ip@.Data[nna]+1L) ,], ncol=2)
      ##
      idx <-c(
        ip@.Data[
          which( nna )
        ]
        , ip@.Data[
          which( nna )
        ]+ x@length ##
      )+1
      ## 
      ip@ipr <- matrix(
        x@ipr[idx]
        , ncol=2
      )
      ## re-idx
      idx           <- cumsum(nna) - 1L
      ip@.Data[nna] <- idx[nna]
      ##
      ip@length <-nrow(ip@ipr)
    }else{
      ip@ipr <- matrix(integer(),nrow=0, ncol=2)
      ip@length <- 0L
    }
    ## !!!NA!!! !is.null(x@id)
    ip@id <- if( length(x@id) ){
      x@id[i]
      ##ip@id[!nna] <- ""
    }else character(0)
    ##
    ip
  }
)
##
## 
## 
# setMethod(
#   "[<-"
#   ## , i='subset.idx' 
#   , signature(x = "IPv4r")
#   ##
#   , function(x, i, ...) {  
#   }
# )
##
## ??? fix nna ???
##
setMethod(
  "[<-"
  , "IPv4r"
  , function (x, i, j, ..., value){
    ## mv
#     if( class(value)!='IPv4r' ) value <- ipv4r(value) 
    ## xpd
    ipr     <- if(nrow(x@ipr))  matrix(x@ipr, ncol=2)[x@.Data+1,] else x@ipr
    ##
    v.na <- is.na(value)
    ## FIXME:NULL
    if (all(v.na==T)){
      ##
      x@.Data[i] <- NA
    }else{ 
      ##
#       if( class(value)!='IPv4r' ) value <- ipv4r(value) 
      if( !inherits(value, 'IPv4r') ) value <- ipv4(value) ##
      ## 
      mx <- max(i)
      ## replace
      if(nrow(x@ipr)){
        ##  grow table if necessary
        if( 
          ( d <- mx - nrow(ipr) )>0
        ){
          ipr <- rbind(ipr, matrix(NA_integer_, nrow(ipr)+d, ncol=2))
        }
        ##
        ipr[i,] <- matrix(value@ipr, ncol=2)[value@.Data+1,]
        ## cp
        x@.Data[i]   <- value@.Data
      }else{ ## empty IP table
        ipr        <- matrix(NA_integer_, nrow= mx, ncol=2)
        ipr[i,]    <- value@ipr
        x@.Data[i] <- value@.Data
      }
    }   
    ## re-idx
    nna          <- !is.na(x@.Data)
    ##
    idx          <- which(nna)
    x@ipr        <- if( length(idx) ) matrix(ipr[idx,],ncol=2) else matrix(0L, nrow=0, ncol=2)##  matrix(ipr[which(nna),],ncol=2)
    ##
    idx          <- cumsum(nna) - 1L
    x@.Data[nna] <- idx[nna]
    ##
    x@length     <- nrow(x@ipr)
    ##
    ##
    x <- IP_setId_replace(x,i,value)
    ##
    x
  }
)
##
##
##
##
setMethod(
  "id"
  , signature(x = "IPv4r")
  , function(x) ip.get.id (x)
)
##
setMethod(
  "id<-"
  , signature(x = "IPv4r")
  , function(x,value) ip.set.id(x,value) 
)
##
##
##
names.IPv4r <- function(x) ip.get.id(x)
##
'names<-.IPv4r' <- function(x,value){ 
  ip.set.id(x,value)
}
##____________________________________________________________________________________________________________________


##________________________________________________________________________________________________________________________##
## 
##
## sync IP_concat
##
`c.IPv4` <- function(...) {
  ##
  x   <- list(...)
  ##
  cl <- unlist(lapply(
    x, function(x) class(x)
  ))
  ## s3 dispatches only on 1st arg
  if( length( neq <- which(cl!="IPv4") )>0 ) stop(
    "class mismatch: expected ", "IPv4", " but also got ", paste(unique(cl[neq]))
  )
  ##
  nna  <- unlist(lapply(x,function(x) if(length(x)>0) !is.na(x) else NULL))
  ##
  if( length(nna)==0 ) return(ipv4())
  ##
  ip4             <- ipv4()
  ip4@.Data       <- cumsum(nna) - 1L
  ip4@.Data[!nna] <- NA
  ##
  if( sum(nna)>0 ){
    ##
    ip4@ipv4   <- do.call('c', lapply(x,function(x) x@ipv4))
    ip4@length <- length(ip4@ipv4)
  }
  else ip4@length <- 0L
  ## names !is.null
  nm        <- unlist(lapply(x,function(x) ( x@id )))
  ##
  if( any(nm==T) ){
    ip4@id <- unlist(lapply(
       x
       , function(x){
         ##!is.null
         if( length( x@id ) ) x@id
         else rep("",length(x) )
       }
    ))
  }
  ##
  ip4
}
##
`c.IPv4r` <- function(...) IP_concat(...)
##
## union: IPv4r,IPv6r
##
setMethod(
  "rbind2"
  , signature(x = "IPv4r", y="IPv4r")
  , function(x, y, ...){
cat("bind ipv4r\n")
    ##
    x@.Data  <- c( x@.Data, y@.Data+x@length )
    ## CHK 
    x@ipr    <- if( length( x@ipr ) ){
      ##
      if( length( y@ipr ) )     rbind(x@ipr, y@ipr)
      else                        x@ipr
    }else if( length( y@ipr ) ) y@ipr
    ## FIXME: NULL IP_setId_rbind
    x@id <- if( length( x@id ) ){
      ##
      if( length( y@id ) )     c( x@id , y@id  )
      else                       c( x@id , rep("",length(y) ) )
    }else if( length( y@id ) ) c( rep("",length(x) ), y@id  )
    else character(0)
    ##
    x@length <- nrow(x@ipr)
    ##
    x
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
  "=="
  , signature(e1 = "IPv4", e2 = "IPv4")
  ##
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4_op2_bool_eq_2", e1, e2 ) else .Call("Rip_ipv4_op2_bool_eq_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "!="
  , signature(e1 = "IPv4", e2 = "IPv4")
  ##
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4_op2_bool_neq_2", e1, e2 ) else .Call("Rip_ipv4_op2_bool_neq_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "<"
  , signature(e1 = "IPv4", e2 = "IPv4")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4_op2_bool_lt_2", e1, e2 ) else .Call("Rip_ipv4_op2_bool_lt_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "<="
  , signature(e1 = "IPv4", e2 = "IPv4")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4_op2_bool_le_2", e1, e2 ) else .Call("Rip_ipv4_op2_bool_le_0", e1, e2 )
  }
)
##
##
##
setMethod(
  ">"
  , signature(e1 = "IPv4", e2 = "IPv4")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4_op2_bool_gt_2", e1, e2 ) else .Call("Rip_ipv4_op2_bool_gt_0", e1, e2 )
  }
)
##
##
##
setMethod(
  ">="
  , signature(e1 = "IPv4", e2 = "IPv4")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4_op2_bool_ge_2", e1, e2 ) else .Call("Rip_ipv4_op2_bool_ge_0", e1, e2 )
  }
)
##________________________________________________________________________________________________________________________
##
##
##
##
setMethod(
  "=="
  , signature(e1 = "IPv4r", e2 = "IPv4r")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4r_op2_bool_eq_2", e1, e2 ) else  .Call("Rip_ipv4r_op2_bool_eq_0", e1, e2 )
  }
)
## 
##
##
setMethod(
  "!="
  , signature(e1 = "IPv4r", e2 = "IPv4r")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4r_op2_bool_neq_2", e1, e2 ) else .Call("Rip_ipv4r_op2_bool_neq_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "<"
  , signature(e1 = "IPv4r", e2 = "IPv4r")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4r_op2_bool_lt_2", e1, e2 ) else .Call("Rip_ipv4r_op2_bool_lt_0", e1, e2 )
  }
)
##
##
##
setMethod(
  "<="
  , signature(e1 = "IPv4r", e2 = "IPv4r")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4r_op2_bool_le_2", e1, e2 ) else .Call("Rip_ipv4r_op2_bool_le_0", e1, e2 )
  }
)
##
##
##
setMethod(
  ">"
  , signature(e1 = "IPv4r", e2 = "IPv4r")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4r_op2_bool_gt_2", e1, e2 ) else .Call("Rip_ipv4r_op2_bool_gt_0", e1, e2 )
  }
)
##
##
##
setMethod(
  ">="
  , signature(e1 = "IPv4r", e2 = "IPv4r")
  ## 
  , function(e1,e2){
    if( IP_AVX2 ) .Call("Rip_ipv4r_op2_bool_ge_2", e1, e2 ) else .Call("Rip_ipv4r_op2_bool_ge_0", e1, e2 )
  }
)
## TODO:
## intersection
## intersects : Ripaddr_ipv4r_cmp_intersects
##
## setdiff,setequal
## union
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
  "+"
  , signature(e1 = "IPv4", e2 = "integer")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4_op2_arith_add32_0" ## "Rip_ipv4_op2_arith_add32_1"
      , e1, e2
    )
  }
)
##
setMethod(
  "+"
  ## 
  , signature(e1 = "IPv4", e2 = "logical")
  , function(e1,e2){
    ##
    .Call(
      "Rip_ipv4_op2_arith_add32_0"
      , e1, as.integer(e2)
    )
  }
)
##
##
##
setMethod(
  "+"
  , signature(e1 = "IPv4", e2 = "numeric")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4_op2_arith_addfl64_0"
      , e1, e2

    )
  }
)
##
##
##
setMethod(
  "+"
  , signature(e1 = "IPv4", e2 = "IPv4")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4_op2_arith_addv4_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "-"
  , signature(e1 = "IPv4", e2='missing')
  ## 
  , function(e1){
    .Call(
      "Rip_ipv4_op1_arith_neg_0"
      , e1
    )
  }
)
##
##
##
setMethod(
  "-"
  , signature(e1 = "IPv4", e2 = "integer")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4_op2_arith_sub32_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "-"
  , signature(e1 = "IPv4", e2 = "numeric")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4_op2_arith_subfl64_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "-"
  , signature(e1 = "IPv4", e2 = "IPv4")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4_op2_arith_subv4_0"
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
setMethod(
  "+"
  , signature(e1 = "IPv4r", e2 = "integer")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4r_op2_arith_add32_0" ## 
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
setMethod(
  "&"
  , signature(e1 = "IPv4", e2 = "IPv4")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4_op2_mask_and_0"
      , e1, e2
    )
  }
)
##
setMethod(
  "|"
  , signature(e1 = "IPv4", e2 = "IPv4")
  ## 
  , function(e1,e2){
    .Call(
      "Rip_ipv4_op2_mask_or_0"
      , e1, e2
    )
  }
)
## 
setMethod(
  "!"
  , signature(x = "IPv4")
  ## 
  , function(x){
    ##
    x@ipv4 <- bitwNot(x@ipv4)
    ##
    x
  }
)
##
##
##
setMethod(
  "ip.xor"
  , signature(e1 = "IPv4", e2 = "IPv4")
  ##
  , function(e1, e2){
    .Call(
      "Rip_ipv4_op2_mask_xor_0"
      , e1, e2
    )
  }
)
##
setMethod(
  "^"
  , signature(e1 = "IPv4", e2 = "IPv4")
  , function(e1, e2){
    .Call(
      "Rip_ipv4_op2_mask_xor_0"
      , e1, e2
    )
  }
)
##
##
##
setMethod(
  "%>>%"
  , signature(e1='IPv4', e2='integer')
  , function(e1, e2){
    .Call(
      "Rip_ipv4_op2_arith_rshift_0"
      , e1, e2
    )
  }
)
##
setMethod(
  "%<<%"
  , signature(e1='IPv4', e2='integer')
  , function(e1, e2){
    .Call(
      "Rip_ipv4_op2_arith_lshift_0"
      , e1, e2
    )
  }
)
##
## 
## 
##
ipv4.netmask <- function(n){
  ##
  n <- as.integer(n)
  ##
  .Call(
    "Rip_ipv4_mask_netmask_0"
    , n
  )
}
##
ipv4.hostmask <- function(n){
  ##
  n <- as.integer(n)
  ##
  .Call(
    "Rip_ipv4_mask_hostmask_0"
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
## ¡¡¡ TODO : getGroupMembers("Summary")
## "max"   "min"   "range" "prod"  "sum"   "any"   "all" 
##
## 
## na.rm = T ?
## 
setMethod(
  "ip.range"
  ## 
  , "IPv4r"
  , function(ipr){
     .Call('Rip_ipv4r_range_0', ipr)
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
if( T ){
  ##
  setMethod(
      "ip.order"
    , "IPv4"
    ##  
    , function(x, na.last = TRUE, decreasing = FALSE){
      ##
      order(x, na.last=na.last, decreasing=decreasing)
    }
  )
}else if( F ){
##  
setMethod(
  "ip.order"
  ## 
  , "IPv4"
  ##  
  , IP_order
)
  
}else{
##
# setMethod(
#   "ip.order"
#   ## 
#   , "IPv4"
#   ## method 
#   , function(x, na.last = TRUE, decreasing = FALSE){
#     ##    
#     idx <- .Call(
#       ##
#       "Rip_ipv4_qsort0"
#       , if( na <- any.na(x) ) x[ !(naidx <- is.na(x)) ] else x
#       , decreasing ## 
#     )+1L
#     ##
#     if(!na) return(x)
#     ##
#     if( is.na( na.last) ) idx 
#     else{
#       idx <- ((1:length(x))[!naidx])[idx]
#       if(na.last)       c(idx         , which(naidx) )
#       else if(!na.last) c(which(naidx), idx          )
#     }
#     ##
#   }
# )
}
##________________________________________________________________________________________________________________________
##
## 
## 
##
setMethod(
  "xtfrm"
  ## 
  , "IPv4"
  , function(x){
    ##
     .Call( 'Rip_ipv4_cvtfl64_0', x)
  }
)
##________________________________________________________________________________________________________________________
##
## 
##
##
setMethod(
    "ip.order"
  , "IPv4r"
  ##  
  , function(x, na.last = TRUE, decreasing = FALSE){
    ##
    order(x, na.last=na.last, decreasing=decreasing)
  }
)
# setMethod(
#   "ip.order"
#   ## 
#   , "IPv4r"
#   ##  
#   , IP_order
# )
## 
## 
##
setMethod(
  "xtfrm"
  ## 
  , "IPv4r"
  , function(x){
    ##
    idx <- order( .Call( 'Rip_ipv4_cvtfl64_0', lo(x)) , .Call( 'Rip_ipv4_cvtfl64_0', hi(x)) ) 
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
##
setMethod(
  "match"
  ## 
  , signature(x = "IPv4", table = "IPv4", nomatch='ANY', incomparables='ANY')
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##cat("ip4 match\n")  
    ## 
    match(
      .Call( 'Rip_ipv4_cvtfl64_0', x)
      , .Call( 'Rip_ipv4_cvtfl64_0', table )
      , nomatch=nomatch, incomparables=incomparables
    )
  }
)
##
##
##
setMethod(
  "ip.match"
  ## 
  , signature(x = "IPv4", table = "IPv4")
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##
    ##
    if( is.null(attr(table@ipv4,"htb")) ){
      ##
      htb.sz <- .Call("nextPrime_MillerRabin", as.integer(length(table)*2))
      ## FIXME: htb.sz==M2
      .Call("Rip_h_ipv4_hash_0_0", table, c(htb.sz = htb.sz, M1 = htb.sz, M2 = 7L))
    }
    ## !!!nomatch
    .Call("Rip_h_ipv4_lookup_0_0", x, table, nomatch)
  }
)
## 
##
## "ip.hash<-"
##
##
setMethod(
  "ip.index"
  ## 
  , signature(table = "IPv4r")
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
      x.clnm <- if( ( kl <-class(x)) %in% c('IPv4', 'IPv4r' ) ){
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
      if( value )  return(table[midx]) ## return(x[midx])##
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
      x.clnm <- if( ( kl <-class(x)) %in% c('IPv4', 'IPv4r' ) ){
        tolower(kl)
      }else stop('bsearch with overlap not implemented for object of class ', kl , ' and table ', class(table))    
      ##
      m <- .Call(
          ## "dispatch"
          if( x.clnm=='ipv4') "Rip_bsearch_intvTree_ipv4_in_ipv4r_0" else "Rip_bsearch_intvTree_ipv4r_overlap_ipv4r_0"
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
          ))
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
        "Rip_bsearch_intvTree_ipv4r_index_0"
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
if(F) setMethod(
  "ip.index"
  ## 
  , signature(table = "IPv4r")
  ##
  , function(table, overlap=FALSE,...){
    ##
    bsearch <- function(x=NULL,nomatch=NA_integer_,value=F,...){
      ##
      if( is.null(x) ) x <- table
      ##
      ## "polymorphisme"
      ##
#       tb.clnm <- tolower(class(table))
      ##
      x.clnm <- if( ( kl <-class(x)) %in% c('IPv4', 'IPv4r' ) ){
        tolower(kl)
      }else stop('bsearch not implemented for object of class ', kl , ' and table ', tb.clnm)
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
      if( value ) return(table[midx])
      ##
      midx
    }
    ##
    bsearch.overlap <- function(x=NULL,nomatch=NA_integer_,value=F,...){
      ##
      if( is.null(x) ) x <- table
      ##
      ## "polymorphisme"
      ##
#       tb.clnm <- tolower(class(table))
      ##
      x.clnm <- if( ( kl <-class(x)) %in% c('IPv4', 'IPv4r' ) ){
        tolower(kl)
      }else stop('bsearch not implemented for object of class ', kl , ' and table ', tb.clnm)
      ##
      m <- .Call(
          ## "dispatch"
#           sprintf('Rip_bsearch_%s_in_%s_0', x.clnm, tb.clnm)
          ##
          if( x.clnm=='ipv4') "ipv4r_bearch_intv_ip_in_0" else "ipv4r_bearch_intv_ipv4r_in_0"
          ## 
          , x 
          , table
          , idx
          , minmxIdx
          , NA_integer_
      )
      ## TODO
#       if( value ) return(table[midx])
# print(str(m))
      ##
      attr(m, "midx") <- attr(m, "midx") + 1L
      ##
      m
    }
    ## !!! CHK
    if( !length(table) ) stop("empty table")
    ##
    table <- table[!(na<-is.na(table))]
    ##
    if( (na <- sum(na) ) ) warning("removing ", na, " NA from table")
    ## utile ?
    tb.clnm <- tolower(class(table)) ##'ipv4r'
    ## 
    idx <- order( ## ip.order
      ## TODO: table (cf. xtrfm pour IPv4r ) 
      lo(table), hi(table) ## ipv4(table )[['lo']] 
      ##
      , na.last= NA ## rm ?
    ) - 1L
    ##
    minmxIdx <- if(overlap){
      ##
      .Call(
        "ipv4r_bearch_intv_index_0"
        , table
        , idx
      )
    } else NULL
    ##
    return(
      if( !overlap ) bsearch else bsearch.overlap
    )
  }
)
##
setMethod(
  "match"
  ## 
  , signature(x = "IPv4", table = "IPv4r", nomatch='ANY', incomparables='ANY')
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##
    ip.index(table)(x,nomatch=nomatch, incomparables = incomparables)
  }
)
##
setMethod(
  "ip.match"
  ## 
  , signature(x = "IPv4", table = "IPv4r")
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##
    ip.index(table)(x, nomatch=nomatch, incomparables = incomparables )
  }
)
##
setMethod(
  "match"
  ## 
  , signature(x = "IPv4r", table = "IPv4r", nomatch='ANY', incomparables='ANY')
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
    ##
    match(as.character(x), as.character(table),  nomatch, incomparables)
  }
)
##
setMethod(
  "ip.match"
  ## 
  , signature(x = "IPv4r", table = "IPv4r")
  ##
  , function(x,table,nomatch=NA_integer_, incomparables = NULL){
# cat("ipv4r hash\n")    
    ##
    if( is.null(attr(table@ipr,"htb")) ){
      n <- length(table)
      htb.sz  <- as.integer(n*1.63)+1L
      ## CHK 7L (htb.sz%/% 2L)+
      .Call("Rip_h_ipv4r_h64dblh_lemire_hash_0_0", table, c(htb.sz = htb.sz, M2 = if( (htb.sz)>14L ) 7L else 1L ))
    }
    ## Rip_h_ipv4r_lookup_0_0
    .Call("Rip_h_ipv4r_h64dblh_lemire_lookup_0_0", x, table,nomatch)
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
ipv4.addr.space <- function() ipv4.addrspace.ipr
## 
ipv4.reserved   <- function() ipv4.reserved.ipr
##
ipv4.rir        <- function() ipv4.addrspace.ipr[(ipv4.addrspace.ipr@id %in% rir.names)]
##
ipv4.recovered  <- function() ipv4.recovered.ipr
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
