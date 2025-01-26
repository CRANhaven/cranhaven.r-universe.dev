ogalt1<-function (formula, k, d, aa, data = NULL, na.action, 
    ...) 
{
    k <- as.matrix(k)
    d <- as.matrix(d)
    k1 <- k[1L]
    d1 <- d[1L]
    if (length(aa) == 1L) 
        A <- as.matrix(aa)
    else A <- diag(aa)
    altes <- function(formula, k1, d1, aa, data = NULL, na.action, 
        ...) {
        cal <- match.call(expand.dots = FALSE)
        mat <- match(c("formula", "data", "na.action"), names(cal))
        cal <- cal[c(1L, mat)]
        cal[[1L]] <- as.name("model.frame")
        cal <- eval(cal)
        y <- model.response(cal, "numeric")
        md <- attr(cal, "terms")
        x <- model.matrix(md, cal, contrasts)
        s <- t(x) %*% x
xin<-solve(s)
        I <- diag(NCOL(x))
        bb1 <- solve(s) %*% t(x) %*% y
        bk1 <- (solve(s + k1 * I) - d1 * solve(s + k1 * I) %*% 
            solve(s)) %*% t(x) %*% y
        bk <- A %*% bk1
bkve<-as.vector(bk)
j<-0
sumsq<-0
for (j in 1:NROW(bkve))
{
sumsq=(bkve[j])^2+sumsq
}
cval<-sumsq
        ev <- (t(y) %*% y - t(bb1) %*% t(x) %*% y)/(NROW(x) - 
            NCOL(x))
        ev <- diag(ev)
rval<-(1/cval)*bk%*%t(bk)
ahat<-cval*rval%*%solve(ev*xin+cval*rval)
ogalt1<-ahat%*%bb1
colnames(ogalt1) <- c("Estimate")
dbd <-ev*(ahat%*%xin%*%t(ahat)) 
        Standard_error <- sqrt(diag(abs(dbd)))
        dbt <- t(ogalt1)
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
mse1 <-cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bk)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bk 
mse1<-as.vector(mse1)
        mse1 <- round(mse1, digits <- 4L)
        names(mse1) <- c("MSE")
        ans1 <- cbind(ogalt1, Standard_error, hggh, tst)
        ans1 <- round(ans1, digits = 4L)
        rownames(ans1) <- rownames(bb1)
        anw <- list(`*****Ordinary Generalized Type (1) Adjusted Liu Estimator*****` = ans1, 
            `****Mean Square Error value*****` = mse1)
        return(anw)
    }
    npt <- altes(formula, k1, d1, aa, data, na.action)
    plotalt1 <- function(formula, k, d, aa, data = NULL, na.action, 
        ...) {
        i <- 0
        j <- 0
        arr <- 0
        for (j in 1:nrow(k)) {
            for (i in 1:nrow(d)) {
                altem1 <- function(formula, k, d, aa, data, na.action, 
                  ...) {
                  cal <- match.call(expand.dots = FALSE)
                  mat <- match(c("formula", "data", "na.action"), 
                    names(cal))
                  cal <- cal[c(1L, mat)]
                  cal[[1L]] <- as.name("model.frame")
                  cal <- eval(cal)
                  y <- model.response(cal, "numeric")
                  md <- attr(cal, "terms")
                  x <- model.matrix(md, cal, contrasts)
                  s <- t(x) %*% x
xin<-solve(s)
                  I <- diag(NCOL(x))
                  bb <- solve(t(x) %*% x) %*% t(x) %*% y
bb1 <- solve(s) %*% t(x) %*% y
bk1 <- (solve(s + k * I) - d * solve(s + k * I)%*%solve(s)) %*% t(x) %*% y            
bk <- A %*% bk1
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
rval<-(1/cval)*bk%*%t(bk)
ahat<-cval*rval%*%solve(ev*xin+cval*rval)
dbd <-ev*(ahat%*%xin%*%t(ahat)) 
mse1 <-cval^2*ev*tr(ev*rval*solve(ev*xin+cval*rval)%*%xin%*%solve(ev*xin+cval*rval)%*%rval)+ev^2*t(bk)%*%solve(ev*I+cval*rval%*%s)%*%solve(ev*I+cval*rval%*%s)%*%bk 
mse1<-as.vector(mse1)
                  return(mse1)
                }
                arr[i * j] <- altem1(formula, k[j], d[i], aa, 
                  data, na.action)
                falt1 = file("alt1.data", "a+")
                cat(k[j], d[i], arr[i * j], "\n", file = falt1, 
                  append = TRUE)
                close(falt1)
            }
        }
        mat <- read.table("alt1.data")
        unlink("alt1.data")
        rmat <- matrix(mat[, 3L], nrow = NROW(d), dimnames = list(c(paste0("d=", 
            d)), c(paste0("k=", k))))
        return(rmat)
    }
    pl1 <- plotalt1(formula, k, d, aa, data, na.action)
    if (nrow(k) > 1L | nrow(d) > 1L) 
        val <- pl1
    else val <- npt
    val
}