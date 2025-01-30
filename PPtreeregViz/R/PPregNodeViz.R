#' Visualize node in projection pursuit regression tree.
#'
#' This function is developed for the visualization of inner and final nodes.
#' Visual representation of the projection coefficient value of each node and
#' the result of projected data help understand growth process of the projection pursuit regression tree.
#' For the inner node, two plots are provided - the bar chart style plot with
#' projection pursuit coefficients of each variable, the histogram of the
#' projected data.
#' For the final node, scatter plot of observed Y vs. fitted Y according to the final rules.
#' @title Node visualization
#' @usage PPregNodeViz(PPTreeregOBJ,node.id,Rule=5)
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param node.id node ID of inner or final node
#' @param Rule split rule
#'             1: mean of two group means
#'             2: weighted mean of two group means - weight with group size
#'             3: weighted mean of two group means - weight with group sd
#'             4: weighted mean of two group means - weight with group se
#'             5: mean of two group medians
#'             6: weighted mean of two group medians - weight with group size
#'             7: weighted mean of two group median - weight with group IQR
#'             8: weighted mean of two group median - weight with group IQR
#'                                                    and group size
#' @export
#' @keywords tree
#' @return An object of the class \code{ggplot}
#' @examples
#' data(dataXY)
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' PPregNodeViz(Model,node.id=1)
#' PPregNodeViz(Model,node.id=4)
#'
PPregNodeViz<-function(PPTreeregOBJ,node.id,Rule=5){

  searchGroup<-function(node.id,TS,gName){
    flag<-TRUE
    sel.id<-TS[node.id,2:3]
    sel.group<-NULL
    i<-1
    while((sel.id[i]!=0)&&(i<length(sel.id))){
      if(TS[sel.id[i],2]!=0){
        sel.id<-c(sel.id,TS[sel.id[i],2:3])
      }
      if(TS[sel.id[i+1],2]!=0){
        sel.id<-c(sel.id,TS[sel.id[i+1],2:3])
      }
      i<-i+2
    }
    return(gName[sort(TS[sel.id[which(TS[sel.id,2]==0)],3])])
  }

  final.search<-function(PPtreeobj,node.id,direction){
    TS<-PPtreeobj$Tree.Struct
    leaf.group<-NULL
    if(direction=="left"){
      keep.id<-TS[node.id,2]
      i<-1
      while(i<=length(keep.id)){
        if(TS[keep.id[i],2]==0){
          leaf.group<-c(leaf.group,TS[keep.id[i],3])
          i<-i+1
        } else{
          keep.id<-c(keep.id,TS[keep.id[i],2:3])
          i<-i+1
        }
      }
    } else if(direction=="right"){
      keep.id<-TS[node.id,3]
      i<-1
      while(i<=length(keep.id)){
        if(TS[keep.id[i],2]==0){
          leaf.group<-c(leaf.group,TS[keep.id[i],3])
          i<-i+1
        } else{
          keep.id<-c(keep.id,TS[keep.id[i],2:3])
          i<-i+1
        }
      }
    }
    return(leaf.group)
  }

  PPtreeOBJ<-PPTreeregOBJ$Tree.result
  TS<-PPtreeOBJ$Tree.Struct
  Alpha<-PPtreeOBJ$projbest.node
  cut.off<-PPtreeOBJ$splitCutoff.node
  origdata<-PPtreeOBJ$origdata
  origclass<-PPtreeOBJ$origclass
  p<-ncol(origdata)
  gName<-names(table(origclass))
  if(!is.null(PPTreeregOBJ$origX.mean))
    origdata<-t(apply(origdata,1,function(x)
      (x-PPTreeregOBJ$origX.mean)/PPTreeregOBJ$origX.sd))
  if(node.id==0){
    Y<-PPTreeregOBJ$origY

    pred.data<- predict.PPTreereg(PPTreeregOBJ,Rule=Rule,final.rule=1)
    plot.data<-data.frame(pred.data,Y)
    MSE<- mean((pred.data-Y)^2)
    minY<-min(c(Y,pred.data))
    maxY<-max(c(Y,pred.data))
    p1<-ggplot2::ggplot(plot.data,ggplot2::aes(y=pred.data,x=Y))+
      ggplot2::geom_point()+ ggplot2::ylab("Fitted Y")+
      ggplot2::xlab("Observed Y")+
      ggplot2::xlim(minY,maxY)+
      ggplot2::ylim(minY,maxY)+
      ggplot2::coord_fixed()+
      ggplot2::geom_abline(intercept=0,slope=1,lwd=1,color="red")+
      ggplot2::ggtitle(paste("Final Rule 1-MSE =",round(MSE,2)))

    pred.data<- predict.PPTreereg(PPTreeregOBJ,Rule=Rule,final.rule=2)
    plot.data<-data.frame(pred.data,Y)
    MSE<- mean((pred.data-Y)^2)
    p2<-ggplot2::ggplot(plot.data,ggplot2::aes(y=pred.data,x=Y))+
      ggplot2::geom_point()+
      ggplot2::ylab("Fitted Y")+
      ggplot2::xlab("Observed Y")+
      ggplot2::xlim(minY,maxY)+
      ggplot2::ylim(minY,maxY)+
      ggplot2::coord_fixed()+
      ggplot2::geom_abline(intercept=0,slope=1,lwd=1,color="red")+
      ggplot2::ggtitle(paste("Final Rule 2-MSE =",round(MSE,2)))
    p3<-ggplot2::ggplot()+
      ggplot2::theme_bw()+
      ggplot2::theme(panel.border = ggplot2::element_rect(color="white"))

    pred.data<- predict.PPTreereg(PPTreeregOBJ,Rule=Rule,final.rule=3)
    plot.data<-data.frame(pred.data,Y)
    MSE<- mean((pred.data-Y)^2)
    p4<-ggplot2::ggplot(plot.data,ggplot2::aes(y=pred.data,x=Y))+
      ggplot2::geom_point()+ ggplot2::ylab("Fitted Y")+
      ggplot2::xlab("Observed Y")+
      ggplot2::xlim(minY,maxY)+
      ggplot2::ylim(minY,maxY)+
      ggplot2::coord_fixed()+
      ggplot2::geom_abline(intercept=0,slope=1,lwd=1,color="red")+
      ggplot2::ggtitle(paste("Final Rule 3-MSE =",round(MSE,2)))
    pred.data<- predict.PPTreereg(PPTreeregOBJ,Rule=Rule,final.rule=4)
    plot.data<-data.frame(pred.data,Y)
    MSE<- mean((pred.data-Y)^2)
    p5<-ggplot2::ggplot(plot.data,ggplot2::aes(y=pred.data,x=Y))+
      ggplot2::geom_point()+ ggplot2::ylab("Fitted Y")+
      ggplot2::xlab("Observed Y")+
      ggplot2::xlim(minY,maxY)+
      ggplot2::ylim(minY,maxY)+
      ggplot2::coord_fixed()+
      ggplot2::geom_abline(intercept=0,slope=1,lwd=1,color="red")+
      ggplot2::ggtitle(paste("Final Rule 4-MSE =",round(MSE,2)))

    pred.data<- predict.PPTreereg(PPTreeregOBJ,Rule=Rule,final.rule=5)
    plot.data<-data.frame(pred.data,Y)
    MSE<- mean((pred.data-Y)^2)
    p6<-ggplot2::ggplot(plot.data,ggplot2::aes(y=pred.data,x=Y))+
      ggplot2::geom_point()+ ggplot2::ylab("Fitted Y")+
      ggplot2::xlab("Observed Y")+
      ggplot2::xlim(minY,maxY)+
      ggplot2::ylim(minY,maxY)+
      ggplot2::coord_fixed()+
      ggplot2::geom_abline(intercept=0,slope=1,lwd=1,color="red")+
      ggplot2::ggtitle(paste("Final Rule 5-MSE =",round(MSE,2)))
    gridExtra::grid.arrange(p1,p2,p3,p4,p5,p6,ncol=3)
  } else if(TS[node.id,2]!=0){
    selG<-searchGroup(node.id,TS,gName)
    sel.id<-NULL
    for(i in 1:length(selG)){
      sel.id<-c(sel.id,which(origclass==selG[i]))
    }


    proj.data<-c(as.matrix(origdata)%*%
                   as.matrix(Alpha[TS[node.id,4],]))[sel.id]
    proj.class<-factor(round(PPTreeregOBJ$mean.G[origclass[sel.id]],3))
    Y<-PPTreeregOBJ$origY[sel.id]
    plot.data<-data.frame(proj.data,origclass=proj.class,Y)
    cut.index.X<-PPTreeregOBJ$Tree.result$splitCutoff.node[TS[node.id,4],Rule]
    min.X<-min(proj.data)
    max.X<-max(proj.data)
    cut.index.Y<-PPTreeregOBJ$cut.class[
      max(final.search(PPtreeOBJ,node.id,"left"))]
    colorGroup<-1 # dummy for removing "NOTE: no visible binding"
    plot.data<-data.frame(proj.data,origclass=proj.class,Y,
                          colorGroup=factor(ifelse(Y<=cut.index.Y,1,2)))
    p1<- ggplot2::ggplot(data = plot.data)+
      ggplot2::geom_point(ggplot2::aes(x = proj.data,y=Y,color=colorGroup,
                                       fill=colorGroup),show.legend = FALSE,alpha=0.5)+
      ggplot2::geom_point(ggplot2::aes(x = proj.data,y=Y,color=origclass),
                          show.legend = FALSE)+
      ggplot2::geom_vline(xintercept=cut.index.X,
                          linetype="longdash",lwd=0.7,color="red")+
      ggplot2::geom_hline(yintercept=cut.index.Y,
                          linetype="longdash",lwd=0.7,color="blue")
    p1.1<-ggExtra::ggMarginal(p1,type="density",groupColour=TRUE,groupFill = TRUE)
    vID <-1:p
    Vcoef<-Alpha[TS[node.id,4],]
    coef_data<-data.frame(vID = factor(vID),Vcoef=Vcoef)
    bin.width<-ifelse(p>100,1,0.1)
    y.max <-max(c(abs( coef_data$Vcoef),1/sqrt(p)))
    p2<-ggplot2::ggplot( coef_data,ggplot2::aes(x=vID,y=Vcoef))+
      ggplot2::geom_segment(ggplot2::aes(yend=0,xend=vID,size=3))+
      #ggplot2::geom_segment(ggplot2::aes(yend=0,xend=vID, width=0.1))+
      ggplot2::geom_hline(yintercept=0)+
      ggplot2::geom_hline(yintercept=c(-1,1)*1/sqrt(ncol(origdata)),
                          color="red",linetype="dashed")+
      ggplot2::xlab("variable ID")+
      ggplot2::ggtitle(paste("Node",node.id,sep=" "))+
      ggplot2::ylim(-y.max,y.max)+
      ggplot2::theme(legend.position = "none")
    gridExtra::grid.arrange(p2,p1.1,nrow=1)
  } else{
    sel.id<-which(predict.PPTreereg(PPTreeregOBJ,
                                    Rule=Rule,classinfo=TRUE,
                                    final.rule=1)$Yhat.class==
                    gName[TS[node.id,3]])

    Yorig<-PPTreeregOBJ$origY
    proj.data<-rep(1,length(Yorig))
    proj.data<-c(as.matrix(origdata)%*%
                   as.matrix(Alpha[TS[which((TS[,2]!=0&TS[,3]==node.id)|
                                              TS[,2]==node.id),4],]))
    plotT<-list()
    minY<-min(Yorig)
    maxY<-max(Yorig)

    predY<- predict.PPTreereg(PPTreeregOBJ,Rule=Rule,final.rule=1)
    cutclasses <- c(min(predY,PPTreeregOBJ$origY)-1,
                    PPTreeregOBJ$cut.class,
                    max(predY,PPTreeregOBJ$origY))

    contResult <- data.frame("predY" = c(as.integer(cut(predY,cutclasses,labels = c(1,2,3,4),right = TRUE))),
                             "Yorig" = cut(Yorig,cutclasses,labels = c(1,2,3,4),right = TRUE))
    count=prop=1

    p3<- contResult %>%
      dplyr::group_by(predY, Yorig) %>%
      dplyr::summarise(count = dplyr::n()) %>%
      dplyr::mutate(predY.count = sum(predY),
                    prop = count/sum(count)) %>%
      dplyr::ungroup() %>%
      ggplot2::ggplot(ggplot2::aes(x = predY, y = prop, fill = Yorig)) +
      ggplot2::geom_bar(stat="identity", position = "fill", colour = "black",width = 1)+
      ggplot2::scale_fill_brewer(palette = "Set3") +
      ggplot2::theme_bw()+
      ggplot2::theme(panel.grid.minor = ggplot2::element_blank(), panel.spacing= ggplot2::unit(0, "npc"))


    for(i in 1:5){
      predY<- predict.PPTreereg(PPTreeregOBJ,Rule=Rule,final.rule=i)
      pred.data<-predY[sel.id];Y=Yorig[sel.id]
      plot.data3<-data.frame(pred.data,Y)
      pred.data<-predY[-sel.id];Y=Yorig[-sel.id]
      plot.data4<-data.frame(pred.data,Y)
      n.class<-length(table(PPtreeOBJ$origclass))
      plotT[[i]]<- ggplot2::ggplot()+
        ggplot2::geom_point(data=plot.data4,
                            ggplot2::aes(y=pred.data,x=Y),
                            color="grey80",size=1.3)+
        ggplot2::geom_point(data=plot.data3,
                            ggplot2::aes(y=pred.data,x=Y),size=1.3)+
        ggplot2::geom_vline(xintercept=PPTreeregOBJ$cut.class,
                            col=4,linetype="dashed")+
        ggplot2::xlim(minY,maxY)+
        ggplot2::ylim(minY,maxY)+
        ggplot2::coord_fixed()+
        ggplot2::geom_abline(intercept=0,slope=1,lwd=1,color="red")+
        ggplot2::ylab("Fitted Y")+ggplot2::xlab("Observed Y")+
        ggplot2::ggtitle(paste("final.rule=",i,
                               sep=""))+
        ggplot2::theme(plot.title = ggplot2::element_text(size = 10),
                       axis.title = ggplot2::element_text(size = 10))
    }
    p3<-ggplot2::ggplot()+
      ggplot2::theme_bw()+
      ggplot2::theme(panel.border = ggplot2::element_rect(color="white"))

    gridExtra::grid.arrange(plotT[[1]],plotT[[2]],plotT[[3]],
                            plotT[[4]],plotT[[5]],p3,ncol=5,
                            top = grid::textGrob(paste("Node",node.id), gp = grid::gpar(fontsize = 15, fontface = "bold")))
  }
}
