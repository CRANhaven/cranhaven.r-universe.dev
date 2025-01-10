mergeclust <- function(clustering,from,to)
{ 
    clustering <- as.integer(clustify(clustering))

    if (length(from) != length(to))
        stop("Vectors 'from' and 'to' must be the same length")
    for (i in 1:length(from))  clustering[clustering==from[i]] <- to[i]
    out <- list()
    out$clustering <- as.numeric(factor(clustering))
    class(out) <- 'clustering'
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out
}

