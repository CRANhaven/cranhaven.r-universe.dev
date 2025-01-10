#silhouette <- function(x, dist, ...)
#{
#    UseMethod("silhouette")
#}

silhouette.partana <- function (x, dist, ...)
{
    if (!inherits(x,'partana')) 
        stop("The first argument must be an object of class 'partana'")
    if (!inherits(dist,'dist')) 
       stop("The second argument must be an object of class 'dist'") 
    out <- silhouette(as.numeric(clustify(x)),dist,...)
    row.names(out) <- attr(dist,'Labels')
    attr(out,'class') <- 'silhouette'
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out
}

silhouette.clustering <- function (x, dist, ...)
{
    if (!inherits(x,'clustering')) 
        stop("You must supply an object of class clustering as the first argument")
    if (class(dist) != 'dist') 
        stop("You need to specify an object of class dist as the second argument")
    out <- silhouette(as.numeric(clustify(x)),dist)
    row.names(out) <- attr(dist,'Labels')
    attr(out,'class') <- 'silhouette'
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out
}




silhouette.stride <- function(x,dist,...)
{
    if (!inherits(x,'stride'))
        stop("The first argument must be an object of class 'strid'")
    res <- rep(NA,ncol(x$clustering))
    for (i in 1:ncol(x$clustering)) {
        res[i] <-  mean(silhouette(x$clustering[,i],dist)[,3])
    }
    clusters <- x$seq
    sil_width <- res
    out <- data.frame(clusters,sil_width)
    out
}


testsil <- function(sil)
{
    if (!inherits(sil,'silhouette')) 
        stop('You must pass an object of class silhouette')
    tmp <- sil[sil[,3]<0,]
    tmp <- tmp[order(tmp[,1],tmp[,3]),]
    tmp
}
