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


marginalPlot <- function (object,
                          xvar.names,
                          tm.unq,
                          subset,
                          plot.it = FALSE,
                          path_saveplot = NULL,
                          Verbose = TRUE,
                         ...)
{
  if (sum(inherits(object, c("boostmtree", "grow"), TRUE) == c(1, 2)) != 2) {
    stop("this function only works for objects of class `(boostmtree, grow)'")
  }
  if (missing(xvar.names)) {
    xvar.names <- colnames(object$x)
  }
  xvar.names <- intersect(xvar.names, colnames(object$x))
  if (length(xvar.names) == 0) {
    stop("x-variable names provided do not match original variable names")
  }
  n.xvar <- length(xvar.names)
  tmOrg <- sort(unique(unlist(object$time)))
  if (missing(tm.unq)) {
    tm.unq <- unique(quantile(tmOrg, (1:9)/10, na.rm = TRUE))
    tm.pt <- sapply(tm.unq, function(tt) {#assign original time values
      max(which.min(abs(tmOrg - tt)))
    })
  }
  else {
    tm.pt <- sapply(tm.unq, function(tt) {#assign original time values
      max(which.min(abs(tmOrg - tt)))
    })
  }
  n.tm <- length(tm.pt)
  if (!missing(subset)) {
    object$x <- object$x[subset,, drop = FALSE]
  }
  n <- nrow(object$x)
  family <- object$family
  n.Q <- object$n.Q
  Q_set <- object$Q_set
  p.obj <- vector("list",n.Q)
  if(n.Q > 1){
    names(p.obj) <- unlist(lapply(1:n.Q,function(q){
      paste("y = ",Q_set[q],sep="")
    }))
  }
  if(plot.it){
    l.obj <- vector("list",n.Q)
    if(n.Q > 1){
      names(l.obj) <- unlist(lapply(1:n.Q,function(q){
        paste("y = ",Q_set[q],sep="")
      }))
    }
  }
  for(q in 1:n.Q){
  if(n.tm == 1){
    if(family == "Nominal" || family == "Ordinal"){
      muhat <- cbind(matrix(unlist(predict.boostmtree(object = object)$muhat[[q]]),nrow = n,byrow = TRUE)[,tm.pt])
    }else
    {
      muhat <- cbind(matrix(unlist(predict.boostmtree(object = object)$muhat),nrow = n,byrow = TRUE)[,tm.pt])
    }
    }
  else {
    if(family == "Nominal" || family == "Ordinal"){
       muhat <- matrix(unlist(predict.boostmtree(object = object)$muhat[[q]]),nrow = n,byrow = TRUE)[,tm.pt]
    }else
    {
      muhat <- matrix(unlist(predict.boostmtree(object = object)$muhat),nrow = n,byrow = TRUE)[,tm.pt]
    }     
  }
  p.obj[[q]] <- lapply(1:n.xvar, function(nm){
    x <- object$x[, xvar.names[nm]]
    RawDt <- lapply(1:n.tm,function(nt){
      cbind(x,muhat[,nt])
    })
    names(RawDt) <- paste("time = ",tm.unq,sep="")
    RawDt
  })
  names(p.obj[[q]]) <- xvar.names  
  if(plot.it){
   if(is.null(path_saveplot)){
      path_saveplot <- tempdir()
   }
  Plot_Name <- if(n.Q == 1) "MarginalPlot.pdf" else paste("MarginalPlot_Prob(y = ",Q_set[q],")",".pdf",sep="")
  pdf(file = paste(path_saveplot,"/",Plot_Name,sep=""),width = 10,height = 10)
  l.obj[[q]] <- lapply(1:n.xvar, function(nm){
    x <- object$x[, xvar.names[nm]]
    lo.fit <- lapply(1:n.tm,function(nt){
      fit <- lowess(x,muhat[,nt])
      cbind(fit$x,fit$y)
    })
    names(lo.fit) <- paste("time = ",tm.unq,sep="")
    lo.fit
  })
  names(l.obj[[q]]) <- xvar.names
    for(pp in 1:n.xvar){
      xmin <- min(unlist(lapply(1:n.tm,function(nn){  l.obj[[q]][[pp]][[nn]][,1]   })))
      xmax <- max(unlist(lapply(1:n.tm,function(nn){  l.obj[[q]][[pp]][[nn]][,1]   })))
      ymin <- min(unlist(lapply(1:n.tm,function(nn){  l.obj[[q]][[pp]][[nn]][,2]   })))
      ymax <- max(unlist(lapply(1:n.tm,function(nn){  l.obj[[q]][[pp]][[nn]][,2]   })))
      plot(l.obj[[q]][[pp]][[1]][,1],l.obj[[q]][[pp]][[1]][,2],type = "n",xlim=c(xmin,xmax),ylim=c(ymin,ymax) ,
           xlab = xvar.names[pp],ylab = "Predicted response")
      for(nn in 1:n.tm){
      lines(l.obj[[q]][[pp]][[nn]][,1],l.obj[[q]][[pp]][[nn]][,2],type = "l",col = nn)
      }
    }
    dev.off()
    if(Verbose){
       cat("Plot will be saved at:",path_saveplot,sep = "","\n")
    }    
  }
 }
  return(invisible(list(p.obj = if(family == "Nominal" || family == "Ordinal") p.obj else unlist(p.obj,recursive = FALSE), 
                        l.obj = if(plot.it) {if(family == "Nominal" || family == "Ordinal") l.obj else unlist(l.obj,recursive = FALSE)} else NULL, 
                        time = tmOrg[tm.pt])))
}
