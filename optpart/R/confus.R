confus <- function (clustering, model, diss=NULL)
{
    clustering <- clustify(clustering)

    if (inherits(model,'tree')) {
        fitted <- predict(model)
    } else if (inherits(model,'randomForestest')) {
        fitted <- predict(model,type='prob')
    } else if (inherits(model,'matrix')) {
        fitted <- model
    }
    numplt <- length(clustering)
    numclu <- length(levels(clustering))
    pred <- apply(fitted,1,which.max)
    res <- matrix(0,nrow=numclu,ncol=numclu)
    for (i in 1:numplt) {
        res[clustering[i],pred[i]] <- res[clustering[i],pred[i]] + 1
    }

    if(!is.null(diss)) {
        part <- partana(clustering,diss)
        shunt <- diag(part$ctc)
        shunt[shunt==0] <- 1
        tmp <- part$ctc/shunt
        fuzerr <-  1- matrix(pmin(1,tmp),ncol=ncol(tmp))
        diag(fuzerr) <- 1
        fuzres <- res
    
        for (i in 1:ncol(res)) {
            for (j in 1:ncol(res)) {
                if (i != j) {
                    fuzres[i,j] <- res[i,j] * fuzerr[i,j]
                    fuzres[i,i] <- fuzres[i,i] + res[i,j] * (1-fuzerr[i,j])
                }
            }
        }
        res <- fuzres
    }
 
    correct <- sum(diag(res))
    percent <- correct/numplt
    rowsum <- apply(res,1,sum)
    colsum <- apply(res,2,sum)
    summar <- sum(rowsum*colsum)
    kappa <- ((numplt*correct) - summar) / (numplt^2 - summar)
    out <- list(confus=res,correct=correct,percent=percent,kappa=kappa)
    out
}

