

lncPath <- function(LncRNAList, Network,  Weighted = TRUE, PathwayDataSet = "KEGG", minPathSize = 15, maxPathSize = 500, nperm = 1000){

#### for a given LncRNA list, perform a random walk on the "lncRNA - protein coding gene" co-expression network, then the scores of the protein coding genes in the random walk are used for a GSEA enrichment analysis. A list contains the erichment score, the p-value for random test and the false discovery rate will be created.

##LncRNAlist : a character vector, contains the user interested lncRNAs;
##Network : a dataframe with two columns, describing the edges of the network;
##Weighted: logical, tell if a weighted analysis to be performed;
##PathwayDataSet: a character, tells which pathway database is to be used;
##minPathSize: an integer, the lower limit of the mapped genes in pathway;
##maxPathSize: an integer, the upper limit of the mapped genes in pathway;

## test if the input lncRNA list is empty and map the different ID type to Ensembl gene ID;
        if(length(LncRNAList) == 0) stop("The list is empty.");
## perform a random walk; 

        cat("Now start the random walking...\n");
        if(!exists("LncPathEnvir")) LncPathEnvir <- initializeLncPathEnvir();
        #NetLncPath <- get("NetLncPath", envir = LncPathEnvir);
        NetLncPath <- graph.edgelist(as.matrix(Network),directed=FALSE);
        VertexWeight <- rep(0,length(V(NetLncPath)));
        names(VertexWeight) <- V(NetLncPath)$name;
        VertexWeight[V(NetLncPath)$name%in%LncRNAList]<-1;
        print(names(which(VertexWeight == 1)));
        cat(paste(length(which(VertexWeight == 1)), "of", length(LncRNAList), "were mapped to the huge net with", length(VertexWeight), "Nodes.", "\n"));
        WalkRes<-RandomWalk2igraph(NetLncPath,VertexWeight,EdgeWeight=FALSE);
        WalkScore<-as.data.frame(cbind(V(NetLncPath)$name,WalkRes));
	#save(WalkScore, file = "WalkScore.rda");
## WalkScore normalization
	if(length(which(as.numeric(WalkScore[[2]]) == 0)) > 0) WalkScore <- WalkScore[-(which(as.numeric(WalkScore[[2]]) == 0)),];        
        #WalkScore[[2]] <- log10(as.numeric(WalkScore[[2]])/min(as.numeric(WalkScore[[2]])));
        WalkScore[[2]] <- sqrt(as.numeric(WalkScore[[2]]));
        WalkScore <- WalkScore[order(WalkScore[[2]], decreasing=TRUE),];
        PCEnsem2Sym <- get("PCEnsem2Sym", envir = LncPathEnvir);
        PCWalkScore <- merge(PCEnsem2Sym,WalkScore,by.x=2,by.y=1);
        PCWalkScore <- PCWalkScore[order(PCWalkScore[[3]], decreasing = TRUE),];
	#save(PCWalkScore, file = "PCWalkScore.rda");
## GeneSets filteration
        GeneSets<- get(paste(PathwayDataSet, "PathGene", sep = ""), envir = LncPathEnvir);
        GeneSetsTemp <- vector(mode = "list");
        k <- 1;
        #print(length(GeneSets))
        for(i in 1:length(GeneSets)){
                if(length(intersect(GeneSets[[i]]$Components, PCWalkScore[[1]])) > minPathSize && length(intersect(GeneSets[[i]]$Components, PCWalkScore[[1]])) < maxPathSize){
                        GeneSetsTemp[[k]] <- GeneSets[[i]];
                        k <- k + 1;
                }
        }
        GeneSets <- GeneSetsTemp;
## perform a GSEA enrichment analysis;
        cat("Now, calculating running scores of each pathway...");
        Ng <- length(GeneSets);
        N <- dim(PCWalkScore)[1];
        Obs.ES <- vector();
        Result <- list();

        for(i in 1:Ng){
                #print(i);
                GenesIndex <- order(PCWalkScore[[3]], decreasing = TRUE);
                GenesPathIndex <- match(intersect(GeneSets[[i]]$Components, PCWalkScore[[1]]), PCWalkScore[[1]]);
                if(Weighted == FALSE){
                                #       print("Calculating Unweighted");
                        GSEA.results <- lncPath.EnrichmentScore(gene.list = GenesIndex, gene.set = GenesPathIndex, weighted.score.type = 0);
                }else{
                                #       print("Calculating Weighted")
                        GSEA.results <- lncPath.EnrichmentScore(gene.list = GenesIndex, gene.set = GenesPathIndex, weighted.score.type = 1, correl.vector = as.numeric(PCWalkScore[[3]]));
                }
                Obs.ES <- c(Obs.ES, GSEA.results$ES);

                Result[[GeneSets[[i]]$name]] <- list(gs.name = GeneSets[[i]]$name, GSSize = length(intersect(GeneSets[[i]]$Components, PCWalkScore[[1]])), Obs.ES = GSEA.results$ES, Obs.arg.ES = GSEA.results$arg.ES, Obs.RES = GSEA.results$RES, Obs.indicator = GSEA.results$indicator, Obs.s2n = as.numeric(PCWalkScore[[3]]), geneSymbols = PCWalkScore[[1]]);
        }
        cat("Now, do the purtabationsions...");
        phi <- matrix(nrow = Ng, ncol = nperm);

        for(j in 1:nperm){
                #WalkScoreRand <- as.data.frame(cbind(sample(WalkScore[[1]]), WalkScore[[2]]));
                PCWalkScoreRand <- as.data.frame(cbind(PCWalkScore[[1]], sample(PCWalkScore[[3]])));
                PCWalkScoreRand <- PCWalkScoreRand[order(PCWalkScoreRand[[2]],decreasing=TRUE),];
                GenesIndex <- order(PCWalkScoreRand[[2]], decreasing = TRUE);
                for(i in 1:Ng){
                        GenesPathIndex <- match(intersect(GeneSets[[i]]$Components, PCWalkScoreRand[[1]]), PCWalkScoreRand[[1]]);                                                if(Weighted == FALSE){
                                 GSEA.results <- lncPath.EnrichmentScore2(gene.list = GenesIndex, gene.set = GenesPathIndex, weighted.score.type = 0);
                         }else{
                                 GSEA.results <- lncPath.EnrichmentScore2(gene.list = GenesIndex, gene.set = GenesPathIndex, weighted.score.type = 1,correl.vector = as.numeric(PCWalkScore[[3]]));
                         }
                         phi[i, j] <- GSEA.results$ES;

                }

        }

        Obs.ES.norm <- ESNorm(Obs.ES);
        #save(phi, file = "phi.rda");

        GSEA_P <- vector("numeric", length = Ng);
        for(i in 1:Ng){
                GSEA_P[i] <- signif(sum(as.numeric(phi[i,]) >= Obs.ES[i])/nperm, digits=5)
        }
        GSEA_FDR <- p.adjust(GSEA_P, method = "fdr");

        for(i in 1:Ng){
                Result[[i]]$P_Val <- GSEA_P[i];
                Result[[i]]$FDR <- GSEA_FDR[i];
                Result[[i]]$Obs.ES.norm <- Obs.ES.norm[i];
        }
        return(Result);
}





