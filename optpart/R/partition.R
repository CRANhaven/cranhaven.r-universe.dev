partition <- function(x, dist, ...)
{
    UseMethod("partition")
}

partition.default <- function (x, dist, ...)
{
    if (!inherits(dist,'dist')) {
        stop("The second argument must be an object of class 'dist'")
    }
    x <- as.numeric(clustify(x))
    out <- list()
    out$diss <- dist
    out$clustering <- x
    out$silinfo <- silhouette(x,dist)
    attr(out,'class') <- 'partition'
    attr(out,"call") <- match.call()
    attr(out,'timestamp') <- date()
    return(out)
}
