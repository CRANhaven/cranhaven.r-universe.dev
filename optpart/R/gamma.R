gamma <- function(clust,dis,digits=5)
{
    clust <- as.numeric(clustify(clust))
    size <- length(clust)
    bigsiz <- (size^2-size)/2
    sd <- rep(0,bigsiz)
    nd <- 0
    nc <- 0

    out <- .Fortran('gamma',
         as.integer(clust),
         as.double(dis),
         as.integer(sd),
         as.integer(size),
         as.integer(bigsiz),
         nc=as.integer(nc),
         nd=as.integer(nd),
         package='optpart')
    res <- round((out$nc-out$nd)/(out$nc+out$nd),digits)
    cat(paste(res,"\n"))

}

