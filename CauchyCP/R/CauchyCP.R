#' A robust test under non-proportional hazards using Cauchy combination of change-point Cox regressions.
#' @param time - Follow up time for right censored data.
#' @param status - The event status indicator, 0=censored, 1=event.
#' @param x - The variable of interest, e.g. a treatment indicator.
#' @param covar - The matrix of covariates. If no covariates, a vector of ones should be used (default).
#' @param cutpoints - The pre-specified change-points. The default choice is a vector of 0th, 25th, 50th and 75th percentiles of the event time.
#' @return 1. A matrix of estimated hazard ratios before and after the change-points. 2. the vector of p-values corresponding to the change-points. 3. a final p-value.
#' @references Hong Zhang, Qing Li, Devan Mehrotra and Judong Shen. "CauchyCP: a powerful test under non-proportional hazards using Cauchy combination of change-point Cox regressions", arXiv:2101.00059.
#' @examples
#' data(gast)
#' CauchyCP(time=gast$time, status=gast$status, x=gast$trt)
#' @export
#' @import survival stats

CauchyCP <- function(time, status, x, covar=rep(1,length(time)), cutpoints = c(0, quantile(time[status==1])[2:4])){
  data.analysis <- data.frame(cbind(time,status, covar, x=x))

  pvals = rep(NA, length(cutpoints))
  hrs = matrix(NA, ncol=2, nrow=length(cutpoints))
  fit0 = coxph(Surv(time, status) ~ . - x, data=data.analysis)
  fit1 <- coxph(Surv(time, status) ~ ., data=data.analysis)
  pvals[1] = anova(fit0, fit1, test="LRT")[2, 4] # Pr(>|Chi|)
  tmp = summary(fit1)
  hrs[1,1] = hrs[1,2] = tmp$coefficients["x",2]
  for(l in 2:length(cutpoints)){
    mydat_split <- survSplit(Surv(time, status) ~ .,
                             data=data.analysis, cut=c(cutpoints[l]),
                             episode= "tgroup", id="id")
    id_rm = which(abs(mydat_split$tstart-mydat_split$time)<0.00274) # 1/365
    if(length(id_rm)>0){
      mydat_split = mydat_split[-id_rm,]
    }
    fit0 <- coxph(Surv(tstart, time, status) ~ . - tgroup - id - x, data=mydat_split)
    fit1 <- coxph(Surv(tstart, time, status) ~ . - tgroup - id + x:strata(tgroup), data=mydat_split)

    pvals[l] = anova(fit0, fit1, test="LRT")[2, 4] # Pr(>|Chi|)

    tmp = summary(fit1)
    hrs[l, 1] = tmp$coefficients["x",2]
    hrs[l, 2] = exp(tmp$coefficients["x",1] + tmp$coefficients["x:strata(tgroup)tgroup=2",1])
  }
  stat.cauchy = sum(tan(pi*(0.5-pvals)), na.rm=TRUE)/length(na.omit(pvals))
  pval.cauchy = 0.5 - atan(stat.cauchy)/pi
  hrs = as.data.frame(hrs)
  colnames(hrs) = c("before", "after")
  rownames(hrs) = paste0("CP_", round(cutpoints))
  return(list(hrs=hrs, p.unadj=pvals, pval=pval.cauchy))
}
