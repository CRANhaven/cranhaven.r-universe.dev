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


plot.boostmtree <- function (x, 
                             use.rmse = TRUE,
                             path_saveplot = NULL,
                             Verbose = TRUE,
                              ...)
{
  if (sum(inherits(x, c("boostmtree", "grow"), TRUE) == c(1, 2)) != 2 &
      sum(inherits(x, c("boostmtree", "predict"), TRUE) == c(1, 2)) != 2) {
    stop("this function only works for objects of class `(boostmtree, grow)' or '(boostmtree, predict)'")
  }
  if (sum(inherits(x, c("boostmtree", "grow"), TRUE) == c(1, 2)) == 2) {
    n.Q <- x$n.Q
    Q_set <- x$Q_set
    Family <- x$family
    if(Family == "Continuous" || Family == "Binary"){
      List_Temp <- vector("list",1)
      List_Temp[[1]] <- x$mu
      x$mu <- List_Temp
      rm(List_Temp)
      List_Temp <- vector("list",1)
      List_Temp[[1]] <- x$Yorg
      x$Yorg <- List_Temp
      rm(List_Temp)
     if(!is.null(x$err.rate)){
      List_Temp <- vector("list",1)
      List_Temp[[1]] <- x$err.rate
      x$err.rate <- List_Temp
      rm(List_Temp)
     }
     if(!is.null(x$rho)){
       x$rho <- as.matrix(x$rho) 
     }
      if(!is.null(x$phi)){
        x$phi <- as.matrix(x$phi) 
      }
      if(!is.null(x$lambda)){
        x$lambda <- as.matrix(x$lambda) 
      }
    }
    for(q in 1:n.Q){
    Plot_Name <- if(n.Q == 1) "boostmtree_plot.pdf" else paste("boostmtree_plot_Prob(y = ",Q_set[q],")",".pdf",sep="")
    if(is.null(path_saveplot)){
      path_saveplot <- tempdir()
   }
    pdf(file = paste(path_saveplot,"/",Plot_Name,sep=""),width = 10,height = 10)
    def.par <- par(no.readonly = TRUE) 
    n <- x$n
    M <- x$M
    univariate <- length(x$id) == length(unique(x$id))
    if (!univariate) {
      if (is.null(x$err.rate)) {
        layout(rbind(c(1, 4), c(2, 5), c(3, 6)), widths = c(1, 1))
      }
      else {
        layout(rbind(c(1, 3), c(2, 4), c(2, 5)), widths = c(1, 1))
      }
    } else 
      {
      if (!is.null(x$err.rate)) {
        layout(rbind(c(1, 2)), widths = c(1, 1))
      }
    }
    if (!univariate) {
        plot(unlist(x$time), unlist(x$mu[[q]]), xlab = "time", ylab = "predicted", type = "n")
        line.plot(x$time, x$mu[[q]])
    }
    if (!use.rmse) {
       x$err.rate[[q]][, "l2"] <- (x$err.rate[[q]][, "l2"] * x$ysd)^2
       y.lab <- "OOB MSE"
    }
    else {
      y.lab <- "OOB standardized RMSE"
    }
    if (!univariate) {
      if(is.null(x$err.rate)) {
        plot(unlist(x$time), unlist(x$Yorg[[q]]) - unlist(x$mu[[q]]), xlab = "time", ylab = "residual", type = "n")
        line.plot(x$time, lapply(1:n, function(i) {x$Yorg[[q]][[i]] - x$mu[[q]][[i]]}))
        plot(unlist(x$Yorg[[q]]), unlist(x$mu[[q]]), xlab = "y", ylab = "predicted", type = "n")
        line.plot(x$Yorg[[q]], x$mu[[q]])
      }
      else {#error rate
        plot(1:M, x$err.rate[[q]][, "l2"],
           xlab = "iteration", 
           ylab = y.lab,
           type = "l", lty = 1)
        abline(v = x$Mopt[q], lty = 2, col = 2, lwd = 2)
      }
    }
    else {
      plot(unlist(x$Yorg[[q]]), unlist(x$mu[[q]]), xlab = "y", ylab = "predicted", type = "n")
      point.plot(x$Yorg[[q]], x$mu[[q]])
      abline(0, 1, col = "gray", lty = 2)
      if (!is.null(x$err.rate)) {
        plot(1:M, x$err.rate[[q]][, "l2"],
             xlab = "iteration", 
             ylab = y.lab,
             type = "l", lty = 1)
        abline(v = x$Mopt[q], lty = 2, col = 2, lwd = 2)
      }
    }
    if (!univariate) {
      plot(1:M, x$rho[,q], ylim = range(lowess.mod(1:M, x$rho[,q])$y),
           xlab = "iterations", ylab = expression(rho), type = "n")
      lines(lowess.mod(1:M, x$rho[,q], f = 5/10))
      plot(1:M, x$phi[,q], ylim = range(lowess.mod(1:M, x$phi[,q])$y),
           xlab = "iterations", ylab = expression(phi), type = "n")
      lines(lowess.mod(1:M, x$phi[,q], f = 5/10))
      plot(1:M, x$lambda[,q], ylim = range(lowess.mod(1:M, x$lambda[,q])$y),
           xlab = "iterations", ylab = expression(lambda), type = "n")
      lines(lowess.mod(1:M, x$lambda[,q], f = 5/10))
    }
    par(def.par)
    dev.off()
    if(Verbose){
       cat("Plot will be saved at:",path_saveplot,sep = "","\n")
    } 
   }
  }
  else {
    n.Q <- x$n.Q
    Q_set <- x$Q_set
    Family <- x$family
    if(Family == "Continuous" || Family == "Binary"){
      List_Temp <- vector("list",1)
      List_Temp[[1]] <- x$mu
      x$mu <- List_Temp
      rm(List_Temp)
      List_Temp <- vector("list",1)
      List_Temp[[1]] <- x$err.rate
      x$err.rate <- List_Temp
      rm(List_Temp)
      if(!is.null(x$boost.obj$rho)){
        x$boost.obj$rho <- as.matrix(x$boost.obj$rho)   
      }
      if(!is.null(x$boost.obj$phi)){
        x$boost.obj$phi <- as.matrix(x$boost.obj$phi)   
      }
      if(!is.null(x$boost.obj$lambda)){
        x$boost.obj$lambda <- as.matrix(x$boost.obj$lambda)   
      }
    }
    for(q in 1:n.Q){
    Plot_Name <- if(n.Q == 1) "boostmtree_plot.pdf" else paste("boostmtree_plot_Prob(y = ",Q_set[q],")",".pdf",sep="")
    if(is.null(path_saveplot)){
      path_saveplot <- tempdir()
    }
    pdf(file = paste(path_saveplot,"/",Plot_Name,sep=""),width = 10,height = 10)
    univariate <- length(x$boost.obj$id) == length(unique(x$boost.obj$id))
    if (!(univariate && is.null(x$err.rate))) {
      def.par <- par(no.readonly = TRUE) 
    }
    if (!univariate && is.null(x$err.rate)) {
      plot(unlist(x$time), unlist(x$mu[[q]]), xlab = "time", ylab = "predicted", type = "n")
      line.plot(x$time, x$mu[[q]])
    }
    else if (!is.null(x$err.rate)) {
      M <- x$boost.obj$M
      Mopt <- x$Mopt[q]
      x$vimp <- NULL
      if (!univariate) {
        if (!is.null(x$vimp)) {
          layout(rbind(c(1, 3), c(1, 4), c(2, 5), c(2, 6)), widths = c(1, 1))
        }
        else {
          layout(rbind(c(1, 2), c(1, 3), c(1, 4), c(1, 5)), widths = c(1, 1))
        }
      }
      else {
        if (!is.null(x$vimp)) {
          layout(rbind(c(1, 2)), widths = c(1, 1))
        }
      }
      if (!use.rmse) {
        x$err.rate[[q]][, "l2"] <- (x$err.rate[[q]][, "l2"] * x$boost.obj$ysd)^2
        if (!is.null(x$vimp)) {
          x$vimp <- (x$vimp * x$boost.obj$ysd)^2
        }
        y.lab.err <- "Test sample MSE"
        y.lab.vimp <- "Variable Importance (MSE)"
      }
      else {
        y.lab.err <- "Test sample standardized RMSE"
        y.lab.vimp <- "Variable Importance (standardized RMSE)"
      }
      plot(1:M, x$err.rate[[q]][, "l2"],
           xlab = "iteration", 
           ylab = y.lab.err,
           type = "l", lty = 1)
      abline(v = Mopt[q], lty = 2, col = 2, lwd = 2)
      if (!is.null(x$vimp)) {
        vimp <- x$vimp
        barplot(vimp, las = 2, ylab = y.lab.vimp, cex.names = 1.0)
      }
      if (!univariate) {
        plot(unlist(x$time), unlist(x$mu[[q]]), xlab = "time", ylab = "predicted", type = "n")
        line.plot(x$time, x$mu[[q]])
        plot(1:M, x$boost.obj$rho[,q], ylim = range(lowess.mod(1:M, x$boost.obj$rho[,q])$y), 
             xlab = "iterations", ylab = expression(rho), type = "n")
        lines(lowess.mod(1:M, x$boost.obj$rho[,q], f = 5/10))
        abline(v=Mopt[q], lty = 2, col = 2, lwd = 2)
        plot(1:M, x$boost.obj$phi[,q], ylim = range(lowess.mod(1:M, x$boost.obj$phi[,q])$y), 
             xlab = "iterations", ylab = expression(phi), type = "n")
        lines(lowess.mod(1:M, x$boost.obj$phi[,q], f = 5/10))
        abline(v=Mopt, lty = 2, col = 2, lwd = 2)
        plot(1:M, x$boost.obj$lambda[,q], ylim = range(lowess.mod(1:M, x$boost.obj$lambda[,q])$y),
             xlab = "iterations", ylab = expression(lambda), type = "n")
        lines(lowess.mod(1:M, x$boost.obj$lambda[,q], f = 5/10))
        abline(v=Mopt[q], lty = 2, col = 2, lwd = 2)
      }
    }
    if (!(univariate && is.null(x$err.rate))) {
      par(def.par)
    }
    dev.off()
    if(Verbose){
       cat("Plot will be saved at:",path_saveplot,sep = "","\n")
    } 
  }
  }
}
