##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
##
## 
##
setClassUnion(".__IP__.", c("IPv4", "IPv6", "IP"))
##
setClassUnion(".__IPr__.", c("IPv4r", "IPv6r", "IPr"))
##
setClassUnion(".__IPvr__.", c("IPv4", "IPv6", "IP", "IPv4r", "IPv6r", "IPr"))
##
setClassUnion(".__ipvr__.", c("IPv4", "IPv6", "IPv4r", "IPv6r"))
## 
##
##
setClassUnion(".__subscript__.", c("numeric", "integer", "logical"))
## 
setClassUnion(".__intFP__.", c("numeric", "integer"))
##________________________________________________________________________________________________________________________
##
## promoting is.integer to generic seems prohibited
##
## setGeneric |is.primitive(f) -> methods:::genericForBasic -> methods:::.BasicFunsList[[f]] -> F
##
# setGeneric("is.integer", function(x){standardGeneric("is.integer")})
##
# setGeneric("is.integer", signature = "x")
## 
##
##
setGeneric("ipv4", function(object,...){
    standardGeneric("ipv4")
})
##
setGeneric("ipv4r", function(e1,e2,...){
    standardGeneric("ipv4r")
})
##
##
##
setGeneric("ipv6", function(object,...){
    standardGeneric("ipv6")
})
##
setGeneric("ipv6r", function(e1,e2,...){
    standardGeneric("ipv6r")
})
##
## 
## 
setGeneric("ip", function(e1,e2,...){
    standardGeneric("ip")
})
##
setGeneric("ipr", function(e1,e2,...){
    standardGeneric("ipr")
})
##
## 
##
setGeneric("lo", function(e1,...){
    standardGeneric("lo")
})
##
setGeneric("hi", function(e1,...){
    standardGeneric("hi")
})
##
## 
##
setGeneric("ip.version", function(ip,...){
    standardGeneric("ip.version")
})
##
##
##
# setGeneric("any.na", function(x){
#   standardGeneric("any.na")
# })
##
##
##
setGeneric("id", function(x){
  standardGeneric("id")
})
##
setGeneric("id<-", function(x,value){
  standardGeneric("id<-")
})
##
##
##
setGeneric("ip.range", function(ipr) {
    standardGeneric("ip.range")
})
##________________________________________________________________________________________________________________________
##
##
##
##
##
##
setMethod(
  "Ops" ##
  ## 
  , signature(e1 = ".__IPvr__.", e2 = "ANY")
  , function(e1,e2){
    ##
    stop("Ops IPvr : unimplemented method ", .Generic, " for classes ", class(e1), " and ",  class(e2) )
  }
)
##
setMethod(
  "Ops" ##
  ## 
  , signature(e1 ="ANY" , e2 = ".__IPvr__.")
  , function(e1,e2){
    ##
    stop("Ops IPvr : unimplemented method ", .Generic, " for classes ", class(e1), " and ",  class(e2) )
  }
)
##
## getGroupMembers("Summary")
##
setMethod(
  "Summary" ##
  ## 
  , signature(x = ".__IPvr__.")
  , function(x, ..., na.rm = FALSE){
    ##
    cat("Summary\n")
    ##
    if(
      .Generic %in% c( "min",   "max", "range" )
    ){
      x <- sort(x,  na.last= if( na.rm ) NA else F )
      ##
      n <- length(x)
      ##
      x1 <- x[1]
      ##
      if( .Generic=="min" ){
        return( x1 )
      }else if( .Generic=="max" ){
        return( 
          if( is.na(x1) ) x1 else x[n]  
        )
      }else{
        return(
          if( is.na(x1) ) c(x1, x1) else x[c(1,n)] 
        )
      }
    }
    else stop("Summary IPvr : unimplemented method ", .Generic, " for classes ", class(x) )
  }
)
##
# setMethod(
#   "Summary" ##
#   ## 
#   , signature(x= ".__IPvr__.")
#   , function(x, ..., na.rm = FALSE){
#     ##
#     stop("Summary IPvr : unimplemented method ", .Generic, " for classes ", class(x) )
#   }
# )
##
# `Summary..__IPvr__.` <- function(...){
#     stop("Summary IPvr : unimplemented method ", .Generic, " for classes ", class( as.list(...)[[1]]) )
#   }

##
##
##
setMethod(
  "Math" ##
  ## 
  , signature(x= ".__IPvr__.")
  , function(x){
    ##
    stop("Math IPvr : unimplemented method ", .Generic, " for classes ", class(x) )
  }
)
##
##
##
# setMethod(
#   "Math2" ##
#   ## 
#   , signature(e1 = ".__IPvr__.", e2 = "ANY")
#   , function(e1,e2){
#     ##
#     stop("Math2 IPvr : unimplemented method ", .Generic, " for classes ", class(e1), " and ",  class(e2) )
#   }
# )
##
##
## !!! -- TODO : bitw* -- !!!
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
setGeneric("ip.xor", function(e1, e2) {
    standardGeneric("ip.xor")
})
##
## rshift
setGeneric("%>>%", function(e1, e2) {
  standardGeneric("%>>%")
})
## lshift
setGeneric("%<<%", function(e1, e2) {
  standardGeneric("%<<%")
})
##
## 
##
# ##
# setGeneric("netmask", function(n){
#     standardGeneric("netmask")
# })
##
# setGeneric("hostmask", function(n){
#     standardGeneric("hostmask")
# })
##
##
##
setGeneric("host", function(host,...){
    standardGeneric("host")
})
##
setGeneric("host.info", function(host,...){
    standardGeneric("host.info")
})
##________________________________________________________________________________________________________________________


##________________________________________________________________________________________________________________________
##
##
##
##
setGeneric("ip.order", function(x,...){
    standardGeneric("ip.order")
})
##
## 
##
if( 
  !isGeneric("match") 
){
  setGeneric("match")
  setGenericImplicit("match")
}
##
##
##
setGeneric("ip.match", function(x,table,...){
    standardGeneric("ip.match")
})
##
##
##
setGeneric("ip.index", function(table,...){
    standardGeneric("ip.index")
})
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
  "anyNA"
  ## 
  , signature(x = ".__ipvr__." )
  ##
  , function(x){
    length(x@.Data)!=length(
      slot(x, ip.slotname(class(x)))
    )
  }
)
## TODO: IP, IPr
# callGeneric(x@ipv4) && callGeneric(x@ipv6)
##
## TODO
##
##
# setMethod(
#   "dropNA"
#   , "IPv4"
#   , function(x){
#     if(
#       length(x@.Data)==length(x@ipv4)
#     ){
#       x[!is.na(x@.Data)]
#     }else{
#       x
#     }
#   }
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
setMethod(
  "["
  ## 
  , signature(x = ".__IPvr__.", i='missing' )
  ##
  , function(x, i, ...) x
)
##
##
##
setMethod(
  "["
  ## 
  , signature(x = ".__IPvr__.", i='character' )
  ##
  , function(x, i, ...) { 
    ##
    if( !is.null(
      nm <- names(x) 
    )){
      ##
      idx <- match(i, nm)
      ##
      return(x[idx])
    }
    ##
    return(
      new(class(x), rep(NA_character_,length(i)))
    )
  }
)
##
setMethod(
  "[["
  ## 
  , signature(x = ".__IPvr__.", i='.__subscript__.' )
  ##
  , function(x, i, ...) x[i]
)
##
##________________________________________________________________________________________________________________________
##
##
## check.cl=T
## 
`IP_concat` <- function(...) {
# cat("IP_concat \n")
  ##
  x   <- list(...)
  ##
  cl0 <- class(x[[1]])
  cl <- unlist(lapply(
    x, function(x) class(x)
  ))
  ##
  if( length( neq <- which(cl!=cl0) )>0 ) stop(
    "class mismatch: expected ", cl0, " but also got ", paste(unique(cl[neq]))
  )
  ##
  ip <- switch(
    cl0
    ## ? IPv4
    , IPv4r = ipv4r()
    , IPv6  = ipv6()
    , IPv6r = ipv6r()
  )
  ##
# print(str(x))
#   nna  <- unlist(lapply(x,function(x) if(length(x)>0) !is.na(x) else NULL))
  nna  <- unlist(lapply(x,function(x) !is.na(x) )) 
# print(str(nna))
  ##
  if( length(nna)==0 ) return(ip)
  ##
  ip@.Data       <- cumsum(nna) - 1L
  ip@.Data[!nna] <- NA
  ipSlotname     <- ip.slotname(cl0)
# cat(cl0 ,'ipSlotname', ipSlotname, '\n')
  ##
  if( 
    ##
    sum(nna)>0
  ){
    ## IPv4 : c
    slot(ip, ipSlotname)  <-  do.call('rbind', lapply(x,function(x) (slot(x,ipSlotname))))
    ip@length             <- nrow(slot(ip, ipSlotname)) ## ==nnna
  }
  else ip@length <- 0L ## FIXME: set @ip* slot
  ## 
  ## names
  ##!is.null
  nm        <- unlist(lapply(x,function(x) length( x@id )))
  ##
  if( any(nm==T) ){
    ip@id <- unlist(lapply(
       x
       , function(x){
         if( !is.null( x@id ) ) x@id
         else rep("",length(x) )
       }
    ))
  }
  ##
  ip
}
#`IPvr_concat` <- function(...) {
#   ##
#   x   <- list(...)
#   ##
#   ip <- switch(
#     cl0 <- class(x[[1]])
#     ## 
#     , IP  = ip()
#     , IPr = ipr()
#   )
#   ipSlotname     <- ip.slotname(cl0)
#   ##
#   ip@ipv4 <- do.call( `c`, lapply(x,ipv4))
#   ##
#   ip@ipv6 <- do.call( `c`, lapply(x,ipv6))
#   ##
#   ip@.Data <- ifelse(
#       !is.na(ip@ipv4)
#       , 4L
#       , ifelse(
#         !is.na(ip@ipv6)
#         , 6L
#         , NA_integer_
#       )
#     )
#   ##
#   ip
# }
##________________________________________________________________________________________________________________________
##
##
##
IP_uniq <- function(x,...){
  ##
  cl0 <- class(x)
  ##
  ipSlotname     <- ip.slotname(cl0)
  ##
  val <- unique( slot(x, ipSlotname) )
  ##
  ip <- switch(
    cl0
    ## 
    , IPv4  = ipv4()
    , IPv4r = ipv4r()
    , IPv6  = ipv6()
    , IPv6r = ipv6r()
  )
  ##
  na <- any(is.na(x))
  ##
  len <- if( is.vector(val) ) length(val) else nrow(val)
  ##
  ip@.Data              <- if( !na ) 1:len else c(1:len, NA)
  ##
  slot(ip, ipSlotname)  <- val
  ##
  ip@length             <- len + na
  ##
  ip
}
##________________________________________________________________________________________________________________________
##
## cf. setequals, setdiff,…
##
## ¿ TODO: add as.numeric ?
##
setMethod(
  "as.vector"
  , ".__IPvr__."
  , function(x, mode = "any"){
    if( mode %in% c("any", "character") ) as.character(x) else stop("cannot coerce to ", mode, " vector")
  }
)
##________________________________________________________________________________________________________________________
##
##
##
as.data.frame.ipvr <- function (x, row.names = NULL, optional = FALSE, ..., nm = paste(deparse(substitute(x), 
    width.cutoff = 500L), collapse = " ")) 
{
##
# cat("as.data.frame\n")
    force(nm)
    nrows <- length(x)
    if (!(is.null(row.names) || (is.character(row.names) && length(row.names) == 
        nrows))) {
        warning(gettextf("'row.names' is not a character vector of length %d -- omitting it. Will be an error!", 
            nrows), domain = NA)
        row.names <- NULL
    }
    if (is.null(row.names)) {
        if (nrows == 0L) 
            row.names <- character()
        else if (length(row.names <- names(x)) != nrows || anyDuplicated(row.names)) 
            row.names <- .set_row_names(nrows)
    }
#     if (!is.null(names(x))) 
#         names(x) <- NULL
    value <- list(x)
    if (!optional) 
        names(value) <- nm
    structure(value, row.names = row.names, class = "data.frame")
}
##
as.data.frame.IPv4 <- as.data.frame.IPv4r <- as.data.frame.IPv6 <- as.data.frame.IPv6r <- as.data.frame.IP <- as.data.frame.IPr <- function (x,...){
  as.data.frame.ipvr(x,...)
}
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
`as.list.IPv4` <- `as.list.IPv6` <- `as.list.IPv4r` <-`as.list.IPv6r` <- `as.list.IP` <- `as.list.IPr` <-function(x, ...){
  rv <- lapply( seq_along(x), function(i, x) x[i], x=x ) 
  names(rv) <- names(x)
  rv
}
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
rep.IPv4  <- rep.IPv4r <- rep.IPv6  <- rep.IPv6r <- rep.IP <-rep.IPr <- IP_rep  <- function(x,...) x[rep(1:length(x),...)]
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
##
seq.IPv6r <- seq.IPv4r <- function(x,...){
  lo(x) + seq(0,ip.range(x),...)
}
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
setGeneric("ip.setequal", function(x,y,...){
  standardGeneric("ip.setequal")
})
##
setMethod(
  "ip.setequal"
  ## 
  , signature(x = ".__IPvr__.", y=".__IPvr__." )
  ##
  , function (x, y,...){
    if( (xkl <- class(x))!=(ykl <- class(y)) )stop("non matching classes ", xkl, " ", ykl )
    !(anyNA(ip.match(x, y)) || anyNA(ip.match(y, x)))
  }
)
##
##
##
setGeneric("ip.union", function(x,y,...){
  standardGeneric("ip.union")
})
##
setMethod(
  "ip.union"
  ## 
  , signature(x = ".__IPvr__.", y=".__IPvr__." )
  ##
  , function (x, y,...){
    if( (xkl <- class(x))!=(ykl <- class(y)) )stop("non matching classes ", xkl, " ", ykl )
    unique(c(x, y))
  }
)
##
##
setGeneric("ip.setdiff", function(x,y,...){
  standardGeneric("ip.setdiff")
})
setMethod(
  "ip.setdiff"
  ## 
  , signature(x = ".__IPvr__.", y=".__IPvr__." )
  ##
  , function(x, y,...){
    if( (xkl <- class(x))!=(ykl <- class(y)) )stop("non matching classes ", xkl, " ", ykl )
    sort(unique(
      if (length(x) || length(y)) x[is.na(ip.match(x, y))]
      else x
    ))
  }
)
##
##
##
setGeneric("ip.intersect", function(x,y,...){
  standardGeneric("ip.intersect")
})
##
setMethod(
  "ip.intersect"
  ## 
  , signature(x = ".__IPvr__.", y=".__IPvr__." )
  ##
  , function(x, y,...){
    if( (xkl <- class(x))!=(ykl <- class(y)) )stop("non matching classes ", xkl, " ", ykl )
    unique(
      y[ !is.na(ip.match(x, y)) ]
    )
  }
)
##
##
##
setGeneric("ip.symdiff", function(x,y,...){
  standardGeneric("ip.symdiff")
})
##
setMethod(
  "ip.symdiff"
  ## 
  , signature(x = ".__IPvr__.", y=".__IPvr__." )
  ##
  , function(x, y,...){
    if( (xkl <- class(x))!=(ykl <- class(y)) )stop("non matching classes ", xkl, " ", ykl )
    ip.union(
      ip.setdiff(x, y), ip.setdiff( y, x)
    )
  }
)
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
getIdx <- function(m){
  ##
  midx <- attr(m, "midx") 
  ## 
  ptr  <- attr(m, "ptr")
  ##
  if( (!is.null(midx)) | (!is.null(ptr)) ) list(midx=midx,ptr=ptr) else stop('missing index')
}
##
##
##
##
# setMethod(
#   "ip.index"
#   ## 
#   , signature(table = ".__IPvr__.")
#   ##
#   , function(table,...){
#     ##
#     f <- function(x,nomatch=NA_integer_,...){
#       ##
#       if( (kl <-class(x))=='IPv6' )
#         .Call(
#           ##
#           'Rip_bsearch_ipv6_in_ipv6r_0'
#           , x
#           , table
#           , idx
#           , nomatch
#         )+1
#       else if( kl=='IPv6r' )
#         .Call(
#           ##
#           'Rip_bsearch_ipv6r_in_ipv6r_0'
#           , x
#           , table
#           , idx
#           , nomatch
#         )+1
#       else stop('bsearch not unimplemented for object of class', kl )
#     }
#     ##
#     idx <- order( 
#       ##ipv6(table)[['lo']]  
#       with( 
#         ipv6(table), lo + ( hi - lo ) %>>%1L
#       )
#     ) - 1L
#     ##
#     tb.clname <- if( (kl <-class(table))=='IPv4r' ) "v4r"
#       else if( kl=='IPv6r' ) "v6r"
#       else stop('bsearch not unimplemented for object of class', kl )
#     ##
#     return(
#       f
#     )
#   }
# )
##________________________________________________________________________________________________________________________
##
## getDLLRegisteredRoutines()
##
# IP_order <- function(
#   x, na.last = TRUE, decreasing = FALSE
#   , method = c(
#     "qsort", "radix", "order" ##, "qsort1", "shellsort"
#   )
# ){
#   ##
#   fcall_fmt <- c(radix = "Rip_%s_radix_2", qsort = "Rip_%s_qsort_cpv_2")
#   ##
#   method <- match.arg(method)
#   ##
#   if( method== "order" ) return( order(x, na.last = na.last, decreasing = decreasing) )
#   ##
#   klnm <-  tolower(class(x))
#   ##
#   fnm <- fcall_fmt[match(method, names(fcall_fmt))]
#   ##
#   cat("method:", method, " fnm:", fnm, "\n", sep="")
##  fcall <- match(method, names(fcall_fmt))
#   ##    
#   .Call(
#     ##
#     sprintf(
#        fnm
#       , klnm
#     )
#     , x
#     , decreasing ## 
#     , na.last
#   )
# }
##________________________________________________________________________________________________________________________
