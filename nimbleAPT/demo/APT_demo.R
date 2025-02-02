##################################################################################################################
## This script provides a rather contrived toy example designed to exhibit poor MCMC mixing with standard samplers
## Data is simulate with a simple "right" model.
## Parameters are then estimated for a "wrong" model, which resembles a misspecified mixture model.
##################################################################################################################

library(coda)
library(nimbleAPT)

## usePackage <- TRUE ## FALSE
## if (usePackage) {
##     ## THIS FAILS
##     ## library(nimble)
##     ## library(nimbleAPT)
##     print(search()) ## [1] ".GlobalEnv" "package:coda" "package:nimble" "ESSR"  "package:stats" "package:graphics" "package:grDevices" "package:utils" "package:datasets" "package:methods" "Autoloads" "package:base"
##     print(environment())
##     print(environment(buildMCMC)) ## <environment: 0x89a4f50>
##     print(environment(buildAPT))  ## <environment: 0x5ba1398>
## } else {
##     ## THIS WORKS
##     ## library(nimble)
##     packDir <- find.package("nimbleAPT")
##     source(paste0(packDir, "/APT_functions.R"))
##     source(paste0(packDir, "/APT_samplers.R"))
##     source(paste0(packDir, "/APT_build.R"))
##     print(search()) ## [1] ".GlobalEnv" "package:coda" "package:nimble" "ESSR"  "package:stats" "package:graphics" "package:grDevices" "package:utils" "package:datasets" "package:methods" "Autoloads" "package:base"
##     print(environment())
##     print(environment(buildMCMC)) ## <environment: 0x89a4f50>
##     print(environment(buildAPT))  ## <environment: 0x5ba1398>
## }



#############################
## Set up graphics devices ##
#############################
graphics.off(); X11(w=5,h=5); X11(w=5,h=5); X11(w=5,h=5); X11(w=5,h=5)

####################
## Some Functions ##
####################
k2theta <- nimbleFunction(
    run = function(k = double(),              ## A categorical random variable in continuous form.
                   K = double(),              ## Upper limit of k.
                   randomEffects = double(1), ## A set of "randomEffects" which will be fixed during MCMC in order to generate poor mixing
                   theta0=double()            ## An intercept term
                   ) {
        ## Uses a categorical rv to apply a shift in the value of a parameter theta
        k <- ceiling(k)
        if (k < 1 | k > K)
            return(-Inf)
        theta <- theta0 + randomEffects[k]
        return(theta)
        returnType(double())
    }
)
## k2theta(k=wrong$k, K=K, randomEffects=wrong$rfx_theta, theta0=wrong$theta0)
## ck2theta <- compileNimble(k2theta)
## ck2theta(k=wrong$k, K=K, randomEffects=wrong$rfx_theta, theta0=wrong$theta0)

k2sigma <- nimbleFunction(
    run = function(k = double(), K = double(), randomEffects = double(1), sigma0=double()) {
        ## Uses a categorical rv to determine a change in a standard deviation parameter theta
        k <- ceiling(k)
        if (k < 1 | k > K)
            return(-Inf)
        sigma <- abs(sigma0 + randomEffects[k])
        return(sigma)
        returnType(double())
    }
)
## k2sigma(k=wrong$k, K=K, randomEffects=wrong$rfx_sigma, sigma0=wrong$sigma0)
## ck2sigma <- compileNimble(k2sigma)
## ck2sigma(k=wrong$k, K=K, randomEffects=wrong$rfx_sigma, sigma0=wrong$sigma0)

##################################
## BUGS code for the 'right' model
##################################
rightCode <- nimbleCode({
    theta ~ dnorm(0, sd=1E6)
    for (i in 1:N)
        y[i] ~ dnorm(mean=theta, sd=sigma0)
})
##################################
## BUGS code for the 'wrong' model
##################################
wrongCode <- nimbleCode({
    k      ~ dcat(pk[1:K])
    theta0 ~ dnorm(0, sd=1E6)
    theta <- k2theta(k, K, rfx_theta[1:K], theta0)
    sigma0 ~ dexp(1)
    sigma <- abs(k2sigma(k, K, rfx_sigma[1:K], sigma0))
    for (i in 1:N)
        y[i] ~ dnorm(mean=theta, sd=sigma)
})


##############################################
## Parameters, constants and initial values ##
##############################################
N         <- 50  ## low N => MCMC jumps between modes easily, high N => MCMC never jumps between modes, intermediate N => MCMC occasionally jumps between modes.
theta0    <- 0
sigma0    <- 1
K         <- 10
pk        <- rep(1/K, K)
rfx_theta <- rnorm(K)
rfx_sigma <- rnorm(K)
##
rConstants <- list(N=N, pk=pk, sigma0=sigma0)
rInits     <- list(theta=theta0)
##
wConstants <- list(N=N, K=K)
wInits     <- list(theta0=theta0, sigma0=sigma0, rfx_theta=rfx_theta, rfx_sigma=rfx_sigma, k=1, pk=pk)

###########################
## Initialise the models ##
###########################
right <- nimbleModel(rightCode, constants=rConstants, inits=rInits)
wrong <- nimbleModel(wrongCode, constants=wConstants, inits=wInits)

#############################################
## Simulate data but not the stochastic nodes
#############################################
set.seed(11)
right$simulate('y')
wrong$simulate(wrong$getDependencies(c('theta0','sigma0'), self=FALSE), includeData = TRUE)
par(mfrow=n2mfrow(2))
hist(right$y, breaks=N, main="right model", xlab="y")
hist(wrong$y, breaks=N, main="wrong model", xlab="y") ## Different to the hist(right$y)

#####################################################
## Transfer data simulated with 'right' to 'wrong' ##
#####################################################
Data    <- list(y=right$y)
wrong   <- nimbleModel(wrongCode, constants=wConstants, inits=wInits, data=Data) ## For standard MCMC samplers
wrong2  <- nimbleModel(wrongCode, constants=wConstants, inits=wInits, data=Data) ## For APT samplers
par(mfrow=n2mfrow(2))
hist(right$y, breaks=N, main="right model", xlab="y")
hist(wrong$y, breaks=N, main="wrong model", xlab="y") ## Identical to the previous hist(right$y)
wrong$calculate()  ## Total logProb of wrong
wrong2$calculate() ## Total logProb of wrong2

#########################
## Compile wrong model ##
#########################
cWrong  <- compileNimble(wrong)
cWrong2 <- compileNimble(wrong2)

###################################
## Setup MCMC samplers for wrong ##
###################################
nimCopy(wrong, cWrong, logProb=TRUE)
mcmc <- configureMCMC(wrong, print=TRUE)
mcmc$removeSamplers()
mcmc$addSampler("theta0", type="sampler_RW")
mcmc$addSampler("sigma0", type="sampler_RW")
mcmc$addSampler("k",      type="sampler_slice")
mcmc$addSampler(c("theta0","sigma0"), type="sampler_RW_block")
mcmc$printSamplers()
## Add monitors for logProbs
(allLogProbs <- wrong$getVarNames(TRUE)[grep("logProb", wrong$getVarNames(TRUE))])
mcmc$addMonitors2(allLogProbs)
mcmc$getMonitors()
mcmc$getMonitors2()

print(mcmc)

###################################
## Setup APT samplers for wrong2 ##
###################################
nimCopy(wrong, cWrong2, logProb=TRUE)
apt <- configureMCMC(wrong2, print=TRUE)
apt$removeSamplers()
apt$addSampler("theta0", type="sampler_RW_tempered", control=list(temperPriors=TRUE))
apt$addSampler("sigma0", type="sampler_RW_tempered", control=list(temperPriors=TRUE))
apt$addSampler("k",      type="sampler_slice_tempered", control=list(temperPriors=TRUE))
apt$addSampler(c("theta0","sigma0"), type="sampler_RW_block_tempered", control=list(temperPriors=TRUE))
apt$printSamplers()
## Add monitors for logProbs
(allLogProbs <- wrong2$getVarNames(TRUE)[grep("logProb", wrong2$getVarNames(TRUE))])
apt$addMonitors2(allLogProbs)
apt$getMonitors()
apt$getMonitors2()

#################################################
## Build and compile the MCMC & APT algorithms ##
#################################################
MCMC  <- buildMCMC(mcmc)
cMCMC <- compileNimble(MCMC)
## undebug(buildAPT)
APT   <- buildAPT(apt, Temps=1:7, monitorTmax=TRUE)
cAPT  <- compileNimble(APT)

###############
## MCMC in C ##
###############
nIter   <- 1E5
cMCMC$run(nIter)
samples  <- as.matrix(cMCMC$mvSamples)
codaMCMC <- as.mcmc(samples)
## Plot 1: trajectories
plot(codaMCMC)                               ## Trajectories display the expected poor mixing - particularly in k
(ess <- sort(effectiveSize(codaMCMC)))       ## Effective sample size is very low
(suggestedThinning <- round(nIter/min(ess))) ## Thinning would need to be at least this high
## Plot 2: autocorrelation
dev.set()
autocorr.plot(codaMCMC)
## Plot 3: sigma0~theta0
dev.set()
par(mfrow=c(1,1))
plot(samples[,"theta0"],samples[,"sigma0"], xlab="theta0", ylab="sigma0")

##############
## APT in C ##
##############
nIter   <- 1E5
cAPT$thinPrintTemps <- floor(nIter/10)             ## Limits printing temperature ladder to 10 lines
cAPT$run(nIter, printTemps=TRUE, progressBar=FALSE)
samples <- as.matrix(cAPT$mvSamples)
codaAPT <- as.mcmc(samples)

## Plot 1: trajectories
dev.set()
plot(codaAPT)                                ## Trajectories display improved mixing - but could be better
## Plot 2: autocorrelation
dev.set()
(ess <- sort(effectiveSize(codaAPT)))        ## Effective sample size is higher
(suggestedThinning <- round(nIter/min(ess))) ## Thinning can be lower
autocorr.plot(codaAPT)
## Plot 3: sigma0~theta0
dev.set()
par(mfrow=c(1,1))
plot(samples[,"theta0"],samples[,"sigma0"], xlab="theta0", ylab="sigma0")
## Plot 4: temperature ladder trajectories
dev.set()
plotTempTraj(cAPT)


##################################################################################################
## In practice we often                                                                         ##
## 1) do not have good starting values, and                                                     ##
## 2) can't know (a priori) how long a sampler needs to reach likely regions of parameter space ##
## Moreover,                                                                                    ##
## 3) Feedback between adaptive MH and APT can sometimes generate surprising dynamics           ##
## So we should turn off adaption once the sampler is in the right region                       ##
## To test for this we can use a series of short runs                                           ##
## Finally,                                                                                     ##
## 4) It can also be hard to know a priori what is a good thinning value                        ##
## Here effective sample size calculated from the pre-runs can help                             ##
##################################################################################################

## Reinitialise wrong2 with some wild values
samplesTmax <- as.matrix(cAPT$mvSamplesTmax)
init <- samplesTmax[samplesTmax[,"theta0"]==max(samplesTmax[,"theta0"]),]
cWrong2$k      <- init["k"]
cWrong2$theta0 <- init["theta0"]
cWrong2$sigma0 <- init["sigma0"]
cWrong2$simulate(cWrong2$getDependencies(c("k","theta0","sigma0"), includeData=FALSE, self=FALSE))

## Rebuild APT with longer temperature ladder
APT  <- buildAPT(apt, Temps=1:11, monitorTmax=TRUE)
cAPT <- compileNimble(APT)

print("#########################")
print("Starting adaptive burn-in")
print("#########################")
##
THIN       <- 1
cAPT$thin  <- THIN
cAPT$thin2 <- THIN
TuneTemper <- c(1, 1)  ## default value is c(10,1)
meanL      <- cWrong2$calculate()
meanL_previous <- -Inf
ii             <- 0
while(ii==0 | meanL > meanL_previous + 2) {
    ii <- ii+1
    meanL_previous <- meanL
    print(paste0("iteration nb.", ii, "within while loop. meanL = ", meanL_previous))
    ##############################################################################################
    ## Short run 1 - don't increase the flexibility of the AMH samplers & adapt temperature ladder
    nIter <- 5E4
    cAPT$thinPrintTemps <- round(nIter / 10) ## Ensures temps are only printed 10 times
    syst2 <- system.time(cAPT$run(nIter,
                                  reset          = FALSE, ## Do not reset the adaptive MCMC, let adaptation continue as it is
                                  adaptTemps     = TRUE,  ## Allows temperature ladder to adjust
                                  resetTempering = FALSE, ## Keeps the adjustments modest so avoids volatile behaviour. Setting to TRUE can make the temperature ladder make vary large changes
                                  printTemps     = TRUE,  ## Prevents verbose printing of temperature ladder updates
                                  progressBar    = FALSE,
                                  tuneTemper1=TuneTemper[1], tuneTemper2=TuneTemper[2]))
    nimPrint("While loop: 2nd short run finished. sysT = ", syst2[3])
    samples   <- tail(as.matrix(cAPT$mvSamples), floor(nIter/THIN))
    ## Plot 1: temperature ladder trajectories
    dev.set()
    plotTempTraj(cAPT)
    ## Plot 2: sigma0~theta0
    dev.set()
    par(mfrow=c(1,1))
    plot(samples[,"theta0"],samples[,"sigma0"], xlab="theta0", ylab="sigma0")
    ##################################################################################################
    ## Short run 2 - reset the flexibility of the AMH samplers & prevent temperature ladder adaptation
    nIter <- 5E4; cAPT$thinPrintTemps <- nIter / 10
    syst1 <- system.time(cAPT$run(nIter,
                                  reset          = TRUE,  ## Resets the adaptive MCMC. Let's proposal distributions change direction if required.
                                  adaptTemps     = FALSE, ## Prevents temperature ladder adaptation (to avoid volatile behaviour when counter is reset)
                                  resetTempering = TRUE,  ## Resets counter used in temperature ladder adaptation. i.e. counter will be at nIter when adaptation is turned on in step 1
                                  printTemps     = FALSE, ## Will print once only
                                  progressBar    = TRUE,
                                  tuneTemper1=TuneTemper[1], tuneTemper2=TuneTemper[2]))
    ## Update meanL
    nimPrint("While loop: 1st short run finished. sysT = ", syst1[3])
    ## Update meanL
    samples2 <- tail(as.matrix(cAPT$mvSamples2), floor(nIter/THIN)) ## LogProbs
    meanL    <- mean(rowSums(samples2))
    nimPrint("meanL = ", meanL)
    ## Calculate & print ESS
    samples   <- tail(as.matrix(cAPT$mvSamples), floor(nIter/THIN)) ## Sampled parameters T=1
    mc        <- as.mcmc(samples)
    ESS       <- sort(effectiveSize(mc))
    (suggestedThinning <- round(nIter/min(ESS)))
    nimPrint("ESS = ", ESS[1])
    ## Plot 3: trajectories
    dev.set()
    plot(mc)
}

print("#####################################")
print("Parallel tempering without adaptation")
print("#####################################")
nIter <- 1E4 * suggestedThinning
cAPT$thin <- cAPT$thin2 <- suggestedThinning
syst2 <- system.time(cAPT$run(nIter,
                              reset          = FALSE,
                              adaptTemps     = FALSE,
                              resetTempering = FALSE,
                              printTemps     = FALSE,
                              progressBar    = TRUE))
nimPrint("While loop: 2nd short run finished. sysT = ", syst2[3])
samples <- tail(as.matrix(cAPT$mvSamples), floor(nIter/suggestedThinning))
codaAPT <- as.mcmc(samples)

## Plot 1: trajectories
dev.set()
plot(codaAPT)                  ## Trajectories display good mixing
## Plot 2: autocorrelation
dev.set()
autocorr.plot(codaAPT)
## Plot 3: sigma0~theta0
dev.set()
par(mfrow=c(1,1))
plot(samples[,"theta0"],samples[,"sigma0"], xlab="theta0", ylab="sigma0")
## Plot 4: temperature ladder trajectories
dev.set()
plotTempTraj(cAPT)

(effectiveSize(codaAPT)) ## Much healthier!
