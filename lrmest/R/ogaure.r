ogaur<-function (formula, k, data = NULL, na.action, ...) 
{
    k <- as.matrix(k)
    k1 <- k[1L]
    ogauri <- function(formula, k1, data = NULL, na.action, ...) {
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
        I <- diag(NCOL(x))
        tk <- solve(s + k1 * I) %*% s
        bar <- (I - k1^2 * solve(s + k1 * I) %*% solve(s + k1 * 
            I)) %*% bb
barve<-as.vector(bar)
j<-0
sumsq<-0
for (j in 1:NROW(barve))
{
sumsq=(barve[j])^2+sumsq
}
cval<-sumsq
        ev <- (t(y) %*% y - t(bb) %*% t(x) %*% y)/(NROW(x) - 
            NCOL(x))
        ev <- diag(ev)
ahat<-bar%*%t(bar)%*%solve(ev*xin+bar%*%t(bar))
ogaure<-ahat%*%bb
colnames(ogaure) <- c("Estimate")
        dbb <- ev*(ahat%*%xin%*%t(ahat))
rval<-(1/cval)*bar%*%t(bar)
mse1 <- cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bar)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bar
mse1<-as.vector(mse1)
        names(mse1) <- c("MSE")
        Standard_error <- sqrt(diag(abs(dbb)))
        dbt <- t(ogaure)
        sdbd_inv <- (sqrt(diag(abs(dbb))))^-1
        sdbd_inv_mat <- diag(sdbd_inv)
        if (NCOL(dbt) == 1L) 
            tbb <- dbt * sdbd_inv
        else tbb <- dbt %*% sdbd_inv_mat
        hggh <- t(tbb)
        tst <- t(2L * pt(-abs(tbb), df <- (NROW(x) - NCOL(x))))
        colnames(tst) <- c("p_value")
        colnames(hggh) <- c("t_statistic")
        ans1 <- cbind(ogaure, Standard_error, hggh, tst)
        ans <- round(ans1, digits = 4L)
        adw <- list(`*****Ordinary Generalized Almost Unbiased Ridge Estimator******` = ans, 
            `*****Mean square error value*****` = mse1)
        return(adw)
    }
    npt <- ogauri(formula, k1, data, na.action)
    plotogaur <- function(formula, k, data = NULL, na.action, ...) {
        j <- 0
        arr <- 0
        for (j in 1:nrow(k)) {
            ogaurm <- function(formula, k, data, na.action, ...) {
                cal <- match.call(expand.dots = FALSE)
                mat <- match(c("formula", "data", "na.action"), 
                  names(cal))
                cal <- cal[c(1L, mat)]
                cal[[1L]] <- as.name("model.frame")
                cal <- eval(cal)
                y <- model.response(cal)
                md <- attr(cal, "terms")
                x <- model.matrix(md, cal, contrasts)
                s <- t(x) %*% x
                xin <- solve(s)
                bb <- xin %*% t(x) %*% y
                I <- diag(NCOL(x))
                tk <- solve(s + k * I) %*% s
                bar <- (I - k^2 * solve(s + k * I) %*% solve(s + 
                  k * I)) %*% bb
barve<-as.vector(bar)
j<-0
sumsq<-0
for (j in 1:NROW(barve))
{
sumsq=(barve[j])^2+sumsq
}
cval<-sumsq
                ev <- (t(y) %*% y - t(bb) %*% t(x) %*% y)/(NROW(x) - 
                  NCOL(x))
                ev <- diag(ev)
ahat<-bar%*%t(bar)%*%solve(ev*xin+bar%*%t(bar))
                dbb <- ev*(ahat%*%xin%*%t(ahat))
rval<-(1/cval)*bar%*%t(bar)
mse1 <- cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bar)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bar
mse1<-as.vector(mse1)
                return(mse1)
            }
            arr[j] <- ogaurm(formula, k[j], data, na.action)
        }
        MSE <- arr
        parameter <- k
        pvl <- cbind(parameter, MSE)
        colnames(pvl) <- c("Parameter", "MSE")
        sval <- pvl
        return(sval)
    }
    paur <- plotogaur(formula, k, data, na.action)
    if (nrow(k) > 1L) 
        val <- paur
    else val <- npt
    val
}
