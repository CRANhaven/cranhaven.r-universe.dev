lambda <- function(x,y,digits=5)
{
    x <- clustify(x)
    y <- clustify(y)

    x <- x[names(x) %in% names(y)]
    y <- y[names(y) %in% names(x)]
    z <- table(x,y)

    a <- sum(apply(z,1,max))
    b <- sum(apply(z,2,max))
    c <- max(apply(z,1,sum))
    d <- max(apply(z,2,sum))

    print(z)
    lambda <- (a + b - c - d) / (2*sum(z)-c-d)
    cat(paste('\n lambda =',round(lambda,digits),'\n'))
    invisible(lambda)
}

