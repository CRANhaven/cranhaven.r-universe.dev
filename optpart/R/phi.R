phi <- function (comm,clustering,minplt=10,p.adjust=FALSE)
{
    clustering <- clustify(clustering)
    names.phival <- levels(clustering)
    clustering <- as.numeric(clustering)

    testubiq <- apply(comm>0,2,sum)
    if (any(testubiq == nrow(comm))) {
        cat("\n Deleting ubiquitous species\n\n")
        comm <- comm[,testubiq != nrow(comm)]
    }
    numocc <- apply(comm>0,2,sum)
    comm <- comm[,numocc>=minplt]

    calcphi <- function(comm,clustering) {
        N <- nrow(comm)
        N.p <- table(clustering)
        phival <- matrix(NA,nrow=ncol(comm),ncol=length(N.p))

        for (i in 1:ncol(comm)) {
            n <- sum(comm[,i]>0)
            n.p <- tapply(comm[,i]>0,clustering,sum)
            numer <- (N*n.p) - (n*N.p)
            denom <-
               sqrt(as.numeric(n*N.p)*as.numeric((N-n)*(N-N.p)))
            phival[i,] <- numer/denom
         }
         phival <- data.frame(phival)
         row.names(phival) <- names(comm)
         names(phival) <- names.phival
         phival
    }

    fisher <- function(comm, clustering) {
        rows <- ncol(comm)
        cols <- length(table(clustering))
        pval <- matrix(NA, nrow = rows, ncol = cols)
        for (i in 1:rows) {
            for (j in 1:cols) {
                pval[i, j] <- fisher.test(comm[, i] > 0,
                        clustering == j,alternative='greater')$p.val
            }
        }
        pval <- data.frame(pval)
        row.names(pval) <- names(comm)
        names(pval) <- names.phival
        pval
    }
    phi <- calcphi(comm,clustering)
    pvals <- fisher(comm,clustering)
    if (p.adjust) pvals <- apply(pvals,2,function(x)p.adjust(x,method='hochberg'))

    cluster <- apply(phi,1,which.max)
    indic <- apply(phi,1,max)
    pval <- apply(pvals,1,min)
    res <- data.frame(cluster=cluster,phi=indic,pval=pval)

    out <- list(phi=phi,pvals=pvals,numocc=numocc,results=res)
    class(out) <- 'phi'
    out
}

plot.phi <- function(phi,panel='all')
{
    if (panel == 'all' || panel == 1) {
        plot(phi$numocc,phi$results$pval,
        xlab='Number of Occurrences',ylab='Phi Indicator Value')
        points(phi$numocc[phi$results$pval<=0.05],
               phi$results$pval[phi$results$pval<=0.05],
               col=2)
        if (panel == 'all') readline("Hit return to continue : ")
    } 
    if (panel == 'all' || panel == 2) {
        plot(phi$results$phi,phi$results$pval,
            xlab='Phi Indicator Value',ylab='Probability')
        points(phi$results$phi[phi$results$pval<=0.05],
               phi$results$pval[phi$results$pval<=0.05],col=2)
    }
}
