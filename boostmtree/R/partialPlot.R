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


partialPlot <- function (object,
                         M = NULL,
                         xvar.names,
                         tm.unq,
                         xvar.unq = NULL,
                         npts = 25,
                         subset,
                         prob.class = FALSE,
                         conditional.xvars = NULL,
                         conditional.values = NULL,
                         plot.it = FALSE,
                         Variable_Factor = FALSE,
                         path_saveplot = NULL,
                         Verbose = TRUE,
                         useCVflag = FALSE,
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
  if ( !is.null(conditional.xvars) && !is.null(conditional.values) ) {
    if (length(conditional.xvars) != length(conditional.values)) {
      stop("conditional x-variable and conditional value vectors are not of same length")
    }
    for (i in 1:length(conditional.xvars)) {
      if( is.factor(object$x[,conditional.xvars[i] ])){
        xuniq <- unique(object$x[,conditional.xvars[i] ])
        if ( !any(xuniq == conditional.values[i] )  ) {
          stop("conditional value for the conditional variable:", conditional.xvars[i], " is not from the original data.")
        }
      }
    }
  }
  tmOrg <- sort(unique(unlist(object$time)))
  if (missing(tm.unq)) {
    tm.q <- unique(quantile(tmOrg, (1:9)/10, na.rm = TRUE))
    tm.pt <- sapply(tm.q, function(tt) {#assign original time values
      max(which.min(abs(tmOrg - tt)))
    })
  }
  else {
    tm.pt <- sapply(tm.unq, function(tt) {#assign original time values
      max(which.min(abs(tmOrg - tt)))
    })
  }
  n.tm <- length(tm.pt)
  if(is.null(M)){
    if(is.null(object$Mopt)){
      M <- object$M
    }else
    {
      M <- object$Mopt
    }
  }
  #----------------------------------------------------------------------------------
  # Date: 09/08/2020
  # Following comment added as a part of estimating partial predicted mu based on
  # oob sample
  # How the subset should be handled in the case of useCVflag == TRUE?
  #----------------------------------------------------------------------------------
  if (!missing(subset)) {
    object$x <- object$x[subset,, drop = FALSE]
  }
  if( !is.null(conditional.xvars) && !is.null(conditional.values) ){
    n.cond.xvar <- length(conditional.xvars)
    for(i in 1:n.cond.xvar){
      if(is.factor(object$x[, conditional.xvars[i]  ])){
        object$x[, conditional.xvars[i]  ] <- as.factor(conditional.values[i])
      }else
      {
        object$x[, conditional.xvars[i]  ] <- conditional.values[i]
      }
    }
  }
  family <- object$family
  if(family == "Ordinal" && prob.class == TRUE){
    n.Q <- (object$n.Q + 1)
    Q_set <- c(object$Q_set,max(object$Q_set) + 1)
    p.obj <- vector("list",n.Q)
  } else
  {
    n.Q <- object$n.Q
    Q_set <- object$Q_set
    p.obj <- vector("list",n.Q)
  }
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
  p.obj[[q]] <- lapply(xvar.names, function(nm) {
    x <- object$x[, nm]
    n.x <-length( unique(na.omit(x) ))
    if(is.null(xvar.unq)){
      x.unq <- sort(unique( na.omit(x) ))[unique(as.integer(seq(1, n.x, length = min(npts, n.x))))] 
    }else
    {
      if(!is.list(xvar.unq)){
        stop("xvar.unq must be a list of length same as xvar.names")
      }
      if( length(xvar.unq) != length(xvar.names) ){
        stop("Length of xvar.unq and xvar.names is different")
      }
      if(!identical(xvar.names,names(xvar.unq))){
        stop("Names of xvar.unq must match with xvar.names")
      }
     x.unq <- xvar.unq[[which(names(xvar.unq) == nm)]] 
    }
    newx <- object$x
    rObj <- t(sapply(x.unq, function(xu) {
      newx[, nm] <- rep(xu, nrow(newx))
      if(Variable_Factor){
        newx[, nm] <- as.factor(newx[, nm])
      }
      if(family == "Ordinal" && prob.class == TRUE){
        mu <- predict.boostmtree(object, x = newx, tm = tmOrg, partial = TRUE,M = M,useCVflag = useCVflag, ...)$Prob_class[[q]]
      } else
      {
        if(family == "Continuous" || family == "Binary"){
            mu <- predict.boostmtree(object, x = newx, tm = tmOrg, partial = TRUE,M = M,useCVflag = useCVflag, ...)$mu
        }else
        {
          mu <- predict.boostmtree(object, x = newx, tm = tmOrg, partial = TRUE,M = M,useCVflag = useCVflag, ...)$mu[[q]]
        }        
      }
      mn.x <- colMeans(do.call(rbind, lapply(mu, function(mm) {mm[tm.pt]})),na.rm = TRUE)
      c(xu, mn.x)
    }))
    colnames(rObj) <- c("x", paste("y.", 1:length(tm.pt), sep = ""))
    rObj
  })
  names(p.obj[[q]]) <- xvar.names
  if (plot.it) {
   if(is.null(path_saveplot)){
      path_saveplot <- tempdir()
   }
    Plot_Name <- if(n.Q == 1) "PartialPlot.pdf" else paste("PartialPlot_Prob(y = ",Q_set[q],")",".pdf",sep="")
    pdf(file = paste(path_saveplot,"/",Plot_Name,sep=""),width = 10,height = 10)
  l.obj[[q]] <- lapply(p.obj[[q]], function(pp) {
    x <- pp[, 1]
    y <- apply(pp[, -1, drop = FALSE], 2, function(yy) {
      lowess(x, yy)$y})
    rObj <- cbind(x, y)
    colnames(rObj) <- c("x", paste("y.", 1:length(tm.pt), sep = ""))
    rObj
  })
  names(l.obj[[q]]) <- xvar.names
  def.par <- par(no.readonly = TRUE)
    for (k in 1:n.xvar) {
      plot(range(l.obj[[q]][[k]][, 1],na.rm = TRUE), range(l.obj[[q]][[k]][, -1],na.rm = TRUE), type = "n",
           xlab = xvar.names[k], ylab = "predicted y (adjusted)")
      for (l in 1:n.tm) {
        lines(l.obj[[q]][[k]][, 1], l.obj[[q]][[k]][, -1, drop = FALSE][, l], type = "l", ,col = l)
      }
    }
  par(def.par)
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
