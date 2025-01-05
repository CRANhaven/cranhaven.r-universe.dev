#' Fit Marginalized Transition and/or Latent Variable Models
#'
#' Fit a marginalized transition and/or latent variable models (mTLV) as described by Schildcrout and Heagerty 2007.

#' @param mean.formula Mean model formula in which a binary variable is regressed on covariates
#' @param lv.formula Latent variable model formula (right hand side only)
#' @param t.formula Transition model formula (right hand side only)
#' @param id a vector of cluster identifiers (it should be the same length of nrow(data)).
#' @param data a required data frame
#' @param inits an optional list of length 3 containing initial values for marginal mean parameters
#' and all dependence parameters. The format of the list should be: (1) estimates of the mean
#' parameters, (2) estimates of the transition parameters (or NULL if including a latent variable only in the dependence model)
#' and (3) estimates of the latent variable parameters (or NULL if including a transition term only in the dependence model).
#' If NULL, initial values will be automatically generated.
#' @param weight a vector of sampling weights - if using weighted estimating equations. The vector should be the same length of nrow(data).
#' @param offset an optional offset
#' @param q a scalar to denote the number of quadrature points used to compute the Gauss-Hermite quadrature rule
#' @param step.max a scalar
#' @param step.tol a scalar
#' @param hess.eps a scalar
#' @param adapt.quad an indicator if adaptive quadrature is to be used. NOT CURRENTLY IMPLEMENTED.
#' @param verbose an indicator if model output should be printed to the screen during maximization (or minimization of negative log-likelihood)
#' @param iter.lim a scalar to denote the maximum iteration limit. Default value is 100.
#' @param return_args indicator to denote if attributes of the output should be printed.
#'
#' @return This function returns marginal mean (beta) and dependence parameters (alpha) along with the associated model and empirical covariance matrices
#' @export
#'
#' @examples
#' \donttest{
#' data(datrand)
#' fit <- mm(Y~time*binary, t.formula=~1, data=datrand, id=id, step.max=4, verbose=FALSE)}

mm <- function(mean.formula, lv.formula = NULL, t.formula = NULL, id, data, inits = NULL,
               weight = NULL, offset = NULL, q = 30,
               step.max = 1, step.tol = 1e-06, hess.eps = 1e-07,
               adapt.quad = FALSE, verbose = FALSE, iter.lim=100, return_args=FALSE) {

  if(is.null(lv.formula) & is.null(t.formula)) {
    stop('Specify association model (both lv.formula and t.formula arguments cannot be NULL.')}
  if(!is.data.frame(data)) {
    data <- as.data.frame(data)
    warning('data converted to data.frame.')
  }

  terms = unique( c(all.vars(mean.formula), all.vars(lv.formula), all.vars(t.formula),
                    as.character(substitute(id))) )
  data  = data[,terms]
  if(any(is.na(data))) data = na.omit(data)
  id0   =  as.character(substitute(id))
  id    = data$id    = data[ , id0 ]

  if(q<=1) q <- 2
  if(is.null(lv.formula)) q = 1

  mean.f = model.frame(mean.formula, data)
  mean.t = attr(mean.f, "terms")
  y  = model.response(mean.f,'numeric')
  uy = unique(y)
  x  = model.matrix(mean.formula,mean.f)

  x.t = x.lv = matrix(0, ncol=1, nrow=length(y))
  if(!is.null(t.formula))   x.t  = model.matrix(t.formula,model.frame(t.formula, data))
  if(!is.null(lv.formula))  x.lv = model.matrix(lv.formula, model.frame(lv.formula, data))


  useROBCOV <- TRUE
  if(is.null(weight)) {
    weight = matrix(1,nrow=length(y),ncol=1)
    useROBCOV <- FALSE
  }

  if (!is.null(inits)) {
    inits <- unlist(inits)
  }

  if(is.null(inits)) {
    inits = c(glm(mean.formula,family='binomial',data=data)$coef, rep(1, ncol(x.t) + ncol(x.lv)))
    if(any(is.na(inits))) {
      omit_dup_col = which(is.na(inits))
      x            = x[,-c(omit_dup_col)]
      inits        = inits[-c(omit_dup_col)]
    }
  }

  if(is.null(offset)) {
    offset <- rep(0, length(y))
  }

  mm.fit = MMLongit(params=inits, id=id, X=x, Y=y, Xgam=x.t, Xsig=x.lv, Q=q,
                    weight=weight, offset=offset,
                    stepmax=step.max, steptol=step.tol, hess.eps=hess.eps,
                    AdaptiveQuad=adapt.quad, verbose=verbose,iterlim=iter.lim)

  nms = list()
  nms$beta = colnames(x)
  nms$alpha = c( if(!is.null(t.formula)){paste('gamma',colnames(x.t),sep=':')},
                 if(!is.null(lv.formula)){paste('log(sigma)',colnames(x.lv),sep=':')})

  out = NULL
  out$call    = match.call()
  out$logLik = mm.fit$logL
  out$beta  = mm.fit$beta
  out$alpha = mm.fit$alpha
  out$mod.cov = mm.fit$modelcov
  out$rob.cov = mm.fit$empiricalcov
  names(out$beta) = nms$beta
  names(out$alpha) = nms$alpha
  colnames(out$mod.cov) = rownames(out$mod.cov) = colnames(out$rob.cov) = rownames(out$rob.cov) = unlist(nms)

  out$control = with(mm.fit, c(AdaptiveQuad, code, niter, length(table(id)), max(table(id)),
                               useROBCOV))
  names(out$control) <- c('adaptive.quad','convergence_code','n_iter','n_subj','max_n_visit','useRobCov')


  aic = function(l=mm.fit$logL,k=nrow(mm.fit$modelcov)) 2*k-2*l
  bic = function(l=mm.fit$logL,k=nrow(mm.fit$modelcov),n=length(table(id))) -2*l + k *log(n)
  deviance = function(l=mm.fit$logL) -2*l
  out$info_stats = c(aic(),bic(),mm.fit$logL,deviance())
  names(out$info_stats) = c('AIC','BIC','logLik','Deviance')
  out$LogLikeSubj = mm.fit$LogLikeSubj
  out$ObsInfoSubj = mm.fit$ObsInfoSubj
  out$LLSC_args   = mm.fit$LLSC_args

  if(return_args) attr(out,'args') <- list('mean.formula'=mean.formula, 't.formula'=t.formula, 'lv.formula'=lv.formula,
                                           'id'=id0, 'weight'=weight,'offset'=offset)
  class(out) = 'MMLong'
  out
}
