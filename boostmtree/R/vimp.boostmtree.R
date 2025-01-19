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


vimp.boostmtree <- function(object,x.names = NULL,joint = FALSE){
  if (sum(inherits(object, c("boostmtree", "grow"), TRUE) == c(1, 2)) != 2 &
      sum(inherits(object, c("boostmtree", "predict"), TRUE) == c(1, 2)) != 2) {
    stop("This function only works for objects of class `(boostmtree, grow)' or '(boostmtree, predict)'")
  }
  if (sum(inherits(object, c("boostmtree", "grow"), TRUE) == c(1, 2)) == 2) {
  if(!object$cv.flag){
    stop("The grow object of boostmtree does not include in-sample CV estimates")
  }  
  X <- object$x
  P <- ncol(X)
  xvar.names <- object$xvar.names
  if(is.null(x.names)){
    vimp_set <- 1:P
    x_Names <- xvar.names
  }else
  {
      n.x.names <- length(x.names)
      vimp_set <- match(x.names,xvar.names)
      if(any(is.na( vimp_set ))){
        stop("x.names do not match with variable names from original data")
      }
      if(joint){
        x_Names <- "joint_vimp"
      }else
      {
        x_Names <- x.names
      }
  }
  if(joint){
    p <- 1
  }else
  {
    p <- length(vimp_set)  
  }
  Ymean <- object$ymean
  Ysd <- object$ysd
  df.D <- ncol(object$X.tm)
  Mopt <- object$Mopt
  ni <- object$ni
  K <- object$K
  n.Q <- object$n.Q
  Q_set <- object$Q_set
  y.unq <- object$y.unq
  y_reference <- object$y_reference
  gamma.i.list <- object$gamma.i.list
  membership <- object$membership
  D <- object$D
  n <- object$n
  rmse <- object$rmse*object$ysd
  nu.vec <- rep(object$nu[1],df.D)
  family <- object$family
  Yorg <- object$Yorg
  if(family == "Continuous" || family == "Binary"){
      List_Temp <- vector("list",1)
      List_Temp[[1]] <- Yorg
      Yorg <- List_Temp
      rm(List_Temp)
  }
  oob.list <- lapply(1:n.Q,function(q){  vector("list",Mopt[q]) })
  membershipNoise.list <- vector("list",n.Q)
  l_pred_db.vimp <- lapply(1:n.Q,function(q){  vector("list",p) })
  l_pred_ref.vimp <- vector("list",p)
  l_pred.vimp <- lapply(1:n.Q,function(q){  vector("list",p) })
for(q in 1:n.Q){
membershipNoise.list[[q]] <- lapply(1:Mopt[q],function(m){
    oob <- which(object$baselearner[[q]][[m]]$inbag == 0)
    oob.list[[q]][[m]] <<- oob
    n.oob <- length(oob)
    Xnoise <- do.call(rbind, lapply(1:p, function(k) {
      X.k <- X[oob,, drop = FALSE]
      if(joint){
        X.k[, vimp_set] <- X.k[sample(nrow(X.k)), vimp_set]
      }else
      {
        X.k[, vimp_set[k] ] <- sample(X.k[, vimp_set[k] ])
      }
      X.k
    }))
    membershipNoise <- c(predict.rfsrc(object$baselearner[[q]][[m]],
                                       newdata = Xnoise,
                                       membership = TRUE,
                                       ptn.count = K,
                                       importance = "none",
                                       na.action = "na.impute")$ptn.membership)
    membershipNoise <- matrix(membershipNoise,nrow = n.oob,byrow = FALSE)
    membershipNoise
  })
}  
  if(df.D > 1){
  vimp.main <- vimp.int <- matrix(NA,nrow = p,ncol = n.Q)
  vimp.time <- rep(NA,n.Q)
    for(q in 1:n.Q){
    for(k in 1:p){
      l_pred_db.vimp[[q]][[k]] <- lapply(1:n,function(i){
        l_pred_db.main.i <- l_pred_db.int.i <- rep(0,ni[i])
        if(k == p){ l_pred_db.time.i <- rep(0,ni[i])  }
        NullObj <- lapply(1:Mopt[q],function(m){
          if( any(i == oob.list[[q]][[m]] )){
            membershipNoise.i <- membershipNoise.list[[q]][[m]][ which(oob.list[[q]][[m]] == i) , k ,drop = TRUE]  
            membershipOrg.i.vec <- gamma.i.list[[q]][[m]][[i]][,1,drop = TRUE]
            gamma.noise.i <- t(gamma.i.list[[q]][[m]][[i]][which(membershipOrg.i.vec == membershipNoise.i),-1,drop = FALSE])
            membershipOrg.i <- membership[[q]][[m]][ i ]
            gamma.org.i <- t(gamma.i.list[[q]][[m]][[i]][which(membershipOrg.i.vec == membershipOrg.i),-1,drop = FALSE])
            gamma.main <- cbind(c(gamma.noise.i[1,1],gamma.org.i[-1,1]))
            out.main <- c(D[[i]] %*% (gamma.main * nu.vec))
            gamma.int <- cbind(c(gamma.org.i[1,1],gamma.noise.i[-1,1]))
            out.int <- c(D[[i]] %*% (gamma.int * nu.vec))
            if(k == p){
              n.D <- nrow(D[[i]])
              out.time <- c(D[[i]][sample(1:n.D,n.D,replace = TRUE),,drop = FALSE] %*% (gamma.org.i * nu.vec))
            }
          }
          else{
            out.main <- out.int <- rep(0,ni[i])
            if(k == p){ out.time <- rep(0,ni[i])  }
          }
          l_pred_db.main.i <<- l_pred_db.main.i + out.main
          l_pred_db.int.i <<- l_pred_db.int.i + out.int
          if(k == p){ l_pred_db.time.i <<- l_pred_db.time.i + out.time }
          NULL
        })
        list(l_pred_db.main = l_pred_db.main.i,l_pred_db.int = l_pred_db.int.i,l_pred_db.time = if (k == p) l_pred_db.time.i else NULL  )
      })
      }
    }
    for(k in 1:p){
      if(family == "Nominal"){
         l_pred_ref.vimp[[k]] <- lapply(1:n,function(i){
            l_pred_ref.main.i <-  log((1 + (Reduce("+",lapply(1:n.Q,function(q){
                                  exp(l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.main)  
                              }))))^{-1})
            l_pred_ref.int.i <-  log((1 + (Reduce("+",lapply(1:n.Q,function(q){
                                  exp(l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.int)  
                              }))))^{-1})
            if(k == p) {
            l_pred_ref.time.i <-  log((1 + (Reduce("+",lapply(1:n.Q,function(q){
                                  exp(l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.time)  
                              }))))^{-1})     
            }
            list(l_pred_ref.main = l_pred_ref.main.i,l_pred_ref.int = l_pred_ref.int.i,l_pred_ref.time = if (k == p) l_pred_ref.time.i else NULL) 
         }) 
      } else
      {
        l_pred_ref.vimp[[k]] <- lapply(1:n,function(i){
             l_pred_ref.main.i <-  l_pred_ref.int.i <- rep(0,ni[i])
             if(k == p){
               l_pred_ref.time.i <- rep(0,ni[i])
             }
            list(l_pred_ref.main = l_pred_ref.main.i,l_pred_ref.int = l_pred_ref.int.i,l_pred_ref.time = if (k == p) l_pred_ref.time.i else NULL)
        })
      }  
    }
    for(q in 1:n.Q){
      for(k in 1:p){
        l_pred.vimp[[q]][[k]] <- lapply(1:n,function(i){
          l_pred.main.i <- l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.main + l_pred_ref.vimp[[k]][[i]]$l_pred_ref.main
          l_pred.int.i <- l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.int + l_pred_ref.vimp[[k]][[i]]$l_pred_ref.int
          if(k == p){
            l_pred.time.i <- l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.time + l_pred_ref.vimp[[k]][[i]]$l_pred_ref.time
          }
          list(l_pred.main = l_pred.main.i,l_pred.int = l_pred.int.i,l_pred.time = if (k == p) l_pred.time.i else NULL)
        })
      }
    }
      nullObj <- lapply(1:n.Q,function(q){
        lapply(1:p,function(k){
           mu.main <- lapply(1:n,function(i){ GetMu(Linear_Predictor = l_pred.vimp[[q]][[k]][[i]]$l_pred.main * Ysd + Ymean, Family = family) })
           err.rate.main <- l2Dist(Yorg[[q]], mu.main)
           vimp.main[k,q] <<- (err.rate.main - rmse[q])/rmse[q]
           mu.int <- lapply(1:n,function(i){ GetMu(Linear_Predictor = l_pred.vimp[[q]][[k]][[i]]$l_pred.int * Ysd + Ymean, Family = family) })
           err.rate.int <- l2Dist(Yorg[[q]], mu.int)
           vimp.int[k,q] <<- (err.rate.int - rmse[q])/rmse[q]
           if(k == p){
           mu.time <- lapply(1:n,function(i){ GetMu(Linear_Predictor = l_pred.vimp[[q]][[k]][[i]]$l_pred.time * Ysd + Ymean, Family = family) })
           err.rate.time <- l2Dist(Yorg[[q]], mu.time)
           vimp.time[q] <<- (err.rate.time - rmse[q])/rmse[q]
           }
          NULL
        })
        NULL
      })
      rm(nullObj)
    rownames(vimp.main) <- x_Names
    rownames(vimp.int) <- paste(x_Names, "time", sep=":")
    names(vimp.time) <- rep("time",n.Q)
    vimp <- list(vimp.main,vimp.int,vimp.time)  
  }
  else{
    vimp <- matrix(NA,nrow = p,ncol = n.Q)
    for(q in 1:n.Q){
      for(k in 1:p){
      l_pred_db.vimp[[q]][[k]] <- lapply(1:n,function(i){
        l_pred_db.i <- rep(0,ni[i])    
        NullObj <- lapply(1:Mopt[q],function(m){
          if( any(i == oob.list[[q]][[m]] )){
            membershipNoise.i <- membershipNoise.list[[q]][[m]][ which(oob.list[[q]][[m]] == i)   , k ,drop = TRUE]  
            membershipOrg.i.vec <- gamma.i.list[[q]][[m]][[i]][,1,drop = TRUE]
            gamma.noise.i <- t(gamma.i.list[[q]][[m]][[i]][which(membershipOrg.i.vec == membershipNoise.i),-1,drop = FALSE])
            out <- c(D[[i]] %*% (gamma.noise.i * nu.vec))
          }
          else
          {
            out <- rep(0,ni[i])
          }
          l_pred_db.i <<- l_pred_db.i + out
          NULL
        })
        l_pred_db.i
      })
    }
    }
    for(k in 1:p){
      if(family == "Nominal"){
         l_pred_ref.vimp[[k]] <- lapply(1:n,function(i){
            log((1 + (Reduce("+",lapply(1:n.Q,function(q){
                              exp(l_pred_db.vimp[[q]][[k]][[i]])  
                        }))))^{-1})
         }) 
      } else 
      {
         l_pred_ref.vimp[[k]] <- lapply(1:n,function(i){
           rep(0,ni[i])
         }) 
      }
    }
    for(q in 1:n.Q){
      for(k in 1:p){
        l_pred.vimp[[q]][[k]] <- lapply(1:n,function(i){
             l_pred_db.vimp[[q]][[k]][[i]] + l_pred_ref.vimp[[k]][[i]]
        })
      }
    }
      nullObj <- lapply(1:n.Q,function(q){
        lapply(1:p,function(k){
           mu.main <- lapply(1:n,function(i){ GetMu(Linear_Predictor = l_pred.vimp[[q]][[k]][[i]] * Ysd + Ymean, Family = family) })
           err.rate.main <- l2Dist(Yorg[[q]], mu.main)
           vimp[k,q] <<- (err.rate.main - rmse[q])/rmse[q]
          NULL
        })
        NULL
      })
      rm(nullObj)
    rownames(vimp) <- x_Names
   }
}
  else {
    X <- object$x
    P <- ncol(X)
    xvar.names <- object$xvar.names
    if(is.null(x.names)){
      vimp_set <- 1:P
      x_Names <- xvar.names
    }else
    {
      n.x.names <- length(x.names)
      vimp_set <- match(x.names,xvar.names)
      if(any(is.na( vimp_set ))){
        stop("x.names do not match with variable names from original data")
      }
      if(joint){
        x_Names <- "joint_vimp"
      }else
      {
        x_Names <- x.names
      }
    }
    if(joint){
      p <- 1
    }else
    {
      p <- length(vimp_set)  
    }
    y <- object$y
    if(is.null(y)){
      stop("Response is not provied in the predict object")
    }
    Ymean <- object$ymean
    Ysd <- object$ysd
    n <- object$n
    K <- object$K
    ni <- object$ni
    n.Q <- object$n.Q
    Q_set <- object$Q_set
    y.unq <- object$y.unq
    df.D <- object$df.D
    D <- object$D
    nu.vec <- object$nu.vec
    Mopt  <- object$Mopt
    baselearner <- object$baselearner
    gamma <- object$gamma
    membership <- object$membership
    rmse <- object$rmse*Ysd
    family <- object$family
    Y    <- object$Y
    if(family == "Continuous" || family == "Binary"){
      List_Temp <- vector("list",1)
      List_Temp[[1]] <- Y
      Y <- List_Temp
      rm(List_Temp)
    }
    membershipNoise <- vector("list",n.Q)
    l_pred_db.vimp <- lapply(1:n.Q,function(q){  vector("list",p) })
    l_pred_ref.vimp <- vector("list",p)
    l_pred.vimp <- lapply(1:n.Q,function(q){  vector("list",p) })
    for(q in 1:n.Q){
    membershipNoise[[q]] <- lapply(1:Mopt[q], function(m) {
      Xnoise <- do.call(rbind, lapply(1:p, function(k) {
        X.k <- X
        if(joint){
          X.k[, vimp_set] <- X.k[sample(nrow(X.k)), vimp_set]
        }else
        {
          X.k[, vimp_set[k] ] <- sample(X.k[, vimp_set[k] ])
        }
        X.k
      }))
      options(rf.cores = 1, mc.cores = 1)
      c(predict.rfsrc(baselearner[[q]][[m]],
                      newdata = Xnoise,
                      membership = TRUE,
                      ptn.count = K,
                      na.action = "na.impute",
                      importance = "none")$ptn.membership)
    })
    }
    if(df.D > 1){
      vimp.main <- vimp.int <- matrix(NA,nrow = p,ncol = n.Q)
      vimp.time <- rep(NA,n.Q)
        for(q in 1:n.Q){
          for(k in 1:p){
             l_pred_db.vimp[[q]][[k]] <-  lapply(1:n,function(i){
                  l_pred_db.main.i <- l_pred_db.int.i <- rep(0,ni[i])
                  if(k == p){ l_pred_db.time.i <- rep(0,ni[i])  }
                  NullObj <- lapply(1:Mopt[q],function(m){
                    orgMembership  <- gamma[[q]][[m]][, 1]
                    gamma.Org      <- gamma[[q]][[m]][match(membership[[q]][[m]][i], orgMembership), -1, drop = FALSE]
                    membership.k   <- membershipNoise[[q]][[m]][((k-1) * n + 1):(k * n)]
                    membership.k.i <- membership.k[i]
                    gamma.Noise    <- gamma[[q]][[m]][match(membership.k.i, orgMembership), -1, drop = FALSE]
                    gamma.main     <- cbind(c(gamma.Noise[1],gamma.Org[-1]))
                    gamma.int      <- cbind(c(gamma.Org[1],gamma.Noise[-1]))
                    l_pred_db.main.i  <<- l_pred_db.main.i + c(D[[i]]%*%(gamma.main*nu.vec))
                    l_pred_db.int.i   <<- l_pred_db.int.i  + c(D[[i]]%*%(gamma.int*nu.vec))
                    if(k == p){
                      n.D <- nrow(D[[i]])
                      l_pred_db.time.i <<- l_pred_db.time.i + D[[i]][sample(1:n.D,n.D,replace = TRUE),,drop = FALSE]%*%t(gamma.Org*nu.vec)
                    }
                    NULL
                  })
                  list(l_pred_db.main = l_pred_db.main.i,l_pred_db.int = l_pred_db.int.i, l_pred_db.time = if (k == p) l_pred_db.time.i else NULL)
                })
          }
        }
        for(k in 1:p){
          if(family == "Nominal"){
            l_pred_ref.vimp[[k]] <- lapply(1:n,function(i){
                l_pred_ref.main.i <-  log((1 + (Reduce("+",lapply(1:n.Q,function(q){
                                      exp(l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.main)  
                                  }))))^{-1})
                l_pred_ref.int.i <-  log((1 + (Reduce("+",lapply(1:n.Q,function(q){
                                      exp(l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.int)  
                                  }))))^{-1})
                if(k == p) {
                l_pred_ref.time.i <-  log((1 + (Reduce("+",lapply(1:n.Q,function(q){
                                      exp(l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.time)  
                                  }))))^{-1})     
                }
                list(l_pred_ref.main = l_pred_ref.main.i,l_pred_ref.int = l_pred_ref.int.i,l_pred_ref.time = if (k == p) l_pred_ref.time.i else NULL) 
            }) 
          } else
          {
            l_pred_ref.vimp[[k]] <- lapply(1:n,function(i){
                l_pred_ref.main.i <-  l_pred_ref.int.i <- rep(0,ni[i])
                if(k == p){
                  l_pred_ref.time.i <- rep(0,ni[i])
                }
                list(l_pred_ref.main = l_pred_ref.main.i,l_pred_ref.int = l_pred_ref.int.i,l_pred_ref.time = if (k == p) l_pred_ref.time.i else NULL)
            })
          }  
        }
        for(q in 1:n.Q){
          for(k in 1:p){
            l_pred.vimp[[q]][[k]] <- lapply(1:n,function(i){
              l_pred.main.i <- l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.main + l_pred_ref.vimp[[k]][[i]]$l_pred_ref.main
              l_pred.int.i <- l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.int + l_pred_ref.vimp[[k]][[i]]$l_pred_ref.int
              if(k == p){
                l_pred.time.i <- l_pred_db.vimp[[q]][[k]][[i]]$l_pred_db.time + l_pred_ref.vimp[[k]][[i]]$l_pred_ref.time
              }
              list(l_pred.main = l_pred.main.i,l_pred.int = l_pred.int.i,l_pred.time = if (k == p) l_pred.time.i else NULL)
            })
          }
        }
      nullObj <- lapply(1:n.Q,function(q){
        lapply(1:p,function(k){
           mu.main <- lapply(1:n,function(i){ GetMu(Linear_Predictor = l_pred.vimp[[q]][[k]][[i]]$l_pred.main * Ysd + Ymean, Family = family) })
           err.rate.main <- l2Dist(Y[[q]], mu.main)
           vimp.main[k,q] <<- (err.rate.main - rmse[q])/rmse[q]
           mu.int <- lapply(1:n,function(i){ GetMu(Linear_Predictor = l_pred.vimp[[q]][[k]][[i]]$l_pred.int * Ysd + Ymean, Family = family) })
           err.rate.int <- l2Dist(Y[[q]], mu.int)
           vimp.int[k,q] <<- (err.rate.int - rmse[q])/rmse[q]
           if(k == p){
           mu.time <- lapply(1:n,function(i){ GetMu(Linear_Predictor = l_pred.vimp[[q]][[k]][[i]]$l_pred.time * Ysd + Ymean, Family = family) })
           err.rate.time <- l2Dist(Y[[q]], mu.time)
           vimp.time[q] <<- (err.rate.time - rmse[q])/rmse[q]
           }
          NULL
        })
        NULL
      })
      rm(nullObj)
    rownames(vimp.main) <- x_Names
    rownames(vimp.int) <- paste(x_Names, "time", sep=":")
    names(vimp.time) <- rep("time",n.Q)
    vimp <- list(vimp.main,vimp.int,vimp.time)
    }
    else {
    vimp <- matrix(NA,nrow = p,ncol = n.Q)
    for(q in 1:n.Q){
      for(k in 1:p){
      l_pred_db.vimp[[q]][[k]] <- lapply(1:n,function(i){
        l_pred_db.i <- rep(0,ni[i])    
        NullObj <- lapply(1:Mopt[q],function(m){
            orgMembership  <- gamma[[q]][[m]][, 1]
            membership.k   <- membershipNoise[[q]][[m]][((k-1) * n + 1):(k * n)]
            membership.k.i <- membership.k[i]
            gamma.Noise    <- gamma[[q]][[m]][match(membership.k.i, orgMembership), -1, drop = FALSE]
            l_pred_db.i    <<- l_pred_db.i  + c(D[[i]]%*%t(gamma.Noise*nu.vec))
            NULL
        })
        l_pred_db.i
      })
    }
    }
    for(k in 1:p){
      if(family == "Nominal"){
         l_pred_ref.vimp[[k]] <- lapply(1:n,function(i){
            log((1 + (Reduce("+",lapply(1:n.Q,function(q){
                              exp(l_pred_db.vimp[[q]][[k]][[i]])  
                        }))))^{-1})
         }) 
      } else 
      {
         l_pred_ref.vimp[[k]] <- lapply(1:n,function(i){
           rep(0,ni[i])
         }) 
      }
    }
    for(q in 1:n.Q){
      for(k in 1:p){
        l_pred.vimp[[q]][[k]] <- lapply(1:n,function(i){
             l_pred_db.vimp[[q]][[k]][[i]] + l_pred_ref.vimp[[k]][[i]]
        })
      }
    }
      nullObj <- lapply(1:n.Q,function(q){
        lapply(1:p,function(k){
           mu.main <- lapply(1:n,function(i){ GetMu(Linear_Predictor = l_pred.vimp[[q]][[k]][[i]] * Ysd + Ymean, Family = family) })
           err.rate.main <- l2Dist(Y[[q]], mu.main)
           vimp[k,q] <<- (err.rate.main - rmse[q])/rmse[q]
          NULL
        })
        NULL
      })
      rm(nullObj)
      rownames(vimp) <- x_Names
    }
  }
  obj <- vimp
  invisible(obj)
}
