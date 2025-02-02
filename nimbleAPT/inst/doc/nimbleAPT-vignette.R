## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----model, fig.width=7, fig.height=7-----------------------------------------
library(nimbleAPT) # Also loads nimble

bugsCode <- nimbleCode({
    for (ii in 1:nObs) {
        y[ii,1:2] ~ dmnorm(mean=absCentroids[1:2], cholesky=cholCov[1:2,1:2], prec_param=0)
    }
    absCentroids[1:2] <- abs(centroids[1:2])
    for (ii in 1:2) {
        centroids[ii] ~ dnorm(0, sd=1E3)
    }
})

nObs      <- 100
centroids <- rep(-3, 2)
covChol   <- chol(diag(2))

rModel <- nimbleModel(bugsCode,
                      constants=list(nObs=nObs, cholCov=covChol),
                      inits=list(centroids=centroids))

## ----sim, fig.width=7, fig.height=7-------------------------------------------
simulate(rModel, "y") ## Use model to simulate data

rModel <- nimbleModel(bugsCode,
                      constants=list(nObs=nObs, cholCov=covChol),
                      data=list(y=rModel$y),
                      inits=list(centroids=centroids))

cModel <- compileNimble(rModel)

plot(cModel$y, typ="p", xlab="", ylab="", xlim=c(-1,1)*max(cModel$y), ylim=c(-1,1)*max(cModel$y), pch=4)
points(x=cModel$centroids[1], y=cModel$centroids[1], col="red", pch=4, cex=3)
points(x=-cModel$centroids[1], y=cModel$centroids[1], col="red", pch=4, cex=3)
points(x=cModel$centroids[1], y=-cModel$centroids[1], col="red", pch=4, cex=3)
points(x=-cModel$centroids[1], y=-cModel$centroids[1], col="red", pch=4, cex=3)
legend("topleft", c("posterior modes", "data"), col=c("red","black"), pch=4, cex=2)


## ----fitting1, fig.width=7, fig.height=7--------------------------------------

simulate(cModel, "centroids")
mcmcR <- buildMCMC(configureMCMC(cModel, nodes="centroids", monitors="centroids"), print=TRUE)

mcmcC <- compileNimble(mcmcR)

mcmcC$run(niter=15000)

samples <- tail(as.matrix(mcmcC$mvSamples), 10000)
summary(samples)

plot(samples, xlab="", ylab="", typ="l", xlim=c(-1,1)*max(cModel$y), ylim=c(-1,1)*max(cModel$y))
points(x=cModel$centroids[1], y=cModel$centroids[1], col="red", pch=4, cex=3)
points(x=-cModel$centroids[1], y=cModel$centroids[1], col="red", pch=4, cex=3)
points(x=cModel$centroids[1], y=-cModel$centroids[1], col="red", pch=4, cex=3)
points(x=-cModel$centroids[1], y=-cModel$centroids[1], col="red", pch=4, cex=3)
legend("topleft", legend=c("posterior modes","jumps"), col=c("red","black"), pch=c("X","_"), bg="white")

library(coda)      # Loads coda
plot(as.mcmc(samples))

## ----fitting2, fig.width=7, fig.height=7--------------------------------------

conf <- configureMCMC(cModel, nodes="centroids", monitors="centroids", enableWAIC = TRUE)
conf$removeSamplers()
conf$addSampler("centroids[1]", type="sampler_RW_tempered", control=list(temperPriors=TRUE))
conf$addSampler("centroids[2]", type="sampler_RW_tempered", control=list(temperPriors=TRUE))
conf

aptR <- buildAPT(conf, Temps=1:5, ULT= 1000, print=TRUE)

aptC <- compileNimble(aptR)

aptC$run(niter=15000)

samples <- tail(as.matrix(aptC$mvSamples), 10000)
summary(samples)

plot(samples, xlab="", ylab="", typ="l", xlim=c(-1,1)*max(cModel$y), ylim=c(-1,1)*max(cModel$y))
points(samples, col="red", pch=19, cex=0.1)
legend("topleft", legend=c("jumps", "samples"), col=c("black","red"), pch=c("_","X"), bg="white")

plot(as.mcmc(samples))

plot(as.mcmc(aptC$logProbs))

aptC$calculateWAIC()



