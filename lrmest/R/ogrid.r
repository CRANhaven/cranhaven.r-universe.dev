ogre<-function (formula, k, data = NULL, na.action, ...) 
{
    k <- as.matrix(k)
    k1 <- k[1L]
    ogres <- function(formula, k1, data = NULL, na.action) {
        cal <- match.call(expand.dots = FALSE)
        mat <- match(c("formula", "data", "na.action"), names(cal))
        cal <- cal[c(1L, mat)]
        cal[[1L]] <- as.name("model.frame")
        cal <- eval(cal)
        y <- model.response(cal)
        md <- attr(cal, "terms")
        x <- model.matrix(md, cal, contrasts)
        s <- t(x) %*% x
xin<-solve(s)
        I <- diag(NCOL(x))
        bb <- solve(s) %*% t(x) %*% y
        bk <- solve(s + k1 * I) %*% t(x) %*% y
bkve<-as.vector(bk)
j<-0
sumsq<-0
for (j in 1:NROW(bkve))
{
sumsq=(bkve[j])^2+sumsq
}
cval<-sumsq
        ev <- (t(y) %*% y - t(bb) %*% t(x) %*% y)/(NROW(x) - 
            NCOL(x))
        ev <- diag(ev)
ahat<-bk%*%t(bk)%*%solve(ev*xin+bk%*%t(bk))
ogrid<-ahat%*%bb
        colnames(ogrid) <- c("Estimate")
        dbd <- ev*(ahat%*%xin%*%t(ahat))
        Standard_error <- sqrt(diag(abs(dbd)))
        dbt <- t(ogrid)
        dbd <- ev*(ahat%*%xin%*%t(ahat))
        sdbd_inv <- (sqrt(diag(abs(dbd))))^-1
        sdbd_inv_mat <- diag(sdbd_inv)
        if (NCOL(dbt) == 1L) 
            tbd <- dbt * sdbd_inv
        else tbd <- dbt %*% sdbd_inv_mat
        hggh <- t(tbd)
rval<-(1/cval)*bk%*%t(bk)
mse1 <- cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bk)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bk
mse1<-as.vector(mse1)
        mse1 <- round(mse1, digits <- 4L)
        names(mse1) <- c("MSE")
        tst <- t(2L * pt(-abs(tbd), df <- (NROW(x) - NCOL(x))))
        colnames(tst) <- c("p_value")
        colnames(hggh) <- c("t_statistic")
        ans1 <- cbind(ogrid, Standard_error, hggh, tst)
        ans <- round(ans1, digits <- 4L)
        anw <- list(`*****Ordinary Generalized Ridge Regression Estimators*****` = ans, 
            `*****Mean square error value*****` = mse1)
        return(anw)
    }
    npt <- ogres(formula, k1, data, na.action)
    plotogre <- function(formula, k, data = NULL, na.action, ...) {
        j <- 0
        arr <- 0
        for (j in 1:nrow(k)) {
            ridm <- function(formula, k, data, na.action, ...) {
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
xin<-solve(s)
                I <- diag(NCOL(x))
                bb <- solve(s) %*% t(x) %*% y
bk <- solve(s + k * I) %*% t(x) %*% y
bkve<-as.vector(bk)
j<-0
sumsq<-0
for (j in 1:NROW(bkve))
{
sumsq=(bkve[j])^2+sumsq
}
cval<-sumsq
ev <- (t(y) %*% y - t(bb) %*% t(x) %*% y)/(NROW(x) - 
                  NCOL(x))
                ev <- diag(ev)
ahat<-bk%*%t(bk)%*%solve(ev*xin+bk%*%t(bk))
rval<-(1/cval)*bk%*%t(bk)
mse1 <-cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bk)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bk 
mses<-as.vector(mse1)
                return(mses)
            }
            arr[j] <- ridm(formula, k[j], data, na.action)
        }
        MSE <- arr
        parameter <- k
        pvl <- cbind(parameter, MSE)
        colnames(pvl) <- c("Parameter", "MSE")
        sval <- pvl
        return(sval)
    }
    prdes <- plotogre(formula, k, data, na.action)
    if (nrow(k) > 1L) 
        val <- prdes
    else val <- npt
    val
}
