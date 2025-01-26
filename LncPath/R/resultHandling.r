

lncPath2Table <- function(Result){
        #Result: a data frame, resulted from function lncPath;
        gs.name <- vector();
        GSSize <- vector();
        Obs.ES <- vector();
        Obs.ES.norm <- vector();
        P_Val <- vector();
        FDR <- vector();

        for( i in 1:length(Result)){
                gs.name <- c(gs.name, Result[[i]]$gs.name);
                GSSize <- c(GSSize, Result[[i]]$GSSize);
                Obs.ES <- c(Obs.ES, Result[[i]]$Obs.ES);
                Obs.ES.norm <- c(Obs.ES.norm, Result[[i]]$Obs.ES.norm);
                P_Val <- c(P_Val, Result[[i]]$P_Val);
                FDR <- c(FDR, Result[[i]]$FDR);
        }

        Table <- as.data.frame(cbind(gs.name, GSSize, Obs.ES, Obs.ES.norm, P_Val, FDR));
        names(Table) <- c("Gene Set Name", "Gene Set Size", "Enrichment Scores", "Normalized Enrichment Scores", "P Value", "False Discovery Rate");
        Table <- Table[order(Table[["False Discovery Rate"]], decreasing = FALSE),];
        return(Table);

}


geneSetDetail <- function(Result, Name){
        ## Result: a lncPath object come from the lncPath function;
        ## Name: a string, the geneset name to be print;
            GSInfo <- Result[[Name]];
            kk <- 1
            N <- length(GSInfo$geneSymbols);
            gene.number <- vector(length = GSInfo$GSSize, mode = "character")
            gene.names <- vector(length = GSInfo$GSSize, mode = "character")
            #gene.symbols <- vector(length = GSInfo$GSSize, mode = "character")
            #gene.descs <- vector(length = GSInfo$GSSize, mode = "character")
            gene.list.loc <- vector(length = GSInfo$GSSize, mode = "numeric")
            core.enrichment <- vector(length = GSInfo$GSSize, mode = "character")
            gene.s2n <- vector(length = GSInfo$GSSize, mode = "numeric")
            gene.RES <- vector(length = GSInfo$GSSize, mode = "numeric")
            #rank.list <- seq(1, N)

            if (GSInfo$Obs.ES >= 0) {
              set.k <- seq(1, N, 1)
              #phen.tag <- phen1
              #loc <- match(i, Obs.ES.index)
            } else {
              set.k <- seq(N, 1, -1)
              #phen.tag <- phen2
              #loc <- Ng - match(i, Obs.ES.index) + 1
            }

            for (k in set.k) {
               if (GSInfo$Obs.indicator[k] == 1) {
                  gene.number[kk] <- kk
                  gene.names[kk] <- GSInfo$geneSymbols[k];
                  #gene.symbols[kk] <- substr(obs.gene.symbols[k], 1, 15)
                  #gene.descs[kk] <- substr(obs.gene.descs[k], 1, 40)
                  gene.list.loc[kk] <- k
                  gene.s2n[kk] <- signif(GSInfo$Obs.s2n[k], digits = 3)
                  gene.RES[kk] <- signif(GSInfo$Obs.RES[k], digits = 3)
                  if (GSInfo$Obs.ES >= 0) {
                     core.enrichment[kk] <- ifelse(gene.list.loc[kk] <= GSInfo$Obs.arg.ES, "YES", "NO")
                  } else {
                     core.enrichment[kk] <- ifelse(gene.list.loc[kk] > GSInfo$Obs.arg.ES, "YES", "NO")
                  }
                  kk <- kk + 1
               }
            }

       gene.report <- data.frame(cbind(gene.number, gene.names, gene.list.loc, gene.s2n, gene.RES, core.enrichment))
       names(gene.report) <- c("#", "GENE", "LIST LOC", "S2N", "RES", "CORE_ENRICHMENT")
       return(gene.report);


}


drawAHeatMap <- function(Result, Name, PCExpr, Labels){
        ## Draw a hearmap for a certain element of the lncPath object;
        ## Result: a lncPath object come from the lncPath function;
        ## Name: a string, the geneset name to be print;
        ## PCExpr: the expression of Protein Coding genes;
        ## Labels: a vector of 0 and 1, 0 indicates control and 1 indicates case; 
        GSInfo <- Result[[Name]];
        GSP <- geneSetDetail(Result, Name);
        #Symbols <- GSP[["GENE"]][which(GSP[["CORE_ENRICHMENT"]] == "YES")];     
        Symbols <- GSP[["GENE"]];
        #Expr <- PCExpr[row.names(PCExpr)%in%Symbols,];
        Expr <- PCExpr[match(Symbols, row.names(PCExpr))[!is.na(match(Symbols, row.names(PCExpr)))],];
        #write.csv(Expr, file = "Expr.csv");
        lncPath.HeatMapPlot(as.matrix(Expr), col.labels = Labels, col.classes = c("N", "T"), row.names = row.names(Expr), col.names = names(Expr), main = "HeatMap for genes in gene set");
}


printSignifResult <- function(Result, Threshold = 0.01, Path = ".", HeatPlot = FALSE, PCExpr = "", Labels = "", Top = 0){
        ## Result: the result from lncPath method;
        ## Threshold: the FDR threshold;
        ## Path: the output directory;
        ## HeatPlot: logical, should the heatmaps be plotted?
        ## PCExpr: a data frame, represents the expression profile of genes, the rownames must be gene names, must be set if HeatPlot is TRUE;
        ## Labels: a vector of 0 and 1, 0 indicates control and 1 indicates case, must be set if HeatPlot is TRUE;
        ## Top: an integer, indicates the number of top significant pathways to be print;
        if(Top >0){
                Table <- lncPath2Table(Result);
                for(i in 1:Top){
                        GSP <- geneSetDetail(Result, Table[["Gene Set Name"]][i]);
                        write.csv(GSP, file = paste(Path, "/", gsub(" ", "_", Table[["Gene Set Name"]][i]), ".csv", sep = ""), row.names = FALSE);
                        pdf(file = paste(Path, "/", gsub(" ", "_", Table[["Gene Set Name"]][i]), ".pdf", sep = ""));
                        plotRunningES(Result, Table[["Gene Set Name"]][i]);
                        dev.off();
                        if(HeatPlot == TRUE){
                                pdf(file = paste(Path, "/", gsub(" ", "_", Table[["Gene Set Name"]][i]), "HeatMap.pdf", sep = ""));
                                drawAHeatMap(Result, Table[["Gene Set Name"]][i], PCExpr, Labels);
                                dev.off();
                        }

                }
        }else{

                for(i in 1:length(Result)){
                        if(Result[[i]]$FDR <= Threshold){
                                GSP <- geneSetDetail(Result, Result[[i]]$gs.name);
                                write.csv(GSP, file = paste(Path, "/", gsub(" ", "_", Result[[i]]$gs.name), ".csv", sep = ""), row.names = FALSE);
                                pdf(file = paste(Path, "/", gsub(" ", "_", Result[[i]]$gs.name), ".pdf", sep = ""));
                                plotRunningES(Result, Result[[i]]$gs.name);
                                dev.off();
                             if(HeatPlot == TRUE){
                                        pdf(file = paste(Path, "/", gsub(" ", "_", Result[[i]]$gs.name), "HeatMap.pdf", sep = ""));
                                        drawAHeatMap(Result, Result[[i]]$gs.name, PCExpr, Labels);
                                        dev.off();
                                 }
                        }
                 }
        }
}


plotRunningES<-function(Result, Name){

        ## Result: a lncPath object come from the lncPath function;
        ## Name: a string, the geneset name to be print;

        GSInfo <- Result[[Name]];

        N <- length(GSInfo$geneSymbols);

        WalkScore <- as.data.frame(cbind(GSInfo$geneSymbols,GSInfo$Obs.s2n));

        gs.name <- GSInfo$gs.name;

        Obs.ES <- GSInfo$Obs.ES;

        Obs.RES <- GSInfo$Obs.RES;

        Obs.indicator <- GSInfo$Obs.indicator;

        Obs.arg.ES <- GSInfo$Obs.arg.ES

        obs.s2n <- as.numeric(WalkScore[[2]]);

        obs.s2n <- sort(obs.s2n, decreasing=T);

        ind <- 1:N;

        min.RES <- min(Obs.RES)

        max.RES <- max(Obs.RES)

        if (max.RES < 0.3) max.RES <- 0.3

        if (min.RES > -0.3) min.RES <- -0.3

        delta <- (max.RES - min.RES)*0.50

        min.plot <- min.RES - 2*delta

        max.plot <- max.RES;
        max.corr <- max(obs.s2n);

        min.corr <- min(obs.s2n);

        Obs.correl.vector.norm <- (obs.s2n - min.corr)/(max.corr - min.corr)*1.25*delta + min.plot

        zero.corr.line <- (- min.corr/(max.corr - min.corr))*1.25*delta + min.plot

        col <- ifelse(Obs.ES > 0, 2, 4)

        sub.string <- paste("Number of genes: ", N, " (in list), ", gs.name, " (in gene set)", sep = "", collapse="");

        main.string <- gs.name;

        plot(ind, Obs.RES, main = main.string, sub = sub.string, xlab = "Gene List Index", ylab = "Running Enrichment Score (RES)", xlim=c(1, N), ylim=c(min.plot, max.plot), type = "l", lwd = 2, cex = 1, col = col);

        for (k in seq(1, N, 20)) {

                lines(c(k, k), c(zero.corr.line, Obs.correl.vector.norm[k]), lwd = 1, cex = 1, col = colors()[12]) # shading of correlation plot

            }

            lines(c(1, N), c(0, 0), lwd = 1, lty = 2, cex = 1, col = 1) # zero RES line

            lines(c(Obs.arg.ES, Obs.arg.ES), c(min.plot, max.plot), lwd = 1, lty = 3, cex = 1, col = col) # max enrichment vertical line

                        for (k in 1:N) {

               if (Obs.indicator[k] == 1) {

                  lines(c(k, k), c(min.plot + 1.25*delta, min.plot + 1.75*delta), lwd = 1, lty = 1, cex = 1, col = 1)  # enrichment tags

               }

            }

            lines(ind, Obs.correl.vector.norm, type = "l", lwd = 1, cex = 1, col = 1)

            lines(c(1, N), c(zero.corr.line, zero.corr.line), lwd = 1, lty = 1, cex = 1, col = 1) # zero correlation horizontal line

            temp <- order(abs(obs.s2n), decreasing=T);

            arg.correl <- temp[N]

            adjx <- ifelse(Obs.ES > 0, 0, 1)

            leg.txt <- paste("Peak at ", Obs.arg.ES, sep="", collapse="")

            text(x=Obs.arg.ES, y=min.plot + 1.8*delta, adj = c(adjx, 0), labels=leg.txt, cex = 1.0)
}











