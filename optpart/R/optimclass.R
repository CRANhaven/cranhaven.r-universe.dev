optimclass <- function (comm, stride, pval = 0.01, counts = 2) 
{
    if (!inherits(stride,'stride'))
        stop("The second argument must be of class 'stride'")
    strides <- ncol(stride$clustering)
    mondo.fisher <- function(comm, clust) {
        rows <- ncol(comm)
        cols <- length(table(clust))
        res <- matrix(NA, nrow = rows, ncol = cols)
        for (i in 1:rows) {
            for (j in 1:cols) {
                res[i, j] <- fisher.test(comm[, i] > 0, clust == 
                  j)$p.val
            }
        }
        res
    }
    vals <- rep(NA, strides)
    cts <- rep(NA, strides)
    for (i in 1:strides) {
        tmp <- mondo.fisher(comm = comm, clust = stride$clustering[, 
            i])
        vals[i] <- sum(tmp <= pval)
        cts[i] <- sum(apply(tmp <= pval, 2, sum) >= counts)
    }
    out <- data.frame(stride$seq,vals,cts)
    names(out) <- c('clusters','sig.spc','sig.clust')
    attr(out, "call") <- match.call()
    attr(out, "timestamp") <- date()
    out
}
