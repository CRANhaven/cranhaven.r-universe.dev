clusters <- function(c)
{
    UseMethod("clusters")
}

clusters.partition <- function(c)
{
    print(table(c$clustering))
}

clusters.clustering <- function(c)
{
    print(table(c$clustering))
}

members <- function (clustering,which=NULL)
{
    clust <- clustering$clustering

    if (!is.null(which)) {
        cat(paste("cluster ",which,"\n"))
        print(names(clust)[clust==which])
    } else {
        for (i in 1:max(clust)) {
            cat(paste("cluster ",i,"\n"))
            print(names(clust)[clust==i])
        }
    }
}

