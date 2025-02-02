####################################################################
### Virtual nimbleFunction template, included for ALL samplers #####
####################################################################

globalVariables(c("sampler_APT"))
Sys.setenv(R_CHECK_SYSTEM_CLOCK = FALSE) ## Sys.getenv("R_CHECK_SYSTEM_CLOCK", unset = NA)


#' A virtual function to use as a contains argument when writing APT samplers
#'
#' Modified from NIMBLE's samplers_BASE to include a setTemp method
#'
#' Set up functions for this class should include the following arguments
#'
#' @param model name of model to be sampled
#' @param mvSaved model values object to use when sampling
#' @param target nodes to be targeted by sampler
#' @param control other control parameters
#'
#' @details APT samplers must include "contains = sampler_APT" and include a setTemp method
#'
#' @rdname samplers
#' @import nimble
#' @import methods
#' @export
sampler_APT <- nimbleFunctionVirtual(
    ## run = function(temperture=double(0, default=1)) {},
    name = 'sampler_APT',
    methods = list(
        setTemp = function(temp = double()) {},
        ## turnOffAdaptation = function() {},
        reset   = function() {}
    )
)

### utils::globalVariables("sampler_APT")


#######################################################################################################################################################
## #' @title Resize a vector.                                                                                                                        ##
## #' @description Returns a resized version of a vector.                                                                                            ##
## #' @param x A vector.                                                                                                                             ##
## #' @param length Desired length of the new vector.                                                                                                ##
## #' @return A vector.                                                                                                                              ##
## #' @details If the new vector is longer, new elements are initialised as zeros. Otherwise, the new vector is a clipped version of the old vector. ##
## #' @author David Pleydell                                                                                                                         ##
## #' @examples                                                                                                                                      ##
## #' resizeVector(1:10, 11)                                                                                                                         ##
## #' resizeVector(1:11, 10)                                                                                                                         ##
## #'                                                                                                                                                ##
## #' @import nimble                                                                                                                                 ##
## #' @name resizeVector                                                                                                                             ##
## #'
## #' @examples                                                                                                                                      ##
## #' x = nimNumeric(length=10)                                                                                                                      ##
## #' x = resizeVector(x, length=11)                                                                                                                 ##
## #' length(x)                                                                                                                                      ##
## resizeVector = nimbleFunction(                                                                                                                    ##
##   run = function(x = double(1), length = double(0)) {                                                                                             ##
##     returnType(double(1))                                                                                                                         ##
##     lengthOri = length(x)                                                                                                                         ##
##     xPrev     = nimNumeric(length=lengthOri, value=x[1:lengthOri])                                                                                ##
##     x         = nimNumeric(length=length, value=0)                                                                                                ##
##     if (lengthOri <= length) {                                                                                                                    ##
##       x[1:lengthOri] = xPrev[1:lengthOri]                                                                                                         ##
##     } else {                                                                                                                                      ##
##       x[1:length] = xPrev[1:length]                                                                                                               ##
##     }                                                                                                                                             ##
##     return(x[])                                                                                                                                   ##
##   }                                                                                                                                               ##
## )                                                                                                                                                 ##
#######################################################################################################################################################




######################################################################################
## buildAPT was adapted from NIMBLE's buildMCMC to provide adaptive parallel tempering
######################################################################################

##' Create an APT function, from an MCMCconf object
##'
##' Adapted from nimble::buildMCMC. Accepts a single required argument, which
##' may be of class MCMCconf, or inherit from class modelBaseClass (a
##' NIMBLE model object).  Returns an APT function; see details
##' section.
##'
##' Calling buildAPT(conf,Temps,monitorTmax,ULT,thinPrintTemps) will
##' produce an uncompiled (R) APT function object, say 'myAPT'.
##'
##' The uncompiled MCMC function will have arguments:
##'
##' \code{niter} The number of iterations to run the MCMC.
##'
##' \code{reset} Boolean specifying whether to reset the internal MCMC
##' sampling algorithms to their initial state (in terms of self-adapting
##' tuning parameters), and begin recording posterior sample chains anew.
##' Specifying \code{reset=FALSE} allows the MCMC algorithm to continue running
##' from where it left off, appending additional posterior samples to the
##' already existing sample chains. Generally, \code{reset=FALSE} should only
##' be used when the MCMC has already been run (default = TRUE).
##'
##' \code{resetMV}: Boolean specifying whether to begin recording posterior sample chains anew. This
##' argument is only considered when using \code{reset = FALSE}.  Specifying \code{reset = FALSE,
##' resetMV = TRUE} allows the MCMC algorithm to continue running from where it left off, but
##' without appending the new posterior samples to the already existing samples, i.e. all previously
##' obtained samples will be erased. This option can help reduce memory usage during burn-in
##' (default = FALSE).
##'
##' \code{resetTempering} Boolean specifying whether to reset the
##' flexibility of the temperature ladder's adaptation process.
##'
##' \code{simulateAll} Boolean specifying whether to simulate into all
##' stochastic nodes.  This will overwrite the current values in all stochastic
##' nodes (default = FALSE).
##'
##' \code{time} Boolean specifying whether to record runtimes of the
##' individual internal MCMC samplers.  When \code{time=TRUE}, a vector of
##' runtimes (measured in seconds) can be extracted from the MCMC using the
##' method \code{mcmc$getTimes()} (default = FALSE).
##'
##' \code{adaptTemps} Boolean specifying whether the temperature
##' ladder will be adapted or not.
##'
##' \code{printTemps} Boolean specifying whether the temperature
##' ladder will be printed during the MCMC. The print frequency is
##' controlled by thinPrintTemps. The output includes (in order):
##' iteration number of current MCMC run;
##' total number of iterations of the tempering scheme - this will include itterations from previous MCMC runs unless resetTempering=TRUE;
##' the number of rows in mvSamples;
##' the number of rows in mvSamples2;
##' the temperature ladder.
##'
##' \code{tuneTemper1} Numeric tuning parameter of the adaptation
##' process of the temperature ladder. See source code for
##' buildAPT. Defaults to 10.
##'
##' \code{tuneTemper2} Numeric tuning parameter of the adaptation
##' process of the temperature ladder. See source code for
##' buildAPT. Defaults to 1.
##'
##' \code{progressBar} Boolean specifying whether to display a progress bar
##' during MCMC execution (default = TRUE).  The progress bar can be
##' permanently disabled by setting the system option
##' \code{nimbleOptions(MCMCprogressBar = FALSE)}.
##'
##' \code{thin} Thinning to be applied to monitor.
##'
##' \code{thin2} Thinning to be applied to monitor2
##'
##' Samples corresponding to the \code{monitors} and \code{monitors2} from the
##' MCMCconf are stored into the interval variables \code{mvSamples} and
##' \code{mvSamples2}, respectively. These may be accessed and converted into R
##' matrix objects via: \code{as.matrix(mcmc$mvSamples)}
##' \code{as.matrix(mcmc$mvSamples2)}
##'
##' The uncompiled (R) MCMC function may be compiled to a compiled MCMC object,
##' taking care to compile in the same project as the R model object, using:
##' \code{Cmcmc <- compileNimble(Rmcmc, project=Rmodel)}
##'
##' The compiled function will function identically to the uncompiled object,
##' except acting on the compiled model object.
##'
##' @param conf An object of class MCMCconf that specifies the model, samplers,
##' monitors, and thinning intervals for the resulting MCMC function.  See
##' \code{configureMCMC} for details of creating MCMCconf objects.
##' Alternatively, \code{MCMCconf} may a NIMBLE model object, in which case an
##' MCMC function corresponding to the default MCMC configuration for this
##' model is returned.
##' @param Temps A numeric vector giving the initial temperature ladder.
##' @param monitorTmax A logical indicator (default = TRUE) controlling if MCMC output should be stored at the hottest rung of the temperature ladder. Useful when monitoring the behaviour of APT. When TRUE mvSamples and mvSamples2 monitor T=1 and mvSamplesTmax and mvSamples2Tmax provide identically defined monitors (i.e. for exactly the same nodes) for T=Tmax.
##' @param ULT A numeric value (default = 1E6) that provides an upper limit to temperature during APT.
##' @param thinPrintTemps A numeric value controlling how often temperatures of the temperature ladder should be printed to screen when runtime parameter printTemps is TRUE. The default value of 1 is often too verbose. A good value to use is niter/10.
##'
##' @param ... Additional arguments to be passed to \code{configureMCMC} if
##' \code{conf} is a NIMBLE model object
## ##' @section Calculating WAIC:
## ##'
## ##' After the MCMC has been run, calling the \code{calculateWAIC()} method of
## ##' the MCMC object will return the WAIC for the model, calculated using the
## ##' posterior samples from the MCMC run.
## ##'
## ##' \code{calculateWAIC()} has a single arugment:
## ##'
## ##' \code{nburnin} The number of iterations to subtract from the beginning of
## ##' the posterior samples of the MCMC object for WAIC calculation.  Defaults to
## ##' 0.
## ##'
## ##' The \code{calculateWAIC} method calculates the WAIC of the model that the
## ##' MCMC was performed on. The WAIC (Watanabe, 2010) is calculated from
## ##' Equations 5, 12, and 13 in Gelman (2014).  Note that the set of all
## ##' parameters monitored by the mcmc object will be treated as \eqn{theta} for
## ##' the purposes of e.g. Equation 5 from Gelman (2014).  All parameters
## ##' downstream of the monitored parameters that are necessary to calculate
## ##' \eqn{p(y|theta)} will be simulated from the posterior samples of
## ##' \eqn{theta}.
##'
##' @author David Pleydell, Daniel Turek
##'
##' @return
##' Calling \code{buildAPT} returns an uncompiled APT function object. This is very similar to how NIMBLE's \code{buildMCMC} function returns an uncompiled MCMC function object. See \code{?buildMCMC}. Users should be familiar with the chapter 'MCMC' of the NIMBLE manual.
##'
##' @name buildAPT
##'
##' @examples
##'
##' ## See the nimbleAPT vignette for more details.
##' bugsCode <- nimbleCode({
##'   for (ii in 1:nObs) {
##'     y[ii,1:2] ~ dmnorm(mean=absCentroids[1:2], cholesky=cholCov[1:2,1:2], prec_param=0)
##'   }
##'   absCentroids[1:2] <- abs(centroids[1:2])
##'   for (ii in 1:2) {
##'     centroids[ii] ~ dnorm(0, sd=1E3)
##'   }
##' })
##'
##' nObs      <- 100
##' centroids <- rep(-3, 2)
##' covChol   <- chol(diag(2))
##'
##' rModel <- nimbleModel(bugsCode,
##'                       constants=list(nObs=nObs, cholCov=covChol),
##'                       inits=list(centroids=centroids))
##' simulate(rModel, "y")
##' rModel <- nimbleModel(bugsCode,
##'                       constants=list(nObs=nObs, cholCov=covChol),
##'                       data=list(y=rModel$y),
##'                       inits=list(centroids=centroids))
##'
##' conf <- configureMCMC(rModel, nodes="centroids", monitors="centroids", enableWAIC = TRUE)
##' conf$removeSamplers()
##' conf$addSampler("centroids[1]", type="sampler_RW_tempered", control=list(temperPriors=TRUE))
##' conf$addSampler("centroids[2]", type="sampler_RW_tempered", control=list(temperPriors=TRUE))
##' aptR <- buildAPT(conf, Temps=1:5, ULT= 1000, print=TRUE)
##'
##'
##'
#'
#' @import nimble
#' @export
buildAPT <- nimbleFunction(
    setup = function(conf,                ## As for buildMCMC
                     Temps,               ## Vector of temperatures. Typically, lowest temperature should be 1.
                     monitorTmax=TRUE,    ## Logical. Save MCMC output for Tmax too.
                     ULT=1E6,             ## Scalar, Upper Limit on Temperatures
                     thinPrintTemps=1,    ## Nb. iterations between prints of temps when adaptTemps==TRUE
                     ...) {
        if(inherits(conf, 'modelBaseClass')) {
            conf <- configureMCMC(conf, ...)
        } else if(!inherits(conf, 'MCMCconf')) {
            stop('conf must either be a nimbleModel or a MCMCconf object (created by configureMCMC(...) )')
        }
        if (missing(ULT)) {
            ULT <- 1E6
            message(paste("ULT set to", ULT))
        }
        dotdotdotArgs <- list(...)
        enableWAICargument <- if(!is.null(dotdotdotArgs$enableWAIC)) dotdotdotArgs$enableWAIC else nimbleOptions('MCMCenableWAIC')    ## accept enableWAIC argument regardless
        model              <- conf$model
        my_initializeModel <- initializeModel(model)
        mvSaved            <- modelValues(model)                   ## Used to restore model following rejection in MCMC
        nSamplersPerT      <- length(seq_along(conf$samplerConfs)) ## Nb. samplers / temp'
        samplerFunctions   <- nimbleFunctionList(sampler_APT)
        ## Tempering related objects
        Temps        <- as.numeric(sort(Temps)) ## Ensures compiler knows Temps is not integer
        nTemps       <- length(Temps)           ## Number of temperatures for tempering
        invTemps     <- 1/Temps[1:nTemps]
        TempsCurrent <- Temps[1:nTemps]
        TempsOri     <- Temps[1:nTemps]
        nTemps_1     <- nTemps - 1
        mvTemps      <- modelValues(model, nTemps) ## Stores state of MCMC at each temperature
        tempTraj     <- nimMatrix(0, nrow=1000, ncol=nTemps) ## Stores trajectories of temperatures
        logProbTemps <- numeric(nTemps)
        pSwapMatrix  <- nimMatrix(0, nTemps, nTemps)
        temporary    <- numeric(nTemps)
        accCountSwap <- nimMatrix(0, nTemps, nTemps)
        # nimPrint("Initial temperatures: ", Temps,"\n")
        message(paste("Initial temperatures:", paste(Temps, collapse=" ")))
        ##
        for (tt in 1:nTemps) {
            for(ss in 1:nSamplersPerT) {
                ist <- ss + (tt-1) * nSamplersPerT ## index for Sampler & Temperature
                samplerFunctions[[ist]] <- conf$samplerConfs[[ss]]$buildSampler(model=model, mvSaved=mvSaved)
                samplerFunctions[[ist]]$setTemp(temp=Temps[tt])
            }
        }
        ##
        ## A function to weed out missing indices from the monitors
        processMonitorNames <- function(model, nodes){
            isLogProbName        <- grepl('logProb', nodes)
            expandedNodeNames    <- model$expandNodeNames(nodes[!isLogProbName])
            origLogProbNames     <- nodes[isLogProbName]
            expandedLogProbNames <- character()
            if (length(origLogProbNames) > 0) {
                nodeName_fromLogProbName <- gsub('logProb_', '', origLogProbNames)
                expandedLogProbNames     <- model$modelDef$nodeName2LogProbName(nodeName_fromLogProbName)
            }
            return( c(expandedNodeNames, expandedLogProbNames) )
        }
        ##
        thin              <- conf$thin
        thin2             <- conf$thin2
        mvSamplesConf     <- conf$getMvSamplesConf(1)
        mvSamples2Conf    <- conf$getMvSamplesConf(2)
        monitors          <- processMonitorNames(model, conf$monitors)
        monitors2         <- processMonitorNames(model, conf$monitors2)
        thinFromConfVec   <- c(conf$thin, conf$thin2)  ## vector
        thinToUseVec      <- c(0, 0)                      ## vector, needs to member data
        mvSamples         <- modelValues(mvSamplesConf)   ## For storing MCMC output (T=1)
        mvSamples2        <- modelValues(mvSamples2Conf)  ## For storing MCMC output (T=Tmax)
        logProbs          <- nimNumeric(length=0)
        ##
        if (monitorTmax==TRUE) {
            mvSamplesTmax  <- modelValues(mvSamplesConf)  ## For MCMC output (T=Tmax)
            mvSamples2Tmax <- modelValues(mvSamples2Conf) ## For MCMC output (T=Tmax) too
        }
        samplerTimes      <- c(0,0) ## Establish as a vector
        progressBarLength <- 52     ## Multiples of 4 only
        resetAnyway       <- TRUE
        totalIters        <- 1
        ## WAIC setup:
        dataNodes <- model$getNodeNames(dataOnly = TRUE)
        dataNodeLength <- length(dataNodes)
        sampledNodes <- model$getVarNames(includeLogProb = FALSE, nodes = monitors)
        sampledNodes <- sampledNodes[sampledNodes %in% model$getVarNames(includeLogProb = FALSE)]
        paramDeps <- model$getDependencies(sampledNodes, self = FALSE, downstream = TRUE)
        allVarsIncludingLogProbs <- model$getVarNames(includeLogProb = TRUE)
        enableWAIC <- enableWAICargument || conf$enableWAIC   ## enableWAIC comes from MCMC configuration, or from argument to buildMCMC
        if(enableWAIC) {
            if(dataNodeLength == 0)   stop('WAIC cannot be calculated, as no data nodes were detected in the model.')
            mcmc_checkWAICmonitors(model = model, monitors = sampledNodes, dataNodes = dataNodes)
        }
    },
    #################################################
    run = function(niter          = integer(),
                   reset          = logical(default=TRUE),
                   resetMV        = logical(default = FALSE), ## Allows resetting mvSamples when reset==FALSE
                   resetTempering = logical(default=FALSE),
                   simulateAll    = logical(default=FALSE),
                   time           = logical(default=FALSE),
                   adaptTemps     = logical(default=TRUE),
                   printTemps     = double(default=FALSE),
                   tuneTemper1    = double(default=10),
                   tuneTemper2    = double(default=1),
                   progressBar    = logical(default=TRUE),
                   thin           = integer(default = -1),
                   thin2          = integer(default = -1)) {
        ##
        if(niter < 0)       stop('cannot specify niter < 0')
        thinToUseVec <<- thinFromConfVec
        if(thin  != -1) thinToUseVec[1] <<- thin
        if(thin2 != -1) thinToUseVec[2] <<- thin2
        ##
        if(simulateAll) {
            simulate(model)     ## Default behavior excludes data nodes
        }
        if(resetAnyway==TRUE) { ## Force reset to be TRUE on first usage to avoid segfault.
            reset          <- resetAnyway
            resetTempering <- resetAnyway
            resetAnyway   <<- !reset
            totalIters    <<- 1
        }
        my_initializeModel$run()
        if(resetTempering) {
            totalIters <<- 1
        }
        accCountSwap[,] <<- 0 * accCountSwap[,]
        if(reset) {
            for (tt in 1:nTemps) {
                nimCopy(from = model, to = mvTemps, row = tt, logProb = TRUE)
            }
            for(i in seq_along(samplerFunctions)) {
                samplerFunctions[[i]]$reset()
            }
            mvSamples_offset  <- 0
            mvSamples2_offset <- 0
        } else {
            mvSamples_offset  <- getsize(mvSamples)
            mvSamples2_offset <- getsize(mvSamples2)
            if (resetMV) {
                mvSamples_offset  <- 0
                mvSamples2_offset <- 0
            }
        }
        setSize(tempTraj,  niter/thinToUseVec[1], nTemps)
        resize(mvSamples,  mvSamples_offset  + niter/thinToUseVec[1])
        resize(mvSamples2, mvSamples2_offset + niter/thinToUseVec[2])
        if (monitorTmax==TRUE) {
            resize(mvSamplesTmax,  mvSamples_offset  + niter/thinToUseVec[1])
            resize(mvSamples2Tmax, mvSamples2_offset + niter/thinToUseVec[2])
        }
        logProbs <<- resizeVector(logProbs, mvSamples_offset + niter/thinToUseVec[1])
        ##### Monitors & Progress Bar #####
        if (printTemps == TRUE) {
            progressBar = FALSE
        }
        if(dim(samplerTimes)[1] != length(samplerFunctions))
            setSize(samplerTimes, length(samplerFunctions))
        if(niter < progressBarLength+3)
            progressBar <- progressBar & 0 ## avoids compiler warning
        if(progressBar) {
            for(iPB1 in 1:4) {
                cat('|'); for(iPB2 in 1:(progressBarLength/4)) cat('-')
            }
            nimPrint('|'); cat('|')
        }
        progressBarIncrement <- niter/(progressBarLength+3)
        progressBarNext      <- progressBarIncrement
        progressBarNextFloor <- floor(progressBarNext)
        ##########################
        ######## SAMPLING ########
        for (iter in 1:niter) {
            ## nimPrint(iter)
            checkInterrupt()
            ## ###############################################################
            ## Random Walk & Adaptation Phase:                              ##
            ## i.e. MCMC at each temperature, with or without time tracking ##
            if(time) { ## time == TRUE
                for(tt in 1:nTemps) {
                    ## Copy state of MCMC at temperature tt to model & mvSaved and continue
                    nimCopy(from=mvTemps, to=model,   row=tt,  logProb = TRUE)
                    nimCopy(from=model,   to=mvSaved, rowTo=1, logProb = TRUE)
                    for(ss in 1:nSamplersPerT) {
                        iST <- ss + (tt-1) * nSamplersPerT
                        samplerFunctions[[iST]]$setTemp(temp=Temps[tt])
                        samplerTimes[iST] <<- samplerTimes[iST] +
                            run.time(samplerFunctions[[iST]]$run())
                    }
                    ## Copy state of MCMC at temperature tt back to mvTemps
                    nimCopy(from=model, to=mvTemps, rowTo=tt, logProb = TRUE)
                    logProbTemps[tt] <<- model$getLogProb()
                }
            } else {   ## time == FALSE
                for(tt in 1:nTemps) {
                    ## browser()
                    ## Copy state of MCMC at temperature tt to model & mvSaved and continue
                    nimCopy(from=mvTemps, to=model,   row=tt,  logProb = TRUE)
                    nimCopy(from=model,   to=mvSaved, rowTo=1, logProb = TRUE)
                    for(ss in 1:nSamplersPerT) {
                        iST <- ss + (tt-1) * nSamplersPerT
                        samplerFunctions[[iST]]$setTemp(temp=Temps[tt])
                        samplerFunctions[[iST]]$run()
                    }
                    ## Copy state of MCMC at temperature tt back to mvTemps
                    nimCopy(from=model, to=mvTemps, rowTo=tt, logProb = TRUE)
                    logProbTemps[tt] <<- model$getLogProb()
                }
            }
            ## ################################################
            ## Random Swap Phase: Jumps between temperatures ##
            pSwapCalc() ## Updates pSwapMatrix
            for (ii in 1:nTemps) {
                if (iter %% 2 == 0) {
                    iFrom <- ii
                } else {
                    iFrom <- nTemps + 1 - ii
                }
                iTo   <- rcat(n=1, prob=pSwapMatrix[iFrom, 1:nTemps])
                pProp <- pSwapMatrix[iFrom,iTo]
                pRev  <- pSwapMatrix[iTo,iFrom]
                lMHR  <- (invTemps[iTo]-invTemps[iFrom]) * (logProbTemps[iFrom]-logProbTemps[iTo]) + log(pRev) - log(pProp)
                lu    <- log(runif(1))
                if (lu < lMHR) {
                    ## Swap model values
                    nimCopy(from=mvTemps, to=mvSaved, row=iTo,   rowTo=1,     logProb = TRUE)
                    nimCopy(from=mvTemps, to=mvTemps, row=iFrom, rowTo=iTo,   logProb = TRUE)
                    nimCopy(from=mvSaved, to=mvTemps, row=1,     rowTo=iFrom, logProb = TRUE)
                    ## Swap logProbTemps elements
                    temporary[1]        <<- logProbTemps[iTo]
                    logProbTemps[iTo]   <<- logProbTemps[iFrom]
                    logProbTemps[iFrom] <<- temporary[1]
                    ## Swap rows of pSwapMat
                    temporary[1:nTemps]         <<- pSwapMatrix[iTo,1:nTemps]
                    pSwapMatrix[iTo,1:nTemps]   <<- pSwapMatrix[iFrom,1:nTemps]
                    pSwapMatrix[iFrom,1:nTemps] <<- temporary[1:nTemps]
                    ## Swap cols of pSwapMat
                    temporary[1:nTemps]         <<- pSwapMatrix[1:nTemps,iTo]
                    pSwapMatrix[1:nTemps,iTo]   <<- pSwapMatrix[1:nTemps,iFrom]
                    pSwapMatrix[1:nTemps,iFrom] <<- temporary[1:nTemps]
                    ## Acceptance counter
                    accCountSwap[iFrom, iTo]    <<- accCountSwap[iFrom, iTo] + 1
                }
            }
            ## nimPrint(pSwapMatrix)
            ## nimPrint(Temps, "     ", invTemps)
            ###################################
            ## Temperature adaptation scheme ##
            totalIters <<- totalIters + 1
            if (adaptTemps) {
                ## gammaTSA <- 1 / ((totalIters/thinToUseVec[1] + 3) ^ 0.8)
                gammaTSA    <- 1 / ((totalIters/tuneTemper1 + 3) ^ tuneTemper2)
                TempsCurrent[1:nTemps] <<- Temps
                for (ii in 1:nTemps_1) {
                    accProb          <- min(1, exp( (invTemps[ii+1]-invTemps[ii]) * (logProbTemps[ii]-logProbTemps[ii+1]) ))
                    Temps[ii+1]     <<- Temps[ii] + (TempsCurrent[ii+1] - TempsCurrent[ii]) * exp(gammaTSA*(accProb-0.234))
                    if (Temps[ii+1] > ULT)
                        Temps[ii+1] <<- ULT + ii ## This prevents the temperature ladder from exploding
                }
                for (ii in 1:nTemps_1)
                    invTemps[ii+1]  <<- 1 / Temps[ii+1]
                ## nimPrint("iter: ", iter)
                ## nimPrint("logProbTemps: ", logProbTemps)
                ## nimPrint(accCountSwap)
            }
            ##############################################
            ## Automatically drop unneeded temperatures ##
            ##############################################
            ## Not implimented
            ##
            #################
            ## MCMC Output ##
            #################
            if(iter %% thinToUseVec[1] == 0) {
                nimCopy(from = mvTemps, to = mvSamples, row = 1, rowTo = mvSamples_offset + iter/thinToUseVec[1],  nodes = monitors)
                tempTraj[iter/thinToUseVec[1], 1:nTemps] <<- Temps[1:nTemps]
                logProbs[mvSamples_offset + iter/thinToUseVec[1]] <<- logProbTemps[1]
            }
            if(printTemps == 1.0) {
                if(totalIters %% thinPrintTemps == 1) {
                    ## nimPrint(iter, asRow(Temps))
                    size_mvSamples  <- getsize(mvSamples)
                    size_mvSamples2 <- getsize(mvSamples2)
                    nimPrint(iter, " ", totalIters-1, " ", size_mvSamples, " ", size_mvSamples2, asRow(Temps))
                    if(!adaptTemps) {
                        printTemps <- 0.0
                    }
                }
            }
            if(iter %% thinToUseVec[2] == 0)
                nimCopy(from = mvTemps, to = mvSamples2, row = 1, rowTo = mvSamples2_offset + iter/thinToUseVec[2], nodes = monitors2)
            if (monitorTmax==TRUE) {
                if(iter %% thinToUseVec[1] == 0)
                    nimCopy(from = mvTemps, to = mvSamplesTmax, row = nTemps,
                            rowTo = mvSamples_offset  + iter/thinToUseVec[1],  nodes = monitors)
                if(iter %% thinToUseVec[2] == 0)
                    nimCopy(from = mvTemps, to = mvSamples2Tmax, row = nTemps,
                            rowTo = mvSamples2_offset + iter/thinToUseVec[2], nodes = monitors2)
            }
            ## Progress Bar
            if(progressBar & (iter == progressBarNextFloor)) {
                cat('-')
                progressBarNext <- progressBarNext + progressBarIncrement
                progressBarNextFloor <- floor(progressBarNext)
            }
        }
        if(progressBar) nimPrint('|')
        nimCopy(from = mvTemps, to = model, row = 1, logProb = TRUE) ## Ensures model is parameterised with T=1 samples prior to exiting.
    },
    ## #########################################################
    methods = list(
        getTimes = function() {
            returnType(double(1))
            return(samplerTimes)
        },
        pSwapCalc = function() {
            ## Fill matrix
            for (ii in 2:nTemps) {
                for (jj in 1:(ii-1)) {
                    pSwapMatrix[ii,jj] <<- exp(-abs(logProbTemps[ii] - logProbTemps[jj]))
                    pSwapMatrix[jj,ii] <<- pSwapMatrix[ii,jj]
                }
            }
            ## Normalise rows
            for (ii in 1:nTemps) {
                rowSum <- sum(pSwapMatrix[ii,1:nTemps])
                if(rowSum>0) {
                    for (jj in 1:nTemps)
                        pSwapMatrix[ii,jj] <<- pSwapMatrix[ii,jj] / rowSum
                } else {
                    for (jj in 1:nTemps) {
                        pSwapMatrix[ii,jj] <<- (ii!=jj) / nTemps_1
                    }
                }
            }
        },
        mvTemps2model = function(row = double()) {
            ## Useful in R for exploring node values at each temp
            nimCopy(mvTemps, model, row=row, logProb=TRUE)
        },
        resizeVector = function(x = double(1), length = double(0)) {
            returnType(double(1))
            lengthOri = length(x)
            xPrev     = nimNumeric(length=lengthOri, value=x[1:lengthOri])
            x         = nimNumeric(length=length, value=0)
            if (lengthOri <= length) {
                x[1:lengthOri] = xPrev[1:lengthOri]
            } else {
                x[1:length] = xPrev[1:length]
            }
            return(x[])
        },
        calculateWAIC = function(nburnin = integer(default = 0) # ,
                                 # burnIn = integer(default = 0)
                                 ) {
            if(!enableWAIC) {
                nimPrint('Error: must set enableWAIC = TRUE in buildAPT to use the method calcualteWAIC. See help(buildAPT) and help(buildMCMC) for additional information.')
                return(NaN)
            }
            ## if(burnIn != 0) {
            ##     print('Warning: \'burnIn\' argument is deprecated and will not be supported in future versions of NIMBLE. Please use the \'nburnin\' argument instead.')
            ##     ## If nburnin has not been changed, replace with burnIn value
            ##     if(nburnin == 0)   nburnin <- burnIn
            ## }
            nburninPostThinning <- ceiling(nburnin/thinToUseVec[1])
            numMCMCSamples <- getsize(mvSamples) - nburninPostThinning
            if((numMCMCSamples) < 2) {
                nimPrint('Error: need more than one post burn-in MCMC samples')
                return(-Inf)
            }
            logPredProbs <- matrix(nrow = numMCMCSamples, ncol = dataNodeLength)
            logAvgProb <- 0
            pWAIC <- 0
            currentVals <- values(model, allVarsIncludingLogProbs)

            for(i in 1:numMCMCSamples) {
                copy(mvSamples, model, nodesTo = sampledNodes, row = i + nburninPostThinning)
                model$simulate(paramDeps)
                model$calculate(dataNodes)
                for(j in 1:dataNodeLength)
                    logPredProbs[i,j] <- model$getLogProb(dataNodes[j])
            }
            for(j in 1:dataNodeLength) {
                maxLogPred <- max(logPredProbs[,j])
                thisDataLogAvgProb <- maxLogPred + log(mean(exp(logPredProbs[,j] - maxLogPred)))
                logAvgProb <- logAvgProb + thisDataLogAvgProb
                pointLogPredVar <- var(logPredProbs[,j])
                pWAIC <- pWAIC + pointLogPredVar
            }
            WAIC <- -2*(logAvgProb - pWAIC)
            values(model, allVarsIncludingLogProbs) <<- currentVals
            if(is.nan(WAIC)) nimPrint('WAIC was calculated as NaN.  You may need to add monitors to model latent states, in order for a valid WAIC calculation.')
            returnType(double())
            return(WAIC)
        }
    )    ## ,
    ## where = getLoadingNamespace()
    ## where = getNamespace("nimbleAPT")
)



####################################################################
### scalar RW sampler with normal proposal distribution ############
####################################################################
#' @rdname samplers
#' @export
#' @import nimble
sampler_RW_tempered <- nimbleFunction(
    name = 'sampler_RW_tempered',
    contains = sampler_APT,
    setup = function(model, mvSaved, target, control) {
        ## Control list extraction
        logScale            <- if(!is.null(control$log))           control$log           else FALSE
        reflective          <- if(!is.null(control$reflective))    control$reflective    else FALSE
        adaptive            <- if(!is.null(control$adaptive))      control$adaptive      else TRUE
        adaptInterval       <- if(!is.null(control$adaptInterval)) control$adaptInterval else 200
        adaptFactorExponent <- if(!is.null(control$adaptFactorExponent)) control$adaptFactorExponent else 0.8
        scale               <- if(!is.null(control$scale))         control$scale         else 1
        temperPriors        <- if(!is.null(control$temperPriors))  control$temperPriors  else stop("control$temperPriors unspecified in sampler_RW_tempered")
        ## logScale      <- control$log
        ## reflective    <- control$reflective
        ## adaptive      <- control$adaptive
        ## adaptInterval <- control$adaptInterval
        ## scale         <- control$scale
        ## temperPriors  <- control$temperPriors
        if (is.null(temperPriors))
            stop("control$temperPriors unspecified in sampler_RW_tempered")
        ## Node list generation
        targetAsScalar <- model$expandNodeNames(target, returnScalarComponents = TRUE)
        calcNodes      <- model$getDependencies(target)
        targetNode     <- model$expandNodeNames(target)
        dependantNodes <- calcNodes[!is.element(calcNodes, targetNode)]
        ## Numeric value generation
        scaleOriginal <- scale
        timesRan      <- 0
        timesAccepted <- 0
        timesAdapted  <- 0
        optimalAR     <- 0.44
        gamma1        <- 0
        ## Checks
        if(length(targetAsScalar) > 1) stop('cannot use RW sampler on more than one target; try RW_block sampler')
        if(model$isDiscrete(target))   stop('cannot use RW sampler on discrete-valued target; try slice sampler')
        if(logScale & reflective)      stop('cannot use reflective RW sampler on a log scale (i.e. with options log=TRUE and reflective=TRUE')
        if(adaptFactorExponent < 0)    stop('cannot use RW sampler with adaptFactorExponent control parameter less than 0')
        if(scale < 0)                  stop('cannot use RW sampler with scale control parameter less than 0')
        ## Initialise temperature
        temperature <- nimNumeric(length=2, value=1) ## Length 2 is just a hack. Only 1st element is used.
    },
    run = function() {
        ## nimPrint(temperature[1])
        ## browser()
        currentValue <- model[[target]]
        propLogScale <- 0
        if(logScale) {
            propLogScale <- rnorm(1, mean = 0, sd = scale)
            propValue    <- currentValue * exp(propLogScale)
        } else {
            propValue <- rnorm(1, mean = currentValue,  sd = scale)
        }
        if(reflective) {
            lower <- model$getBound(target, 'lower')
            upper <- model$getBound(target, 'upper')
            while(propValue < lower | propValue > upper) {
                if(propValue < lower) propValue <- 2*lower - propValue
                if(propValue > upper) propValue <- 2*upper - propValue
            }
        }
        if (temperPriors) {
            model[[target]] <<- propValue
            logMHR <- calculateDiff(model, calcNodes) / temperature[1] + propLogScale ## Original. Tempers everything.
        } else {
            logPriorWeightOri   <- getLogProb(model, target)
            model[[target]]    <<- propValue
            diffLogProb         <- calculateDiff(model, calcNodes)
            logPriorWeightProp  <- getLogProb(model, target)
            diffLogPriorWeights <- logPriorWeightProp - logPriorWeightOri
            logMHR <- (diffLogProb - diffLogPriorWeights) / temperature[1] + diffLogPriorWeights + propLogScale ## POSSIBLY BUGGY ???
        }
        jump <- decide(logMHR)
        if (jump) {
            nimCopy(from = model, to = mvSaved, row = 1, nodes = calcNodes, logProb = TRUE)
        } else {
            nimCopy(from = mvSaved, to = model, row = 1, nodes = calcNodes, logProb = TRUE)
        }
        if(adaptive) {
            adaptiveProcedure(jump)
        }
    },
    methods = list(
        setTemp = function(temp=double()) {
            temperature[1] <<- temp
        },
        adaptiveProcedure = function(jump = logical()) {
            timesRan <<- timesRan + 1
            if(jump)     timesAccepted <<- timesAccepted + 1
            if(timesRan %% adaptInterval == 0) {
                acceptanceRate <- timesAccepted / timesRan
                timesAdapted <<- timesAdapted + 1
                gamma1 <<- 1/((timesAdapted + 3)^adaptFactorExponent)
                gamma2 <- 10 * gamma1
                adaptFactor <- exp(gamma2 * (acceptanceRate - optimalAR))
                scale <<- scale * adaptFactor
                timesRan <<- 0
                timesAccepted <<- 0
            }
        },
        ## turnOffAdaptation = function() {
        ##     adaptive <<- FALSE
        ## },
        reset = function() {
            scale         <<- scaleOriginal
            timesRan      <<- 0
            timesAccepted <<- 0
            timesAdapted  <<- 0
            gamma1        <<- 0
        }
    )    ## ,
    ## where = getLoadingNamespace()
    ## where = getNamespace("nimbleAPT")
)


########################################################################
### block RW sampler with multi-variate normal proposal distribution ###
########################################################################
#' @rdname samplers
#' @export
#' @import nimble
sampler_RW_block_tempered <- nimbleFunction(
    name = 'sampler_RW_block_tempered',
    contains = sampler_APT,
    setup = function(model, mvSaved, target, control) {
        ## control list extraction
        adaptive            <- if(!is.null(control$adaptive))       control$adaptive       else TRUE
        adaptScaleOnly      <- if(!is.null(control$adaptScaleOnly)) control$adaptScaleOnly else FALSE
        adaptInterval       <- if(!is.null(control$adaptInterval))  control$adaptInterval  else 200
        adaptFactorExponent <- if(!is.null(control$adaptFactorExponent)) control$adaptFactorExponent else 0.8
        scale               <- if(!is.null(control$scale))          control$scale          else 1
        propCov             <- if(!is.null(control$propCov))        control$propCov        else 'identity'
        temperPriors        <- if(!is.null(control$temperPriors))   control$temperPriors   else stop("control$temperPriors unspecified in sampler_RW_block_tempered")
        ## adaptive       <- control$adaptive
        ## adaptScaleOnly <- control$adaptScaleOnly
        ## adaptInterval  <- control$adaptInterval
        ## scale          <- control$scale
        ## propCov        <- control$propCov
        ## temperPriors   <- control$temperPriors
        ## if (is.null(temperPriors)) {
        ##     stop("control$temperPriors unspecified in sampler_RW_block_tempered")
        ## }
        ## node list generation
        targetAsScalar <- model$expandNodeNames(target, returnScalarComponents = TRUE)
        calcNodes      <- model$getDependencies(target)
        targetNodes    <- model$expandNodeNames(target)
        ## numeric value generation
        scaleOriginal <- scale
        timesRan      <- 0
        timesAccepted <- 0
        timesAdapted  <- 0
        d <- length(targetAsScalar)
        if(is.character(propCov) && propCov == 'identity') {
            propCov <- diag(d)
        }
        propCovOriginal <- propCov
        chol_propCov <- chol(propCov)
        chol_propCov_scale <- scale * chol_propCov
        empirSamp <- matrix(0, nrow=adaptInterval, ncol=d)
        ## nested function and function list definitions
        my_setAndCalculateDiff  <- setAndCalculateDiff(model, target)
        my_decideAndJump        <- decideAndJump(model, mvSaved, calcNodes)
        my_calcAdaptationFactor <- calcAdaptationFactor(d, adaptFactorExponent)
        ## checks
        ## browser()
        if(!inherits(propCov, 'matrix')) stop('propCov must be a matrix\n')
        if(!inherits(propCov[1,1], 'numeric')) stop('propCov matrix must be numeric\n')
        if(!all(dim(propCov)   == d)) stop('propCov matrix must have dimension ', d, 'x', d, '\n')
        if(!isSymmetric(propCov)) stop('propCov matrix must be symmetric')
        ## Initialise temperature
        temperature <- nimNumeric(length=2, value=1) ## Length 2 is a hack. Only temperature[1] is used.
    },
    run = function() {
        ## browser()
        propValueVector <- generateProposalVector()
        if (temperPriors) {
            lpMHR <- my_setAndCalculateDiff$run(propValueVector) / temperature[1]
        } else {
            logPriorWeightOri   <- getLogProb(model, targetNodes)
            lpMHR               <- my_setAndCalculateDiff$run(propValueVector)
            diffLogPriorWeights <- getLogProb(model, targetNodes) - logPriorWeightOri
            lpMHR               <- (lpMHR - diffLogPriorWeights) / temperature[1] + diffLogPriorWeights
        }
        jump <- my_decideAndJump$run(lpMHR, 0, 0, 0) ## will use lpMHR - 0
        ## nimPrint(temperature[1], " ", jump)
        if (adaptive) {
            adaptiveProcedure(jump)
        }
    },
    methods = list(
        setTemp = function(temp=double()) {
            temperature[1] <<- temp
        },
        generateProposalVector = function() {
            propValueVector <- rmnorm_chol(1, values(model,target), chol_propCov_scale, 0)  ## last argument specifies prec_param = FALSE
            returnType(double(1))
            return(propValueVector)
        },
        adaptiveProcedure = function(jump = logical()) {
            timesRan <<- timesRan + 1
            if(jump) {
                timesAccepted <<- timesAccepted + 1
            }
            if(!adaptScaleOnly) {
                empirSamp[timesRan, 1:d] <<- values(model, target)
            }
            if(timesRan %% adaptInterval == 0) {
                acceptanceRate <- timesAccepted / timesRan
                timesAdapted <<- timesAdapted + 1
                adaptFactor <- my_calcAdaptationFactor$run(acceptanceRate)
                scale <<- scale * adaptFactor
                ## calculate empirical covariance, and adapt proposal covariance
                if(!adaptScaleOnly) {
                    gamma1 <- my_calcAdaptationFactor$gamma1
                    for(i in 1:d)     empirSamp[, i] <<- empirSamp[, i] - mean(empirSamp[, i])
                    empirCov <- (t(empirSamp) %*% empirSamp) / (timesRan-1)
                    propCov <<- propCov + gamma1 * (empirCov - propCov)
                    chol_propCov <<- chol(propCov)
                }
                chol_propCov_scale <<- chol_propCov * scale
                timesRan <<- 0
                timesAccepted <<- 0
            }
        },
        ## turnOffAdaptation = function() {
        ##     adaptive <<- FALSE
        ## },
        reset = function() {
            scale              <<- scaleOriginal
            propCov            <<- propCovOriginal
            chol_propCov       <<- chol(propCov)
            chol_propCov_scale <<- chol_propCov * scale
            timesRan           <<- 0
            timesAccepted      <<- 0
            timesAdapted       <<- 0
            my_calcAdaptationFactor$reset()
        }
    )    ## ,
    ## where = getLoadingNamespace()
    ## where = getNamespace("nimbleAPT")
)


####################################################################
### slice sampler (discrete or continuous) #########################
####################################################################
#' @rdname samplers
#' @export
#' @import nimble
sampler_slice_tempered <- nimbleFunction(
    name = 'sampler_slice_tempered',
    contains = sampler_APT,
    setup = function(model, mvSaved, target, control) {
        ## control list extraction
        adaptive       <- if(!is.null(control$adaptive))       control$adaptive       else TRUE
        adaptInterval  <- if(!is.null(control$adaptInterval))  control$adaptInterval  else 200
        width         <- if(!is.null(control$width))           control$width          else 1
        maxSteps      <- if(!is.null(control$sliceMaxSteps))   control$sliceMaxSteps else 100
        ## adaptive       <- control$adaptive
        ## adaptInterval  <- control$adaptInterval
        ## width          <- control$sliceWidth
        ## maxSteps       <- control$sliceMaxSteps
        ## node list generation
        targetAsScalar <- model$expandNodeNames(target, returnScalarComponents = TRUE)
        calcNodes      <- model$getDependencies(target)
        ## numeric value generation
        widthOriginal <- width
        timesRan      <- 0
        timesAdapted  <- 0
        sumJumps      <- 0
        discrete      <- model$isDiscrete(target)
        ## checks
        if(length(targetAsScalar) > 1)     stop('cannot use slice sampler on more than one target node')
        ## initialise temperature
        temperature <- nimNumeric(length=2, value=1) ## Length 2 is a hack. Only first element is used.
    },
    run = function() {
        ## nimPrint(temperature[1])
        u  <- getLogProb(model, calcNodes) / temperature[1] - rexp(1, 1)    # generate (log)-auxiliary variable: exp(u) ~ uniform(0, exp(lp))
        x0 <- model[[target]]    # create random interval (L,R), of width 'width', around current value of target
        L  <- x0 - runif(1, 0, 1) * width
        R  <- L + width
        maxStepsL <- floor(runif(1, 0, 1) * maxSteps)    # randomly allot (maxSteps-1) into maxStepsL and maxStepsR
        maxStepsR <- maxSteps - 1 - maxStepsL
        lp <- setAndCalculateTarget(L) / temperature[1]
        while(maxStepsL > 0 & !is.nan(lp) & lp >= u) {   # step L left until outside of slice (max maxStepsL steps)
            L <- L - width
            lp <- setAndCalculateTarget(L) / temperature[1]
            maxStepsL <- maxStepsL - 1
        }
        lp <- setAndCalculateTarget(R) / temperature[1]
        while(maxStepsR > 0 & !is.nan(lp) & lp >= u) {   # step R right until outside of slice (max maxStepsR steps)
            R <- R + width
            lp <- setAndCalculateTarget(R) / temperature[1]
            maxStepsR <- maxStepsR - 1
        }
        x1 <- L + runif(1, 0, 1) * (R - L)
        lp <- setAndCalculateTarget(x1) / temperature[1]
        while(is.nan(lp) | lp < u) {   # must be is.nan()
            if(x1 < x0) {
                L <- x1
            } else {
                R <- x1
            }
            x1 <- L + runif(1, 0, 1) * (R - L)           # sample uniformly from (L,R) until sample is inside of slice (with shrinkage)
            lp <- setAndCalculateTarget(x1) / temperature[1]
        }
        nimCopy(from = model, to = mvSaved, row = 1, nodes = calcNodes, logProb = TRUE)
        jumpDist <- abs(x1 - x0)
        if(adaptive)     adaptiveProcedure(jumpDist)
    },
    methods = list(
        setTemp = function(temp = double()) {
            temperature[1] <<- temp
        },
        setAndCalculateTarget = function(value = double()) {
            if(discrete)     value <- floor(value)
            model[[target]] <<- value
            lp <- calculate(model, calcNodes)
            returnType(double())
            return(lp)
        },
        adaptiveProcedure = function(jumpDist = double()) {
            timesRan <<- timesRan + 1
            sumJumps <<- sumJumps + jumpDist   # cumulative (absolute) distance between consecutive values
            if(timesRan %% adaptInterval == 0) {
                adaptFactor <- (3/4) ^ timesAdapted
                meanJump <- sumJumps / timesRan
                width <<- width + (2*meanJump - width) * adaptFactor   # exponentially decaying adaptation of 'width' -> 2 * (avg. jump distance)
                timesAdapted <<- timesAdapted + 1
                timesRan <<- 0
                sumJumps <<- 0
            }
        },
        ## turnOffAdaptation = function() {
        ##     adaptive <<- FALSE
        ## },
        reset = function() {
            width        <<- widthOriginal
            timesRan     <<- 0
            timesAdapted <<- 0
            sumJumps     <<- 0
        }
    )    ## ,
    ## where = getLoadingNamespace()
    ## where = getNamespace("nimbleAPT")
)


#######################################################################################
### RW_multinomial sampler for multinomial distributions ##############################
#######################################################################################
#' @rdname samplers
#' @export
#' @import nimble
#' @importFrom stats runif
sampler_RW_multinomial_tempered <- nimbleFunction(
    name = 'sampler_RW_multinomial_tempered',
    contains = sampler_APT,
    setup = function(model, mvSaved, target, control) {
        ## control list extraction
        adaptive      <- if(!is.null(control$adaptive))         control$adaptive      else TRUE
        adaptInterval <- if(!is.null(control$adaptInterval))    control$adaptInterval else 200
        useTempering      <- if(!is.null(control$useTempering)) control$useTempering  else stop("control$useTempering unspecified in sampler_RW_multinomial_tempered")
        ## adaptive      <- control$adaptive
        ## adaptInterval <- control$adaptInterval
        ## useTempering  <- control$useTempering
        ## node list generation
        targetAsScalar <- model$expandNodeNames(target, returnScalarComponents = TRUE)
        targetAllNodes <- unique(model$expandNodeNames(target))
        calcNodes      <- model$getDependencies(target)
        lTarget        <- length(targetAsScalar)
        Ntotal         <- sum(values(model,target))
        NOverL         <- Ntotal / lTarget
        ## numeric value generation
        Zeros             <- matrix(0, lTarget, lTarget)
        Ones              <- matrix(1, lTarget, lTarget)
        timesRan          <- Zeros
        AcceptRates       <- Zeros
        ScaleShifts       <- Zeros
        totalAdapted      <- Zeros
        timesAccepted     <- Zeros
        ENSwapMatrix      <- Ones
        ENSwapDeltaMatrix <- Ones
        RescaleThreshold  <- 0.2 * Ones
        lpProp  <- 0
        lpRev   <- 0
        Pi      <- pi
        PiOver2 <- Pi / 2 ## Irrational number prevents recycling becoming degenerate
        u       <- runif(1, 0, Pi)
        ## nested function and function list definitions
        my_setAndCalculateDiff <- setAndCalculateDiff(model, target)
        my_decideAndJump       <- decideAndJump(model, mvSaved, calcNodes)
        ## checks
        ## if(model$getNodeDistribution(target) != 'dmulti')   stop('can only use RW_multinomial sampler for multinomial distributions')
        if(model$getDistribution(target) != 'dmulti') stop('can only use RW_multinomial sampler for multinomial distributions')
        if(length(targetAllNodes) > 1)                stop('cannot use RW_multinomial sampler on more than one target')
        if(adaptive & adaptInterval < 100)            stop('adaptInterval < 100 is not recommended for RW_multinomial sampler')
        ## initialise temperature
        temperature <- nimNumeric(length=2, value=1) ## Length 2 is a hack. Only first element is used.
    },
    run = function() {
        for(iFROM in 1:lTarget) {
            for(iTO in 1:(lTarget-1)) {
                if(u > PiOver2) {
                    iFrom <- iFROM
                    iTo   <- iTO
                    if (iFrom == iTo)
                        iTo <- lTarget
                    u <<- 2 * (u - PiOver2)   # recycle u
                } else {
                    iFrom <- iTO
                    iTo   <- iFROM
                    if (iFrom == iTo)
                        iFrom <- lTarget
                    u <<- 2 * (PiOver2 - u)   # recycle u
                }
                propValueVector <- generateProposalVector(iFrom, iTo)
                if (useTempering) {
                    lpMHR <- my_setAndCalculateDiff$run(propValueVector) / temperature[1] + lpRev - lpProp
                } else {
                    lpMHR <- my_setAndCalculateDiff$run(propValueVector) + lpRev - lpProp
                }
                jump <- my_decideAndJump$run(lpMHR, 0, 0, 0) ## returns lpMHR + 0 - 0 + 0
                if(adaptive)   adaptiveProcedure(jump=jump, iFrom=iFrom, iTo=iTo)
            }
        }
    },
    methods = list(
        setTemp = function(temp=double()) {
            temperature[1] <<- temp
        },
        generateProposalVector = function(iFrom = integer(), iTo = integer()) {
            propVector <- values(model,target)
            pSwap      <- min(1, max(1, ENSwapMatrix[iFrom,iTo]) / propVector[iFrom])
            nSwap      <- rbinom(n=1,   size=propVector[iFrom], prob=pSwap)
            lpProp    <<- dbinom(nSwap, size=propVector[iFrom], prob=pSwap, log=TRUE)
            propVector[iFrom] <- propVector[iFrom] - nSwap
            propVector[iTo]   <- propVector[iTo]   + nSwap
            pRevSwap   <- min(1, max(1, ENSwapMatrix[iTo,iFrom]) / (propVector[iTo] + nSwap))
            lpRev     <<- dbinom(nSwap, size=propVector[iTo], prob=pRevSwap, log=TRUE)
            returnType(double(1))
            return(propVector)
        },
        adaptiveProcedure = function(jump=logical(), iFrom=integer(), iTo=integer()) {
            NVector <- values(model,target)
            timesRan[iFrom, iTo] <<- timesRan[iFrom, iTo] + 1
            if(jump)
                timesAccepted[iFrom, iTo] <<- timesAccepted[iFrom, iTo] + 1
            if (timesRan[iFrom, iTo] %% adaptInterval == 0) {
                totalAdapted[iFrom, iTo] <<- totalAdapted[iFrom, iTo] + 1
                accRate                   <- timesAccepted[iFrom, iTo] / timesRan[iFrom, iTo]
                AcceptRates[iFrom, iTo]  <<- accRate
                if (accRate > 0.5) {
                    ENSwapMatrix[iFrom, iTo] <<-
                        min(Ntotal,
                            ENSwapMatrix[iFrom,iTo] + ENSwapDeltaMatrix[iFrom, iTo] / totalAdapted[iFrom,iTo])
                } else {
                    ENSwapMatrix[iFrom, iTo] <<-
                        max(1,
                            ENSwapMatrix[iFrom,iTo] - ENSwapDeltaMatrix[iFrom,iTo] / totalAdapted[iFrom,iTo])
                }
                if(accRate<RescaleThreshold[iFrom,iTo] | accRate>(1-RescaleThreshold[iFrom,iTo])) {
                    ## rescale iff ENSwapMatrix[iFrom, iTo] is not set to an upper or lower bound
                    if (ENSwapMatrix[iFrom, iTo] > 1 & ENSwapMatrix[iFrom, iTo] < Ntotal) {
                        ScaleShifts[iFrom, iTo]       <<- ScaleShifts[iFrom, iTo] + 1
                        ENSwapDeltaMatrix[iFrom, iTo] <<- min(NOverL, ENSwapDeltaMatrix[iFrom, iTo] * totalAdapted[iFrom,iTo] / 10)
                        ENSwapDeltaMatrix[iTo, iFrom] <<- ENSwapDeltaMatrix[iFrom, iTo]
                        RescaleThreshold[iFrom,iTo]   <<- 0.2 * 0.95^ScaleShifts[iFrom, iTo]
                    }
                }
                ## lower Bound
                if(ENSwapMatrix[iFrom, iTo] < 1)
                    ENSwapMatrix[iFrom, iTo] <<- 1
                ## symmetry in ENSwapMatrix helps maintain good acceptance rates
                ENSwapMatrix[iTo,iFrom]   <<- ENSwapMatrix[iFrom,iTo]
                timesRan[iFrom, iTo]      <<- 0
                timesAccepted[iFrom, iTo] <<- 0
            }
        },
        ## turnOffAdaptation = function() {
        ##     adaptive <<- FALSE
        ## },
        reset = function() {
            timesRan          <<- Zeros
            AcceptRates       <<- Zeros
            ScaleShifts       <<- Zeros
            totalAdapted      <<- Zeros
            timesAccepted     <<- Zeros
            ENSwapMatrix      <<- Ones
            ENSwapDeltaMatrix <<- Ones
            RescaleThreshold  <<- 0.2 * Ones
        }
    )    ## ,
    ## where = getLoadingNamespace()
    ## where = getNamespace("nimbleAPT")
)


#' APT Sampling Algorithms
#'
#' Details of the adaptive parallel tempering (APT) samplers adapted from nimble's MCMC samplers.
#'
#' @param model (uncompiled) model on which the APT algorithm is to be run
#' @param mvSaved \code{modelValues} object to be used to store MCMC samples
#' @param target node(s) on which the sampler will be used
#' @param control named list that controls the precise behavior of the sampler, with elements specific to \code{samplertype}.  The default values for control list are specified in the setup code of each sampling algorithm.  Descriptions of each sampling algorithm, and the possible customizations for each sampler (using the \code{control} argument) appear below.
#'
#' @section \code{sampler_APT}: base class for APT samplers
#'
#' When you write a new sampler for use in a NIMBLE MCMC with APT, you must include \code{contains = sampler_APT}.
#'
#' @section RW sampler:
#'
#' The RW sampler executes adaptive Metropolis-Hastings sampling with a normal proposal distribution (Metropolis, 1953), implementing the adaptation routine given in Shaby and Wells, 2011.  This sampler can be applied to any scalar continuous-valued stochastic node, and can optionally sample on a log scale.
#'
#' The RW sampler accepts the following control list elements:
#' \itemize{
#' \item logScale. A logical argument, specifying whether the sampler should operate on the log scale. (default = FALSE)
#' \item reflective. A logical argument, specifying whether the normal proposal distribution should reflect to stay within the range of the target distribution. (default = FALSE)
#' \item adaptive. A logical argument, specifying whether the sampler should adapt the scale (proposal standard deviation) throughout the course of MCMC execution to achieve a theoretically desirable acceptance rate. (default = TRUE)
#' \item adaptInterval. The interval on which to perform adaptation.  Every adaptInterval MCMC iterations (prior to thinning), the RW sampler will perform its adaptation procedure.  This updates the scale variable, based upon the sampler's achieved acceptance rate over the past adaptInterval iterations. (default = 200)
#' \item scale. The initial value of the normal proposal standard deviation.  If adaptive = FALSE, scale will never change. (default = 1)
#' \item temperPriors. Logical indicator determining if tempering should apply to prior likelihoods. Usually can be set to TRUE. But setting to FALSE can help avoid degeneracy issues for complex problems where bounded uniform priors have been transformed to other (e.g. logit) scales.
#' }
#'
#' The RW sampler cannot be used with options log=TRUE and reflective=TRUE, i.e. it cannot do reflective sampling on a log scale.
#'
#' @section RW_block sampler:
#'
#' The RW_block sampler performs a simultaneous update of one or more model nodes, using an adaptive Metropolis-Hastings algorithm with a multivariate normal proposal distribution (Roberts and Sahu, 1997), implementing the adaptation routine given in Shaby and Wells, 2011.  This sampler may be applied to any set of continuous-valued model nodes, to any single continuous-valued multivariate model node, or to any combination thereof. \cr
#'
#' The RW_block sampler accepts the following control list elements:
#' \itemize{
#' \item adaptive. A logical argument, specifying whether the sampler should adapt the scale (a coefficient for the entire proposal covariance matrix) and propCov (the multivariate normal proposal covariance matrix) throughout the course of MCMC execution.  If only the scale should undergo adaptation, this argument should be specified as TRUE. (default = TRUE)
#' \item adaptScaleOnly. A logical argument, specifying whether adaption should be done only for scale (TRUE) or also for provCov (FALSE).  This argument is only relevant when adaptive = TRUE.  When adaptScaleOnly = FALSE, both scale and propCov undergo adaptation; the sampler tunes the scaling to achieve a theoretically good acceptance rate, and the proposal covariance to mimic that of the empirical samples.  When adaptScaleOnly = TRUE, only the proposal scale is adapted. (default = FALSE)
#' \item adaptInterval. The interval on which to perform adaptation.  Every adaptInterval MCMC iterations (prior to thinning), the RW_block sampler will perform its adaptation procedure, based on the past adaptInterval iterations. (default = 200)
#' \item scale. The initial value of the scalar multiplier for propCov.  If adaptive = FALSE, scale will never change. (default = 1)
#' \item propCov. The initial covariance matrix for the multivariate normal proposal distribution.  This element may be equal to the character string 'identity', in which case the identity matrix of the appropriate dimension will be used for the initial proposal covariance matrix. (default = 'identity')
#' \item temperPriors. Logical indicator determining if tempering should apply to prior likelihoods. Usually can be set to TRUE. But setting to FALSE can help avoid degeneracy issues for complex problems where bounded uniform priors have been transformed to other (e.g. logit) scales.
#' }
#'
#' @section slice sampler:
#'
#' The slice sampler performs slice sampling of the scalar node to which it is applied (Neal, 2003).  This sampler can operate on either continuous-valued or discrete-valued scalar nodes.  The slice sampler performs a 'stepping out' procedure, in which the slice is iteratively expanded to the left or right by an amount sliceWidth.  This sampler is optionally adaptive, governed by a control list element, whereby the value of sliceWidth is adapted towards the observed absolute difference between successive samples.
#'
#' The slice sampler accepts the following control list elements:
#' \itemize{
#' \item adaptive. A logical argument, specifying whether the sampler will adapt the value of sliceWidth throughout the course of MCMC execution. (default = TRUE)
#' \item adaptInterval. The interval on which to perform adaptation. (default = 200)
#' \item width. The initial value of the width of each slice, and also the width of the expansion during the iterative 'stepping out' procedure. (default = 1)
#' \item maxSteps. The maximum number of expansions which may occur during the 'stepping out' procedure. (default = 100)
#' }
#'
#' @section RW_multinomial sampler:
#'
#' This sampler is designed for sampling multinomial target distributions.  The sampler performs a series of Metropolis-Hastings steps between pairs of groups.  Proposals are generated via a draw from a binomial distribution, whereafter the proposed number density is moved from one group to another group.  The acceptance or rejection of these proposals follows a standard Metropolis-Hastings procedure.  Probabilities for the random binomial proposals are adapted to a target acceptance rate of 0.5.
#'
#' The \code{RW_multinomial} sampler accepts the following control list elements:
#' \itemize{
#' \item adaptive.  A logical argument, specifying whether the sampler should adapt the binomial proposal probabilities throughout the course of MCMC execution. (default = TRUE)
#' \item adaptInterval.  The interval on which to perform adaptation.  A minimum value of 100 is required. (default = 200)
#' \item useTempering. A logical argument to optionally turn tempering off (i.e. assume all temperatures are 1) for this sampler.
#' }
#'
#' @name samplers
#'
#' @return These functions are called from the \code{addSampler} function and return an uncompiled APT sampler object that can be included in an APT sampling scheme.
#'
#' @aliases sampler sampler_RW_tempered sampler_RW_block_tempered sampler_RW_multinomial_tempered sampler_slice_tempered
#'
#' @seealso \code{\link{configureMCMC}} \code{\link{addSampler}} \code{\link{buildMCMC}} \code{\link{buildAPT}} \code{\link{runMCMC}}
#'
#' @author David Pleydell, Daniel Turek
#'
#' @examples
#' ## This example is taken from the nimbleAPT vignette. See the vignette for more details.
#'
#' bugsCode <- nimbleCode({
#'    for (ii in 1:nObs) {
#'        y[ii,1:2] ~ dmnorm(mean=absCentroids[1:2], cholesky=cholCov[1:2,1:2], prec_param=0)
#'    }
#'    absCentroids[1:2] <- abs(centroids[1:2])
#'    for (ii in 1:2) {
#'        centroids[ii] ~ dnorm(0, sd=1E3)
#'    }
#' })
#'
#' nObs      <- 100
#' centroids <- rep(-3, 2)
#' covChol   <- chol(diag(2))
#'
#' rModel <- nimbleModel(bugsCode,
#'                      constants=list(nObs=nObs, cholCov=covChol),
#'                      inits=list(centroids=centroids))
#'
#'simulate(rModel, "y") ## Use model to simulate data
#'
#' rModel <- nimbleModel(bugsCode,
#'                       constants=list(nObs=nObs, cholCov=covChol),
#'                       data=list(y=rModel$y),
#'                       inits=list(centroids=centroids))
#'
#' conf <- configureMCMC(rModel, nodes="centroids", monitors="centroids", enableWAIC = TRUE)
#'
#' conf$removeSamplers()
#' conf$addSampler("centroids[1]", type="sampler_RW_tempered", control=list(temperPriors=TRUE))
#' conf$addSampler("centroids[2]", type="sampler_RW_tempered", control=list(temperPriors=TRUE))
#' aptR <- buildAPT(conf, Temps=1:5, ULT= 1000, print=TRUE)
#'
#' @references
#'
#' Metropolis, N., Rosenbluth, A. W., Rosenbluth, M. N., Teller, A. H., and Teller, E. (1953). Equation of State Calculations by Fast Computing Machines. \emph{The Journal of Chemical Physics}, 21(6), 1087-1092.
#'
#' Neal, Radford M. (2003). Slice Sampling. \emph{The Annals of Statistics}, 31(3), 705-741.
#'
#' Roberts, G. O. and S. K. Sahu (1997). Updating Schemes, Correlation Structure, Blocking and Parameterization for the Gibbs Sampler. \emph{Journal of the Royal Statistical Society: Series B (Statistical Methodology)}, 59(2), 291-317.
#'
#' Shaby, B. and M. Wells (2011). \emph{Exploring an Adaptive Metropolis Algorithm}. 2011-14. Department of Statistics, Duke University.
NULL




##########################################
## Other functions for working with APT ##
##########################################

##' Plot the trajectories of a temperature ladder of an adaptive parallel tempering algorithm
##'
##' plotTempTraj Returns two plots, one with T~iterations, the other log10(T)~iterations.
##' @title plot.tempTraj
##' @param cAPT An APT object generated by buildAPT and compiled by compileNimble.
##' @return A plot of the trajectories.
##' @author David Pleydell
##' @seealso An example is provided in the documentation of buildAPT.
##' @name plotTempTraj
##' @import nimble
##' @importFrom grDevices rainbow n2mfrow
##' @importFrom graphics lines par plot
##' @export
plotTempTraj <- function(cAPT) {
    ## Backup & recover current plotting parameters
    oldpar <- par(no.readonly = TRUE)
    on.exit(par(oldpar))
    ##
    par(mfrow=n2mfrow(2))
    traj   <- cAPT$tempTraj
    nRow   <- nrow(traj)
    nCol   <- ncol(traj)
    myCols <- rainbow(nCol)
    YLIM   <- range(pretty(c(0, cAPT$tempTraj[,nCol])))
    plot(1:nRow, cAPT$tempTraj[,nCol], typ="n", ylim=YLIM, xlab="Iteration", ylab="Temperature")
    for (ii in 1:nCol)
        lines(cAPT$tempTraj[,ii], col=myCols[ii])
    YLIM <- range(pretty(c(0, log10(cAPT$tempTraj[,nCol]))))
    plot(1:nRow, log10(cAPT$tempTraj[,nCol]), typ="n", ylim=YLIM, xlab="Iteration", ylab="log10(Temperature)")
    for (ii in 1:nCol)
        lines(log10(cAPT$tempTraj[,ii]), col=myCols[ii])
}



## Copied from NIMBLE since they do not export this function
mcmc_checkWAICmonitors <- function(model, monitors, dataNodes) {
    monitoredDetermNodes <- model$expandNodeNames(monitors)[model$isDeterm(model$expandNodeNames(monitors))]
    if(length(monitoredDetermNodes) > 0) {
        monitors <- monitors[- which(monitors %in% model$getVarNames(nodes = monitoredDetermNodes))]
    }
    thisNodes <- model$getNodeNames(stochOnly = TRUE, topOnly = TRUE)
    thisVars <- model$getVarNames(nodes = thisNodes)
    thisVars <- thisVars[!(thisVars %in% monitors)]
    while(length(thisVars) > 0) {
        nextNodes <- model$getDependencies(thisVars, stochOnly = TRUE, omit = monitoredDetermNodes, self = FALSE, includeData = TRUE)
        if(any(nextNodes %in% dataNodes)) {
            badDataNodes <- dataNodes[dataNodes %in% nextNodes]
            if(length(badDataNodes) > 10) {
                badDataNodes <- c(badDataNodes[1:10], "...")
            }
            stop(paste0("In order for a valid WAIC calculation, all parameters of",
                        " data nodes in the model must be monitored, or be",
                        " downstream from monitored nodes.",
                        " See help(buildMCMC) for more information on valid sets of",
                        " monitored nodes for WAIC calculations.", "\n",
                        " Currently, the following data nodes have un-monitored",
                        " upstream parameters:", "\n ",
                        paste0(badDataNodes, collapse = ", ")))
        }
        thisVars <- model$getVarNames(nodes = nextNodes)
        thisVars <- thisVars[!(thisVars %in% monitors)]
    }
    message('Monitored nodes are valid for WAIC')
}
