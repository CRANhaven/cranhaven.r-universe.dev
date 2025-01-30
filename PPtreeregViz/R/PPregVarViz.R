#' Visualize independent variable action in projection pursuit regression tree.
#'
#' This function is developed to see the influence of independent variables on the range of dependent variable.
#' @usage PPregVarViz(PPTreeregOBJ,var.id,indiv=FALSE,
#'                    DEPTH=NULL,smoothMethod="auto", var.factor=FALSE)
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param var.id independent variable name
#' @param indiv TRUE: individual group plot, FALSE: combined one plot
#' @param DEPTH depth for exploration
#' @param smoothMethod method in geom_smooth function
#' @param var.factor TRUE when indepedent variable is a categorical variable (as factor)
#' @export
#' @return An object of the class \code{ggplot}
#' @import PPtreeViz
#' @keywords tree
#' @examples
#' data(dataXY)
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' PPregVarViz(Model,"X1")
#' PPregVarViz(Model,"X1",indiv = TRUE)
#'
PPregVarViz<-function(PPTreeregOBJ,var.id,indiv=FALSE,
                      DEPTH=NULL,smoothMethod="auto", var.factor = FALSE){

  X<-Y<-1 # dummy for removing "NOTE: no visible binding"
  plot.data<-data.frame(Y=PPTreeregOBJ$origY,
                        X=PPTreeregOBJ$Tree.result$origdata[,var.id],
                        finalclass=PPTreeregOBJ$Tree.result$origclass)
  TS<-PPTreeregOBJ$Tree.result$Tree.Struct
  minY<-min(plot.data$Y)
  maxY<-max(plot.data$Y)
  if(var.factor){
    if(is.null(DEPTH)){
      vlineY<-PPTreeregOBJ$cut.class
      if(indiv){
        plot.data %>%
          dplyr::mutate(origclass = paste0("final leaf class : ",finalclass)) %>%
          ggplot2::ggplot(ggplot2::aes(x=X,y=Y,group=finalclass))+
          ggplot2::geom_point(ggplot2::aes(color=finalclass),
                              position = ggplot2::position_jitterdodge(seed = 1),
                              show.legend = FALSE)+
          ggplot2::facet_wrap(~origclass,scale="free")+
          ggplot2::xlab(var.id)+ggplot2::theme_bw()
      } else {
        ggplot2::ggplot(plot.data,ggplot2::aes(x=X,y=Y,group=finalclass))+
          ggplot2::geom_point(ggplot2::aes(color=finalclass),
                              position = ggplot2::position_jitterdodge(dodge.width = 0,seed = 1 ),
                              show.legend = FALSE)+
          ggplot2::geom_hline(yintercept=vlineY,
                              color="grey70",linetype=2)+
          ggplot2::ylim(minY,maxY)+ggplot2::theme_bw()+
          ggplot2::xlab(var.id)
      }
    } else{
      depth.keep<-0
      sel.id<-1
      flag<-TRUE
      while(depth.keep<DEPTH){
        sel.id.keep<-NULL
        for(i in sel.id)
          sel.id.keep<-c(sel.id.keep,TS[i,2:3])
        depth.keep<-depth.keep+1
        sel.id<-sel.id.keep
      }
      sel.id<-sel.id.keep
      final.id.keep<-NULL
      for(i in sel.id){
        track.i<-i
        flag<-TRUE
        while(flag){
          if(TS[track.i,2]==0){
            final.id.keep<-c(final.id.keep,TS[track.i,3])
            flag<-FALSE
          } else{
            track.i<-TS[track.i,2]
          }
        }
      }
      classlabel<-finalclass<-
        1:(length(PPTreeregOBJ$cut.class)+1)
      classlabel[-final.id.keep]<-NA
      vlineY<-PPTreeregOBJ$cut.class[classlabel-1]
      vlineY<-vlineY[!is.na(vlineY)]
      classlabel[!is.na(classlabel)]<-sel.id
      value<-1 # dummy for removing "NOTE: no visible binding"
      newclasslabel<-unlist((tidyr::fill(tibble::as_tibble(classlabel),value)))
      class.data<-data.frame(finalclass=factor(finalclass),
                             newclasslabel=factor(newclasslabel))
      plot.data<- dplyr::left_join(plot.data,class.data,by="finalclass")
      if(indiv){
        ggplot2::ggplot(plot.data,ggplot2::aes(x=X,y=Y,group=newclasslabel))+
          ggplot2::geom_point(ggplot2::aes(color=newclasslabel),
                              show.legend = FALSE)+
          ggplot2::geom_smooth(method=smoothMethod,
                               ggplot2::aes(group="1"),color="black")+
          ggplot2::facet_wrap(~newclasslabel,scale="free")+
          ggplot2::xlab(var.id)+ggplot2::theme_bw()
      } else {
        ggplot2::ggplot(plot.data,ggplot2::aes(x=X,y=Y,group=newclasslabel))+
          ggplot2::geom_point(ggplot2::aes(color=newclasslabel),
                              show.legend = FALSE)+
          ggplot2::geom_smooth(method=smoothMethod,
                               ggplot2::aes(group="1"),color="black")+
          ggplot2::geom_hline(yintercept=vlineY,
                              color="grey70",linetype=2)+
          ggplot2::ylim(minY,maxY)+ggplot2::theme_bw()+
          ggplot2::xlab(var.id)
      }   }
  }else{
    if(is.null(DEPTH)){
      vlineY<-PPTreeregOBJ$cut.class
      if(indiv){
        plot.data %>%
          dplyr::mutate(origclass = paste0("final leaf class : ",finalclass)) %>%
          ggplot2::ggplot(ggplot2::aes(x=X,y=Y,group=finalclass))+
          ggplot2::geom_point(ggplot2::aes(color=finalclass),
                              show.legend = FALSE)+
          ggplot2::geom_smooth(method=smoothMethod,
                               ggplot2::aes(group="1"),color="black")+
          ggplot2::facet_wrap(~origclass,scale="free")+
          ggplot2::xlab(var.id)+ggplot2::theme_bw()
      } else {
        ggplot2::ggplot(plot.data,ggplot2::aes(x=X,y=Y,group=finalclass))+
          ggplot2::geom_point(ggplot2::aes(color=finalclass),
                              show.legend = FALSE)+
          ggplot2::geom_smooth(method=smoothMethod,
                               ggplot2::aes(group="1"),color="grey30")+
          ggplot2::geom_hline(yintercept=vlineY,
                              color="grey70",linetype=2)+
          ggplot2::ylim(minY,maxY)+ggplot2::theme_bw()+
          ggplot2::xlab(var.id)
      }
    } else{
      depth.keep<-0
      sel.id<-1
      flag<-TRUE
      while(depth.keep<DEPTH){
        sel.id.keep<-NULL
        for(i in sel.id)
          sel.id.keep<-c(sel.id.keep,TS[i,2:3])
        depth.keep<-depth.keep+1
        sel.id<-sel.id.keep
      }
      sel.id<-sel.id.keep
      final.id.keep<-NULL
      for(i in sel.id){
        track.i<-i
        flag<-TRUE
        while(flag){
          if(TS[track.i,2]==0){
            final.id.keep<-c(final.id.keep,TS[track.i,3])
            flag<-FALSE
          } else{
            track.i<-TS[track.i,2]
          }
        }
      }
      classlabel<-finalclass<-
        1:(length(PPTreeregOBJ$cut.class)+1)
      classlabel[-final.id.keep]<-NA
      vlineY<-PPTreeregOBJ$cut.class[classlabel-1]
      vlineY<-vlineY[!is.na(vlineY)]
      classlabel[!is.na(classlabel)]<-sel.id
      value<-1 # dummy for removing "NOTE: no visible binding"
      newclasslabel<-unlist((tidyr::fill(tibble::as_tibble(classlabel),value)))
      class.data<-data.frame(finalclass=factor(finalclass),
                             newclasslabel=factor(newclasslabel))
      plot.data<- dplyr::left_join(plot.data,class.data,by="finalclass")
      if(indiv){
        ggplot2::ggplot(plot.data,ggplot2::aes(x=X,y=Y,group=newclasslabel))+
          ggplot2::geom_point(ggplot2::aes(color=newclasslabel),
                              show.legend = FALSE)+
          ggplot2::geom_smooth(method=smoothMethod,
                               ggplot2::aes(group="1"),color="black")+
          ggplot2::facet_wrap(~newclasslabel,scale="free")+
          ggplot2::xlab(var.id)+ggplot2::theme_bw()
      } else {
        ggplot2::ggplot(plot.data,ggplot2::aes(x=X,y=Y,group=newclasslabel))+
          ggplot2::geom_point(ggplot2::aes(color=newclasslabel),
                              show.legend = FALSE)+
          ggplot2::geom_smooth(method=smoothMethod,
                               ggplot2::aes(group="1"),color="black")+
          ggplot2::geom_hline(yintercept=vlineY,
                              color="grey70",linetype=2)+
          ggplot2::ylim(minY,maxY)+ggplot2::theme_bw()+
          ggplot2::xlab(var.id)
      }
    }
  }
}
