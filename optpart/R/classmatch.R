classmatch <- function (x,y,type='full')
{
    clustx <- deparse(substitute(x))
    clusty <- deparse(substitute(y))

    x <- clustify(x)
    y <- clustify(y)
    tab <- table(x,y)

    if (type=='full') {
        total <- sum(tab)
        size <- max(nrow(tab),ncol(tab))
    
        match <- sum(tab>0)
        pairs <- matrix(0,nrow=match,ncol=3)
        partial <- rep(0,match)
        combo <- rep(0,length(x))
        ord <- matrix(0,nrow=nrow(tab),ncol=ncol(tab))
        running <- 0
    
        for (i in 1:match) {
            find <- max(tab)
            for (j in 1:nrow(tab)) {
                test <- max(tab[j,])
                if (test == find) {
                    col <- which.max(as.vector(tab[j,]))
                    pairs[i,] <- c(j,col,tab[j,col])
                    tab[j,col] <- 0
                    ord[j,col] <- i
                    break
                }
            }
        }
    
        for (i in 1:length(x)) {
            for (j in 1:nrow(pairs)) {
                if (x[i] == pairs[j,1] && y[i] == pairs[j,2]) {
                    combo[i] <- j
                    break
                }
            }
        }
    
        partial <- cumsum(pairs[,3])/total
        pairs <- data.frame(pairs)
        names(pairs) <- c('row','column','n')
        res <- list(tab=table(x,y,dnn=list(clustx,clusty)),
                     pairs=pairs,partial=partial,ord=ord,combo=combo)
    } else{
        grand <- sum(tab)
        if (nrow(tab) != ncol(tab))
            cat("Warning: classifications have different numbers of classes")
    
        size <- min(nrow(tab),ncol(tab))
        pairs <- matrix(0,ncol=4)
        sum <- 0
    
        for (i in 1:size) {
            sum <- sum + max(tab)
            z <- which(tab==max(tab),arr.ind=TRUE)
            z <- z[1,]
            pairs[i,1] <- i
            pairs[i,2] <- z[1]
            pairs[i,3] <- z[2]
            pairs[i,4] <- max(tab)
            tab[z[1],] <- -1
            tab[,z[2]] <- -1
        }

        pairs <- data.frame(pairs)
        names(pairs) <- c('rank','row','col','count')

        res <- list(tab=table(x,y,dnn=list(clustx,clusty)),
                   pairs=pairs,partial=sum/grand)
    }
    attr(res,'class') <- 'classmatch'
    attr(res,'type') <- type

    invisible(res)
}

print.classmatch <- function(cm)
{
    cat("Cross-tabulated Table\n\n")
    print(cm$tab)
    cat("\nBest Match\n\n")
    print(cm$pairs)
    cat("\nPartial Correspondence\n\n")
    print(cm$partial)
}
