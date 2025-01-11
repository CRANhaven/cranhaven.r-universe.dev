## -----------------------------------------------------------------------------
library(DBpower)
library(magrittr)
set.seed(0)

# make the correlation matrix of the genotypes
corMat <- matrix(data=NA, nrow=5, ncol=5)
corMat[1:2, 1:2] <- 0.3
corMat[3:5, 3:5] <- 0.3
corMat[1:2, 3:5] <- 0.1
corMat[3:5, 1:2] <- 0.1
diag(corMat) <- 1

# calculate rejection region for this setting.
# the iBJ bounds are the same as the BJ bounds, because iBJ decorrelates
# the test statistics first and then applies the standard BJ assuming independence.
bjBounds <- set_BJ_bounds(alpha = 0.01, J=5)
bjBounds
gbjBounds <- set_GBJ_bounds(alpha = 0.01, J=5, sig_vec = corMat[lower.tri(corMat)])
gbjBounds

## -----------------------------------------------------------------------------

# eigendecomposition of the correlation matrix
eVals <- eigen(corMat)$values
eVecs <- eigen(corMat)$vectors

# calculate the distributions of the test statistics under the alternative
effectSizes <- c(0.25, 0, 0, 0, 0)
MAF <- 0.3
n <- 400
sigSqY <- 1
Wg <- diag(rep(sqrt(2 * MAF * (1 - MAF)), 5))

# these are the approximate means of the generalized and innovated test statistics
genMean <- as.numeric( sqrt(n / sigSqY) * corMat %*% Wg %*% effectSizes )
genMean
innMean <- as.numeric( sqrt(n / sigSqY) * diag(sqrt(eVals)) %*% t(eVecs) %*% Wg %*% effectSizes )
innMean

## -----------------------------------------------------------------------------

# upper and lower bounds on power for iBJ
innBounds <- calcb2(lower = TRUE, upper = TRUE, muVec = innMean, sigMat = diag(rep(1, 5)), bounds = bjBounds)
c(innBounds$lowerProb, innBounds$upperProb)

# upper and lower bounds on power for GBJ
genBounds <- calcb2(lower = TRUE, upper = TRUE, muVec = genMean, sigMat = corMat, bounds = gbjBounds)
# clearly we should use the GBJ in this situation
c(genBounds$lowerProb, genBounds$upperProb)


## -----------------------------------------------------------------------------

# note that the exact power does indeed fall within the bounds
innPower <- calc_exact_power(bounds = bjBounds, sig_mat = diag(rep(1, 5)), muVec = innMean)
innPower$power
genPower <- calc_exact_power(bounds = gbjBounds, sig_mat = corMat, muVec = genMean)
genPower$power


## -----------------------------------------------------------------------------

# these functions simulate the probability of falling in the simplified rejection regions
# used to calculate the lower and upper bounds - note how they match the lower and upper bounds
# calculated above.
simBoundsInn <- sim_b2(lower=TRUE, upper=TRUE, n = 30000, muVec = innMean, sigMat = diag(rep(1, 5)), 
                             bounds = bjBounds)
simBoundsInn
simBoundsGen <- sim_b2(lower=TRUE, upper=TRUE, n = 30000, muVec = genMean, sigMat = corMat, bounds = gbjBounds)
simBoundsGen

# these functions simulate the exact power - note how they match the exact power calculations
simPowerInn <- sim_power_mvn(n = 30000, muVec = innMean, sigMat = diag(rep(1, 5)), bounds=bjBounds, test=NULL, alpha = alpha)
simPowerInn$boundsPower
simPowerGen <- sim_power_mvn(n = 30000, muVec = genMean, sigMat = corMat, bounds=gbjBounds, test=NULL, alpha = alpha)
simPowerGen$boundsPower

## -----------------------------------------------------------------------------

# simulate test statistics
gMat <- bindata::rmvbin(n=n, margprob = rep(MAF, 5), bincorr = corMat) +
        bindata::rmvbin(n=n, margprob = rep(MAF, 5), bincorr = corMat)
xMat <- matrix(data=1, nrow=n, ncol=1)

# note the good correspondence
simStatsOutput <- sim_stats_mef(B=10000, sigSq = sigSqY, xMat = xMat, decompTrue = eigen(corMat),
                                gMat = gMat, alphaVec = c(0), betaVec = effectSizes, checkpoint = FALSE)
apply(simStatsOutput$zMat, 2 , mean)
genMean
apply(simStatsOutput$iMat, 2 , mean)
innMean


## -----------------------------------------------------------------------------

# new correlation matrix 
corMatNew <- matrix(data=NA, nrow=5, ncol=5)
corMatNew[1:2, 1:2] <- 0.7
corMatNew[3:5, 3:5] <- 0.7
corMatNew[1:2, 3:5] <- 0.5
corMatNew[3:5, 1:2] <- 0.5
diag(corMatNew) <- 1

# new effect sizes
effectSizesNew <- c(0, 0.25, 0, 0, 0)

# new rejection regions
bjBoundsNew <- set_BJ_bounds(alpha = 0.01, J=5)
bjBoundsNew
gbjBoundsNew <- set_GBJ_bounds(alpha = 0.01, J=5, sig_vec = corMatNew[lower.tri(corMatNew)])
gbjBoundsNew

# eigendecomposition of the correlation matrix
eValsNew <- eigen(corMatNew)$values
eVecsNew <- eigen(corMatNew)$vectors
  
# these are the approximate means of the generalized and innovated test statistics
genMeanNew <- as.numeric(sqrt(n / sigSqY) * corMatNew %*% Wg %*% effectSizesNew)
innMeanNew <- as.numeric(sqrt(n / sigSqY) * diag(sqrt(eValsNew)) %*% t(eVecsNew) %*% Wg %*% effectSizesNew)

# calculate lower and upper bounds on power
innBoundsNew <- calcb2(lower = TRUE, upper = TRUE, muVec = innMeanNew, sigMat = diag(rep(1, 5)), bounds = bjBoundsNew)
c(innBoundsNew$lowerProb, innBoundsNew$upperProb)
genBoundsNew <- calcb2(lower = TRUE, upper = TRUE, muVec = genMeanNew, sigMat = corMatNew, bounds = gbjBoundsNew)
c(genBoundsNew$lowerProb, genBoundsNew$upperProb)


