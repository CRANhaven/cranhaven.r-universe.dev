refine <- function (x, clustering, ...)
{ 
   UseMethod("refine")
}

refine.dsvord <- function (x, clustering, ax=1, ay=2, ...)
{
    if (!inherits(x,'dsvord'))
        stop("The first argument must be an object of class 'dsvord'")
    clustering <- as.integer(clustify(clustering))

    for (i in 1:max(clustering)) {
        plot(x, ax, ay)
        cat(paste("Refining cluster # ", i, "\n"))
        cols <- rep(8,max(clustering))
        cols[i] <- i+1
        hilight(x, clustering, ax, ay, col=cols)
        chullord(x, clustering == i, ax, ay, col = cols)
        new <- identify(x$points[,ax],x$points[,ay])
        clustering[new] <- i
    }
    hilight(x, clustering, ax, ay)
    chullord(x, clustering == i, ax, ay)
    out <- list(clustering=clustering)
    attr(out, "class") <- "clustering"
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out
}

refine.default <- function (comm,clustering, ...)
{
    clustering <- as.integer(clustify(clustering))

    repeat {
        plots <- readline(' enter the plots    : ')
        if (plots == "") break
        new <- as.numeric(readline(' New cluster        : '))
        for (i in strsplit(plots,",")[[1]]){
            ord <- 1:nrow(comm)
            y <- match(i,row.names(comm))
            if (!is.na(y)) {
                clustering[y] <- new
            }
            else print('no such plot')
        }
    }
    out <- list(clustering=clustering)
    class(out) <- 'clustering'
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out
}

