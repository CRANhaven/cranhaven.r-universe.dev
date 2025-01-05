#' Comparing Two Models: ANOVA
#'
#' Compute analysis of variance tables for two fitted model objects
#' @param object model resulting from \code{mm}
#' @param ...  model resulting from \code{mm} Note that \code{anova} only allow users to compare two models
#'
#' @return ANOVA table
#' @export
#'
#' @examples
#' \donttest{
#' data(datrand)
#' fit1 <- mm(Y~time*binary, t.formula=~1, data=datrand, id=id, step.max=4, verbose=FALSE)
#' fit2 <- mm(Y~time*binary, t.formula=~1, lv.formula =~1, data=datrand, id=id, step.max=4, verbose=FALSE)
#' anova(fit1,fit2)}
#'
anova.MMLong <-
function(object, ...) {
  oo1 = object
  oo2 = list(...)[[1]]

  mod1 = list(mf=oo1$call)
  mod2 = list(mf=oo2$call)

  info.mat = rbind(oo1$info_stats, oo2$info_stats)
  info.mat = data.frame(cbind(df=c(nrow(oo1$mod.cov),nrow(oo2$mod.cov)), info.mat))
  ord = sort(info.mat$Deviance,index.return=TRUE, decreasing=TRUE)$ix
  info.mat = info.mat[ord,]
  info.mat$ChiSq = c(NA,-diff(info.mat$Deviance))
  info.mat$ChiSqdf = c(NA,diff(info.mat$df))
  info.mat$p = c(NA,pchisq(info.mat$ChiSq[2], df=info.mat$ChiSqdf[2],lower.tail=FALSE))
  names(info.mat) = c('df','AIC','BIC','logLik','Deviance','Chi Square','Chi Square df','Pr(>Chi)')
  rownames(info.mat) = c('Model 1','Model 2')
  mod1.nm = mod1[!unlist(lapply(mod1,is.null))]
  mod2.nm = mod2[!unlist(lapply(mod2,is.null))]
  mod1.nm = paste(paste(names(mod1.nm),'(', mod1.nm, ')',sep=''),collapse=' + ')
  mod2.nm = paste(paste(names(mod2.nm),'(', mod2.nm, ')',sep=''),collapse=' + ')
  nms     = c(mod1.nm, mod2.nm)[ord]
  out = list(atable = info.mat, models=nms)
  class(out) = 'anova.MMLong'
  out
}
