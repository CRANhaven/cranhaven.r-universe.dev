ogrls<-function (formula, r, R, delt, data, na.action, ...) 
{
    cal <- match.call(expand.dots = FALSE)
    mat <- match(c("formula", "data", "na.action"), names(cal))
    cal <- cal[c(1L, mat)]
    cal[[1L]] <- as.name("model.frame")
    cal <- eval(cal)
    y <- model.response(cal)
    md <- attr(cal, "terms")
    x <- model.matrix(md, cal, contrasts)
    s <- t(x) %*% x
    xin <- solve(s)
    r <- as.matrix(r)
I <- diag(NCOL(x))
    RC <- matrix(R, NCOL(x))
    RR <- t(RC)
    if (is.matrix(R)) 
        RR <- R
    else RR <- RR
    del <- as.matrix(delt)
    bb <- xin %*% t(x) %*% y
    rb <- bb + solve(s) %*% t(RR) %*% solve(RR %*% solve(s) %*% 
        t(RR)) %*% (r - RR %*% bb)
rbve<-as.vector(rb)
j<-0
sumsq<-0
for (j in 1:NROW(rbve))
{
sumsq=(rbve[j])^2+sumsq
}
cval<-sumsq
    ev <- (t(y) %*% y - t(bb) %*% t(x) %*% y)/(NROW(x) - NCOL(x))
    ev <- diag(ev)
ahat<-rb%*%t(rb)%*%solve(ev*xin+rb%*%t(rb))
ogrlse<-ahat%*%bb
colnames(ogrlse) <- c("Estimate")
    dbd <- ev*(ahat%*%xin%*%t(ahat))
    Standard_error <- sqrt(diag(abs(dbd)))
    dbd <- ev*(ahat%*%xin%*%t(ahat))
rval<-(1/cval)*rb%*%t(rb)
mse1 <-cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(rb)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%rb 
mse1<-as.vector(mse1)    
rdel <- matrix(del, nrow(RR))
    lenr <- length(RR)
    dlpt <- diag(RR %*% xin %*% t(RR))
    if (lenr == ncol(RR)) 
        ilpt <- sqrt(solve(abs(dlpt)))
    else ilpt <- sqrt(solve(diag(abs(dlpt))))
    upt <- RR %*% ogrlse
    tb <- t(upt)
    t_statistic <- ((tb - t(rdel)) %*% ilpt)/sqrt(ev)
    tst <- t(2L * pt(-abs(t_statistic), df <- (NROW(x) - NCOL(x))))
    pvalue <- c(tst, rep(NA, (NCOL(x) - NROW(RR))))
    mse1 <- round(mse1, digits <- 4L)
    names(mse1) <- c("MSE")
    t_statistic <- c(t_statistic, rep(NA, (NCOL(x) - NROW(RR))))
    ans1 <- cbind(ogrlse, Standard_error, t_statistic, pvalue)
    ans <- round(ans1, digits <- 4L)
    anw <- list(`*****Ordinary Generalized Restricted Least Square Estimator*****` = ans, 
        `*****Mean square error value******` = mse1)
    anw
}
