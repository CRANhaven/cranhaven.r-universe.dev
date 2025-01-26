oglt1<-function (formula, k, d, data = NULL, na.action, 
    ...) 
{
    k <- as.matrix(k)
    d <- as.matrix(d)
    k1 <- k[1L]
    d1 <- d[1L]
    ltes1 <- function(formula, k1, d1, data = NULL, na.action, 
        ...) {
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
        bb <- solve(t(x) %*% x) %*% t(x) %*% y
        bk <- (solve(s + k1 * I) - d1 * solve(s + k1 * I) %*% 
            solve(s)) %*% t(x) %*% y
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
oglt1<-ahat%*%bb
colnames(oglt1) <- c("Estimate")
dbd <-ev*(ahat%*%xin%*%t(ahat))
        Standard_error <- sqrt(diag(abs(dbd)))
        dbt <- t(oglt1)
dbd <-ev*(ahat%*%xin%*%t(ahat))
        sdbd_inv <- (sqrt(diag(abs(dbd))))^-1
        sdbd_inv_mat <- diag(sdbd_inv)
        if (NCOL(dbt) == 1L) 
            tbd <- dbt * sdbd_inv
        else tbd <- dbt %*% sdbd_inv_mat
        hggh <- t(tbd)
        tst <- t(2L * pt(-abs(tbd), df <- (NROW(x) - NCOL(x))))
        colnames(tst) <- c("p_value")
        colnames(hggh) <- c("t_statistic")
rval<-(1/cval)*bk%*%t(bk)
mse1 <-cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bk)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bk
mse1<-as.vector(mse1)
        mse1 <- round(mse1, digits <- 4L)
        names(mse1) <- c("MSE")
        ans1 <- cbind(oglt1, Standard_error, hggh, tst)
        ans <- round(ans1, digits = 4L)
        anw <- list(`*****Ordinary Generalized Type (1) Liu Estimator*****` = ans, 
            `*****Mean Square Error value*****` = mse1)
        return(anw)
    }
    npt <- ltes1(formula, k1, d1, data, na.action)
    plotlt1 <- function(formula, k, d, data = NULL, na.action, 
        ...) {
        j <- 0
        i <- 0
        arr <- 0
        for (j in 1:nrow(k)) {
            for (i in 1:nrow(d)) {
                lt1m <- function(formula, k, d, data, na.action, 
                  ...) {
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
                  bb <- solve(t(x) %*% x) %*% t(x) %*% y
bk <- (solve(s + k * I) - d * solve(s + k * I) %*%solve(s)) %*% t(x) %*% y
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
dbd <-ev*(ahat%*%xin%*%t(ahat))
rval<-(1/cval)*bk%*%t(bk)
mse1 <-cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bk)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bk 
mse1<-as.vector(mse1)
                  return(mse1)
                }
                arr[j * i] <- lt1m(formula, k[j], d[i], data, 
                  na.action)
                flte1 <- file("lte1v.data", "a+")
                cat(k[j], d[i], arr[j * i], "\n", file = flte1, 
                  append = TRUE)
                close(flte1)
            }
        }
        mat <- read.table("lte1v.data")
        unlink("lte1v.data")
        rmat <- matrix(mat[, 3L], nrow = NROW(d), dimnames = list(c(paste0("d=", 
            d)), c(paste0("k=", k))))
        return(rmat)
    }
    plte1 <- plotlt1(formula, k, d, data, na.action)
    if (nrow(k) > 1L | nrow(k) > 1L) 
        val <- plte1
    else val <- npt
    val
}
