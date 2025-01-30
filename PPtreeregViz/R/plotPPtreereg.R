#' projection pursuit regression tree plot
#'
#' Draw projection pursuit regression tree with tree structure. It is modified from a function in \code{party} library.
#' @title PPTreereg plot
#' @param x PPTreereg class object
#' @param font.size font size of plot
#' @param width.size size of eclipse in each node.
#' @param ... arguments to be passed to methods
#' @export
#' @aliases plot
#' @keywords tree
#' @return plot object
#' @examples
#' data(dataXY)
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' plot(Model)
#'
plot.PPTreereg<-function(x,font.size=17,width.size=1,...){

   PPregtreeOBJ<-x
   PPtreeobj<-PPregtreeOBJ$Tree.result
   class(PPtreeobj)<-append(class(PPtreeobj),"PPtree")
   plotPPregtree<-function(PPtreeobj,node.id,xlim,ylim){
      TS<-PPtreeobj$Tree.Struct
      if(TS[node.id,2]==0) {
         x<-xlim[1]+0.5
         y<-ylim[2]-1
         Final.Node.V<-grid::viewport(x=grid::unit(x,"native"),
                                y=grid::unit(y,"native"),
                                width=grid::unit(1,"native"),
                                height=grid::unit(1,"native")-
                                   grid::unit(2,"lines"),
                                just=c("center","top"))
         grid::pushViewport(Final.Node.V)
         node.terminal.PPtree(PPtreeobj,node.id)
         grid::upViewport()
         return(NULL)
      }
      nl<-n.final(PPtreeobj,node.id,"left")
      nr<-n.final(PPtreeobj,node.id,"right")
      x0<-xlim[1]+nl
      y0<-max(ylim)-1
      lf<-ifelse(TS[TS[node.id,2],2]==0,0.5,
                   n.final(PPtreeobj,TS[node.id,2],"right"))
      rf<-ifelse(TS[TS[node.id,3],2]==0,0.5,
                   n.final(PPtreeobj,TS[node.id,3],"left"))
      x1l<-x0-lf
      x1r<-x0+rf
      y1<-y0-1
      grid::grid.lines(x=grid::unit(c(x0,x1l),"native"),
                       y=grid::unit(c(y0,y1),"native"))
      grid::grid.lines(x=grid::unit(c(x0,x1r),"native"),
                       y=grid::unit(c(y0,y1),"native"))
      node.V<-grid::viewport(x=grid::unit(x0,"native"),
                             y=grid::unit(y0,"native"),
                             width=grid::unit(1,"native"),
                             height=grid::unit(1,"native")-grid::unit(1,"lines"))
      grid::pushViewport(node.V)
      node.inner.PPtree(PPtreeobj,node.id)
      grid::upViewport()
      ylpos<-y0-0.6
      yrpos<-y0-0.45
      xlpos<-x0-(x0-x1l)*0.6
      xrpos<-x0-(x0-x1r)*0.45
      LeftEdge.V<-grid::viewport(x=grid::unit(xlpos,"native"),
                                 y=grid::unit(ylpos,"native"),
                                 width=grid::unit(xlpos-xrpos,"native"),
                                 height=grid::unit(1,"lines")*1.2)
      grid::pushViewport(LeftEdge.V)
      edge.lable.PPtree(PPtreeobj,node.id,left=TRUE)
      grid::upViewport()
      RightEdge.V<-grid::viewport(x=grid::unit(xrpos,"native"),
                                  y=grid::unit(yrpos,"native"),
                                  width=grid::unit(xlpos-xrpos,"native"),
                                  height=grid::unit(1,"lines"))
      grid::pushViewport(RightEdge.V)
      edge.lable.PPtree(PPtreeobj,node.id,left=FALSE)
      grid::upViewport()
      plotPPregtree(PPtreeobj,TS[node.id,2],c(xlim[1],x0),c(1,y1+1))
      plotPPregtree(PPtreeobj,TS[node.id,3],c(x0,xlim[2]),c(1,y1+1))
   }

   n.final<-function(PPtreeobj,node.id,direction){
      TS<-PPtreeobj$Tree.Struct
      n.leaf<-0
      if(direction=="left"){
         keep.id<-TS[node.id,2]
         i<-1
         while(i<=length(keep.id)){
            if(TS[keep.id[i],2]==0){
               n.leaf<-n.leaf+1
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
               n.leaf<-n.leaf+1
               i<-i+1
            } else{
               keep.id<-c(keep.id,TS[keep.id[i],2:3])
               i<-i+1
            }
         }
      }
      return(n.leaf)
   }

   edge.lable.PPtree<- function(PPtreeobj,node.id,left=TRUE){
      TS<-PPtreeobj$Tree.Struct
      if(left){
         text.t<-paste("< cut",TS[node.id,4],sep="")
         grid::grid.rect(gp=grid::gpar(fill="white",lty=1,col="grey95"),
                         width=grid::unit(width.size,"strwidth",text.t)*1.2)
         grid::grid.text(text.t,just="center",gp=grid::gpar(fontsize=font.size))
      } else{
         text.t<-paste(">= cut",TS[node.id,4],sep="")
         grid::grid.rect(gp=grid::gpar(fill="white",lty=1,col="grey95"),
                         width=grid::unit(width.size,"strwidth",text.t)*1.2)
         grid::grid.text(text.t,just="center",gp=grid::gpar(fontsize=font.size))
      }
   }

   node.inner.PPtree <- function(PPtreeobj,node.id){
      TS<-PPtreeobj$Tree.Struct
      #PPtreeobj
      class(PPtreeobj)<-append(class(PPtreeobj),"PPtree")
      #PPrettreeOBJ
      PS<-print(PPregtreeOBJ,verbose=FALSE)
      label1<-rep(NA,length(PS))
      label2<-rep(NA,length(PS))
      ID<-rep(NA,length(PS))
      final.group<-rep(NA,length(PS))
      temp<-strsplit(PS,"->")
      for(i in 1:length(temp)){
         t<-strsplit(temp[[i]][1],")")
         ID[i]<-as.numeric(t[[1]][1])
         tt<-strsplit(t[[1]][2]," ")[[1]]
         tt<-tt[tt!="" & tt!="*"]
         label1[i]<-tt[1]
         if(tt[1]!="root")
            label2[i]<-paste(tt[2],tt[3])
         if(length(temp[[i]])==2)
            final.group[i]<-temp[[i]][2]
      }
      label.t<-paste("proj",TS[node.id,4]," * X",sep="")
      Inner.Node.V<-grid::viewport(x=grid::unit(0.5,"npc"),
                                   y=grid::unit(0.5,"npc"),
                                   width=grid::unit(width.size*1.5,
                                                    "strwidth",label.t),
                                   height=grid::unit(width.size*2,"lines"))
      grid::pushViewport(Inner.Node.V)
      xell<-c(seq(0,0.2,by=0.01),
              seq(0.2,0.8,by=0.05),
              seq(0.8,1,by=0.01))
      yell<-sqrt(xell*(1-xell))
      grid::grid.polygon(x=grid::unit(c(xell,rev(xell)),"npc"),
                         y=grid::unit(c(yell,-yell)+0.5,"npc"),
                         gp=grid::gpar(fill="white"))
      grid::grid.text(label.t,y=0.3,gp=grid::gpar(fontsize=font.size),
                      just=c("center","bottom"))
      Inner.Node.Id.V<-grid::viewport(x=grid::unit(0.5,"npc"),
                                      y=grid::unit(1,"npc"),
                                      width=max(grid::unit(1,"lines"),
                                                grid::unit(1.2,"strwidth",
                                                           as.character(node.id))),
                                      height=max(grid::unit(1,"lines"),
                                                 grid::unit(1.2,"strheight",
                                                            as.character(node.id))),
                                      just=c("center","center"),
                                      gp=grid::gpar(fontsize=font.size))
      grid::pushViewport(Inner.Node.Id.V)
      grid::grid.rect(gp=grid::gpar(fill="white",lty="solid",
                                    fontsize=font.size))
      grid::grid.text(node.id,gp=grid::gpar(fontsize=font.size))
      grid::popViewport()
      grid::upViewport()
   }

   node.terminal.PPtree<- function(PPtreeobj,node.id){
      TS<-PPtreeobj$Tree.Struct
      gName1<-as.character(round(PPregtreeOBJ$mean.G,3))
      gName2<-as.character(round(PPregtreeOBJ$sd.G,3))
      gN<-paste(gName1[TS[node.id,3]],"\n(",gName2[TS[node.id,3]],")",sep="")
      temp<-strsplit(as.character(gN),split="")[[1]]
      gN.width<-length(temp)
      set.unit<-length(sum(tolower(temp)!=temp)*0.65+
                          sum(tolower(temp)==temp)*0.5)/gN.width
      Terminal.Node.V<-grid::viewport(x=grid::unit(0.5,"npc"),
                                      y=grid::unit(0.8,"npc"),
                                      height=grid::unit(1,"lines")*3,
                                      width=grid::unit(0.3,"lines")*(gN.width),
                                      just=c("center","top"))
      grid::pushViewport(Terminal.Node.V )
      grid::grid.rect(gp=grid::gpar(fill="lightgray"))
      grid::grid.text(y=0.05,gN,gp=grid::gpar(fontsize=font.size),
                      just=c("center","bottom"))
      Terminal.Node.Id.V<-grid::viewport(x=grid::unit(0.5,"npc"),
                                         y=grid::unit(1,"npc"),
                                         width=max(grid::unit(1,"lines"),
                                                   grid::unit(1.2,"strwidth",
                                                              as.character(node.id))),
                                         height=max(grid::unit(1,"lines"),
                                                    grid::unit(1.2,"strheight",
                                                               as.character(node.id))),
                                         just=c("center","center"),
                                         gp=grid::gpar(fontsize=font.size))
      grid::pushViewport(Terminal.Node.Id.V)
      grid::grid.rect(gp=grid::gpar(fill="lightgray",lty="solid",
                                    fontsize=font.size))
      grid::grid.text(node.id,gp=grid::gpar(fontsize=font.size))
      grid::popViewport()
      grid::upViewport()
   }

   calc.depth<-function(PPtreeobj){
      TS<-PPtreeobj$Tree.Struct
      i<-1;
      flag.L<-rep(FALSE,nrow(TS))
      keep.track<-1
      depth.track<-0
      depth<-0
      while(sum(flag.L)!=nrow(TS)){
         if(!flag.L[i]) {
            if(TS[i,2] == 0) {
               flag.L[i]<-TRUE
               id.l<-length(keep.track)-1
               i<-keep.track[id.l]
               depth<-depth -1
            } else if(!flag.L[TS[i,2]]) {
               depth<-depth +1
               i<-TS[TS[i,2],1]
            } else {
               depth<-depth +1
               flag.L[i]<-TRUE
               i<-TS[TS[i,3],1]
            }
            keep.track<-c(keep.track,i)
            depth.track<-c(depth.track,depth)
         } else {
            id.l<-id.l-1
            i<-keep.track[id.l]
            depth<-depth.track[id.l]
         }
      }
      depth<-max(depth.track)+2
      return(depth)
   }

   nx<-length(PPregtreeOBJ$mean.G)
   ny<-calc.depth(PPtreeobj)
   tnex<-1
   node.id<-1
   grid::grid.newpage()
   PPtree.Main.V<-grid::viewport(layout=grid::grid.layout(3,3,
                                                          heights=grid::unit(c(3,1,1),
                                                                             c("lines","null","lines")),
                                                          widths=grid::unit(c(1,1,1),
                                                                            c("lines","null","lines"))))
   grid::pushViewport(PPtree.Main.V)
   PPtree.title.V<-grid::viewport(layout.pos.col=2,layout.pos.row=1)
   grid::pushViewport(PPtree.title.V)
   grid::grid.text(y=grid::unit(1,"lines"),
                   "Projection Pursuit Regression Tree",just="center")
   grid::upViewport()
   PPtree.Tree.V<-grid::viewport(layout.pos.col=2,layout.pos.row=2,
                                 xscale=c(0,nx),yscale=c(0,ny+1))
   grid::pushViewport(PPtree.Tree.V)
   plotPPregtree(PPtreeobj,1,c(0,nx),ylim=c(1,ny+1))
}
