####**********************************************************************
####**********************************************************************
####
####  BOOSTED MULTIVARIATE TREES FOR LONGITUDINAL DATA (BOOSTMTREE)
####  Version 1.5.1 (_PROJECT_BUILD_ID_)
####
####  Copyright 2016, University of Miami
####
####  This program is free software; you can redistribute it and/or
####  modify it under the terms of the GNU General Public License
####  as published by the Free Software Foundation; either version 3
####  of the License, or (at your option) any later version.
####
####  This program is distributed in the hope that it will be useful,
####  but WITHOUT ANY WARRANTY; without even the implied warranty of
####  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
####  GNU General Public License for more details.
####
####  You should have received a copy of the GNU General Public
####  License along with this program; if not, write to the Free
####  Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
####  Boston, MA  02110-1301, USA.
####
####  ----------------------------------------------------------------
####  Project Partially Funded By:
####  ----------------------------------------------------------------
####  Dr. Ishwaran's work was funded in part by grant R01 CA163739 from
####  the National Cancer Institute.
####
####  Dr. Kogalur's work was funded in part by grant R01 CA163739 from 
####  the National Cancer Institute.
####  ----------------------------------------------------------------
####  Written by:
####  ----------------------------------------------------------------
####    Hemant Ishwaran, Ph.D.
####    Professor, Division of Biostatistics
####    Clinical Research Building, Room 1058
####    1120 NW 14th Street
####    University of Miami, Miami FL 33136
####
####    email:  hemant.ishwaran@gmail.com
####    URL:    http://web.ccs.miami.edu/~hishwaran
####    --------------------------------------------------------------
####    Amol Pande, Ph.D.
####    Assistant Staff,
####    Thoracic and Cardiovascular Surgery
####    Heart and Vascular Institute
####    JJ4, Room 508B,
####    9500 Euclid Ave,
####    Cleveland Clinic, Cleveland, Ohio, 44195
####
####    email:  amoljpande@gmail.com
####    --------------------------------------------------------------
####    Udaya B. Kogalur, Ph.D.
####    Kogalur & Company, Inc.
####    5425 Nestleway Drive, Suite L1
####    Clemmons, NC 27012
####
####    email:  ubk@kogalur.com
####    URL:    http://www.kogalur.com
####    --------------------------------------------------------------
####
####**********************************************************************
####**********************************************************************


boostmtree <- function(x,
                       tm,
                       id,
                       y,
                       family = c("Continuous","Binary","Nominal","Ordinal"),
                       y_reference = NULL,
                       M = 200,
                       nu = 0.05,
                       na.action = c("na.omit","na.impute")[2],
                       K = 5,
                       mtry = NULL,
                       nknots = 10,
                       d = 3,
                       pen.ord = 3,
                       lambda,
                       rho, 
                       lambda.max = 1e6,
                       lambda.iter = 2,
                       svd.tol = 1e-6,
                       forest.tol = 1e-3,
                       verbose = TRUE,
                       cv.flag = FALSE,
                       eps = 1e-5,
                       mod.grad = TRUE,
                       NR.iter = 3,
                       ...)
{
  if(Sys.info()["sysname"] == "Windows")
  {
    options(rf.cores = 1, mc.cores = 1)
  }
  if(length(family) != 1){
    stop("Specify any one of the four families")
  }
  if(any(is.na( match(family,c("Continuous","Binary","Nominal","Ordinal"))))){
    stop("family must be any one from Continuous, Binary, Nominal or Ordinal")
  }
  univariate <- FALSE
  if (missing(tm)) {
    id <- 1:nrow(x)
  }
  id.unq <- sort(unique(id))
  n <- length(id.unq)
  if (length(id.unq) == length(id)) {
    univariate <- TRUE
    tm <- rep(0, n)
    d <- -1
  }
  if(family == "Continuous"){
    Q_set <- NA
    n.Q <- 1
  } else
  {
  #---------------------------------------------------------------------------------- 
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Added the following if statement because binary/nominal/ordinal response
  # could be a factor or a character.
  #----------------------------------------------------------------------------------
    if(!is.numeric(y)){
      y <- as.numeric(factor(y))
    }
    y.unq <- sort(unique(y))
    Q   <- length(y.unq)
    if(family == "Nominal"){
      if(is.null(y_reference)){
        y_reference <- min(y.unq)
      } else
      {
        if(length(y_reference) != 1 || is.na(match(y_reference,y.unq))){
          stop(paste("y_reference must take any one of the following:",y.unq,sep=" "))
        }
      }
      Q_set <- setdiff(y.unq,y_reference)
    }
    if(family == "Ordinal")
    {
      Q_set <- setdiff(y.unq,max(y.unq))
    }
    if(family == "Binary"){
      Q_set <- setdiff(y.unq,min(y.unq))
    }
    n.Q  <- length(Q_set)
  }
  if (univariate) {
    mod.grad <- FALSE
    rho <- rep(0,n.Q)
    lambda.mat <- phi.mat <- rho.mat <- NULL
  }
  user.option <- list(...)
  if (any(is.na(id)) || any(is.na(y)) || any(is.na(tm))) {
    stop("missing values encountered y or id or tm: remove observations with missing values")
  }
  x <- as.data.frame(x)
  X <- do.call(rbind, lapply(1:n, function(i) {
    x[id == id.unq[i],, drop = FALSE][1,, drop = FALSE]}))
  x <- do.call(rbind, lapply(1:n, function(i) {x[id == id.unq[i],, drop = FALSE]}))
  #---------------------------------------------------------------------------------- 
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Added the below three lines so that id, tm and y are consistent with x (as
  # described on the line above)
  #----------------------------------------------------------------------------------
  id <- unlist(lapply(1:n,function(i){ id[id == id.unq[i] ]    }))
  tm <- unlist(lapply(1:n,function(i){ tm[id == id.unq[i] ]    }))
  y <- unlist(lapply(1:n,function(i){ y[id == id.unq[i] ]    }))    
  if(any(is.na(X))){
    RemoveMiss.Obj <- RemoveMiss.Fun(X)
    X <- RemoveMiss.Obj$X
    id_all_na <- RemoveMiss.Obj$id.remove
    id_any_na <- which(unlist(lapply(1:nrow(X),function(i){ any(is.na(X[i,])) } )))
    if(na.action == "na.omit"){
      id_na <- id_any_na
    } else
    {
      id_na <- id_all_na
    }
    if( length(id_na) > 0 ){
      id.remove <- id.unq[id_na]
      id.unq <- setdiff(id.unq,id.remove)
      n <- length(id.unq)
      tm <- unlist(lapply(1:n,function(i){ tm[id == id.unq[i] ]    }))
      y <- unlist(lapply(1:n,function(i){ y[id == id.unq[i] ]    }))
      x <- do.call(rbind, lapply(1:n, function(i) {x[id == id.unq[i],, drop = FALSE]}))
      id <- unlist(lapply(1:n,function(i){ id[id == id.unq[i] ]    }))
    }
  }
  p <- ncol(X)
  xvar.names <- colnames(X)
  if(family == "Continuous"){
    Ymean <- mean(y, na.rm = TRUE)
    Ysd <- sd(y, na.rm = TRUE)
    if (Ysd < 1e-6) {
      Ysd <- 1
    }
  }
  else{
    Ymean <- 0
    Ysd <- 1
  }
  ni <- unlist(lapply(1:n, function(i) {sum(id == id.unq[i])}))
  #----------------------------------------------------------------------------------
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # We already sorted the id by arranging id already sorted by id.unq.
  # Therefore, we don't need to sort id here. Commenting out the line below
  #----------------------------------------------------------------------------------
  # id <- sort(id)
  tm.unq <- sort(unique(tm))
  n.tm <- length(tm.unq)
  tm.id <- lapply(1:n, function(i) {
    tm.i <- tm[id == id.unq[i]]
    match(tm.i, tm.unq)
  })
  tm.list <- lapply(1:n, function(i) {tm[id == id.unq[i]]})
  if (nknots < 0) {
    warning("bsplines require a positive number of knots: eliminating b-spline fitting")
    d <- 0
  }
  if (d >= 1) {
    if (n.tm > 1) {
      bs.tm <- bs(tm.unq, df = nknots + d, degree = d)
      X.tm <- cbind(1, bs.tm)
      attr(X.tm, "knots") <- attr(bs.tm, "knots")
      attr(X.tm, "Boundary.knots") <- attr(bs.tm, "Boundary.knots")
    }
    else {
      X.tm <- cbind(1, cbind(tm.unq))
    }
  }
  else {    
    X.tm <- cbind(rep(1, n.tm))
    lambda <- rep(0,n.Q)
  }
  df.D <- ncol(X.tm)
  D <- lapply(1:n, function(i) {
    cbind(X.tm[tm.id[[i]],, drop = FALSE])
  })
  nu <- {if (length(nu) > 1) nu else rep(nu, 2)}
  if (sum(!(0 < nu & nu <= 1)) > 0) {
    stop("regularization parameter (nu) must be in (0,1]")
  }
  nu.vec <- c(nu[1], rep(nu[2], df.D - 1))
  ntree <- is.hidden.ntree(user.option)
  #----------------------------------------------------------------------------------
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # **** PROBLEM **** 
  # I tried to use bootstrap <- "none" and it didn't work
  # because the error occurs in the generic.predict.rfsrc function.
  # This is likely a bug due to specification of ptn.count in the predict.rfsrc function.
  # As a temporary solution, when bootstrap = "none", convert bootstrap = "by.user"
  # and set bst.frac = 1.
  #----------------------------------------------------------------------------------
  bootstrap <- is.hidden.bootstrap(user.option)
  bst.frac <- is.hidden.bst.frac(user.option)
  samp.mat <- is.hidden.samp.mat(user.option)
  if(bootstrap == "none"){
    bootstrap <- "by.user"
    bst.frac <- 1
  }
  #----------------------------------------------------------------------------------
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Added an option where users can specify his/her own inbag sample
  # for each boosting iteration using argument samp.mat
  #----------------------------------------------------------------------------------
  if(bootstrap == "by.user"){
    if(missing(bst.frac)){
      bst.frac <- 0.632
    }
    if(is.null(samp.mat)){
    samp.mat <- matrix(NA,nrow = n,ncol = M)
    for(i in 1:M){
      samp.value <- (sample(1:n,floor(bst.frac*n),replace = FALSE))
      samp.value <- sort(c(samp.value,sample(samp.value, n - length(samp.value),replace = TRUE)))
      samp.value <- unlist(lapply(1:n,function(i){
        sum(samp.value == i)
      }))
      samp.mat[,i] <- samp.value
    }
    }
  }
  #----------------------------------------------------------------------------------
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Added an option where users can specify nsplit. The default is to use all
  # the possible splitting points.
  #----------------------------------------------------------------------------------
  nsplit <- is.hidden.nsplit(user.option)
  #----------------------------------------------------------------------------------
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Added an option where users can specify bootstrap sample with/our replacement.
  # Default is sampling without replacement.
  #----------------------------------------------------------------------------------
  samptype <- is.hidden.samptype(user.option)
  #----------------------------------------------------------------------------------
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Add mtry = NULL in the function argument, and corresponding change it to
  # mtry = p if NULL. In the earlier version mtry was mtry = df.D + p
  #----------------------------------------------------------------------------------
  if (ntree == 1) {
    nodesize <- max(1, round(n/(2 * K)))
    if(is.null(mtry)){
        mtry <- p
    }
  }
  else {
    nodedepth <- max(0, log(max(0, K), base = 2))
    nodesize <- 1
    mtry <- NULL
    if (missing(lambda) || lambda < 0) {
      lambda <- rep(0,n.Q)
    }
  }
  #----------------------------------------------------------------------------------
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Added an option xvar.wt and case.wt where users can specify weights for the
  # covariates and observations. 
  #----------------------------------------------------------------------------------
  xvar.wt <- is.hidden.xvar.wt(user.option)
  case.wt <- is.hidden.case.wt(user.option)
  #----------------------------------------------------------------------------------
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Added an option seed.value to specify value of the seed. This helps to get the
  # same randomization, which helps to compare two boosting model.
  # Default is NULL, meaning the seed value is set randomly.
  #----------------------------------------------------------------------------------
  seed.value <- is.hidden.seed.value(user.option)
  if (ntree > 1) {
    if (univariate) {
      learnerUsed <- "forest learner"
    }
    else {
      learnerUsed <- "mforest learner"
    }
  }
  else {
    if (df.D == 1) {
      learnerUsed <- "tree learner"
    }
    else {
      learnerUsed <- "mtree-Pspline learner"
    }
  }
  lambda.est.flag <- FALSE
  if(!missing(lambda)){
    if(length(lambda) == 1){
      lambda <- rep(lambda,n.Q)  
    }
  }
  pen.lsq.matx <- penBSderiv(df.D - 1, pen.ord)
  if (!univariate && ntree == 1 && (missing(lambda) || lambda < 0)) {
    if (df.D >= (pen.ord + 2)) {
      lambda.est.flag <- TRUE
      pen.mix.matx <- penBS(df.D - 1, pen.ord)
      svd.pen <- svd(pen.mix.matx)
      d.zap <- svd.pen$d < svd.tol
      d.sqrt <- sqrt(svd.pen$d)
      d.sqrt[d.zap] <- 0
      d.inv.sqrt <- 1 / sqrt(svd.pen$d)
      d.inv.sqrt[d.zap] <- 0
      pen.inv.sqrt.matx <- svd.pen$v %*% (t(svd.pen$v) * d.inv.sqrt)
      lambda <- rep(0,n.Q)
    }
    else {
      warning("not enough degrees of freedom to estimate lambda: setting lambda to zero\n")
      lambda <- rep(0,n.Q)
    }
  }
  Yq <- lapply(1:n.Q,function(q){
    if(family == "Continuous"){
      out <- y
    }
  #---------------------------------------------------------------------------------- 
  # Date: 06/04/2020
  # Following comment added while editing for the nominal/ordinal response
  # Following line was modified such that condition for nominal and binary
  # became same. This is in conjunction to changes in the other non-continuous
  # responses so that user can specify factor/character response, and it will be
  # converted to numeric response. 
  #----------------------------------------------------------------------------------
    if(family == "Nominal" || family == "Binary"){
      out <- ifelse(y == Q_set[q],1,0)
    }
    if(family == "Ordinal"){
      out <- ifelse(y <= Q_set[q],1,0)
    }
    out
  })
  Yorg <- lapply(1:n.Q,function(q){
    lapply(1:n, function(i) { Yq[[q]][id == id.unq[i]] })
  })
  Y <- lapply(1:n.Q,function(q){
    lapply(1:n, function(i) {(Yq[[q]][id == id.unq[i]] - Ymean) / Ysd})
  })
  if (ntree == 1) {
    baselearner <- membership.list <- gamma.list <- lapply(1:n.Q,function(q){
      lapply(1:M,function(m){
        NULL
      })
    })
  }
  else {
   membership.list <- gamma.list <- NULL
   baselearner <- vector("list", length = M)
  }
  if (!univariate) {
    lambda.mat <- phi.mat <- rho.mat <- matrix(NA,nrow = M,ncol = n.Q)
  }
  lambda.initial <- Ysd^2
  rho.fit.flag <- TRUE
  rho.tree.grad <- 0
  rho.hide <- is.hidden.rho(user.option)
  if (!is.null(rho.hide) && (rho.hide >= 0 && rho.hide < 1)) {
    rho.fit.flag <- FALSE
    rho <- rep(rho.hide,n.Q)
  }
  else {
    rho <- rep(0,n.Q)
  }
  sigma <- phi <- rep(1,n.Q)
  if (!lambda.est.flag) {
    sigma <- unlist(lapply(1:n.Q,function(q){
      sigma.robust(lambda[q], rho[q])
    }))
  }
  Y.names <- paste("Y", 1:df.D, sep = "")
  rfsrc.f <- as.formula(paste("Multivar(", paste(Y.names, collapse = ","), paste(") ~ ."), sep = ""))
  cv.flag <- cv.flag && (ntree == 1)
  cv.lambda.flag <- cv.flag && is.hidden.CVlambda(user.option) && lambda.est.flag
  cv.rho.flag <- cv.flag && is.hidden.CVrho(user.option) && rho.fit.flag
  #---------------------------------------------------------------------------------- 
  # Date: 06/05/2020
  # Following comment added while editing for the nominal/ordinal response
  # This needs more thoughts because, it probably okay to start l_pred_bd = 0
  # for binary and continuous case. However, is it a good starting point for
  # nominal and ordinal case?
  # Same logic should apply when l_pred_db.i under cv.flag = TRUE 
  #----------------------------------------------------------------------------------
  l_pred_db <- lapply(1:n.Q,function(q){
    lapply(1:n,function(i){
      rep(0,ni[i])
    })
  })
  if (cv.flag) {
    mu.cv.list <- lapply(1:n.Q,function(q){
      vector("list", M)
    })
    if(family == "Nominal"){
      l_pred_ref.cv <- lapply(1:n,function(i){
        rep(log(1/Q),ni[i])
      })
    } else
    {
      l_pred_ref.cv <- lapply(1:n,function(i){
        rep(0,ni[i])
      })
    }
    l_pred.cv <- lapply(1:n.Q,function(q){
          lapply(1:n, function(i) { l_pred_ref.cv[[i]] +  l_pred_db[[q]][[i]] })
    })
    mu.cv <- lapply(1:n.Q,function(q){
      lapply(1:n,function(i){
        GetMu(Linear_Predictor = l_pred.cv[[q]][[i]],Family = family)
      })
    })
    l_pred_db.i <- lapply(1:n.Q,function(q){
      lapply(1:n, function(i) {
        lapply(1:n, function(j) { rep(0,ni[j]) })
      })
    })
    gamma.i.list <- lapply(1:n.Q,function(q){
      lapply(1:M,function(m){
        vector("list", length = n)
      })
    })
    err.rate <- lapply(1:n.Q,function(q){
      err.rate_mat <- matrix(NA, M, 2)
      colnames(err.rate_mat) <- c("l1", "l2")
      err.rate_mat
    })
    Mopt <- rmse <- rep(NA,n.Q)
    if(family == "Continuous"){
      Ymean.i <- lapply(1:n.Q,function(q){
        sapply(1:n, function(i) {
          mean(unlist(Yorg[[q]][-i]), na.rm = TRUE)
        })
      })
      Ysd.i <- lapply(1:n.Q,function(q){
        sapply(1:n, function(i) {
          sd.i <- sd(unlist(Yorg[[q]][-i]), na.rm = TRUE)
          if (sd.i < 1e-6) {
            1
          }
          else {
            sd.i
          }
        })
      })
    }
    else{
      Ymean.i <- lapply(1:n.Q,function(q){
        unlist(lapply(1:n,function(i){ Ymean  }))
      })
      Ysd.i   <- lapply(1:n.Q,function(q){
        unlist(lapply(1:n,function(i){ Ysd  }))
      })
    }
  }
  else {
    err.rate <- rmse <- Mopt <- NULL
  }
  if(family == "Continuous"){
    NR.iter <- 1
  }
  if(family == "Nominal"){
    l_pred_ref <- lapply(1:n,function(i){
      rep(log(1/Q),ni[i])
    })
  } else
  {
    l_pred_ref <- lapply(1:n,function(i){
      rep(0,ni[i])
    })
  }
  if (verbose) pb <- txtProgressBar(min = 0, max = M, style = 3)
  for (m in 1:M) {
    if(m == 1){
      l_pred <- lapply(1:n.Q,function(q){
          lapply(1:n, function(i) { l_pred_ref[[i]] +  l_pred_db[[q]][[i]] })
      })
      mu <- lapply(1:n.Q,function(q){
        lapply(1:n,function(i){
          GetMu(Linear_Predictor =l_pred[[q]][[i]],Family = family)
        })
      }) 
    }
  if (verbose) setTxtProgressBar(pb, m)
    if (verbose && m == M) cat("\n")
for(q in 1:n.Q) {
    VMat <- lapply(1:n,function(i){
      VarTemp <- matrix(rho[q]*phi[q],ni[i],ni[i])
      diag(VarTemp) <- phi[q]
      VarTemp
    })
    inv.VMat <- lapply(1:n,function(i){
      out <- tryCatch({ qr.solve(VMat[[i]])},
                      error = function(ex){NULL})
      if(is.null(out)){
        out <- diag(phi[q],nrow(VMat[[i]]))
      }
      out
    })
    H_Mu <- lapply(1:n,function(i){
      Transform_H(Mu = mu[[q]][[i]], Family = family)
    })
    if (mod.grad == FALSE) {
      gm.mod <- t(matrix(unlist(lapply(1:n, function(i) {
         t(D[[i]])%*%H_Mu[[i]]%*%inv.VMat[[i]]%*%(Y[[q]][[i]] - mu[[q]][[i]])  
      })), nrow = df.D))
    }
    else {
      gm.mod <- t(matrix(unlist(lapply(1:n, function(i) {
        t(D[[i]])%*%H_Mu[[i]]%*%(Y[[q]][[i]] - mu[[q]][[i]])
      })), nrow = df.D))
    }
    incoming.data <- cbind(gm.mod, X)
    names(incoming.data) = c(Y.names, names(X))
    if (ntree > 1) {
      rfsrc.obj <- rfsrc(rfsrc.f,
                         data = incoming.data,
                         mtry = mtry,
                         nodedepth = nodedepth,
                         nodesize = nodesize,
                         nsplit = nsplit,
                         importance = "none",
                         bootstrap = bootstrap,
                         samptype = samptype,
                         ntree = ntree,
                         xvar.wt = xvar.wt,
                         case.wt = case.wt,
                         forest.wt = TRUE, 
                         memebership = TRUE)
      Kmax <- max(rfsrc.obj$leaf.count, na.rm = TRUE)
      baselearner[[m]] <- list(forest = rfsrc.obj)
    }
    else {
      rfsrc.obj <- rfsrc(rfsrc.f,
                         data = incoming.data,
                         ntree = 1,
                         mtry = mtry,
                         nodesize = nodesize,
                         nsplit = nsplit,
                         importance = "none",
                         bootstrap = bootstrap,
                         samptype = samptype,
                         samp = if(bootstrap == "by.user") samp.mat[,m,drop = FALSE] else NULL,
                         xvar.wt = xvar.wt,
                         case.wt = case.wt,
                         membership = TRUE,
                         na.action = na.action,
                         nimpute = 1,
                         seed = seed.value)
      baselearner[[q]][[m]] <- rfsrc.obj
      result.pred <- predict.rfsrc(rfsrc.obj,
                                   membership = TRUE,
                                   ptn.count = K,
                                   importance = "none")
      membership <- membership.org <- c(result.pred$ptn.membership)
      membership.list[[q]][[m]] <- membership.org
      membership <- as.numeric(factor(membership))
      ptn.id <- unique(membership)
      Kmax <-  length(ptn.id)
    }
    if (ntree == 1) {
      if (lambda.est.flag) {
        transf.data <- papply(1:n, function(i) {
          if (ni[i] > 1) {
            ci <- rho.inv.sqrt(ni[i], rho[q])
            R.inv.sqrt <- (diag(1, ni[i]) - matrix(ci, ni[i], ni[i])) / sqrt(1 - rho[q])
            V.inv.sqrt <- phi[q]^(-1/2)*R.inv.sqrt
          }
          else {
            R.inv.sqrt <- cbind(1)
            V.inv.sqrt <- phi[q]^(-1/2)*R.inv.sqrt
          }
          if (cv.lambda.flag) {
            Ynew <- V.inv.sqrt %*% (Y[[q]][[i]] - mu.cv[[q]][[i]])
          }
          else {
            Ynew <- V.inv.sqrt %*% (Y[[q]][[i]] - mu[[q]][[i]])
          }
            mu.2 <- GetMu_Lambda(Linear_Predictor = 2*l_pred[[q]][[i]],Family = family)
            LambdaD <- Transform_H(mu.2,Family = family)%*%D[[i]]
            Xnew <- V.inv.sqrt %*% LambdaD[, 1, drop = FALSE]
            Znew <- V.inv.sqrt %*% LambdaD[, -1, drop = FALSE] %*% pen.inv.sqrt.matx
          list(Ynew = Ynew, Xnew = Xnew, Znew = Znew)
        })
        lambda.hat <- lambda.initial
        for (k in 1:lambda.iter) {
          blup.obj <-  blup.solve(transf.data, membership, lambda.hat, Kmax)
          lambda.obj <- lapply(1:Kmax, function(k) {
            pt.k <- (membership == k)
            Z <- do.call(rbind, lapply(which(pt.k), function(j) {transf.data[[j]]$Znew}))
            X <- do.call(rbind, lapply(which(pt.k), function(j) {transf.data[[j]]$Xnew}))
            Y <- unlist(lapply(which(pt.k), function(j) {transf.data[[j]]$Ynew}))
            ZZ <- t(Z) %*% Z
            rss <- (Y - X %*% c(blup.obj[[k]]$fix.eff))^2
            robust.pt <- (rss <= quantile(rss, .99, na.rm = TRUE))
            rss <- sum(rss[robust.pt], na.rm = TRUE)
            resid <- (Y - X %*% c(blup.obj[[k]]$fix.eff) - Z %*% c(blup.obj[[k]]$rnd.eff))^2
            resid <- resid[robust.pt]
            return(list(trace.Z = sum(diag(ZZ)), rss = rss, resid = resid))
          })
          num <- sum(unlist(lapply(1:Kmax, function(k) {lambda.obj[[k]]$trace.Z})), na.rm = TRUE)
          den <- sum(unlist(lapply(1:Kmax, function(k) {lambda.obj[[k]]$rss})), na.rm = TRUE)
          N <- sum(unlist(lapply(1:Kmax, function(k) {lambda.obj[[k]]$resid})), na.rm = TRUE)
          if (!is.na(den) && den > (.99 * N)) {
            lambda.hat <- num / (den - .99 * N)
          }
          else {
            lambda.hat <- min(lambda.hat, lambda.max)
          }
          lambda.hat <- min(lambda.hat, lambda.max)
        }
        lambda[q] <- lambda.hat 
        sigma[q] <- sigma.robust(lambda[q], rho[q]) 
      }
      gamma <- lapply(1:Kmax, function(k) {
        pt.k <- (membership == k)
        if (sum(pt.k) > 0) {
          which.pt.k <- which(pt.k == TRUE)
          seq.pt.k <- seq(length(which.pt.k) )
          gamma.NR.update <- rep(0,df.D)
          for(Iter in 1:NR.iter){
          mu.NR.update <- lapply(which.pt.k,function(i){
               l_pred_gamma <- l_pred[[q]][[i]]  + c(D[[i]]%*%gamma.NR.update)
               out <- GetMu(Linear_Predictor = l_pred_gamma, Family = family)
               out
          })
          CalD.i <- lapply(seq.pt.k,function(i){
            out_H_Mat <- Transform_H(Mu = mu.NR.update[[i]], Family = family)
            out <- out_H_Mat%*%D[[ which.pt.k[i] ]]
            out
          })
          HesMat.temp <- Reduce("+",lapply(seq.pt.k,function(i){
            t(CalD.i[[i]])%*%inv.VMat[[ which.pt.k[i] ]]%*%CalD.i[[i]]
          }))
          HesMat <- HesMat.temp + (lambda[q]*pen.lsq.matx)
          ScoreVec.temp <-  Reduce("+",lapply(seq.pt.k,function(i){
            t(CalD.i[[i]])%*%inv.VMat[[ which.pt.k[i] ]]%*%(Y[[q]][[ which.pt.k[i]   ]] - mu.NR.update[[ i ]] )
          }))
          ScoreVec <- ScoreVec.temp - (lambda[q]*(pen.lsq.matx%*%gamma.NR.update))
          qr.obj <- tryCatch({qr.solve(HesMat, ScoreVec)}, error = function(ex){NULL})
          if (!is.null(qr.obj)) {
            qr.obj <- qr.obj
          }
          else {
            qr.obj <- rep(0, df.D)
          }
          gamma.NR.update <- gamma.NR.update + qr.obj
          }
          gamma.NR.update
        }
        else {
          rep(0, df.D)
        }
      })
      gamma.matx <- matrix(0, Kmax, df.D + 1)
      gamma.matx[, 1] <- sort(unique(membership.org))
      gamma.matx[, 2:(df.D+1)] <- matrix(unlist(gamma), ncol = df.D, byrow = TRUE)
      gamma.list[[q]][[m]] <- gamma.matx
      bhat <- t(matrix(unlist(lapply(1:n, function(i) {
        gamma[[membership[i]]]})), nrow = df.D) * nu.vec)
      l_pred_db[[q]] <- lapply(1:n, function(i) { 
           l_pred_db_Temp <- l_pred_db[[q]][[i]] + c(D[[i]] %*% bhat[i, ])
           if(family == "Ordinal" && q > 1){
               l_pred_db_Temp <- ifelse(l_pred_db_Temp < l_pred_db[[q-1]][[i]],l_pred_db[[q-1]][[i]],l_pred_db_Temp)
           }
           l_pred_db_Temp
        })
  #----------------------------------------------------------------------------------
  # Date: 06/06/2020
  # Following comment added while editing for the nominal/ordinal response
  # Earlier issue where l_pred_{q + 1} could be less than l_pred_{q} is now resolved.
  # The issued occured because the condition that I have placed to set
  # l_pred_{q + 1} = l_pred_{q} for the observations where l_pred_{q + 1} < l_pred_{q}
  # was applied only to the out-of-bag cases; now it is applied to both in-bag and
  # out-of-bag sample. 
  #----------------------------------------------------------------------------------
      if (cv.flag) {
        oob <- which(rfsrc.obj$inbag == 0) 
        l_pred_db.i[[q]] <- lapply(1:n,function(i) {
          if( any(i == oob )){
          mem.i <- membership[i]  
          l_pred.ij <- l_pred_db.i[[q]][[i]]
          gamma.i <- lapply(1:Kmax, function(k) {
            pt.k <- (membership == k)
            which.pt.k <- setdiff(which(pt.k == TRUE) ,i)
            if (sum(pt.k) > 0 && length(which.pt.k) > 0) {
              seq.pt.k <- seq(length(which.pt.k) )
              gamma.NR.update <- rep(0,df.D)
              for(Iter in 1:NR.iter){
                mu.NR.update <- lapply(which.pt.k,function(j){
                  l_pred_gamma <- l_pred.ij[[j]]  + c(D[[j]]%*%gamma.NR.update)
                  out <- GetMu(Linear_Predictor = l_pred_gamma, Family = family)
                  out
                })
                CalD.i <- lapply(seq.pt.k,function(j){
                  out_H_Mat <- Transform_H(Mu = mu.NR.update[[j]], Family = family)
                  out <- out_H_Mat%*%D[[ which.pt.k[j] ]]
                  out
                })
                HesMat.temp <- Reduce("+",lapply(seq.pt.k,function(j){
                  t(CalD.i[[j]])%*%inv.VMat[[ which.pt.k[j] ]]%*%CalD.i[[j]]
                }))
                HesMat <- HesMat.temp + (lambda[q]*pen.lsq.matx)
                ScoreVec.temp <-  Reduce("+",lapply(seq.pt.k,function(j){
                  t(CalD.i[[j]])%*%inv.VMat[[ which.pt.k[j] ]]%*%(Y[[q]][[ which.pt.k[j]   ]] - mu.NR.update[[ j ]] )
                }))
                ScoreVec <- ScoreVec.temp - (lambda[q]*(pen.lsq.matx%*%gamma.NR.update))
                qr.obj <- tryCatch({qr.solve(HesMat, ScoreVec)}, error = function(ex){NULL})
                if (!is.null(qr.obj)) {
                  qr.obj <- qr.obj
                }
                else {
                  qr.obj <- rep(0, df.D)
                }
                gamma.NR.update <- gamma.NR.update + qr.obj
              }
              gamma.NR.update
            }
            else {
              rep(0, df.D)
            }
          })
          gamma.matx.i <- matrix(0, Kmax, df.D + 1)
          gamma.matx.i[, 1] <- sort(unique(membership.org))
          gamma.matx.i[, 2:(df.D+1)] <- matrix(unlist(gamma.i), ncol = df.D, byrow = TRUE)
          gamma.i.list[[q]][[m]][[i]] <<- gamma.matx.i
          l_pred_db.ij_Temp <- lapply(1:n,function(j){
            which.j <- which(gamma.matx.i[, 1] == membership.org[j])
            l_pred_db.ij_Temp <- l_pred.ij[[j]] + c(D[[j]] %*% (gamma.matx.i[which.j, -1] * nu.vec))
          })
       }else
       {
         l_pred_db.ij_Temp <- l_pred_db.i[[q]][[i]]
       }
       l_pred_db.ij_Temp
     }) 
    if(family == "Ordinal" && q > 1){
      for(i in 1:n){
          for(j in 1:n){
            l_pred_db.ij_Temp <- l_pred_db.i[[q]][[i]][[j]]
            l_pred_db.ij_Temp <- ifelse(l_pred_db.ij_Temp < l_pred_db.i[[q-1]][[i]][[j]],l_pred_db.i[[q-1]][[i]][[j]],l_pred_db.ij_Temp)
            l_pred_db.i[[q]][[i]][[j]] <- l_pred_db.ij_Temp
          } 
        }
      }
    }                 
    }
    else{
      forest.wt <- rfsrc.obj$forest.wt
      Xnew <- mclapply(1:n, function(i) {
        rmi <- rho.inv(ni[i], rho)
        Wi <- diag(1, ni[i]) - matrix(rmi, ni[i], ni[i])
        t(D[[i]]) %*% Wi %*% D[[i]]
      })
      bhat <- do.call("cbind", mclapply(1:n, function(i) {
        fwt.i <- forest.wt[i, ]
        fwt.i[fwt.i <= forest.tol] <- 0
        pt.i <- (fwt.i != 0)
        if (sum(pt.i) > 0) {
          fwt.i <- fwt.i / sum(fwt.i)
          # 09/01/2020: Replace gm by gm.mod
          YnewSum <- colSums(fwt.i[pt.i] * gm.mod[pt.i,, drop = FALSE])
          XnewSum <- Reduce("+", lapply(which(pt.i), function(j) {fwt.i[j] * Xnew[[j]]}))
          XnewSum <- XnewSum + sigma * pen.lsq.matx
          qr.obj <- tryCatch({qr.solve(XnewSum, YnewSum)}, error = function(ex){NULL})
          if (!is.null(qr.obj)) {
            qr.obj
          }
          else {
            rep(0, df.D)
          }
        }
        else {
          rep(0, df.D)
        }
      }))
      bhat <- t(bhat * nu.vec)
      mu <- lapply(1:n, function(i) {mu[[i]] + D[[i]] %*% bhat[i, ]})
      baselearner[[m]] <- c(baselearner[[m]],
                            list(gm = gm.mod),
                            list(Xnew = Xnew),
                            list(pen = sigma * pen.lsq.matx))
    }
}
    if(cv.flag){
      if(family == "Nominal"){
        l_pred_ref.cv <- lapply(1:n,function(i){
          log((1 + (Reduce("+",lapply(1:n.Q,function(q){
            exp(l_pred_db.i[[q]][[i]][[i]])  
          }))))^{-1})
        })
      }
      for(q in 1:n.Q){
        l_pred.cv <-  lapply(1:n,function(i){ l_pred_ref.cv[[i]] + l_pred_db.i[[q]][[i]][[i]]})
        mu.cv[[q]] <- lapply(1:n,function(i){
            GetMu(Linear_Predictor = l_pred.cv[[i]],Family = family)
        })
        l_pred.cv.org <- lapply(1:n,function(i){l_pred.cv[[i]] * Ysd.i[[q]][i] + Ymean.i[[q]][i]})
        mu.cv.org <- lapply(1:n,function(i){
          GetMu(Linear_Predictor = l_pred.cv.org[[i]],Family = family)
        })
        mu.cv.list[[q]][[m]] <- mu.cv.org
        err.rate[[q]][m, ] <- c(l1Dist(Yorg[[q]], mu.cv.org), l2Dist(Yorg[[q]], mu.cv.org))
      }
    } else
    {
    if(family == "Nominal"){
      l_pred_ref <- lapply(1:n,function(i){
        log((1 + (Reduce("+",lapply(1:n.Q,function(q){
          exp(l_pred_db[[q]][[i]])  
        }))))^{-1})
      })
    }
    for(q in 1:n.Q){
    l_pred[[q]] <- lapply(1:n,function(i){
      l_pred_ref[[i]] + l_pred_db[[q]][[i]]
    })
    mu[[q]] <- lapply(1:n,function(i){
       GetMu(Linear_Predictor = l_pred[[q]][[i]],Family = family)
    }) 
    }
  }
  for(q in 1:n.Q){
    if (!univariate && rho.fit.flag) {
      if (cv.rho.flag) {
        resid.data <- data.frame(y  = unlist(lapply(1:n, function(i) {Y[[q]][[i]] - mu.cv[[q]][[i]]})),
                                 x,
                                 tm = unlist(lapply(1:n, function(i) {tm[id == id.unq[i]]})),
                                 id = unlist(lapply(1:n, function(i) {rep(id.unq[i], ni[i])})))
      }
      else {
        resid.data <- data.frame(y  = unlist(lapply(1:n, function(i) {Y[[q]][[i]] - mu[[q]][[i]]})),
                                 x,
                                 tm = unlist(lapply(1:n, function(i) {tm[id == id.unq[i]]})),
                                 id = unlist(lapply(1:n, function(i) {rep(id.unq[i], ni[i])})))
      }
      gls.obj <- tryCatch({gls(y ~ ., data = resid.data,
                               correlation = corCompSymm(form = ~ 1 | id))},
                          error = function(ex){NULL})
      if (is.null(gls.obj)) {
        gls.obj <- tryCatch({gls(y ~ 1, data = resid.data,
                                 correlation = corCompSymm(form = ~ 1 | id))},
                            error = function(ex){NULL})
      }
      if (!is.null(gls.obj)) {
        phi[q] <- gls.obj$sigma^2
        rho_temp <- as.numeric(coef(gls.obj$modelStruct$corStruc, unconstrained = FALSE))
        rho[q] <- max(min(0.999, rho_temp, na.rm = TRUE), -0.999)
      }
    }
    if (!univariate) {
      phi.mat[m,q] <- phi[q] * Ysd^2
      rho.mat[m,q] <- rho[q]
    }
    if (!univariate) {
      sigma[q] <- sigma.robust(lambda[q], rho[q])
      lambda.mat[m,q] <- lambda[q]
    }
    }
  } 
  if (cv.flag) {
    nullObj <- lapply(1:n.Q,function(q){
      diff.err <- abs(err.rate[[q]][, "l2"] - min(err.rate[[q]][, "l2"], na.rm = TRUE))
      diff.err[is.na(diff.err)] <- 1
      if (sum(diff.err < Ysd * eps) > 0) {
        Mopt[q] <<- min(which(diff.err < eps))
      }
      else {
        Mopt[q] <<- M
      }
      rmse[q] <<- err.rate[[q]][Mopt[q], "l2"]
      mu[[q]] <<- lapply(1:n,function(i){mu.cv.list[[q]][[ Mopt[q] ]][[i]]})
      NULL
    })
  }else
  {
  mu <- lapply(1:n.Q,function(q){
    lapply(1:n,function(i){
      l_pred_temp <- c(l_pred[[q]][[i]] * Ysd + Ymean)
      GetMu(Linear_Predictor = l_pred_temp,Family = family)
    })
  })
  }
  y <- lapply(1:n, function(i) {y[id == id.unq[i]]})
  if(family == "Ordinal"){
    Prob_class <- lapply(1:(n.Q+1),function(q){
      if(q == 1){
        out <- lapply(1:n,function(i){
          mu[[q]][[i]]
        })
      }
      if(q == (n.Q+1)){
        out <- lapply(1:n,function(i){
          1 - mu[[q-1]][[i]]
        })
      }
      if(q > 1 && q < (n.Q+1) ){
        out <- lapply(1:n,function(i){
          mu[[q]][[i]] - mu[[q-1]][[i]]
        })
      }
      out
    })
  } else
  {
    Prob_class <- NULL
  }
  obj <- list(x = X,
              xvar.names = xvar.names,
              time = lapply(1:n, function(i) {tm[id == id.unq[i]]}),
              id = id,
              y = y,
              Yorg = if(family == "Nominal" || family == "Ordinal") Yorg else unlist(Yorg,recursive=FALSE),
              family = family,
              ymean = Ymean,
              ysd = Ysd,
              na.action = na.action, 
              n = n,
              ni = ni,
              n.Q = n.Q,
              Q_set = Q_set,
              y.unq = if(family != "Continuous") y.unq else NA,
              y_reference = y_reference,
              tm.unq = tm.unq,
              gamma = gamma.list,
              mu = if(family == "Nominal" || family == "Ordinal") mu else unlist(mu,recursive=FALSE),
              Prob_class = Prob_class,
              lambda = if(family == "Nominal" || family == "Ordinal") lambda.mat else as.vector(lambda.mat),
              phi = if(family == "Nominal" || family == "Ordinal") phi.mat else as.vector(phi.mat),
              rho = if(family == "Nominal" || family == "Ordinal") rho.mat else as.vector(rho.mat),
              baselearner = baselearner,
              membership = membership.list,
              X.tm = X.tm,
              D = D,
              d = d,
              pen.ord = pen.ord,
              K = K,
              M = M,
              nu = nu,
              ntree = ntree,
              cv.flag = cv.flag,
              err.rate = if (!is.null(err.rate)) { if(family == "Nominal" || family == "Ordinal") lapply(1:n.Q,function(q){ err.rate[[q]] / Ysd   }) else err.rate[[1]]/Ysd }  else NULL,
              rmse = if (!is.null(rmse)) unlist(lapply(1:n.Q,function(q){ rmse[q] / Ysd  })) else NULL,
              Mopt = Mopt,
              gamma.i.list = if(cv.flag) gamma.i.list else NULL,
              forest.tol = forest.tol)
  class(obj) <- c("boostmtree", "grow", learnerUsed)
  invisible(obj)
}
