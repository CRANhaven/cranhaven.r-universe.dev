archi <- function(dist,alpha)
{
    if (class(dist) != 'dist') {
        stop("You must pass an object of class dist as the first argument")
    }
    y <- as.matrix(dist)
    clustering <- rep(0,nrow(y))
    tmp <- .Fortran("archi",
        as.double(y),
        as.double(alpha),
        clustering = as.integer(clustering),
        as.integer(nrow(y)),
        PACKAGE='optpart')
    out <- list(clustering=tmp$clustering)
    class(out) <- 'clustering'
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out 
}
