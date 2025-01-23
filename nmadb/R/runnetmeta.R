#' Run \code{netmeta}
#'
#' R package \code{\link[netmeta]{netmeta}} provides frequenstist methods 
#' for network meta-analysis based on Rücker (2012) and Rücker (2014). 
#' This function is used to run netmeta on a specified network 
#' included in the database of network meta-analyses,
#' which can be downloaded using function \code{\link{getNMADB}}. 
#' @references 
#'   Rücker G (2012) <doi:10.1002/jrsm.1058>.
#'
#'   Rücker G, Schwarzer G (2014) <doi:10.1002/sim.6236>.
#'
#' @param recid ID of network in database
#' @param model "fixed" or "random"; specifies if fixed or random effects 
#'   network meta-analysis should be conducted. 
#' @param measure
#' \itemize{
#' \item "notset" (default) is the type of effect 
#'    measure in the original publication
#' \item "OR" odds ratio for binary data
#' \item "RR" risk ratio for binary data
#' \item "RD" risk difference for binary data
#' \item "MD" mean difference for continuous data
#' \item "SMD" standardized mean difference for continuous data
#' \item "HR" hazard ratio for survival data
#' \item "IRR" incidence rate ratio for rate data
#' }
#' If the measure entered is not compatible with network's type you get an error
#' @examples
#' \dontrun{
#'   Conduct random effects network meta-analysis 
#'   in a random network with continuous outcome
#' }
#' cid <- 501427
#' netc <- readByID(cid)
#' \dontrun{get type and effect}
#' netc$type
#' netc$effect
#' \dontrun{In order to run netmeta but get "SMD" summary effects instead}
#' runnetmeta(recid=cid, measure="SMD")
#'
#' \donttest{
#' 
#' \dontrun{If we the following example choosing OR we get an error
#' runnetmeta(recid=cid, measure="OR")}
#' 
#' \dontrun{As before for a network with binary outcome}
#' bid <- 481216
#' netb <- readByID(bid)
#' \dontrun{get type and effect}
#' netb$type
#' netb$effect
#' runnetmeta(recid=bid, measure="OR")
#'  
#' \dontrun{Survival outcome}
#' sid <- 479888
#' nets <- readByID(sid)
#' \dontrun{get type and effect}
#' nets$type
#' nets$effect
#' runnetmeta(recid=sid)
#'  
#' \dontrun{Rate outcome}
#' rid <- 479999
#' netr <- readByID(rid)
#' \dontrun{get type and effect}
#' netr$type
#' netr$effect
#' runnetmeta(recid=rid)
#' }
#'  
#' @return An object of class netmeta; for the descirption 
#'   of the components included in the object, see the help file of
#'   \code{\link[netmeta]{netmeta}}.
#' @seealso \code{\link[netmeta]{netmeta}}
#' ,\code{\link{getNMADB}}
#' ,\code{\link{readByID}}
#' @export runnetmeta
runnetmeta <- function(recid,model="random", measure="notset"){
  indata = readByID(recid)
  if(! is.null(indata)){
    type = indata$type
    format = as.character(indata$format)
    longType = function (indata) {
      if(indata$format != "iv"){
        paste("long_",indata$type,sep="")
      }else{
        "iv"
      }
    }
    dataeffect = indata$effect
    if(indata$effect == "other"){
        stop("don't know how to analyze atypical effect measure")
    }else{
      if(measure != "notset"){
        if (indata$format == "iv"){
          if (indata$effect == measure){
            sm = measure
          }else{
            stop("cannot change effect measure type in inverse variance dataset")
          }
        }else{
          if(isOutcomeCompatibleWithMeasure(type,measure)){
            sm = measure
          }else{
            stop(paste(type, " not compatible with ",measure))
          }
        }
      }else{
        sm = indata$effect
      }
    }
    makelong = function () {
                   return(wide2long(indata$data,indata$type))
               }
    data = switch (format
                  , long = {indata$data}
                  , wide = {makelong()}
                  , iv = {indata$data}
                  )
    C = getmetaNetw(data, type=longType(indata), model, sm, tau="NA")
    return(C)
  }else{
    message("Unable to get dataset check internet connection")
    return (NA)
  }
}


  getmetaNetw = function(indata,type,model="fixed",tau=NA, sm){
    
    D <- indata
    
    #network meta-analysis
    if (type=="long_binary"){
      Dpairs=netmeta::pairwise(treat=D$t
                               ,event=D$r
                               ,n=D$n
                               , data=D
                               , studlab =D$id
                               , sm= sm
                               , allstudies = TRUE)
      metaNetw<-netmeta::netmeta(Dpairs$TE
                                 ,Dpairs$seTE
                                 ,Dpairs$treat1
                                 ,Dpairs$treat2
                                 ,Dpairs$studlab
                                 ,data=Dpairs
                                 ,sm=sm
                                 ,comb.fixed =F
                                 ,comb.random = T
                                 , details.chkmultiarm=TRUE)
    } 
    if (type=="long_continuous"){
      Dpairs=netmeta::pairwise(treat=D$t
                               ,mean=D$y
                               ,sd=D$sd
                               ,n=D$n
                               ,data=D
                               , studlab=D$id
                               , sm=sm
                               , allstudies = TRUE)
      metaNetw<-netmeta::netmeta(Dpairs$TE
                                 ,Dpairs$seTE
                                 ,Dpairs$treat1
                                 ,Dpairs$treat2
                                 ,Dpairs$studlab
                                 ,data=Dpairs
                                 ,sm=sm
                                 ,comb.fixed =F
                                 ,comb.random = T
                                 , details.chkmultiarm=TRUE
                                 , tol.multiarm=0.2)
    }
    if (type=="long_rate"){
      Dpairs=netmeta::pairwise(treat=D$t
                      ,event=D$r
                      ,n=D$n
                      ,time=D$time
                      , data=D
                      , studlab=D$id
                      , sm=sm
                      , allstudies = TRUE)
      metaNetw<-netmeta::netmeta(Dpairs$TE
                        ,Dpairs$seTE
                        ,Dpairs$treat1
                        ,Dpairs$treat2
                        ,Dpairs$studlab
                        ,data=Dpairs
                        ,sm=sm
                        ,comb.fixed =F
                        ,comb.random = T
                        ,details.chkmultiarm=TRUE)
    }
    if (type=="iv"){
      metaNetw=netmeta::netmeta(TE=D$effect
                                ,seTE=D$se
                                ,treat1=D$t1
                                ,treat2=D$t2
                                ,studlab=D$id
                                ,data=D
                                ,sm=sm
                                ,comb.fixed =F
                                ,comb.random = T
                                , details.chkmultiarm=TRUE
                                , tol.multiarm=0.5)
    }

    return(metaNetw)
}

isOutcomeCompatibleWithMeasure = function(outcome, measure){
 binaries = c("OR","RR","RD") 
 continuouses = c("MD","SMD")
 rates = c("IRR")
 survivals = c("HR")
 iscomp = function(compatibles, sm) {
    out = F
    if (sm == "other"){
      out = F
    }else{
      out = sm %in% compatibles
    }
   return (out)
 }
 res = switch (outcome
              , binary = {iscomp(binaries, measure)}
              , continuous = {iscomp(continuouses, measure)}
              , survival = {iscomp(survivals, measure)}
              , rate = {iscomp(rates, measure)}
              )
 return (res)
}
