gensilwidth <- function (clust, dist, p=1)
{
    clust <- clustify(clust)
    if (any(table(clust)<1))
        stop("All clusters must have at least one member")
    clust <- as.numeric(clustify(clust))
    numclu <- max(clust)
    numplt <- length(clust)
    home <- rep(0,numplt)
    neigh <- rep(0,numplt)
    val <- rep(0,numplt)
    names <- attr(dist,'Labels')
    disptc <- matrix(0, nrow = numplt, ncol = numclu)
    if (!inherits(dist,'dist')) {
        stop("The second argument must be an object of class 'dist'")
    }
    dist <- as.matrix(dist)
    if (max(dist) > 1) dist <- dist/max(dist)
    card <- rep(0,numclu)
    for (i in 1:numclu) {
        card[i] <- sum(clust==i)
    }

    if (p == -Inf) {
        for (i in 1:numplt) {
            for (j in 1:numclu) {
                if (clust[i] == j) {
                    if (card[j] > 1) {
                        mask <- clust==j
                        mask[i] <- FALSE
                        disptc[i,j] <- min(dist[i,mask])
                    } else {
                        disptc[i,j] <- 0
                    }
                } else {
                    disptc[i,j] <- min(dist[i,clust==j])
                }
            }
        }
    } else if (p == Inf) {
        for (i in 1:numplt) {
            for (j in 1:numclu) {
                if (clust[i] == j) {
                    if (card[j] > 1) {
                        mask <- clust==j
                        mask[i] <- FALSE
                        disptc[i,j] <- max(dist[i,mask])
                    } else {
                        disptc[i,j] <- 0
                    }
                } else {
                    disptc[i,j] <- max(dist[i,clust==j])
                }

            }
        }
    } else if (p == 0) {
        for (i in 1:numplt) {
            for (j in 1:numclu) {
                if (clust[i] == j) {
                    if (card[j] > 1) {
                        mask <- clust==j
                        mask[i] <- FALSE
                        tmp <- dist[i,mask]
                        tmp[tmp==0] <- 1e-10
                        disptc[i,j] <- prod(tmp)^(1/(card[j]-1))
                    } else {
                        disptc[i,j] <- 0
                    }
                } else {
                    disptc[i,j] <- prod(dist[i,clust==j])^(1/card[j])
                }
            }
        }
    } else {
        for (i in 1:numplt) {
            for (j in 1:numclu) {
                if (clust[i] == j) {
                    if (card[j] > 1) {
                        mask <- clust == j
                        mask[i] <- FALSE
                        disptc[i,j] <- mean(dist[i,mask]^p)^(1/p)
                    } else {
                        disptc[i, j] <- 0
                    }
                } else { 
                    disptc[i, j] <- mean(dist[i,clust==j]^p)^(1/p)
                }
            }
        }
    }
    
    for (i in 1:numplt) {
        home[i] <- disptc[i,clust[i]]
        val[i] <- min(disptc[i,-clust[i]])
        neigh[i] <- which(disptc[i,] == val[i])[1]
    }
    sils <- (val - home) / pmax(home,val)
    for (i in 1:numclu) {
        if (card[i] == 1) sils[clust==i] <- 0
    }
    out <- as.matrix(cbind(clust,neigh,sils))
    colnames(out) <- c('cluster','neighbor','sil_width')
    rownames(out) <-  names
    attr(out,'class') <- 'silhouette'
    attr(out,'call') <- match.call()
    attr(out,'Ordered') <- FALSE
    out
}
