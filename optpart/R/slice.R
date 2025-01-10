slice <- function (clust, k=NULL) 
{
    if (!inherits(clust,c('hclust','agnes')))
        stop("The first argument must be an object of class 'hclust' or 'agnes'")
    if (inherits(clust,'agnes')) clust <- as.hclust(clust)
    if (is.null(k)) {
        out <- locator(n=1)
        abline(out$y,0,col=2)
        out <- list(clustering=cutree(clust,h=out$y))
        cat(paste("Number of clusters = ",max(out$clustering),"\n"))
    }
    else {
        out <- list(clustering=cutree(clust,k=k))
    }
    attr(out,"class") <- "clustering"
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out
}

