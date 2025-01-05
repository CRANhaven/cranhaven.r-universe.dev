#' Generate binary response data from a Marginalized Transition and Latent Variable Model
#'
#' @param mean.formula Right hand side of mean model formula
#' @param lv.formula Latent variable model formula (right hand side only)
#' @param t.formula Transition model formula (right hand side only)
#' @param beta a vector of values for mean.formula
#' @param sigma a vector of values for the latent variable portion of the dependence model (else NULL)
#' @param gamma a vector of values for the transition portion of the dependence model (else NULL)
#' @param id a vector of cluster identifiers (it should be the same length nrow(data))
#' @param data a required data frame
#' @param q a scalar to denote the number of quadrature points used for GH numerical integration
#'
#' @return The function returns a binary response vector.
#' @export
#'
#' @examples
#' \donttest{
#' set.seed(1)
#' N      = 100
#' nclust = sample( seq(10,10), N, replace=TRUE)
#' id     = rep(seq(N), nclust)
#' Xe     = rep(rbinom(N,size=1,prob=.5), nclust) # binary exposure
#' time   = unlist( sapply( as.list(nclust), function(ZZ) seq(ZZ)-1 ) )
#' data   = data.frame(id, time, Xe)
#' data   = data[order(data$id, data$time),]
#' newdata = GenBinaryY(mean.formula=~time*Xe, lv.formula=~1, t.formula=~1,
#' beta=c(-2.5, 0.25, 0.25, 0.1), sigma=1, gamma=1, id=id, data=data, q=20)}
#'
GenBinaryY <- function(mean.formula, lv.formula = NULL, t.formula = NULL,
                       beta = NULL, sigma = NULL, gamma = NULL, id, data,
                       q = 10)
{
  if (is.null(lv.formula) & is.null(t.formula)) {
    stop("Specify association model (both lv.formula and t.formula arguments cannot be NULL).")
  }
  if(is.null(beta)) {
    stop('Specify beta values for marginal mean model.')
  }
  if (is.null(sigma) & is.null(gamma)) {
    stop("Specify sigma and/or gamma values (both sigma and gamma arguments cannot be NULL).")
  }

  terms = unique(c(all.vars(mean.formula), all.vars(lv.formula),
                   all.vars(t.formula), as.character(substitute(id))))
  data0 = data
  data  = data[, terms]
  # if (any(is.na(data))) data = na.omit(data)

  id = data$id = data[, as.character(substitute(id))]

  x = model.matrix(mean.formula, model.frame(mean.formula, data))
  if(ncol(x) != length(beta)) {
    stop('Issue with beta and design matrix associated with mean model.')
  }
  etai <- x %*% cbind(beta, NULL)

  x.t = x.lv = matrix(0, ncol = 1, nrow = nrow(data))
  sigma.tmp = gamma.tmp = 0
  gam = sig = x.t

  if (!is.null(t.formula)) {
    if(is.null(gamma)) stop('Specify both t.formula and gamma.')
    x.t = model.matrix(t.formula, model.frame(t.formula, data))
    gamma.tmp = gamma
    if(ncol(x.t) != length(gamma.tmp)) {
      stop('Issue with gamma and design matrix associated with association model.')
    }
    gam = x.t %*% cbind(gamma.tmp, NULL)
  }
  if (!is.null(lv.formula)) {
    if(is.null(sigma)) stop('Specify both lv.formula and sigma')
    x.lv = model.matrix(lv.formula, model.frame(lv.formula, data))
    sigma.tmp = sigma
    if(ncol(x.lv) != length(sigma.tmp)) {
      stop('Issue with sigma and design matrix associated with association model.')
    }
    sig = x.lv %*% cbind(sigma.tmp, NULL)
  }

  lps   = data.frame(id, etai, sig, gam)
  colnames(lps) <- c('id','etai','sig','gam')

  lps.s = split(lps, lps$id)
  n.id  = length(lps.s)
  YY    = vector('list', n.id)

  tmp = get.GH(q)
  W   = tmp$w
  Z   = tmp$z

  for(ix in seq(n.id)) {
    lp.tmp = lps.s[[ix]]
    nr.lp  = nrow(lp.tmp)

    etai.ix = lp.tmp$etai
    gam.ix  = lp.tmp$gam
    sig.ix  = lp.tmp$sig

    deltai = Etai2Deltai(etai=etai.ix, gamma=gam.ix, sigma=sig.ix, Z=Z, W=W)
    z      = rnorm(1)
    MuC    = numeric(nr.lp)
    Y      = numeric(nr.lp)

    MuC[1] = expit(deltai[1]+sig.ix[1]*z) # Assume lagged value = 0
    Y[1]   = as.integer(runif(1)<MuC[1])

    if(nr.lp > 1) {
      for ( it in seq(2, nr.lp) ) {
        MuC[it] = expit( deltai[it] + gam.ix[it]*Y[it-1] + sig.ix[it]*z )
        Y[it]   = as.integer( runif(1)<MuC[it] )
      }
    } else {
      Y <- Y
    }
    YY[[ix]] <- Y
  }
  Y <- unlist(YY)
  Y
}
