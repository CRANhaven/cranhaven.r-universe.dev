#' @importFrom quantreg rq.fit.sfn
#' @importFrom stats t.test
#' @importFrom SparseM as.matrix.csr


append = compiler::cmpfun(function(env, val, i, j) {
  b <- env$l + 1L
  env$l <- env$l + length(val)
  env$ra[b:env$l] <- val
  env$ia[b:env$l] <- i
  env$ja[b:env$l] <- j
})

initialize = compiler::cmpfun(function(env, nRows, nCols, len) {
  env$d <- c(nRows, nCols)
  env$ra <- numeric(len)
  env$ia <- integer(len)
  env$ja <- integer(len)
  env$l <- 0L
})

l1tp.getTargetVector = function(y, cohHelper, yearsHelper, effects, weights)
{
  nAges = dim(y)[1]
  nYears = dim(y)[2]

  agesDiffLength = max(nAges-2, 0)*nYears
  yearsDiffLength = nAges*max(nYears-2, 0)
  agesYearsDiffLength = max(nAges-1, 0)*max(nYears-1, 0)
  if(effects) {
    yearsEffectDiffLength = yearsHelper$ldif
    yearsEffectDistLength = yearsHelper$l
    cohortDiffLength = cohHelper$ldif
    cohortDistLength = cohHelper$l
  }

  return(
    c(y * weights, rep(0, agesDiffLength + yearsDiffLength + agesYearsDiffLength +
      ifelse(effects, yearsEffectDiffLength + yearsEffectDistLength + cohortDiffLength + cohortDistLength, 0L)))
  )
}

l1tp.unTargetVector = function(y, dims)
{
  t <- y[1:(dims[1]*dims[2])]
  dim(t) <- dims
  return(t)
}

l1tp.unTargetYearsEffect = function(y, dims, yearsHelper)
{
  offset <- dims[1]*dims[2]
  t <- array(0, dims)
  for(age in 1L:dims[1]) {
    for(year in 1L:dims[2]) {
      ind = yearsHelper$p[age, year]
      if(ind > 0L) {
        t[age, year] <- y[offset + ind]
      }
    }
  }
  return(t)
}

l1tp.unTargetCohortEffect = function(y, dims, cohHelper, yearsHelper)
{
  offset <- dims[1]*dims[2] + yearsHelper$l
  t <- array(0, dims)
  for(age in 1L:dims[1]) {
    for(year in 1L:dims[2]) {
      ind = cohHelper$p[age, year]
      if(ind > 0L) {
        t[age, year] <- y[offset + ind]
      }
    }
  }
  return(t)
}

P = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears)
{
  return(ageInd + (yearInd - 1L) * nAges)
})

InvP = function(p, nAges, nYears)
{
  return(c((p-1L)%%nAges+1L, (p-1L)%/%nAges+1L))
}

getV = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears, cm, row, cohHelper, yearsHelper, effects, weight = 1)
{
  p = P(ageInd, yearInd, nAges, nYears)
  append(cm, weight, c(row), c(p))
  if(effects) {
    pp = yearsHelper$p[ageInd, yearInd]
    if(pp > 0L) append(cm, weight, c(row), c(nAges*nYears + pp))
    ppp = cohHelper$p[ageInd, yearInd]
    if(ppp > 0L) append(cm, weight, c(row), c(nAges*nYears + yearsHelper$l + ppp))
  }
})

getVaa = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears, lambda, cm, row)
{
  append(cm, c(-2*lambda, lambda, lambda), c(row, row, row),
    c(P(ageInd, yearInd, nAges, nYears), P(ageInd - 1L, yearInd, nAges, nYears), P(ageInd + 1L, yearInd, nAges, nYears)))
})

getVyy = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears, lambda, cm, row)
{
  append(cm, c(-2*lambda, lambda, lambda), c(row, row, row),
    c(P(ageInd, yearInd, nAges, nYears), P(ageInd, yearInd - 1L, nAges, nYears), P(ageInd, yearInd + 1L, nAges, nYears)))
})

getVay = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears, lambda, cm, row)
{
  append(cm, c(lambda, -lambda, -lambda, lambda), c(row, row, row, row),
    c(P(ageInd, yearInd, nAges, nYears), P(ageInd, yearInd + 1L, nAges, nYears), P(ageInd + 1L, yearInd, nAges, nYears), P(ageInd + 1L, yearInd + 1L, nAges, nYears)))
})

getVYearsaa = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears, lambda, cm, row, yearsHelper)
{
  offset = nAges*nYears
  append(cm, c(-2 * lambda, lambda, lambda), c(row, row, row),
    c(offset + yearsHelper$p[ageInd, yearInd], offset + yearsHelper$p[ageInd - 1L, yearInd], offset + yearsHelper$p[ageInd + 1L, yearInd]))
})

#It is to avoid singularity of the design matrix
getVYearsDist = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears, theta, cm, row, yearsHelper)
{
  offset = nAges*nYears
  append(cm, theta, row, offset + yearsHelper$p[ageInd, yearInd])
})

getVCohortay = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears, lambda, cm, row, cohHelper, yearsHelper)
{
  offset = nAges*nYears + yearsHelper$l
  append(cm, c(-2 * lambda, lambda, lambda), c(row, row, row),
    c(offset + cohHelper$p[ageInd, yearInd], offset + cohHelper$p[ageInd - 1L, yearInd - 1L], offset + cohHelper$p[ageInd + 1L, yearInd + 1L]))
})

#It is to avoid singularity of the design matrix
getVCohortDist = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears, theta, cm, row, cohHelper, yearsHelper)
{
  offset = nAges*nYears + yearsHelper$l
  append(cm, theta, row, offset + cohHelper$p[ageInd, yearInd])
})

PAA = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears)
{
  if(ageInd <= 1L || ageInd >= nAges)
  {
    return(-1L)
  }
  else {
    return((ageInd - 1L) + (yearInd - 1L) * (nAges - 2L))
  }
})

PYY = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears)
{
  if(yearInd <= 1L || yearInd >= nYears)
  {
    return(-1L)
  }
  else {
    return(ageInd + (yearInd - 2L) * nAges)
  }
})

PAY = compiler::cmpfun(function(ageInd, yearInd, nAges, nYears)
{
  if(yearInd < 1L || yearInd >= nYears || ageInd < 1L || ageInd >= nAges)
  {
    return(-1L)
  }
  else {
    return(ageInd + (yearInd - 1L) * (nAges - 1L))
  }
})

prepareCohHelper = compiler::cmpfun(function(cohHelper, dims, cornerLength, affdDiagonals)
{
  nAges = dims[1]
  nYears = dims[2]
  cohHelper$pay = array(-1L, dims)
  cohHelper$p = array(-1L, dims)
  cay = 0L
  c = 0L
  if(is.null(affdDiagonals)) affdDiagonals = 1L:(nAges + nYears -1)
  for(y in 1L:nYears) {
    for(a in 1L:nAges) {
      if((nAges - a + y > cornerLength) && (nYears - y + a > cornerLength) && ((nYears - y + a) %in% affdDiagonals))
      {
        if(a > 1L && a < nAges && y > 1L && y < nYears) {
          cay <- cay + 1L
          cohHelper$pay[a, y] <- cay
        }
        c <- c + 1L
        cohHelper$p[a, y] <- c
      }
    }
  }
  cohHelper$ldif <- cay
  cohHelper$l <- c
})

prepareYearsHelper = compiler::cmpfun(function(yearsHelper, dims, affdYears)
{
  nAges = dims[1]
  nYears = dims[2]
  yearsHelper$paa = array(-1L, dims)
  yearsHelper$p = array(-1L, dims)
  caa = 0L
  c = 0L
  if(is.null(affdYears)) affdYears = 1L:nYears
  for(y in affdYears) {
    for(a in 1L:nAges) {
      if(a > 1L && a < nAges) {
        caa <- caa + 1L
        yearsHelper$paa[a, y] <- caa
      }
      c <- c + 1L
      yearsHelper$p[a, y] <- c
    }
  }
  yearsHelper$ldif <- caa
  yearsHelper$l <- c
})

l1tp.getDesignMatrix = compiler::cmpfun(function(dims, lambda, lambdaaa, lambdayy, lambdaay, lambdaYearsEffect, thetaYearsEffect, lambdaCohortEffect, thetaCohortEffect, cornerLength, cohHelper, yearsHelper, effects, weights)
{
  nAges = dims[1]
  nYears = dims[2]

  valuesLength = nAges*nYears
  agesDiffLength = max(nAges-2L, 0L)*nYears
  yearsDiffLength = nAges*max(nYears-2L, 0L)
  agesYearsDiffLength = max(nAges-1L, 0L)*max(nYears-1L, 0L)
  if(effects) {
    yearsEffectDiffLength = yearsHelper$ldif
    yearsEffectDistLength = yearsHelper$l
    cohortDiffLength = cohHelper$ldif
    cohortDistLength = cohHelper$l
  }

  columnLength = valuesLength + agesDiffLength + yearsDiffLength + agesYearsDiffLength +
    ifelse(effects, yearsEffectDiffLength + yearsEffectDistLength + cohortDiffLength + cohortDistLength, 0L)

  agesOffset = valuesLength
  yearsOffset = agesOffset + agesDiffLength
  agesYearsOffset = yearsOffset + yearsDiffLength
  if(effects) {
    yearsEffectOffset = agesYearsOffset + agesYearsDiffLength
    yearsEffectDistOffset = yearsEffectOffset + yearsEffectDiffLength
    cohortEffectOffset = yearsEffectDistOffset + yearsEffectDistLength
    cohortEffectDistOffset = cohortEffectOffset + cohortDiffLength
    nColumns = nAges*nYears + yearsHelper$l + cohHelper$l
  }
  else {
    nColumns = nAges*nYears
  }

  m = new.env(parent = .GlobalEnv)
  initialize(m, columnLength, nColumns, columnLength*4L)

#   Rprof("performance.out")

  for(a in 1L:nAges) {
    for(y in 1L:nYears) {
      p = P(a, y, nAges, nYears)
      getV(a, y, nAges, nYears, m, p, cohHelper = cohHelper, yearsHelper = yearsHelper, effects = effects, weight = weights[a, y])
      paa = PAA(a, y, nAges, nYears)
      if(paa > 0L) {
        getVaa(a, y, nAges, nYears, lambda * lambdaaa, m, agesOffset + paa)
      }
      pyy = PYY(a, y, nAges, nYears)
      if(pyy > 0L) {
        getVyy(a, y, nAges, nYears, lambda * lambdayy, m, yearsOffset + pyy)
      }
      pay = PAY(a, y, nAges, nYears)
      if(pay > 0L) {
        getVay(a, y, nAges, nYears, 2 * lambda * lambdaay, m, agesYearsOffset + pay)
      }
      if(effects) {
        pyaa = yearsHelper$paa[a, y]
        if(pyaa > 0L) {
          getVYearsaa(a, y, nAges, nYears, lambdaYearsEffect, m, yearsEffectOffset + pyaa, yearsHelper = yearsHelper)
        }
        pyd = yearsHelper$p[a, y]
        if(pyd > 0L) {
          getVYearsDist(a, y, nAges, nYears, thetaYearsEffect, m, yearsEffectDistOffset + pyd, yearsHelper = yearsHelper)
        }
        pcay = cohHelper$pay[a, y]
        if(pcay > 0L) {
          getVCohortay(a, y, nAges, nYears, lambdaCohortEffect, m, cohortEffectOffset + pcay, cohHelper = cohHelper, yearsHelper = yearsHelper)
        }
        pcd = cohHelper$p[a, y]
        if(pcd > 0L) {
          getVCohortDist(a, y, nAges, nYears, thetaCohortEffect, m, cohortEffectDistOffset + pcd, cohHelper = cohHelper, yearsHelper = yearsHelper)
        }
      }
    }
  }

#   Rprof(NULL)

  return(m)
})

l1tp.smooth.demogdata.nc = function(data, lambda = 1, lambdaaa = 1, lambdayy = 1, lambdaay = 1,
                                    lambdaYearsEffect = 5, thetaYearsEffect = 0.1*lambda,
                                    lambdaCohortEffect = 5, thetaCohortEffect = 0.1*lambda,
                                    cornerLength = 7, effects = TRUE, affdDiagonals = NULL, affdYears = NULL,
                                    control = list(nnzlmax = 1000000, nsubmax = 2000000, tmpmax = 200000),
                                    weights = NULL)
{
  if(effects) {
    yearsHelper = new.env(parent = .GlobalEnv)
    prepareYearsHelper(yearsHelper, dim(data), affdYears = affdYears)
    cohHelper = new.env(parent = .GlobalEnv)
    prepareCohHelper(cohHelper, dim(data), cornerLength = cornerLength, affdDiagonals = affdDiagonals)
  }
  else {
    yearsHelper = NULL
    cohHelper = NULL
  }
  if(is.null(weights)) weights = matrix(1, nrow(data), ncol(data))

  m = l1tp.getDesignMatrix(dim(data), lambda = lambda, lambdaaa = lambdaaa, lambdayy = lambdayy, lambdaay = lambdaay,
                           lambdaYearsEffect = lambdaYearsEffect, thetaYearsEffect = thetaYearsEffect,
                           lambdaCohortEffect = lambdaCohortEffect, thetaCohortEffect = thetaCohortEffect,
                           cornerLength = cornerLength, cohHelper = cohHelper, yearsHelper = yearsHelper, effects = effects,
                           weights = weights)
  ra = m$ra[1L:m$l]
  ia = m$ia[1L:m$l]
  ja = m$ja[1L:m$l]
  mcoo = new("matrix.coo", ra = ra[ra != 0], ia = ia[ra != 0], ja = ja[ra != 0], dimension = m$d)
  sm = as.matrix.csr(mcoo)

  rm(mcoo)
  target <- l1tp.getTargetVector(data, cohHelper = cohHelper, yearsHelper = yearsHelper, effects = effects, weights = weights)

  goodRows = rep(FALSE, length(target))
  goodRows[ia[ra != 0]] = TRUE
  noNA = !is.na(target) & goodRows
  targetNoNA = target[noNA]
  smNoNA = sm[noNA,]

#   timeFit = system.time({
  suppressWarnings({
    fit = rq.fit.sfn(smNoNA, targetNoNA, control = control)
  })
#   }); print("timeFit:"); print(timeFit)

  result = l1tp.unTargetVector(fit$coef, dim(data))
  rownames(result) = rownames(data)
  colnames(result) = colnames(data)

  if(effects) {
    yearsEffect = l1tp.unTargetYearsEffect(fit$coef, dim(data), yearsHelper = yearsHelper)
    cohortEffect = l1tp.unTargetCohortEffect(fit$coef, dim(data), cohHelper = cohHelper, yearsHelper = yearsHelper)
    rownames(cohortEffect) = rownames(yearsEffect) = rownames(data)
    colnames(cohortEffect) = colnames(yearsEffect) = colnames(data)
  }
  else {
    yearsEffect = NULL
    cohortEffect = NULL
  }

  result = list(result = result, yearsEffect = yearsEffect, cohortEffect = cohortEffect, original = data)
  class(result) = "smAPC"
  return(result)
}

#' Smooths demographic data optionally taking into account period and cohort effects
#'
#' @param data Demographic data (log mortality) presented as a matrix.
#' Row numbers represent ages and column numbers represet time.
#' @param lambda Controls "general flexibility" of the smooth surface.
#' @param lambdaaa Controls "flexibility" of the smooth surface in age direction (first dimension).
#' @param lambdayy Controls "flexibility" of the smooth surface in years direction (second dimension).
#' @param lambdaay Controls "flexibility" of the smooth surface in age and years directions.
#' @param lambdaYearsEffect Controls "flexibility" of the period effects.
#' @param thetaYearsEffect Reduces the likelihood of period effects.
#' @param lambdaCohortEffect Controls "flexibility" of the cohort effects.
#' @param thetaCohortEffect Reduces the likelihood of cohort effects.
#' @param cornerLength Sets the smallest length of a diagonal to be considered for cohort effects.
#' @param effects Controls if the cohort and period effects are taken into account.
#' @param affdDiagonals Diagonals to be used for cohort effects.
#' @param affdYears Years to be used for period effects.
#' @param control Control data passed directly to \code{\link[quantreg]{rq.fit.sfn}} function..
#' @param weights Define how much every observation effect the resulting smooth surface.
#' The parameter must have same dimentions as \code{data} parameter.
#' Weights can be set to reciprocal of estimated standard deviation of the data.
#' @return List of three components: smooth surface, period effects, cohort effects.
#' @examples
#' \donttest{
#'
#' library(demography)
#' m <- log(fr.mort$rate$female[1:30, 150:160])
#' sm <- smoothAPC(m, lambdaaa = 0.2, lambdayy = 0.1, lambdaay = 0.4, effects = FALSE)
#' plot(sm, "original")
#' plot(sm)
#'
#' }
#' @references \url{http://robjhyndman.com/publications/mortality-smoothing/}
#' @author Alexander Dokumentov
#' @seealso \code{\link{autoSmoothAPC}}, \code{\link{signifAutoSmoothAPC}}.
#' @export

smoothAPC <- compiler::cmpfun(l1tp.smooth.demogdata.nc)
