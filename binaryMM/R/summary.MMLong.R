summary.MMLong <-
function(object, ...) {
  oo      <- object
  m.i     <- seq(length(oo$beta))
  a.i     <- seq(length(oo$alpha))+length(oo$beta)
  mean.oo <- with(oo, data.frame(estimate = beta, mod.se = sqrt(diag(mod.cov)[m.i])))
  mean.oo$X2  <- with(mean.oo, (estimate/mod.se)^2)
  mean.oo$pX2 <- with(mean.oo, pchisq(X2, df=1,lower.tail=FALSE))
  names(mean.oo) = c('Estimate','Model SE', 'Chi Square','Pr(>Chi)')

  assoc.oo <- with(oo, data.frame(estimate = alpha, mod.se = sqrt(diag(mod.cov)[a.i])))
  assoc.oo$X2  <- with(assoc.oo, (estimate/mod.se)^2)
  assoc.oo$pX2 <- with(assoc.oo, pchisq(X2, df=1,lower.tail=FALSE))
  names(assoc.oo) = c('Estimate','Model SE','Chi Square','Pr(>Chi)')

  if(object$control[6]) {
    mean.oo <- with(oo, data.frame(estimate = beta, rob.se = sqrt(diag(rob.cov)[m.i])))
    mean.oo$X2  <- with(mean.oo, (estimate/rob.se)^2)
    mean.oo$pX2 <- with(mean.oo, pchisq(X2, df=1,lower.tail=FALSE))
    names(mean.oo) = c('Estimate','Robust SE', 'Chi Square','Pr(>Chi)')

    assoc.oo <- with(oo, data.frame(estimate = alpha, rob.se = sqrt(diag(rob.cov)[a.i])))
    assoc.oo$X2  <- with(assoc.oo, (estimate/rob.se)^2)
    assoc.oo$pX2 <- with(assoc.oo, pchisq(X2, df=1,lower.tail=FALSE))
    names(assoc.oo) = c('Estimate','Robust SE','Chi Square','Pr(>Chi)')
    warning('When performing a weighted likelihood analysis (by specifying the weight argument), robust standard errors are reported. Model based standard errors will not be correct and should not be used.')
  }

  out = list(class = class(object), call = deparse(object$call), control=object$control,
             info=object$info_stats, mean.table = mean.oo, assoc.table=assoc.oo)
  class(out) = 'summary.MMLong'
  out
}
