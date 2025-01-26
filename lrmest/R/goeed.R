ogols=function (formula, data, na.action, ...) 
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
    bb <- xin %*% t(x) %*% y
bbve<-as.vector(bb)
j<-0
sumsq<-0
for (j in 1:NROW(bbve))
{
sumsq=(bbve[j])^2+sumsq
}
cval<-sumsq
    ev <- (t(y) %*% y - t(bb) %*% t(x) %*% y)/(NROW(x) - NCOL(x))
    ev <- diag(ev)
ahat<-bb%*%t(bb)%*%solve(ev*xin+bb%*%t(bb))
goeol<-ahat%*%bb
 colnames(goeol) <- c("Estimate")
    dbb <- ev*(ahat%*%xin%*%t(ahat))
    Standard_error <- sqrt(diag(abs(dbb)))
    dbt <- t(goeol)
    sdbd_inv <- (sqrt(diag(abs(dbb))))^-1
    sdbd_inv_mat <- diag(sdbd_inv)
    if (NCOL(dbt) == 1L) 
        tbb <- dbt * sdbd_inv
    else tbb <- dbt %*% sdbd_inv_mat
    tst <- t(tbb)
    pval <- t(2 * pt(-abs(tbb), df <- (NROW(x) - NCOL(x))))
    colnames(pval) <- c("p_value")
    colnames(tst) <- c("t_statistic")
  I <- diag(NCOL(x))
rval<-(1/cval)*bb%*%t(bb)
mse1 <-cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bb)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bb 
mse1<-as.vector(mse1)
    names(mse1) <- c("MSE")
    mse1 <- round(mse1, digits <- 4L)
    ans <- cbind(goeol, Standard_error, tst, pval)
    ans1 <- round(ans, digits <- 4L)
    adw <- list('*****Ordinary Generalized Least Square Estimator******' = ans1,'*****Mean square error value*****' = mse1) 
    adw
}
