#' All train data set to calculate \code{PPKernelSHAP}
#'
#' @title Calculate \code{PPKernelSHAP} for all train data set
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param final.rule final rule to assign numerical values in the final nodes.
#'             1: mean value in the final nodes
#'             2: median value in the final nodes
#'             3: using optimal projection
#'             4: using all independent variables
#'             5: using several significant independent variables
#' @param method simple or empirical method to calculate \code{PPKernelSHAP}
#' @return ppshapr_prep class object
#' @export
#' @import data.table
#' @examples
#' data(dataXY)
#' testX <- dataXY[1,-1]
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' shap_long <- ppshapr_prep(Model, final.rule =5, method="simple")
#'
ppshapr_prep = function(PPTreeregOBJ = NULL,
                        final.rule =5,
                        method="simple"){


  id <- value <-  mean_value <- rfvalue  <- stdfvalue <- variable <- NULL # due to NSE notes in R CMD check


  trainNum = nrow(PPTreeregOBJ$Tree.result$origdata)
  leafnum = length(PPTreeregOBJ$mean.G)
  scale_ft <- function(x){
    (x - min(x, na.rm=TRUE)) / (max(x, na.rm=TRUE)-min(x, na.rm=TRUE))
  }
  ppAll = progress::progress_bar$new(
    format= "Progress:[:bar]:percent",
    total = trainNum,
    clear=FALSE,
    width=60)

  ppSHAP <- c()

  if(method == "simple"){
    for(p in 1:trainNum){
      ppAll$tick()
      ppSHAP[[p]] <-  ppshapr.simple(PPTreeregOBJ, PPTreeregOBJ$Tree.result$origdata[p,], final.rule = final.rule)$dt
      ppSHAP[[p]][,':='(id,p)]
    }
  }else{
    for(p in 1:trainNum){
      ppAll$tick()
      ppSHAP[[p]] <-  ppshapr.empirical(PPTreeregOBJ, PPTreeregOBJ$Tree.result$origdata[p,], final.rule = final.rule)$dt
      ppSHAP[[p]][,':='(id,p)]
    }
  }

  shap_score <- data.table::rbindlist(ppSHAP)
  fv <- data.table::as.data.table(PPTreeregOBJ$Tree.result$origdata)
  f_n <- dim(fv)[2]
  vars_ <- colnames(fv)
  shap_score_long  <- data.table::melt.data.table(shap_score, measure.vars = vars_)

  fv[, id := .I]
  fv_long <- data.table::melt.data.table(fv, measure = vars_[-(f_n+1)], value.name = "rfvalue")
  fv_long[, stdfvalue := scale_ft(rfvalue), by = "variable"]

  # SHAP value: value
  # raw feature value: rfvalue;
  # standarized: stdfvalue

  keycols <- c("id","variable")
  data.table::setkeyv(fv_long, keycols)
  data.table::setkeyv(shap_score_long, keycols)
  shap_long <- shap_score_long[fv_long,]

  shap_long[, mean_value := mean(abs(value)), by = variable]
  data.table::setkey(shap_long, variable)

  return(shap_long)

}
