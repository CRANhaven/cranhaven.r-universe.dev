optpart <- function(x, dist, maxitr=100, mininc=0.001, maxdmu=1)
{
    UseMethod("optpart")
}

opt.core <- function (dist, clustering, mininc, maxdmu, maxitr)
{
    if (!inherits(dist,'dist'))
        stop("The first argument must be an object of class 'dist'") 
    clustering <- as.numeric(clustify(clustering))
    numclu <- length(table(clustering))
    simptp <- 1 - as.matrix(dist)
    simptc <- matrix(0, nrow = nrow(simptp), ncol = numclu)
    simctc <- matrix(0, nrow = numclu, ncol = numclu)
    cardin <- matrix(0, nrow = numclu)
    musubx <- matrix(0, nrow = nrow(simptp), ncol = numclu)
    dratio <- matrix(0, nrow = numclu, ncol = numclu)
    maxdif <- matrix(0, nrow = numclu, ncol = numclu)
    dltamu <- matrix(0, nrow = numclu, ncol = numclu)
    pltdif <- matrix(0, nrow = numclu, ncol = numclu)
    final <- musubx
    simrat <- rep(0, maxitr)
    numitr <- 0
    tmp <- .Fortran("optpart", as.double(simptp), simptc = as.double(simptc),
        simctc = as.double(simctc), simrat = as.double(simrat),
        as.double(cardin), as.integer(nrow(simptp)), as.integer(numclu),
        musubx = as.double(musubx), as.double(final), clustering = as.integer(clustering),
        as.double(maxdmu), as.integer(maxitr), numitr = as.integer(numitr),
        as.double(dratio),as.double(maxdif),as.double(dltamu),as.integer(pltdif),
        PACKAGE = "optpart")
    out <- list(ptc = matrix(data = tmp$simptc, ncol = numclu),
        ctc = matrix(data = tmp$simctc, ncol = numclu), musubx = matrix(tmp$musubx,
            nrow = nrow(simptp)), clustering = as.numeric(factor(tmp$clustering)),
        ratio = tmp$simrat[1:tmp$numitr], numitr = tmp$numitr,
        names = attr(dist, "Labels"))
    names(out$clustering) <- attr(dist, "Labels")
    attr(out, "class") <- c("partana", "clustering")
    attr(out, "call") <- call
    attr(out,'timestamp') <- date()
    out
}

optpart.default <- function(x, dist, maxitr = 100, mininc = 0.001, maxdmu = 1)
{
    if (class(dist) != "dist") {
        stop("optpart is not defined for classes other than dist")
    }
        if (max(dist) > 1) {
        dist <- dist/max(dist)
    }
    simptp <- 1 - as.matrix(dist)

    if (is.numeric(x) && length(x) == 1) {
        size <- attr(dist,'Size')
        tmp <- rep(1:x,((size-1))/x+1)[1:size]
        tmp <- sample(tmp,size,replace=FALSE)
        out <- opt.core(dist,tmp,mininc=mininc,maxdmu=maxdmu,maxitr=maxitr)
    } else {
        x <- as.numeric(clustify(x))
        out <- opt.core(dist,x,
            mininc=mininc,maxdmu=maxdmu,maxitr=maxitr)
    }
 
    attr(out,"class") <- c("partana", "clustering")
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out
}


optpart.stride <- function(x,dist,maxitr=100,mininc=0.001,maxdmu=1.0)
{
    if (!inherits(x,'stride'))
        stop("The first argument must be an object of class 'stride'")
    if (!inherits(dist,'dist'))
        stop("The second argument must be an object of class 'dist'")
    res <- matrix(NA,nrow=nrow(x$clustering),ncol=ncol(x$clustering))
    for (i in 1:ncol(x$clustering)) {
        tmp <- opt.core(dist,x$clustering[,i],maxitr=maxitr,mininc=0.001,maxdmu=1.0)
        res[,i] <- tmp$clustering
    }
    out <- data.frame(res)
    names(out) <- as.character(x$seq)
    row.names(out) <- row.names(x$clustering)
    out <- list(clustering=out,seq=x$seq)
    class(out) <- 'stride'
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    out
}

bestopt <- function (dist, numclu, numrep, maxitr=100)
{
    if (class(dist) != "dist") {
        stop("bestopt is only defined for objects of class dist")
    }
    best <- 0
    ratios <- rep(0, numrep)
    for (i in 1:numrep) {
        tmp <- optpart.default(numclu, dist, maxitr = maxitr)
        ratios[i] <- max(tmp$ratio)
        if (ratios[i] > best) {
            best <- ratios[i]
            result <- tmp
            itr <- i
        }
    }
    cat("Ratios for respective optparts \n")
    print(as.numeric(format(ratios, digits = 4)))
    cat(paste("\nChoosing # ", itr, " ratio = ", format(best,
        digits = 4), "\n"))
    invisible(result)
}
