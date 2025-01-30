#' Construct the projection pursuit regression tree
#'
#' Find regression tree structure using various projection pursuit indices
#' in each split.
#' @usage PPTreereg(formula,data,DEPTH=NULL,Rr=1,PPmethod="LDA",
#'                  weight=TRUE,lambda=0.1,r=1,TOL.CV=0.1,selP=NULL,
#'                  energy=0,maxiter=500,
#'                  standardized=TRUE,even=TRUE,space=0,
#'                  maxFinalNode=20,maxNodeN=10,...)
#' @param formula an object of class "formula"
#' @param data data frame
#' @param DEPTH depth of the projection pursuit regression tree
#' @param Rr cutoff rule in each node
#' @param PPmethod method for projection pursuit; \code{"LDA"}, \code{"PDA"}, \code{"Lr"},
#'                 \code{"GINI"}, and \code{"ENTROPY"}.
#' @param weight weight flag in \code{LDA}, \code{PDA} and \code{Lr} index
#' @param lambda lambda in PDA index
#' @param r r in Lr index
#' @param TOL.CV CV limit for the final node
#' @param selP number of variables for the final node in Method 5
#' @param energy energy parameter
#' @param maxiter number of maximum iteration
#' @param standardized standardize each X variable before fitting
#'                     the tree structure. Default value is TRUE
#' @param even divide evenly at each node. Default value is TRUE
#' @param space space between two groups of dependent variable
#' @param maxFinalNode maximum number of final node
#' @param maxNodeN maximum number of observations in the final node
#' @param ... arguments to be passed to methods
#' @return Tree.result projection pursuit regression tree result with
#'                     \code{PPtreeclass} object format
#' @return MSE mean squared error of the final tree
#' @return \code{mean.G}  means of the observations in the final node
#' @return \code{sd.G} standard deviations of the observations in the final node.
#' @return \code{coef.G} regression coefficients for Method 3, 4 and 5
#' @return \code{origY} original dependent variable vector
#' @return \code{origX.mean} mean of original X
#' @return \code{origX.sd} standard deviation of original X
#' @return \code{class.origX.mean} means of the each independent variables in the final node
#' @references ...
#' @export
#' @keywords tree
## usethis namespace: start
#' @useDynLib PPtreeregViz, .registration = TRUE
## usethis namespace: end
#' @importFrom magrittr %>%
#'
#' @examples
#' data(mtcars)
#' Tree.result <- PPTreereg(mpg~.,mtcars,DEPTH=2,PPmethod="LDA")
#' Tree.result
#'
PPTreereg<-function(formula,data,DEPTH=NULL,Rr=1,PPmethod="LDA",
                      weight=TRUE,lambda=0.1,r=1,TOL.CV=0.1,selP=NULL,
                      energy=0,maxiter=500,
                      standardized=TRUE,even=TRUE,space=0,
                      maxFinalNode=20,maxNodeN=10,...){

   Call<-match.call()
   indx<-match(c("formula","data"),names(Call),nomatch=0L)
   if(indx[1]==0L)
     stop("a 'formula' argument is required")
   temp<-Call[c(1L,indx)]
   temp[[1L]]<-quote(stats::model.frame)
   m<-eval.parent(temp)
   Terms<-attr(m,"terms")
   formula<-as.character(formula)
   class.n<-formula[2]
   data.n<-strsplit(formula[3]," \\+ ")[[1]]
   int.flag<-any(strsplit(formula[3]," \\* ")[[1]] == formula[3])
   if(data.n[1]=="."){
     tot.n<-class.n
   } else{
     tot.n<-c(class.n,data.n)
   }
   if(!int.flag){
     stop("PPTreeclass cannot treat interaction terms")
   }else if(!sum(duplicated(c(colnames(data),tot.n))[-c(1:ncol(data))])==
            length(tot.n)){
     stop(paste(paste(tot.n[duplicated(c(colnames(data),
                       tot.n))[-c(1:ncol(data))]],collapse=","),
                " is/are not in your data"))
   }else{
     origY<-data[,class.n]
     if(data.n[1]=="."){
       origXX<-data[,colnames(data)!=class.n]
     }else {
       origXX<-data[,data.n,drop=FALSE]
     }
   }

   Find.proj<-function(origclass,origdata,PPmethod="LDA",weight=TRUE,
                       lambda=0.1,r=1,...){
      n<-nrow(origdata)
      p<-ncol(origdata)
      g<-table(origclass)
      g.name<-as.numeric(factor(names(g)))
      G<-length(g)
      origclass<-as.numeric(factor(origclass))
      if(PPmethod=="LDA"){
         indexbest<-PPtreeViz::LDAindex(origclass,as.matrix(origdata),
                                        weight=weight);
      } else if(PPmethod=="PDA"){
         indexbest<-PPtreeViz::PDAindex(origclass,as.matrix(origdata),
                             weight=weight,lambda=lambda);
      } else if(PPmethod=="Lr"){
         indexbest<-PPtreeViz::Lrindex(origclass,as.matrix(origdata),
                            weight=weight,r=r);
      } else if(PPmethod=="GINI"){
         indexbest<-0;
         for(i in 1:p){
            tempdata<-origdata[,i];
            tempindex<-PPtreeViz::GINIindex1D(origclass,as.matrix(tempdata));
            if(indexbest<tempindex)
               indexbest<-tempindex;
         }
      } else if(PPmethod=="ENTROPY"){
         indexbest<-0;
         for(i in 1:p){
            tempdata<-origdata[,i];
            tempindex<-PPtreeViz::ENTROPYindex1D(origclass,as.matrix(tempdata));
            if(indexbest<tempindex)
               indexbest<-tempindex;
         }
      }
      energy<-ifelse(energy==0,1-indexbest,energy)
      energy.temp<-1-indexbest
      TOL.temp<-energy.temp/1000000
      if(PPmethod=="LDA"){
         a.proj.best<-PPtreeViz::LDAopt(as.numeric(as.factor(origclass)),
                             as.matrix(origdata),weight,q=1)$projbest
      } else if(PPmethod=="PDA"){
         a.proj.best<-PPtreeViz::PDAopt(as.numeric(as.factor(origclass)),
                               as.matrix(origdata),weight,
                               q=1,lambda=lambda)$projbest
      } else {
         a.proj.best<-PPtreeViz::PPopt(as.numeric(as.factor(origclass)),
                            as.matrix(origdata),PPmethod=PPmethod,
                            r=r,q=1,energy=energy,cooling=0.999,
                            TOL=TOL.temp)$projbest
      }
      proj.data<-as.matrix(origdata)%*%a.proj.best
      if(diff(tapply(proj.data,origclass,mean))<0)
         a.proj.best <- -a.proj.best
      proj.data<-as.matrix(origdata)%*%a.proj.best
      class<-origclass
      m.LR<-tapply(proj.data,class,mean)
      sd.LR<-tapply(proj.data, class, function(x)
                                         ifelse(length(x)>1,stats::sd(x),0))
      IQR.LR<-tapply(proj.data, class, function(x)
                                         ifelse(length(x)>1,stats::IQR(x),0))
      median.LR<-tapply(proj.data, class, stats::median)
      n.LR<-table(class)
      c1<-(m.LR[1]+m.LR[2])/2
      c2<-(m.LR[1]*n.LR[2]+m.LR[2]*n.LR[1])/sum(n.LR)
      c3<-ifelse(sum(sd.LR==0)!=0,c1,(m.LR[1]*sd.LR[2]+m.LR[2]*sd.LR[1])/
                                      sum(sd.LR))
      c4<-ifelse(sum(sd.LR==0)!=0,c2,(m.LR[1]*sd.LR[2]/sqrt(n.LR[2])+
                                      m.LR[2]*sd.LR[1]/sqrt(n.LR[1]))/
                           (sd.LR[1]/sqrt(n.LR[1])+sd.LR[2]/sqrt(n.LR[2])))
      c5<-(median.LR[1]+median.LR[2])/2
      c6<-(median.LR[1]*n.LR[2]+median.LR[2]*n.LR[1])/sum(n.LR)
      c7<-ifelse(sum(IQR.LR==0)!=0,c5,(median.LR[1]*IQR.LR[2]+
                                         median.LR[2]*IQR.LR[1])/sum(IQR.LR))
      c8<-ifelse(sum(IQR.LR==0)!=0,c6,(median.LR[1]*(IQR.LR[2]/sqrt(n.LR[2]))+
                                     median.LR[2]*(IQR.LR[1]/sqrt(n.LR[1])))/
                         ((IQR.LR[1]/sqrt(n.LR[1]))+(IQR.LR[2]/sqrt(n.LR[2]))))
      sel.proj<-sort(proj.data[
         which(proj.data>stats::quantile(proj.data,prob=0.25)&
               proj.data<stats::quantile(proj.data,prob=0.75))])
      sel.n<-length(sel.proj)
      temp.cut<-matrix((sel.proj[2:sel.n]+sel.proj[1:(sel.n-1)])/2,ncol=1)
      c9<-sel.proj[sort.list(apply(temp.cut,1,function(x)
                                { temp<-table(class,proj.data>x[1]);
                                  return(prod(temp[,1])+prod(temp[,2]))}))[1]]
      C<-c(c1, c2, c3, c4,c5,c6,c7,c8,c9)
      if(PPmethod=="LDA"){
         Index<-PPtreeViz::LDAindex(as.numeric(as.factor(class)),
                                    as.matrix(proj.data),weight=weight)
      } else if(PPmethod=="PDA"){
         Index<-PPtreeViz::PDAindex(as.numeric(as.factor(class)),
                                    as.matrix(proj.data),
                                    weight=weight,lambda=lambda)
      } else if(PPmethod=="Lr"){
         Index<-PPtreeViz::Lrindex(as.numeric(as.factor(class)),
                                   as.matrix(proj.data),weight=weight,r=r)
      } else if(PPmethod=="GINI"){
         Index<-PPtreeViz::GINIindex1D(as.numeric(as.factor(class)),
                                       as.matrix(proj.data))
      } else if(PPmethod=="ENTROPY"){
         Index<-PPtreeViz::ENTROPYindex1D(as.numeric(as.factor(class)),
                               as.matrix(proj.data))
      }
      Alpha<-t(a.proj.best)
      IOindexL <- class==1
      IOindexR <- class==2
      list(Index=Index,Alpha=Alpha,C=C,IOindexL=IOindexL,IOindexR=IOindexR)
   }

   Tree.construct<-function(origY,origdata,Tree.Struct,id,depth,
                             rep1,rep2,projbest.node,splitCutoff.node,
                             G,cut.class.keep,...) {
      maxG<-500
      N<-length(origY)
      if(even){
        cut.class<-stats::median(origY)
      } else{
        proj.density<-stats::density(origY)
        signD<-sign(diff(proj.density[[2]]))
        min.ID<-which(diff(signD)>0)+1
        if(length(min.ID)>1){
          min.ID<-min.ID[which.min(abs(min.ID-length(proj.density[[1]])/2))]
        }
       if(length(min.ID)==0){
          cut.class<-stats::median(origY)
        } else{
          cut.class<-proj.density[[1]][min.ID[which.min(proj.density[[2]][min.ID])]]
        }
        IOindexL <- origY <= cut.class
        IOindexR <- origY > cut.class

        if(length(min.ID)==0 | sum(IOindexL)<N*0.25 |
           sum(IOindexR)< N*0.25){
           cut.class<-stats::median(origY)
        }
      }
      origclass<-ifelse(origY<=cut.class,1,2)
      if(length(table(origclass))==1){
         origclass<- ifelse(origY < cut.class,1,2)
      }
      n<-nrow(origdata)
      p<-ncol(origdata)
      g<-table(origclass)
      if(length(Tree.Struct)==0) {
         Tree.Struct<-matrix(1:(2*maxG-1),ncol=1)
         Tree.Struct<-cbind(Tree.Struct,0,0,0,0,0,0,0)
      }

      BW <- sum(table(origclass)*
                   (tapply(origY,origclass,mean,na.rm=TRUE)-
                       mean(origY,na.rm=TRUE))^2)/
               (stats::var(origY)*(length(origY)-1))
      if(N<=max(maxNodeN,globeN*2/maxFinalNode)){
        sizeTest <-TRUE
      }else{
        sizeTest<-FALSE
      }
      if(is.null(DEPTH)&(length(table(origclass))<=1)|
         ifelse(!is.null(DEPTH),depth>=DEPTH,FALSE)|BW<TOL.CV|sizeTest){
         G<-G+1
         Tree.Struct[id, 3]<-G
         Tree.Struct[id,7]<-stats::sd(origY)
         Tree.Struct[id,6]<-mean(origY)
         Tree.Struct[id,8]<-n
         cut.class.keep<-sort(cut.class.keep)
         return(list(Tree.Struct=Tree.Struct,projbest.node=projbest.node,
                     depth=depth,splitCutoff.node=splitCutoff.node,
                     rep1=rep1,rep2=rep2,G=G,cut.class.keep=cut.class.keep))
      } else {
         cut.class.keep<-c(cut.class.keep,cut.class)
         depth<-depth+1;
         Tree.Struct[id,2]<-rep1
         rep1<-rep1+1
         Tree.Struct[id,3]<-rep1
         rep1<-rep1+1
         Tree.Struct[id,4]<-rep2
         rep2<-rep2+1
         projS<-(origY<stats::quantile(origY,0.5-space/2) |
                    origY>=stats::quantile(origY,0.5+space/2))
         a<-Find.proj(origclass[projS],origdata[projS,],PPmethod,weight,lambda,r)
         splitCutoff.node<-rbind(splitCutoff.node,a$C)
         Tree.Struct[id,5]<-a$Index
         Tree.Struct[id,8]<-n
         projbest.node<-rbind(projbest.node,a$Alpha)
         t.data<-origdata[a$IOindexL,,drop=FALSE]
         t.Y<-origY[a$IOindexL]

         b<-Tree.construct(t.Y,as.matrix(t.data),Tree.Struct,
                           Tree.Struct[id,2],depth,rep1,rep2,
                           projbest.node,splitCutoff.node,G,
                           cut.class.keep)
         G<-b$G
         cut.class.keep<-b$cut.class.keep
         Tree.Struct<-b$Tree.Struct
         projbest.node<-b$projbest.node
         splitCutoff.node<-b$splitCutoff.node
         rep1<-b$rep1
         rep2<-b$rep2
         t.data<-origdata[a$IOindexR,,drop=FALSE]
         t.Y<-origY[a$IOindexR]
         n<-nrow(t.data)
         b<-Tree.construct(t.Y,as.matrix(t.data),Tree.Struct,
                           Tree.Struct[id,3],depth,rep1,rep2,
                           projbest.node,splitCutoff.node,G,
                           cut.class.keep)
         Tree.Struct<-b$Tree.Struct
         depth<-b$depth
         cut.class.keep<-b$cut.class.keep
         projbest.node<-b$projbest.node
         splitCutoff.node<-b$splitCutoff.node
         rep1<-b$rep1
         rep2<-b$rep2
         G<-b$G
      }
      cut.class.keep <- sort(cut.class.keep)
      colnames(projbest.node) <-colnames(origdata)

      return(list(Tree.Struct=Tree.Struct,projbest.node=projbest.node,
                  splitCutoff.node=splitCutoff.node,depth=depth,
                  rep1=rep1,rep2=rep2,G=G,cut.class.keep=cut.class.keep))
   }

   origX<-origXX<-as.matrix(origXX)
   origX.mean<-NULL
   origX.sd<-NULL
   if(standardized){
      origX.mean<-apply(origX,2,function(x) mean(x,na.rm=TRUE))
      origX.sd<-apply(origX,2,function(x) stats::sd(x,na.rm=TRUE))
      origX<-t(apply(origX,1,function(x)
         (x-origX.mean)/origX.sd))
   }
   globeN <-nrow(origX)
   splitCutoff.node<-NULL
   projbest.node<-NULL
   Tree.Struct<-NULL
   id<-1
   rep1<-2
   rep2<-1
   Tree.final<-Tree.construct(origY,origX,Tree.Struct,id,0,rep1,rep2,
                              projbest.node,splitCutoff.node,0,NULL)

   Tree.Struct<-Tree.final$Tree.Struct
   Tree.Struct<-Tree.Struct[-which(Tree.Struct[,3]==0),,drop=FALSE]

   origclass<-rep(0,length(origY))
   g<-length(Tree.final$cut.class.keep)+1
   for(i in (g-1):1){
      sel.id<-which(origclass==0&origY>Tree.final$cut.class.keep[i])
      if(length(sel.id)==0)
         sel.id<-which(origclass==0&origY>=Tree.final$cut.class.keep[i])
      origclass[sel.id]<-i+1
   }
   origclass[origclass==0]<-1
   colnames(Tree.Struct)<-c("id","L.node.ID","R.node.ID",
                            "Coef.ID","Index","mean","sd","n")
   projbest.node<-Tree.final$projbest.node
   splitCutoff.node<-Tree.final$splitCutoff.node
   origclass<-factor(origclass,levels=1:g)
   median.G<-tapply(origY,origclass,stats::median)
   mean.G<-tapply(origY,origclass,mean,trim=0.1)
   sd.G<-tapply(origY,origclass,stats::sd)
   predict.class<-origclass
   TS<-Tree.Struct
   p<-ncol(origX)
   selP<-ifelse(is.null(selP),max(min(p,2),round(p*0.2)),selP)
   g<-length(table(predict.class))

   coef.G1<-NULL
   coef.G2<-NULL
   coef.G3<-matrix(0,ncol=(1+ncol(origX)),nrow=g)
   coef.G4<-matrix(0,ncol=(1+ncol(origX)),nrow=g)
   coef.G5<-matrix(0,ncol=(1+ncol(origX)),nrow=g)
   predict.Y<-rep(0,length(predict.class))

   origX.G <- matrix(0,ncol=ncol(origXX),nrow=g)
   origX.G.num <- matrix(0,ncol=1,nrow=g)
   for(i in 1:g){
      sel.id<-which(predict.class==i)
      origX.G[i,] <- colMeans(origXX[sel.id,])
      origX.G.num[i]<- length(sel.id)
      if(length(sel.id)!=0 & stats::sd(origY[sel.id])!=0){
         Ycor<-abs(suppressWarnings(
                  stats::cor(origY[sel.id],origX[sel.id,])))
         cor.list<-sort.list(abs(suppressWarnings(
            stats::cor(origY[sel.id],origX[sel.id,]))),
            decreasing=TRUE)
         names(Ycor)<-colnames(origX)
         sort(Ycor,decreasing = TRUE)
         var1<-correlation<-1 # dummy for removing "NOTE: no visible binding"
         tempcor<-abs(suppressWarnings(stats::cor(origX[sel.id,])))
         tempcor[lower.tri(tempcor,diag=TRUE)]<-0
         tempcor<-data.frame(tempcor,var1=colnames(tempcor))
         tempcor<-tidyr::gather(tempcor,key="var2",value="correlation",-var1)
         tempcor <- dplyr::filter(tempcor,correlation>0.9)
         tempcor <- dplyr::arrange(tempcor,dplyr::desc(correlation))
         Ycor.id<-1:ncol(origX)
         names(Ycor.id)<-colnames(origX)
         delY.list<-Ycor.id[unique(apply(tempcor,1,
                 function(x) x[which.min(Ycor[as.character(x[1:2])])]))]
         delY.list<-c(delY.list, which(apply(origX,2,stats::sd)==0))
         cor.list<-cor.list[!(cor.list %in% delY.list)]

         str.id<-TS[c(which(TS[,2]==which(TS[,2]==0 &TS[,3]==i)),
               which(TS[,2]!=0&TS[,3]==which(TS[,2]==0 &TS[,3]==i))),4]
         temp.G<-projbest.node[str.id,]
         proj.data<-as.matrix(origX)%*%matrix(temp.G)
         sel.data<-data.frame(Y=origY[sel.id],X=proj.data[sel.id,1])
         del.id<-which(abs(stats::rstandard(stats::lm(Y~.,data=sel.data)))>3)

         if(length(del.id)==0){
           temp.coef<-stats::coef(stats::lm(Y~.,data=sel.data))
         }else{
           temp.coef<-stats::coef(stats::lm(Y~.,data=sel.data[-del.id,]))
         }
         temp.G<-c(temp.coef[1],temp.G*temp.coef[2])
         temp.G3<-temp.G

         sel.data<-data.frame(Y=origY[sel.id],X=origX[sel.id,cor.list])
         if(nrow(sel.data)>ncol(sel.data)+10){
                  temp.G<-rep(0,ncol(origX)+1)
            del.id<-which(abs(stats::rstandard(stats::lm(Y~.,data=sel.data)))>3)

            if(length(del.id)==0){
              temp.G[c(1,cor.list+1)]<-
                 stats::coef(stats::lm(Y~.,data=sel.data))
           }else{
              temp.G[c(1,cor.list+1)]<-
                 stats::coef(stats::lm(Y~.,data=sel.data[-del.id,]))
           }
            temp.G[is.na(temp.G)]<-0
         } else{
            tempG<-rep(0,ncol(coef.G4))
         }
         temp.G4<-temp.G

         sel.data<-data.frame(Y=origY[sel.id],
                              X=origX[sel.id,cor.list[1:selP]])
         if(nrow(sel.data)>ncol(sel.data)+5){
            temp.G<-rep(0,ncol(origX)+1)
            del.id<-which(abs(stats::rstandard(stats::lm(Y~.,data=sel.data)))>3)

            if(length(del.id)==0){
               temp.G[c(1,cor.list[1:selP]+1)]<-
                  stats::coef(stats::lm(Y~.,data=sel.data))
            }else{
               temp.G[c(1,cor.list[1:selP]+1)]<-
                  stats::coef(stats::lm(Y~.,data=sel.data[-del.id,]))
            }
         } else{
            temp.G<-rep(0,ncol(coef.G5))
         }
         temp.G5<-temp.G
      } else{
         temp.G3<-rep(0,ncol(coef.G3))
         temp.G4<-rep(0,ncol(coef.G4))
         temp.G5<-rep(0,ncol(coef.G5))
      }
      if(!is.null(temp.G3))
         temp.G3[is.na(temp.G3)]<-0
      if(!is.null(temp.G4))
         temp.G4[is.na(temp.G4)]<-0
      if(!is.null(temp.G5))
         temp.G5[is.na(temp.G5)]<-0
      coef.G3[i,]<-temp.G3
      coef.G4[i,]<-temp.G4
      coef.G5[i,]<-temp.G5
   }
   colnames(coef.G3)<-c("intercept",colnames(origX))
   colnames(coef.G4)<-c("intercept",colnames(origX))
   colnames(coef.G5)<-c("intercept",colnames(origX))
   colnames(origX.G)<-colnames(origX)

   if(!is.null(splitCutoff.node))
      colnames(splitCutoff.node)<-paste("Rule",1:9,sep="")
   if(!is.null(projbest.node))
      projbest.node=as.matrix(projbest.node)
   treeobj<-list(Tree.Struct=Tree.Struct,
                 projbest.node=projbest.node,
                 splitCutoff.node=splitCutoff.node,
                 origclass=origclass,
                 origdata=as.matrix(origXX))

   #class(treeobj)<-append(class(treeobj),"PPtreeclass")

   regtreeobj<-list(Tree.result=treeobj,
                    mean.G=mean.G,
                    median.G=median.G,
                    class.origX.mean = origX.G,
                    class.num = origX.G.num,
                    sd.G=sd.G,
                    coef.G=list(coef.G1,coef.G2,coef.G3,coef.G4,coef.G5),
                    origY=origY,
                    cut.class=Tree.final$cut.class.keep,
                    origX.mean=origX.mean,origX.sd=origX.sd,formula=formula)
   class(regtreeobj)<-"PPTreereg"
   return(regtreeobj)
}
