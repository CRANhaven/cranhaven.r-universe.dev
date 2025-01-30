#' summary \code{PPTreereg} result
#'
#' summary the projection pursuit regression tree result
#' @title Summary \code{PPTreereg} result
#' @param object a fitted object of class inheriting from \code{PPTreereg}
#' @param c choose node id to summary. Default value is FALSE.
#' @param ... arguments to be passed to methods
#' @aliases summary.PPTreereg
#' @return coefficient results of tree
#' @export

summary.PPTreereg<-function(object,c=NA, ...){
  PPTreeregOBJ  <- object
  formula <- PPTreeregOBJ$formula
  ans <- cat("Call:", paste("PPTreereg(",formula[2],formula[1],formula[3],")"))

  PPclassOBJ <-PPTreeregOBJ$Tree.result
  TS <- PPclassOBJ$Tree.Struct
  Alpha <- PPclassOBJ$projbest.node
  origdata <- PPclassOBJ$origdata

  if(is.na(c)){
    c <- TS[TS[,4]!=0,1]
  }

  if(length(c)==1){
    coef_result <- round(Alpha[TS[c, 4], ],4)
    coef_result <- as.data.frame(coef_result)
    colnames(coef_result)<-paste0("node",c)
  }else{
    coef_result <- t(round(Alpha[TS[c, 4], ],4))
    colnames(coef_result)<-  c(paste0("node",c))
  }
  ans$coefficient <- coef_result
  class(ans) <- "summary.PPTreereg"

  ans
}
