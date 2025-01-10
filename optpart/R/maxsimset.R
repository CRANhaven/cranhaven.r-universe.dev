maxsimset <- function (dist, size = NULL, alphac = NULL, mean = FALSE) 
{
    if (!inherits(dist,'dist')) 
        stop("The first argument must be an object of class dist")
    if (max(dist) > 1.0) dist <- dist/max(dist)
    sim <- 1 - as.matrix(dist)
    if (is.null(size) & is.null(alphac)) 
        stop("You must specify size or alphac")
    if (!is.null(size)) {
        tmp <- min(apply(sim>0,1,sum))
        if (tmp < size) {
            print(paste("Note, some sets are ambiguous at size ",size))
            print(paste("Reducing size to",tmp))
            size <- tmp
        }
    }
    if (is.null(size)) size <- attr(dist,'Size')
    numplt <- nrow(sim)
    if (mean) 
        morf <- 1
    else morf <- 0
    musuby <- matrix(0, nrow = numplt, ncol = size)
    membry <- matrix(0, nrow = numplt, ncol = size)
    numset <- 0
    used <- rep(0, numplt)
    musubx <- matrix(0, nrow = numplt, ncol = numplt)
    membrx <- matrix(0, nrow = numplt, ncol = numplt)
    mnsimi <- rep(0, numplt)
    maxpnt <- rep(0,numplt)
    tmp <- .Fortran("maxpact", as.double(sim), as.integer(numplt), 
        as.integer(size), as.double(alphac), as.integer(morf), 
        musuby = as.double(musuby), membry = as.integer(membry), 
        numset = as.integer(numset), as.integer(used), as.double(musubx), 
        as.integer(membrx), as.double(mnsimi), as.integer(maxpnt), 
        PACKAGE = "optpart")
     member <- matrix(tmp$membry, nrow = numplt)
     member <- member[1:tmp$numset,]
     musuby <- matrix(tmp$musuby, nrow = numplt)
     musubx <- musuby[1:tmp$numset,]
     distname <- deparse(substitute(dist))
     if (!is.null(alphac)) {
         long <- max(apply(musubx>=alphac,1,sum))
         member[musubx<alphac] <- NA
         member <- member[,1:long]
         musubx[musubx<alphac] <- NA
         musubx <- musubx[,1:long]
     }
    out <- list(musubx = musubx, member = member, numset = tmp$numset, 
        size = size, alphac = tmp$alphac, distname = distname, 
        numele = attr(dist,'Size'))
    class(out) <- "mss"
    attr(out,'call') <- match.call()
    attr(out,'timestamp') <- date()
    return(out)
}


mss.test <- function(mss,env,panel='all',main=deparse(substitute(env)),...)
{
    if (!inherits(mss,'mss')) 
        stop("You must pass an object of class mss from maxsimset()")
    if (!is.numeric(env)) 
        stop("You must pass only numeric vectors as environment variables")
    setsiz <- ncol(mss$member)
    nset <- mss$numset
    null <- rep(0,nset)
    for (i in 1:nset) {
        tmp <- sample(1:length(env),setsiz)
        nullmin <- min(env[tmp])
        nullmax <- max(env[tmp])
        null[i] <- nullmax - nullmin
    }
        
    low <- apply(mss$member,1,function(x){min(env[x])})
    high <- apply(mss$member,1,function(x){max(env[x])})
    observed <- high - low
    if (panel == 'all' | panel == 1) {
        plot(sort(null),ylim=c(0,max(null)),main=main,ylab="Within-Set Difference")
        points(sort(observed),col=2)
        if (panel == 'all')
            readline("Hit return\n")
    }
    if (panel == 'all' || panel == 2) {
        boxplot(null,observed,names=c("null","observed"),
            ylab="Within-Set Difference",main=main)
    }
    print(wilcox.test(null,observed))
}

plot.mss <- function(x, ...)
{
    plot(x$musubx[1,],ylim=c(0,1),xlab="Size",ylab="Similarity",type="n")
    for (i in 1:x$numset) {
        lines(x$musubx[i,])
    }

}

getsets <- function(mss)
{
    UseMethod("getsets")
}


getsets.mss <- function (mss) 
{
    if (!inherits(mss,'mss'))
        stop('You must pass an object of class mss')
    res <- list()
    for (i in 1:nrow(mss$member)) {
        tmp <- rep(FALSE,mss$numele)
        members <- c(mss$member[i,][!is.na(mss$member[i,])])
        tmp[members] <- TRUE
        res[[i]] <- tmp
    }
    res
}

