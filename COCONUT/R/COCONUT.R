
### COCONUT
### Sweeney, TE
### 2016

## send only control to combat to get gammastar and deltastar
## correct diseased and match back
COCONUT <- function (GSEs, control.0.col, disease.col=NULL,
                     byPlatform=FALSE, platformCol, par.prior=TRUE,
                     itConv=1e-04, parallel=FALSE, mc.cores=1){

    ## subset to common genes
    common <- Reduce(intersect, lapply(GSEs, function(X) rownames(X$genes)))
    common <- common[!(common %in% c(NA, ""))]


    ## list of only controls (everything else removed)
    GSEs.control <- lapply(GSEs, function(x) {
        x$pheno <- x$pheno[(x$pheno[ , control.0.col] %in% 0), ]
        x$genes <- x$genes[, rownames(x$pheno)]
        x$class <- rep(0, ncol(x$genes))
        x
    })


    ## check for presence of appropriate controls
    if(byPlatform){
        ## make sure that there are no platforms present without controls
        ## note takes the FIRST item in the column
        checkPlatforms <- function(GSElist) {
            platforms <- lapply(GSElist, function(x) {
                x$pheno[, grep(platformCol, colnames(x$pheno))][1]
            })
            sort(unique(unlist(platforms)))
        }
        if(!identical(checkPlatforms(GSEs), checkPlatforms(GSEs.control))) {
            stop("byPlatform = T but not all platforms have associated controls")
        }
    } else {
        check <- unlist(lapply(GSEs.control, function(x) length(x$class)>1 ))
        if(!all(check)){
            stop(paste("Datasets with <1 control:",
                       names(GSEs.control[!check])))
        }
    }


    ## get ComBat parameters from controls
    ComBatcontrol  <- .CombatCustom(GSEs.control, common,
                                    params = "get", byPlatform = byPlatform,
                                    platformCol = platformCol,
                                    par.prior=par.prior,
                                    itConv=itConv,
                                    parallel=parallel, mc.cores=mc.cores)

    ## list of only disease samples (everything else removed)
    ## can make it a subset by specifying 'disease.col'
    if(is.null(disease.col)){
        GSEs.disease <- lapply(GSEs, function(x) {
            x$pheno <- x$pheno[!(x$pheno[ , control.0.col] %in% 0), ]
            x$genes <- x$genes[, rownames(x$pheno)]
            x$class <- x$pheno[ , control.0.col]
            x
        })
    } else {
        GSEs.disease <- lapply(GSEs, function(x) {
            x$pheno <- x$pheno[!is.na(x$pheno[ , disease.col]), ]
            x$genes <- x$genes[, rownames(x$pheno)]
            x$class <- x$pheno[ , disease.col]
            x
        })
    }

    ## apply ComBat parameters from controls to disease samples
    GSEs.disease.ComBat <- .CombatCustom(GSEs.disease, common,
                                         params = "have", byPlatform = byPlatform,
                                         platformCol = platformCol,
                                         bayesParams = ComBatcontrol$bayesParams,
                                         getPlatforms = ComBatcontrol$getPlatforms)

    return(list(COCONUTList = GSEs.disease.ComBat,
                rawDiseaseList = GSEs.disease,
                controlList = ComBatcontrol))
}


## merge COCONUT-normalized data from multiple sources into single object
## Note, the 'pheno' file will only output columns with common names
combineCOCOoutput <- function (COCONUT.out) {
    COCONUTList <- lapply(1:length(COCONUT.out$COCONUTList), function(i){
        GEM.cntl <- COCONUT.out$controlList$GSEs[[i]]
        GEM.dis <- COCONUT.out$COCONUTList[[i]]
        list(genes=cbind(GEM.cntl $genes, GEM.dis$genes),
             pheno=data.frame(rbind(GEM.cntl $pheno, GEM.dis$pheno)),
             class=c(rep(0, ncol(GEM.cntl $genes)), rep(1, ncol(GEM.dis$genes))))
    })
    genesMat <- Reduce(cbind, lapply(COCONUTList, function(gse) gse$genes))
    common <- Reduce(intersect, lapply(COCONUTList, function(gse) colnames(gse$pheno)))
    phenoMat <- Reduce(rbind, lapply(COCONUTList, function(gse) gse$pheno[, common]))
    class <- Reduce(c, lapply(COCONUTList, function(gse) gse$class))
    list(genes=genesMat, pheno=phenoMat, class.cntl0.dis1=class)
}




.CombatCustom <- function(GSE.list.genes, common, params, byPlatform,
                          platformCol, bayesParams, getPlatforms=NULL,
                          par.prior=TRUE, itConv=1e-04,
                          parallel=FALSE, mc.cores=1) {

    ## must be one or the other
    stopifnot(params %in% c("get", "have"))

    ## make single matrix from all data on common genes
    commonGenes <- Reduce(cbind, lapply(GSE.list.genes, function(X) X$genes[common, ]))

    ## can either normalize by platform or by dataset
    if(byPlatform){
        ## split by platform
        cat("\nTreating platforms as batches...\nPlatforms found: ")
        platforms <- factor(unlist(lapply(GSE.list.genes, function(X){
            ## note takes the FIRST match for grep
            platform <- grep(platformCol, colnames(X$pheno), ignore.case=T)[1]
            GSEplatform <- as.character(X$pheno[ , platform])
            ## list chips found
            cat(GSEplatform[1], ", ")
            ## (!) could get confounded if multiple platforms in same col
            GSEplatform
        })))

        ## will assure correct application of batches
        index <- order(platforms)
        platforms <- platforms[index]
        commonGenes <- commonGenes[index]

        ## quantile normalize datasets from the same platform prior to ComBat
        requireNamespace("limma")
        cat("\nCo-quantile-normalizing datasets from the same platform ")
        invisible(lapply(levels(platforms), function(platform){
            index <- colnames(commonGenes)[platforms==platform]
            samePlatformData <- commonGenes[, index]
            samePlatformData <- limma::normalizeQuantiles(samePlatformData)
            commonGenes[, index] <<- samePlatformData
            cat(" .")
        }))
    } else {
        cat("\nTreating datasets as batches: ")
        platforms <- unlist(lapply(1:length(GSE.list.genes), function(i) {
            rep(i, ncol(GSE.list.genes[[i]]$genes))
        }))
    }


    ## either combat normalize on controls ("get")
    ## or use parameters derived from controls ("have")
    if(params == "get"){
        ComBatWithParams <- .ComBatGetParamsNoCov(commonGenes, batch=platforms,
                                                  par.prior=par.prior,
                                                  itConv=itConv,
                                                  parallel=parallel,
                                                  mc.cores=mc.cores)

        ## split common matrix (bayesdata) back out into list
        ComBatWithParams$GSEs <- lapply(GSE.list.genes, function(GSE) {
            GSE$genes <- data.frame(ComBatWithParams$bayesdata[,
                                                        colnames(GSE$genes)])
            return(GSE)
        })
        ComBatWithParams$bayesdata <- NULL

        ## store platforms to ensure same order in application ("have")
        ## NOTE: 'platforms' are just datasets if byPlatform=F
        ComBatWithParams$getPlatforms <- unique(platforms)

        return(ComBatWithParams)

    } else if (params == "have"){
        ## check order of platforms
        if(!(identical(unique(platforms), getPlatforms))) {
            print(unique(platforms))
            print(getPlatforms)
            stop("Batches not in identical order between controls and cases.")
        } else {
            cat("\nBatches identical between have-params and get-params...\n")
        }

        ## use parameters derived from prior
        ## commonGenesCombats is analogous to 'bayesdata' above
        commonGenesCombat <- .ComBatApplyParamsNoCov(commonGenes,
                                                     batch = platforms,
                                                     bayesParams = bayesParams)

        ## split common matrix back out into list
        GSE.list.genes <- lapply(GSE.list.genes, function(GSE) {
            GSE$genes <- data.frame(commonGenesCombat[, colnames(GSE$genes)])
            return(GSE)
        })

        return(GSE.list.genes)
    }
}



.ComBatGetParamsNoCov <- function (dat, batch, par.prior = TRUE, itConv=1e-04,
                                   parallel=FALSE, mc.cores=1) {

    ## slightly modified from sva::ComBat
    ## no covariates allowed

    batch <- as.factor(batch)
    design <-  stats::model.matrix(~-1 + batch)
    cat("Found", nlevels(batch), "batches\n")
    n.batch <- nlevels(batch)
    batches <- lapply(1:n.batch, function(i) which(batch == levels(batch)[i]))
    n.batches <- sapply(batches, length)
    n.array <- sum(n.batches)

    NAs = any(is.na(dat))
    stopifnot(!NAs)

    cat("Standardizing Data across genes\n")
    B.hat <- solve(t(design) %*% design) %*% t(design) %*% t(as.matrix(dat))
    grand.mean <- t(n.batches/n.array) %*% B.hat[1:n.batch,]
    
    dat <- as.matrix(dat)
    var.pooled <- ((dat - t(design %*% B.hat))^2) %*% rep(1/n.array,  n.array)

    stand.mean <- t(grand.mean) %*% t(rep(1, n.array))

    if (!is.null(design)) {
        tmp <- design
        tmp[, c(1:n.batch)] <- 0
        stand.mean <- stand.mean + t(tmp %*% B.hat)
    }
    s.data <- (dat - stand.mean)/(sqrt(var.pooled) %*% t(rep(1, n.array)))

    cat("Fitting L/S model and finding priors\n")
    batch.design <- design[, 1:n.batch]

    gamma.hat <- solve(t(batch.design) %*% batch.design) %*%
        t(batch.design) %*% t(as.matrix(s.data))

    delta.hat <- NULL
    for (i in batches) {
        delta.hat <- rbind(delta.hat, apply(s.data[, i], 1, stats::var, na.rm = T))
    }
    ## switch to rowMeans
    gamma.bar <- rowMeans(gamma.hat)
    t2 <- apply(gamma.hat, 1, stats::var)


    ### same as sva:::aprior
    a.prior <- apply(delta.hat, 1, function(d.hat) {
        m = mean(d.hat)
        s2 = stats::var(d.hat)
        (2 * s2 + m^2)/s2
    })

    ### same as sva:::bprior
    b.prior <- apply(delta.hat, 1, function(d.hat){
        m = mean(d.hat)
        s2 = stats::var(d.hat)
        (m * s2 + m^3)/s2
    })

    #############    added parallel functionality here    ##################
    if(parallel) {
        cat("parallelized, running on ", mc.cores, "cores\n")
        if (par.prior) {
            cat("Finding parametric adjustments\n")
            gd.star <- parallel::mclapply(1:n.batch,
                                          mc.cores=mc.cores,
                                          function(i) {
                temp <- .sva.it.sol(s.data[, batches[[i]]],
                                    gamma.hat[i,],
                                    delta.hat[i, ],
                                    gamma.bar[i],
                                    t2[i],
                                    a.prior[i],
                                    b.prior[i],
                                    conv=itConv)
                list(g.star = temp[1, ], d.star = temp[2, ])
            })
            gamma.star <- Reduce(rbind, lapply(gd.star, function(i) i$g.star))
            delta.star <- Reduce(rbind, lapply(gd.star, function(i) i$d.star))

        } else {
            cat("Finding nonparametric adjustments\n")
            gd.star <- parallel::mclapply(1:n.batch,
                              mc.cores=mc.cores,
                              mc.allow.recursive=FALSE,
                              function(i) {
                              temp <- .sva.int.eprior(as.matrix(s.data[, batches[[i]]]),
                                                      gamma.hat[i, ],
                                                      delta.hat[i, ],
                                                      parallel=parallel,
                                                      mc.cores=mc.cores)
                              cat("batch ", i, "done...\n")
                              list(g.star = temp[1, ], d.star = temp[2, ])
                          })
            gamma.star <- Reduce(rbind, lapply(gd.star, function(i) i$g.star))
            delta.star <- Reduce(rbind, lapply(gd.star, function(i) i$d.star))
        }
    } else {
    ######  original non-parallel; converted to lapply from for loops ######
        if (par.prior) {
            cat("Finding parametric adjustments\n")
            gd.star <- lapply(1:n.batch, function(i) {
                temp <- .sva.it.sol(s.data[, batches[[i]]],
                                    gamma.hat[i,],
                                    delta.hat[i, ],
                                    gamma.bar[i],
                                    t2[i],
                                    a.prior[i],
                                    b.prior[i],
                                    conv=itConv)
                list(g.star = temp[1, ], d.star = temp[2, ])
            })
            gamma.star <- Reduce(rbind, lapply(gd.star, function(i) i$g.star))
            delta.star <- Reduce(rbind, lapply(gd.star, function(i) i$d.star))

        } else {
            cat("Finding nonparametric adjustments for each batch\n")
            gd.star <- lapply(1:n.batch, function(i) {
                temp <- .sva.int.eprior(as.matrix(s.data[, batches[[i]]]),
                                        gamma.hat[i, ], delta.hat[i, ])
                cat("batch ", i, "done...\n")
                list(g.star = temp[1, ], d.star = temp[2, ])
            })
            gamma.star <- Reduce(rbind, lapply(gd.star, function(i) i$g.star))
            delta.star <- Reduce(rbind, lapply(gd.star, function(i) i$d.star))
        }
    }

    cat("Adjusting the Data\n")
    bayesdata <- s.data
    j <- 1
    for (i in batches) {
        bayesdata[, i] <- (bayesdata[, i] - t(batch.design[i,] %*% gamma.star)) /
            (sqrt(delta.star[j, ]) %*% t(rep(1, n.batches[j])))
        j <- j + 1
    }
    bayesdata <- (bayesdata * (sqrt(var.pooled) %*% t(rep(1, n.array)))) + stand.mean

    bayesParams <- list(B.hat=B.hat,
                        stand.mean=stand.mean,
                        var.pooled=var.pooled,
                        gamma.star=gamma.star,
                        delta.star=delta.star)

    return(list(bayesdata=bayesdata,
                bayesParams=bayesParams))
}


.ComBatApplyParamsNoCov <- function (dat, batch, bayesParams) {
    ## slightly modified from sva::ComBat
    ## no covariates allowed

    batch <- as.factor(batch)
    design <-  stats::model.matrix(~-1 + batch)
    cat("Found", nlevels(batch), "batches\n")
    n.batch <- nlevels(batch)
    batches <- lapply(1:n.batch, function(i) which(batch == levels(batch)[i]))
    n.batches <- sapply(batches, length)
    n.array <- sum(n.batches)

    NAs = any(is.na(dat))
    stopifnot(!NAs)

    ## use params from control patients
    gamma.star <- bayesParams$gamma.star
    delta.star <- bayesParams$delta.star
    ## B.hat <- bayesParams$B.hat
    stand.mean <- bayesParams$stand.mean
    var.pooled <- bayesParams$var.pooled

    cat("Standardizing Data across genes using prior parameters\n")
    # B.hat <- solve(t(design) %*% design) %*% t(design) %*% t(as.matrix(dat))
    # grand.mean <- t(n.batches/n.array) %*% B.hat[1:n.batch,]
    #
    # var.pooled <- ((dat - t(design %*% B.hat))^2) %*% rep(1/n.array,  n.array)
    #
    # stand.mean <- t(grand.mean) %*% t(rep(1, n.array))
    #
    # if (!is.null(design)) {
    #       tmp <- design
    #       tmp[, c(1:n.batch)] <- 0
    #       stand.mean <- stand.mean + t(tmp %*% B.hat)
    # }


    ## stand.mean cols are identical;
    ## if supplied from 'bayesParams' add enough to match dat
    # stand.mean <-  Reduce(cbind, lapply(1:ncol(dat), function(x) stand.mean[,1]))
    geneNames <- rownames(stand.mean)
    stand.mean <-  matrix(data=stand.mean[,1], nrow=nrow(stand.mean), ncol=ncol(dat))
    rownames(stand.mean) <- geneNames 
    
    ## s.data is Z\sub_ijg
    s.data <- (dat - stand.mean)/(sqrt(var.pooled) %*% t(rep(1, n.array)))

    batch.design <- design[, 1:n.batch]

    cat("Adjusting the Data Based on input gamma.star and delta.star\n")
    bayesdata <- s.data
    j <- 1
    for (i in batches) {
        bayesdata[, i] <- (bayesdata[, i] - t(batch.design[i,] %*% gamma.star)) /
            (sqrt(delta.star[j, ]) %*% t(rep(1, n.batches[j])))
        j <- j + 1
    }
    bayesdata <- (bayesdata * (sqrt(var.pooled) %*% t(rep(1, n.array)))) + stand.mean

    return(bayesdata)
}




.sva.it.sol <- function (sdat, g.hat, d.hat, g.bar, t2, a, b, conv = 1e-04) {
    ## taken from sva:::it.sol

    ## switch to rowSums
    n <- rowSums(!is.na(sdat))
    g.old <- g.hat
    d.old <- d.hat
    change <- 1
    count <- 0

    .sva.postmean <- function (g.hat, g.bar, n, d.star, t2) {
        (t2 * n * g.hat + d.star * g.bar)/(t2 * n + d.star)
    }

    .sva.postvar <- function (sum2, n, a, b) {
        (0.5 * sum2 + b)/(n/2 + a - 1)
    }

    while (change > conv) {
        g.new <- .sva.postmean(g.hat, g.bar, n, d.old, t2)
        sum2 <- rowSums((sdat - g.new %*% t(rep(1, ncol(sdat))))^2, na.rm = T)
        d.new <- .sva.postvar(sum2, n, a, b)
        change <- max(abs(g.new - g.old)/g.old, abs(d.new - d.old)/d.old)
        g.old <- g.new
        d.old <- d.new
        count <- count + 1
    }
    adjust <- rbind(g.new, d.new)
    rownames(adjust) <- c("g.star", "d.star")
    adjust
}



.sva.int.eprior <- function (sdat, g.hat, d.hat, parallel=FALSE, mc.cores=1) {
    ## modified from sva:::int.eprior
    ## added parallel

    g.star <- d.star <- NULL
    r <- nrow(sdat)
    if(parallel) {
        tmp <- parallel::mclapply(1:r, mc.cores=mc.cores, function(i) {
            g <- g.hat[-i]
            d <- d.hat[-i]
            x <- sdat[i, !is.na(sdat[i, ])]
            n <- length(x)
            j <- numeric(n) + 1
            dat <- matrix(as.numeric(x), length(g), n, byrow = T)
            resid2 <- (dat - g)^2
            sum2 <- resid2 %*% j
            LH <- 1/(2 * pi * d)^(n/2) * exp(-sum2/(2 * d))
            LH[LH == "NaN"] = 0
            c(g.star = sum(g * LH)/sum(LH),
              d.star = sum(d * LH)/sum(LH) )
        })
    } else {
        tmp <- lapply(1:r, function(i) {
            g <- g.hat[-i]
            d <- d.hat[-i]
            x <- sdat[i, !is.na(sdat[i, ])]
            n <- length(x)
            j <- numeric(n) + 1
            dat <- matrix(as.numeric(x), length(g), n, byrow = T)
            resid2 <- (dat - g)^2
            sum2 <- resid2 %*% j
            LH <- 1/(2 * pi * d)^(n/2) * exp(-sum2/(2 * d))
            LH[LH == "NaN"] = 0
            c(g.star = sum(g * LH)/sum(LH),
              d.star = sum(d * LH)/sum(LH) )
        })
    }
    adjust <- data.matrix(data.frame(tmp))
    colnames(tmp) <- NULL
    adjust
}

