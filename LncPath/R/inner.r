

initializeLncPathEnvir<-function(){
##initialize the environment variable;
   utils::data("LncPathEnvir",package="LncPath");
}


##RandomWalk function
RandomWalk2igraph<-function(igraphM,VertexWeight,EdgeWeight=TRUE,gamma=0.7){
        ##igraphM: an object of class igraph for random walk to perform;
        ##VertexWeight: a vector of the vertex weights, for unweithted strategy, 1 indicates seed vertex, 0 else;
        ##EdgeWeight: logical, if the weight of edge should be take into consideration;
#        print("now, do the random walk:");
#        print(Sys.time());
      if(EdgeWeight==TRUE){
        adjM<-get.adjacency(igraphM,attr="weight") # convert igraph object to a weight matrix
      }
      if(EdgeWeight==FALSE){
        adjM<-get.adjacency(igraphM) # convert igraph object to a conventional matrix
      }
      res<-rw(adjM,VertexWeight,gamma)
#        print(Sys.time());
      return(drop(res))
}


rw<-function(W,p0,gamma) {
## perform a random walk;  
      p0<-t(p0)
      p0 <- p0/sum(p0)
      PT <- p0
      k <- 0
      delta <- 1
      Ng <- dim(W)[2]
      for (i in 1:Ng) {
        sumr<-sum(W[i,])
        if(sumr==0){
        W[i,] <-numeric(length=length(W[i,]))
        }
        if(sumr>0){
        W[i,] <- W[i,]/sum(W[i,])
        }
     }
     W<-as.matrix(W)
     W <- t(W)

     while(delta>1e-10) {
      PT1 <- (1-gamma)*W
      PT2 <- PT1 %*% t(PT)
      PT3 <- (gamma*p0)
      PT4 <- t(PT2) + PT3
      delta <- sum(abs(PT4 - PT))
      PT <- PT4
      k <- k + 1
    }
    PT<-t(PT)
    rownames(PT)<-NULL
    return(PT)
}


lncPath.EnrichmentScore <- function(gene.list, gene.set, weighted.score.type = 1, correl.vector = NULL) {
#
# Computes the weighted GSEA score of gene.set in gene.list. 
# The weighted score type is the exponent of the correlation 
# weight: 0 (unweighted = Kolmogorov-Smirnov), 1 (weighted), and 2 (over-weighted). When the score type is 1 or 2 it is 
# necessary to input the correlation vector with the values in the same order as in the gene list.
#
# Inputs:
#   gene.list: The ordered gene list (e.g. integers indicating the original position in the input dataset)  
#   gene.set: A gene set (e.g. integers indicating the location of those genes in the input dataset) 
#   weighted.score.type: Type of score: weight: 0 (unweighted = Kolmogorov-Smirnov), 1 (weighted), and 2 (over-weighted)  
#  correl.vector: A vector with the coorelations (e.g. signal to noise scores) corresponding to the genes in the gene list 
#
# Outputs:
#   ES: Enrichment score (real number between -1 and +1) 
#   arg.ES: Location in gene.list where the peak running enrichment occurs (peak of the "mountain") 
#   RES: Numerical vector containing the running enrichment score for all locations in the gene list 
#   tag.indicator: Binary vector indicating the location of the gene sets (1's) in the gene list 
#
# The Broad Institute
# SOFTWARE COPYRIGHT NOTICE AGREEMENT
# This software and its documentation are copyright 2003 by the
# Broad Institute/Massachusetts Institute of Technology.
# All rights are reserved.
#
# This software is supplied without any warranty or guaranteed support
# whatsoever. Neither the Broad Institute nor MIT can be responsible for
# its use, misuse, or functionality.
   tag.indicator <- sign(match(gene.list, gene.set, nomatch=0))    # notice that the sign is 0 (no tag) or 1 (tag) 
   no.tag.indicator <- 1 - tag.indicator
   N <- length(gene.list)
   Nh <- length(gene.set)
   Nm <-  N - Nh
   if (weighted.score.type == 0) {
      correl.vector <- rep(1, N)
   }
   alpha <- weighted.score.type
   correl.vector <- abs(correl.vector**alpha)
   sum.correl.tag    <- sum(correl.vector[tag.indicator == 1])
   norm.tag    <- 1.0/sum.correl.tag
   norm.no.tag <- 1.0/Nm
   RES <- cumsum(tag.indicator * correl.vector * norm.tag - no.tag.indicator * norm.no.tag)
   max.ES <- max(RES)
   min.ES <- min(RES)
   if (max.ES > - min.ES) {
#      ES <- max.ES
      ES <- signif(max.ES, digits = 5)
      arg.ES <- which.max(RES)
   } else {
#      ES <- min.ES
      ES <- signif(min.ES, digits=5)
      arg.ES <- which.min(RES)
   }
   return(list(ES = ES, arg.ES = arg.ES, RES = RES, indicator = tag.indicator))
}


lncPath.EnrichmentScore2 <- function(gene.list, gene.set, weighted.score.type = 1, correl.vector = NULL) {
#
# Computes the weighted GSEA score of gene.set in gene.list. It is the same calculation as in 
# lncPath.EnrichmentScore but faster (x8) without producing the RES, arg.RES and tag.indicator outputs.
# This call is intended to be used to asses the enrichment of random permutations rather than the 
# observed one.
# The weighted score type is the exponent of the correlation 
# weight: 0 (unweighted = Kolmogorov-Smirnov), 1 (weighted), and 2 (over-weighted). When the score type is 1 or 2 it is 
# necessary to input the correlation vector with the values in the same order as in the gene list.
#
# Inputs:
#   gene.list: The ordered gene list (e.g. integers indicating the original position in the input dataset)  
#   gene.set: A gene set (e.g. integers indicating the location of those genes in the input dataset) 
#   weighted.score.type: Type of score: weight: 0 (unweighted = Kolmogorov-Smirnov), 1 (weighted), and 2 (over-weighted)  
#  correl.vector: A vector with the coorelations (e.g. signal to noise scores) corresponding to the genes in the gene list 
#
# Outputs:
#   ES: Enrichment score (real number between -1 and +1) 
#
# The Broad Institute
# SOFTWARE COPYRIGHT NOTICE AGREEMENT
# This software and its documentation are copyright 2003 by the
# Broad Institute/Massachusetts Institute of Technology.
# All rights are reserved.
#
# This software is supplied without any warranty or guaranteed support
# whatsoever. Neither the Broad Institute nor MIT can be responsible for
# its use, misuse, or functionality.

   N <- length(gene.list)
   Nh <- length(gene.set)
   Nm <-  N - Nh

   loc.vector <- vector(length=N, mode="numeric")
   peak.res.vector <- vector(length=Nh, mode="numeric")
   valley.res.vector <- vector(length=Nh, mode="numeric")
   tag.correl.vector <- vector(length=Nh, mode="numeric")
   tag.diff.vector <- vector(length=Nh, mode="numeric")
   tag.loc.vector <- vector(length=Nh, mode="numeric")

   loc.vector[gene.list] <- seq(1, N)
   tag.loc.vector <- loc.vector[gene.set]

   tag.loc.vector <- sort(tag.loc.vector, decreasing = F)

   if (weighted.score.type == 0) {
      tag.correl.vector <- rep(1, Nh)
   } else if (weighted.score.type == 1) {
      tag.correl.vector <- correl.vector[tag.loc.vector]
      tag.correl.vector <- abs(tag.correl.vector)
   } else if (weighted.score.type == 2) {
      tag.correl.vector <- correl.vector[tag.loc.vector]*correl.vector[tag.loc.vector]
      tag.correl.vector <- abs(tag.correl.vector)
   } else {
      tag.correl.vector <- correl.vector[tag.loc.vector]**weighted.score.type
      tag.correl.vector <- abs(tag.correl.vector)
   }

   norm.tag <- 1.0/sum(tag.correl.vector)
   tag.correl.vector <- tag.correl.vector * norm.tag
   norm.no.tag <- 1.0/Nm
   tag.diff.vector[1] <- (tag.loc.vector[1] - 1)
   tag.diff.vector[2:Nh] <- tag.loc.vector[2:Nh] - tag.loc.vector[1:(Nh - 1)] - 1
   tag.diff.vector <- tag.diff.vector * norm.no.tag
   peak.res.vector <- cumsum(tag.correl.vector - tag.diff.vector)
   valley.res.vector <- peak.res.vector - tag.correl.vector
   max.ES <- max(peak.res.vector)
   min.ES <- min(valley.res.vector)
   ES <- signif(ifelse(max.ES > - min.ES, max.ES, min.ES), digits=5)

   return(list(ES = ES))

}


ESNorm <- function(ESs){
        ## Perform a standarization for the ES scores;
        pos.m <- mean(ESs[which(ESs >= 0)]);
        neg.m <- mean(abs(ESs[which(ESs < 0)]));
        ESs[which(ESs >= 0)] <- ESs[which(ESs >= 0)]/pos.m;
        ESs[which(ESs < 0)] <- ESs[which(ESs < 0)]/neg.m;
        return(ESs);
}



lncPath.HeatMapPlot <- function(V, row.names = F, col.labels, col.classes, col.names = F, main = " ", xlab=" ", ylab=" ") {

# Plots a heatmap "pinkogram" of a gene expression matrix including phenotype vector and gene, sample and phenotype labels

       n.rows <- length(V[,1])

       n.cols <- length(V[1,])

       row.mean <- apply(V, MARGIN=1, FUN=mean)

       row.sd <- apply(V, MARGIN=1, FUN=sd)

       row.n <- length(V[,1])

       for (i in 1:n.rows) {

           if (row.sd[i] == 0) {

               V[i,] <- 0

           } else {

               V[i,] <- (V[i,] - row.mean[i])/(0.5 * row.sd[i])

           }

           V[i,] <- ifelse(V[i,] < -6, -6, V[i,])

           V[i,] <- ifelse(V[i,] > 6, 6, V[i,])

        }

        mycol <- c("#0000FF", "#0000FF", "#4040FF", "#7070FF", "#8888FF", "#A9A9FF", "#D5D5FF", "#EEE5EE", "#FFAADA", "#FF9DB0", "#FF7080", "#FF5A5A", "#FF4040", "#FF0D1D", "#FF0000") # blue-pinkogram colors. The first and last are the colors to indicate the class vector (phenotype). This is the 1998-vintage, pre-gene cluster, original pinkogram color map

        mid.range.V <- mean(range(V)) - 0.1

        heatm <- matrix(0, nrow = n.rows + 1, ncol = n.cols)

        heatm[1:n.rows,] <- V[seq(n.rows, 1, -1),]

        heatm[n.rows + 1,] <- ifelse(col.labels == 0, 7, -7)

        image(1:n.cols, 1:(n.rows + 1), t(heatm), col=mycol, axes=FALSE, main=main, xlab= xlab, ylab=ylab)

        if (length(row.names) > 1) {

            numC <- nchar(row.names)

            size.row.char <- 35/(n.rows + 5)

            size.col.char <- 25/(n.cols + 5)

            maxl <- floor(n.rows/1.6)

            for (i in 1:n.rows) {

               row.names[i] <- substr(row.names[i], 1, maxl)

            }

            row.names <- c(row.names[seq(n.rows, 1, -1)], "Class")

            axis(2, at=1:(n.rows + 1), labels=row.names, adj= 0.5, tick=FALSE, las = 1, cex.axis=size.row.char, font.axis=2, line=-1)

        }

        if (length(col.names) > 1) {

           axis(1, at=1:n.cols, labels=col.names, tick=FALSE, las = 3, cex.axis=size.col.char, font.axis=2, line=-1)

        }

        C <- split(col.labels, col.labels)

        class1.size <- length(C[[1]])

        class2.size <- length(C[[2]])

        axis(3, at=c(floor(class1.size/2),class1.size + floor(class2.size/2)), labels=col.classes, tick=FALSE, las = 1, cex.axis=1.25, font.axis=2, line=-1)

        return()

}


#########################Differencial Analysis
##### T Test, for a given expression, it performs two-sample t-test for case and control group, in labels, 
##### 0 represents case,1 represents control
calT <- function(inData, classLabel) {
                ## inData: a data frame, represents the expression profile to be tested;
                ## classLabel: a vector of 01s, represents the tags of case and control teams;
        m <- length(ind1 <- which(classLabel == 1))
        n <- length(ind2 <- which(classLabel == 0))
        inData1 <- inData[, ind1]
        inData2 <- inData[, ind2]
        rmean1 <- rowMeans(inData1)
        rmean2 <- rowMeans(inData2)
        ss1 <- rowSums((inData1 - rmean1)^2)
        ss2 <- rowSums((inData2 - rmean2)^2)
        tt <- (m + n - 2)^0.5 * (rmean2 - rmean1)/((1/m + 1/n) *
            (ss1 + ss2))^0.5
        return(list(T = tt, df = m + n - 2))
    }

calFD <- function(inData, classLabel) {
       ## inData: a data frame, represents the expression profile to be tested;
       ## classLabel: a vector of 01s, represents the tags of case and control teams;

        case <- inData[, which(classLabel == 0)];
        control <- inData[, which(classLabel == 1)];
       outData1 <- unname(as.matrix(case))
       outData2 <- unname(as.matrix(control))
       rmean1 <- rowMeans(apply(outData1, 2,as.numeric))
       rmean2 <- rowMeans(apply(outData2, 2,as.numeric))
       fd <- (rmean1/rmean2);
       logfd <- log(fd, 2);
       Result <- as.data.frame(cbind(rownames(inData), fd, logfd));
        names(Result) <- c("ID", "FoldChange", "Log2FoldChange");
       return(Result);
}

