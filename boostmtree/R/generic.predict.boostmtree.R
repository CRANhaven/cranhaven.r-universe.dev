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


generic.predict.boostmtree <- function(object,
                                       x,
                                       tm,
                                       id,
                                       y,
                                       M,
                                       eps = 1e-5,
                                       useCVflag = FALSE,
                                       ...)
{
  if (missing(object)) {
    stop("object is missing!")
  }
  if (sum(inherits(object, c("boostmtree", "grow"), TRUE) == c(1, 2)) != 2) {
    stop("this function only works for objects of class `(boostmtree, grow)'")
  }
  user.option <- match.call(expand.dots = TRUE)
  partial <- is.hidden.partial(user.option)
  if (!partial) {
    if (missing(x)) {
      X <- object$x
      n <- nrow(X)
      X.tm <- object$X.tm
      tm <- object$time
      tm.unq <- sort(unique(unlist(object$time)))
      id <- object$id
      id.unq <- sort(unique(id))
      testFlag <- FALSE
    }
    else {
      if (!missing(x) && (missing(id) || missing(tm))) {
        X <- x
        n <- nrow(X)
        tm.unq <- sort(unique(unlist(object$time)))
        tm <- lapply(1:n, function(i){tm.unq})
        id <- id.unq <- 1:n
        if (!missing(y)) {
          Y <- lapply(1:n, function(i) {y[i]})
          testFlag <- TRUE
        }
        else {
          testFlag <- FALSE
        }
      }
      else{
        if (missing(id)) {
          stop("test set id values are missing\n")
        }
        id.unq <- sort(unique(id))
        n <- length(id.unq)
        if (missing(x)) {
          stop("test set x values are missing\n")
        }
        X <- do.call(rbind, lapply(1:n, function(i) {
          x[id == id.unq[i],, drop = FALSE][1,, drop = FALSE]}))
        if (missing(tm)) {
          stop("test set time values are missing\n")
        }
        tm.unq <- sort(unique(tm))
        if (!missing(y)) {
          tm <- lapply(1:n, function(i) {tm[id == id.unq[i]]})
          testFlag <- TRUE
        }
        else {
          testFlag <- FALSE
        }
      }
    }
  }
  else {
      X <- x
      n <- nrow(X)
      tm.unq <- tm
      tm <- lapply(1:n, function(i){tm.unq})
      id.unq <- 1:n
      id <- rep(id.unq,each = length(tm.unq))
      testFlag <- FALSE
  }
  if (missing(M)) {
    M <- object$M
    Mflag <- FALSE
  }
  else {
    M <- max(1, min(M, object$M))
    Mflag <- TRUE
  }
  K <- object$K
  nu <- object$nu
  ntree <- object$ntree
  p <- ncol(X)
  X.tm <- object$X.tm
  df.D <- ncol(X.tm)
  xvar.names <- colnames(X)
  nu.vec <- c(nu[1], rep(nu[2], df.D - 1))
  Ymean <- object$ymean
  Ysd <- object$ysd
  baselearner <- object$baselearner
  family <- object$family
  n.Q <- object$n.Q
  Q_set <- object$Q_set
  y.unq <- object$y.unq
  na.action <- object$na.action
  #----------------------------------------------------------------------------------
  # Date: 09/04/2020
  # Following comment added as a part of estimating partial predicted mu based on
  # oob sample
  # Earlier, we use gamma estimate which is derived from all the samples, and use
  # all the training sample for prediction. Here, we focus on estimating response
  # based on the oob sample. 
  # This should be ideally be used for the partial plot, however, in case you need
  # to use gamma estimate based on oob sample, you could do that. In either case,
  # this is done using useCVflag = TRUE
  #----------------------------------------------------------------------------------
  if(useCVflag){
    if(!object$cv.flag){
      useCVflag <- FALSE
    }
  }
  if(!useCVflag){
    gamma <- object$gamma
  }else
  {
    gamma <- object$gamma.i.list
    oob.list <- lapply(1:n.Q,function(q){  vector("list",M[q]) })
  }
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
      id.unq.revise <- setdiff(id.unq,id.remove)
      index.id_revise <- match(id.unq.revise,id.unq)
      id.unq <- id.unq.revise
      n <- length(id.unq)
      tm <- lapply(index.id_revise,function(i){ tm[[i]]  })
      X <- X[index.id_revise,drop = FALSE]
      id <- unlist(lapply(1:n,function(i){ id[id == id.unq[i] ]    }))
      if(testFlag){
         y <- unlist(lapply(1:n,function(i){ y[id == id.unq[i] ]    }))
      }
    }
  }
  id.index <- lapply(1:n,function(i){
    which(id == id.unq[i] )
  })
  ni <- unlist(lapply(1:n,function(i){
    length(id.index[[i]])
  }))
  tm.unq_train <- object$tm.unq
  tm.index <- lapply(1:n,function(i){
    AppoxMatch(unlist(tm)[id.index[[i]]],tm.unq_train)
  })
  D <- lapply(1:n,function(i){
    X.tm[tm.index[[i]] ,,drop = FALSE]
  })
  beta <- matrix(0, n, df.D)
  l_pred_db.list <- lapply(1:n.Q,function(q){
    lapply(1:M,function(m){
      lapply(1:n,function(i){
        rep(0,ni[i])
      })
    })
  })
  l_pred_ref <- vector("list", M)
  Mopt <- rep(NA,n.Q)
  rmse <- rep(NA,n.Q)
  forest.tol <- object$forest.tol
  membership <- lapply(1:n.Q,function(q){
    lapply(1:M,function(m){
      NULL
    })
  })
  if(testFlag){
    if(family != "Continuous"){
      if(!is.numeric(y)){
      y <- as.numeric(factor(y))
     }
      y.unq_test <- sort(unique(y))
      if(any(is.na(match(y.unq_test,y.unq)))){
        stop("Unique values of response from training and test data do not match")
      }
    }
    Yq <- lapply(1:n.Q,function(q){
      if(family == "Continuous"){
        out <- y
      }
      if(family == "Nominal" || family == "Binary"){
        out <- ifelse(y == Q_set[q],1,0)
      }
      if(family == "Ordinal"){
        out <- ifelse(y <= Q_set[q],1,0)
      }
      out
    })
    Y <- lapply(1:n.Q,function(q){
      lapply(1:n, function(i) { Yq[[q]][id == id.unq[i]] })
    })
  }
  if (ntree == 1) {
    rf.cores.old <- getOption("rf.cores")
    mc.cores.old <- getOption("mc.cores")
    for(q in 1:n.Q){
      nullObj <- papply(1:M, function(m) {
        options(rf.cores = 1, mc.cores = 1)
        if(!useCVflag){
        membership[[q]][[m]] <<- c(predict.rfsrc(baselearner[[q]][[m]],
                                                 newdata = X,
                                                 membership = TRUE,
                                                 ptn.count = K,
                                                 na.action = na.action,
                                                 importance = "none")$ptn.membership)
        } else
        {
          oob <- which(baselearner[[q]][[m]]$inbag == 0)
          oob.list[[q]][[m]] <<- oob
          membership[[q]][[m]] <<- c(predict.rfsrc(baselearner[[q]][[m]],
                                                   newdata = X[oob,, drop = FALSE],
                                                   membership = TRUE,
                                                   ptn.count = K,
                                                   na.action = na.action,
                                                   importance = "none")$ptn.membership)
        }
        NULL
      })
      rm(nullObj)
    }
    for(q in 1:n.Q){
      nullObj <- lapply(1:M, function(m) {
        if(!useCVflag){
        orgMembership <- gamma[[q]][[m]][, 1]
        if (m == 1) {
          l_pred_db.list[[q]][[m]] <<- lapply(1:n, function(i) {
            l_pred_db_Temp <- D[[i]]%*%t(gamma[[q]][[m]][match(membership[[q]][[m]][i], orgMembership), -1, drop = FALSE]*nu.vec) 
            if(family == "Ordinal" && q > 1){
              l_pred_db_Temp <- ifelse(l_pred_db_Temp < l_pred_db.list[[q-1]][[m]][[i]],l_pred_db.list[[q-1]][[m]][[i]],l_pred_db_Temp)
            }
            l_pred_db_Temp
            })
        }
        else {
          l_pred_db.list[[q]][[m]] <<- lapply(1:n, function(i) {
            l_pred_db_Temp <- unlist(l_pred_db.list[[q]][[m-1]][i]) + D[[i]]%*%t(gamma[[q]][[m]][match(membership[[q]][[m]][i], orgMembership), -1, drop = FALSE]*nu.vec)
            if(family == "Ordinal" && q > 1){
              l_pred_db_Temp <- ifelse(l_pred_db_Temp < l_pred_db.list[[q-1]][[m]][[i]],l_pred_db.list[[q-1]][[m]][[i]],l_pred_db_Temp)
            }
            l_pred_db_Temp
          })
        }
       } else
       {
         if(m == 1){
           l_pred_db.list[[q]][[m]] <<- lapply(1:n,function(i){
             if( any(i == oob.list[[q]][[m]] )){
               orgMembership <- gamma[[q]][[m]][[i]][,1,drop = TRUE]
               l_pred_db_Temp <- D[[i]]%*%t(gamma[[q]][[m]][[i]][match(membership[[q]][[m]][ which(oob.list[[q]][[m]] == i) ], orgMembership), -1, drop = FALSE]*nu.vec) 
               if(family == "Ordinal" && q > 1){
                 l_pred_db_Temp <- ifelse(l_pred_db_Temp < l_pred_db.list[[q-1]][[m]][[i]],l_pred_db.list[[q-1]][[m]][[i]],l_pred_db_Temp)
               }   
             } else
             {
               l_pred_db_Temp <- l_pred_db.list[[q]][[m]][[i]]
             }
             l_pred_db_Temp
           })
         }else
         {
           l_pred_db.list[[q]][[m]] <<- lapply(1:n,function(i){
             if( any(i == oob.list[[q]][[m]] )){
               orgMembership <- gamma[[q]][[m]][[i]][,1,drop = TRUE]
               l_pred_db_Temp <- l_pred_db.list[[q]][[m-1]][[i]] + D[[i]]%*%t(gamma[[q]][[m]][[i]][match(membership[[q]][[m]][ which(oob.list[[q]][[m]] == i) ], orgMembership), -1, drop = FALSE]*nu.vec) 
               if(family == "Ordinal" && q > 1){
                 l_pred_db_Temp <- ifelse(l_pred_db_Temp < l_pred_db.list[[q-1]][[m]][[i]],l_pred_db.list[[q-1]][[m]][[i]],l_pred_db_Temp)
               }   
             } else
             {
               l_pred_db_Temp <- l_pred_db.list[[q]][[m-1]][[i]]
             }
             l_pred_db_Temp
           })
         }
       }
        NULL
      })
      rm(nullObj)
    }
    if(family == "Nominal"){
    nullObj <- lapply(1:M,function(m){
      l_pred_ref[[m]] <<- lapply(1:n,function(i){
        log((1 + (Reduce("+",lapply(1:n.Q,function(q){
          exp(l_pred_db.list[[q]][[m]][[i]])  
        }))))^{-1})
      })
      NULL
    })
    rm(nullObj)
    } else
    {
      nullObj <- lapply(1:M,function(m){
        l_pred_ref[[m]] <<- lapply(1:n,function(i){
                        rep(0,ni[i])
        })
        NULL
      })
      rm(nullObj)
    }
    l_pred.list <- lapply(1:n.Q,function(q){
      lapply(1:M,function(m){
        lapply(1:n,function(i){
          l_pred_db.list[[q]][[m]][[i]] + l_pred_ref[[m]][[i]]
        })
      })
    })
    l_pred.list <- lapply(1:n.Q,function(q){
      lapply(1:M,function(m){
        lapply(1:n,function(i){
          l_pred.list[[q]][[m]][[i]] * Ysd + Ymean
        })
      })
    })
    mu.list <- lapply(1:n.Q,function(q){
      lapply(1:M,function(m){
        lapply(1:n,function(i){
          GetMu(Linear_Predictor = l_pred.list[[q]][[m]][[i]],Family = family)
        })
      })
    })
    if (testFlag) {
      err.rate <- lapply(1:n.Q,function(q){
        err.rate_temp <- matrix(unlist(lapply(1:M, function(m) {
          c(l1Dist(Y[[q]], mu.list[[q]][[m]]), l2Dist(Y[[q]], mu.list[[q]][[m]])) 
        })), ncol = 2, byrow = TRUE)
        colnames(err.rate_temp) <- c("l1", "l2")
        err.rate_temp
      })
    }
    else {
      err.rate <- NULL
    }
    for(q in 1:n.Q){
      if (!Mflag && testFlag) {
        diff.err <- abs(err.rate[[q]][, "l2"] - min(err.rate[[q]][, "l2"], na.rm = TRUE))
        diff.err[is.na(diff.err)] <- 1
        if (sum(diff.err < Ysd * eps) > 0) {
          Mopt[q] <- min(which(diff.err < eps))
        }
        else {
          Mopt[q] <- M
        }
       rmse[q] <- err.rate[[q]][Mopt[q], "l2"]
      }
      else {
        Mopt[q] <- M
      }
    }
    mu <- lapply(1:n.Q,function(q){ mu.list[[q]][[ Mopt[q] ]]  })
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
  }
  else{
    nullObj <- lapply(1:M, function(m) {
      gm <- baselearner[[m]]$gm
      Xnew <- baselearner[[m]]$Xnew
      pen <- baselearner[[m]]$pen
      forest.wt <- predict.rfsrc(baselearner[[m]]$forest,
                                 newdata = X,
                                 importance = "none",
                                 forest.wt = TRUE)$forest.wt
      beta.m.org <- do.call("cbind", mclapply(1:n, function(i) {
        fwt.i <- forest.wt[i, ]
        fwt.i[fwt.i <= forest.tol] <- 0
        pt.i <- (fwt.i != 0)
        if (sum(pt.i) > 0) {
          fwt.i <- fwt.i / sum(fwt.i)
          YnewSum <- colSums(fwt.i[pt.i] * gm[pt.i,, drop = FALSE])
          XnewSum <- Reduce("+", lapply(which(pt.i), function(j) {fwt.i[j] * Xnew[[j]]}))
          XnewSum <- XnewSum + pen
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
      beta.m <- t(beta.m.org * nu.vec * Ysd)
      if (m == 1) {
        beta.m[, 1] <- beta.m[, 1] + Ymean
        beta <<- beta.m
      }
      else {
        beta <<- beta + beta.m 
      }
      Dbeta.m <- D %*% (beta.m.org * nu.vec)
      if (m == 1) {
        mu.list[[m]] <<- lapply(1:n, function(i) {
          Dbeta.m[, i][match(tm[[i]], tm.unq, tm[[i]])]
        })
      }
      else {
        mu.list[[m]] <<- lapply(1:n, function(i) {
          unlist(mu.list[[m-1]][i]) + Dbeta.m[, i][match(tm[[i]], tm.unq, tm[[i]])]
        })
      }
      NULL
    })
    mu.list <- lapply(mu.list, function(mlist){  
      lapply(1:n,function(i) {mlist[[i]] * Ysd + Ymean})
    })
    if (testFlag) {
      err.rate <- matrix(unlist(lapply(mu.list, function(mlist) {
        c(l1Dist(Y, mlist), l2Dist(Y, mlist))
      })), ncol = 2, byrow = TRUE) 
      colnames(err.rate) <- c("l1", "l2")
    }
    else {
      err.rate <- NULL
    }
    if (!Mflag && testFlag) {
      diff.err <- abs(err.rate[, "l2"] - min(err.rate[, "l2"], na.rm = TRUE))
      diff.err[is.na(diff.err)] <- 1
      if (sum(diff.err < Ysd * eps) > 0) {
        Mopt <- min(which(diff.err < eps))
      }
      else {
        Mopt <- M
      }
    }
    else {
      Mopt <- M
    }
  }
  #----------------------------------------------------------------------------------
  # Date: 09/08/2020
  # Following comment added as a part of estimating partial predicted mu based on
  # oob sample.
  # Earlier I have provided an estimate of mu based on gamma obtained using oob sample.
  # This is in addition to the mu based on gamma obtained using all the sample.
  # In the procedure below, I am going to estimate muhat and Prob_hat_class only
  # based on gamma obtained using all the sample. Thus, when useCVflag == TRUE,
  # we use muhat and Prob_hat_class as NULL.
  # This is due to time constraints.
  # Later, I will come back to the code below, and provide two separate estimates,
  # one based on gamma from all the sample, and other based on gamma from oob sample.
  #----------------------------------------------------------------------------------
  if(!useCVflag){
  l_pred_db_hat_Temp <- lapply(1:n.Q,function(q){
    lapply(1:n,function(i){
      lapply(1:Mopt[q],function(m){
        orgMembership <- gamma[[q]][[m]][, 1]
        as.vector(X.tm%*%t(gamma[[q]][[m]][match(membership[[q]][[m]][i], orgMembership), -1, drop = FALSE]*nu.vec))
      })
    })
  })
  l_pred_db_hat <- lapply(1:n.Q,function(q){
    lapply(1:n,function(i){
       sum_l_pred_db_Temp <- Reduce("+",lapply(1:Mopt[q],function(m){
        l_pred_db_Temp <- l_pred_db_hat_Temp[[q]][[i]][[m]]
        if(family == "Ordinal" && q > 1){
          l_pred_db_Temp <- ifelse(l_pred_db_Temp < l_pred_db_hat_Temp[[q-1]][[i]][[m]],l_pred_db_hat_Temp[[q-1]][[i]][[m]],l_pred_db_Temp)
          l_pred_db_hat_Temp[[q]][[i]][[m]] <<- l_pred_db_Temp
          l_pred_db_Temp
        }
        l_pred_db_Temp
      }))
       sum_l_pred_db_Temp
    })
  })
  #if(FALSE){
  # This should be deleted once I know that above code works
  #l_pred_db_hat <- lapply(1:n.Q,function(q){
  #  l_pred_db_i_list <- lapply(1:n,function(i){
  #    l_pred_db.i <- rep(0,nrow(X.tm))
  #    nullObj <- lapply(1:Mopt[q],function(m){
  #      orgMembership <- gamma[[q]][[m]][, 1]
  #      l_pred_db.i <<- l_pred_db.i + X.tm%*%t(gamma[[q]][[m]][match(membership[[q]][[m]][i], orgMembership), -1, drop = FALSE]*nu.vec)
  #      NULL
  #    })
  #    l_pred_db.i
  #  })
  #  l_pred_db_i_list
  #})
  #}
  if(family == "Nominal"){
  l_pred_ref_hat <- lapply(1:n,function(i){
      log((1 + (Reduce("+",lapply(1:n.Q,function(q){
        exp(l_pred_db_hat[[q]][[i]])  
      }))))^{-1})
  })
  } else 
  {
    l_pred_ref_hat <- lapply(1:n,function(i){
      rep(0,nrow(X.tm))
    })
  }
  l_pred_hat <- lapply(1:n.Q,function(q){
    lapply(1:n,function(i){
      (l_pred_db_hat[[q]][[i]] + l_pred_ref_hat[[i]])* Ysd + Ymean
    })
  })
  muhat <- lapply(1:n.Q,function(q){
    lapply(1:n,function(i){
      GetMu(Linear_Predictor = l_pred_hat[[q]][[i]],Family = family)
    })
  })
  if(family == "Ordinal"){
    Prob_hat_class <- lapply(1:(n.Q+1),function(q){
      if(q == 1){
        out <- lapply(1:n,function(i){
          muhat[[q]][[i]]
        })
      }
      if(q == (n.Q+1)){
        out <- lapply(1:n,function(i){
          1 - muhat[[q-1]][[i]]
        })
      }
      if(q > 1 && q < (n.Q+1) ){
        out <- lapply(1:n,function(i){
          muhat[[q]][[i]] - muhat[[q-1]][[i]]
        })
      }
      out
    })
  } else
  {
    Prob_hat_class <- NULL
  }
 }else
 {
   muhat <- NULL
   Prob_hat_class <- NULL
 }
  object$baselearner <- object$membership <- object$gamma <- NULL
  pobj <- list(boost.obj = object,
               x = X,
               time = tm,
               id = id,
               y = if (testFlag) y else NULL,
               Y = if(testFlag) {if(family == "Nominal" || family == "Ordinal") Y else unlist(Y,recursive=FALSE)} else NULL,
               family = family,
               ymean = Ymean,
               ysd = Ysd,
               xvar.names = xvar.names,
               K = K,
               n = n,
               ni = ni,
               n.Q = n.Q,
               Q_set = Q_set,
               y.unq = y.unq,
               nu.vec = nu.vec,
               D = D,
               df.D = df.D,
               time.unq = tm.unq,
               baselearner = baselearner,
               gamma = gamma,
               membership = membership,
               mu = if(family == "Nominal" || family == "Ordinal") mu else unlist(mu,recursive=FALSE),
               Prob_class = Prob_class,
               muhat = if(!useCVflag)  if(family == "Nominal" || family == "Ordinal") muhat else unlist(muhat,recursive=FALSE) else NULL,
               Prob_hat_class = Prob_hat_class,
               err.rate = if (!is.null(err.rate)) { if(family == "Nominal" || family == "Ordinal") lapply(1:n.Q,function(q){ err.rate[[q]] / Ysd   }) else err.rate[[1]]/Ysd }  else NULL,
               rmse = if (testFlag) unlist(lapply(1:n.Q,function(q) { rmse[q] / Ysd })) else NULL,
               Mopt = if (testFlag) Mopt else NULL)
  class(pobj) <- c("boostmtree", "predict", class(object)[3])
  invisible(pobj)
}
