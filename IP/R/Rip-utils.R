##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
IP_AVX2 <- F
## 
IP_IDN <- F
##
avx2.support <- function() IP_AVX2
##
ip.capabilities <- function(){
  c(
      AVX2 = IP_AVX2
    , IDN  = IP_IDN
  )
}
## FIXME: 
#  namespace can be loaded without the namespace being attached (e.g. by pkgname::fun) and that a package can be detached and re-attached whilst its namespace remains loaded
##
.onLoad <- function(libname, pkgname){
  ##
  .Call("Rip_init")
  ##
  .Call("Rip_defineGlobalVar_0", e <- parent.env(environment()) )
  ##
#   e <- parent.env(environment())
#   packageStartupMessage( paste( 
#     "assigning in", deparse(substitute(e))
#   ))
  ## CHK
  .Call("Rip_idn_defineGlobalVar_0", e)
  ##
  IdnaFlags <- c(IDNA_DEFAULT, IDNA_ALLOW_UNASSIGNED, IDNA_USE_STD3_ASCII_RULES)
  names(IdnaFlags) <- c("IDNA_DEFAULT", "IDNA_ALLOW_UNASSIGNED", "IDNA_USE_STD3_ASCII_RULES")
  assign("IdnaFlags", IdnaFlags, e)
}
## ¿ .Last.lib ?
.onUnload <- function(libpath){
  ## WSA
  if( .Platform$OS.type=="windows" ) rc <- .Call("Rip_WSACleanup")
  ##
  library.dynam.unload("IP", libpath)
}
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
slotnames <- c(
    "IPv4"  = "ipv4"
  , "IPv6"  = "ipv6"
  , "IPv4r" = "ipr"
  , "IPv6r" = "ipr"
  , "IP"    = "ip"
  , "IPr"   = "ipr"
)
##
ip.slotname <- function(cl){
  slotnames[cl]
}
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
## 
## ¿ test NA ? nope
## 
## 
IP_getId <- function(x) x@id
## 
ip.get.id <- function(x) IP_getId(x) ## x@id
## 
IP_setId <- function(x,value){
  ##
  if( !length(value) ){
    ##
#     warning(if( is.null(value) ) "NULL" else  "empty", " names" )
    ##
    return(x)
  }
  ##
#   value[is.na(value)] <- NA
  ##
  if( 
    (l<-length(x))==(n<-length(value))
  ){
    ##
    x@id <- as.character(value)
    ##
    return(x)
  }
#     if( 
#       (n==0)
#     ){
#       ##
#       x@id <- rep('',l)
#       return(x)
#     }
  ##
  warning('names length mismatch ', l, ' ', n)
  ##
  x
} 
## 
ip.set.id <- function(x,value) IP_setId(x,value)
##
## 
##
## 
# ipc_getId <- function(x){
#   ##
#   c(id()
# }
##
##
##
IP_setId_rbind <- function(x, value){
  ##!is.null
  if( length( x@id ) ){
    ##!is.null
    if( length( value ) ) x@id <- c( x@id , value  )
    else x@id <- c( x@id , rep(NA_character_,length(x) ) )
  }else if( length( value ) ) 
    x@id <- c( rep(NA_character_,length(x) ) , value  )
  ##
  x
}
##
rbind_setId <- function(x, value) IP_setId_rbind(x, value)
##
##
##
IP_setId_replace <- function(x,i,value){
  ## N-R
#   if( !is.null(x@id) ){
#     ##
#     if( is.null(value) ) x@id <- rep(NA_character_, length(x@.Data))
#     ##
#     x@id[i] <- NA_character_
#     ##
#   }else if( !is.null(value@id) ){
#     ##
#     x@id[i] <- value@id[i]
#   }
  ##!is.null
#   if( length(value@id) ){
#     ##is.null
#     if( !length(x@id) ) x@id <- rep(NA_character_, length(x@.Data))
#     ##
#     x@id[i] <- value@id
  ##
  nm <- names(value)
  ##
  if( length(nm) ){
    ##is.null
    if( !length(x@id) ) x@id <- rep(NA_character_, length(x@.Data))
    ##
    x@id[i] <- nm ## value@id

  }else if( length(x@id) ){
    ##
    x@id[i] <- NA_character_
  }
  x
}
##
replace_setId <- function(x,i,value) IP_setId_replace(x,i,value)
##________________________________________________________________________________________________________________________

##________________________________________________________________________________________________________________________
##
##
##
##________________________________________________________________________________________________________________________
##
## Fully qualified domain name
##
## 
fqdn <- function(hostname){
  stringi::stri_match(hostname, regex="(^|\\.)([A-Za-z0-9]+(\\-[A-Za-z0-9]+)*\\.[A-Za-z]{2,}$)")[,3]
} 
## 
is.fqdn <- function(hostname){
  !is.na(
    stringi::stri_match(hostname, regex="^([A-Za-z0-9]+(\\-[A-Za-z0-9]+)*\\.[A-Za-z]{2,}$)")[,2]
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
rir.names <- function() rir.names
## 
##________________________________________________________________________________________________________________________
