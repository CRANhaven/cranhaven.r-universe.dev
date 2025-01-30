#' Calculate variable importance
#'
#' Calculate the importance of variables in the \code{PPTreereg} model.
#' For local importance, weighted sum of projection coefficients with the number of data corresponding to
#' each node as the weighted value in each node is used.
#' The global importance is absolute sum of local importance.
#'
#' @usage PPimportance(PPTreeregOBJ,...)
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param ... arguments to be passed to methods
#' @return An object of the class \code{PPimpobj}
#' @export
#' @examples
#' data(dataXY)
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' PPimportance(Model)
#'
PPimportance<-function(PPTreeregOBJ,...){
  PPtreeOBJ<-PPTreeregOBJ$Tree.result
  n.class<-length(table(PPtreeOBJ$origclass))
  N<-length(PPTreeregOBJ$origY)
  TS<-PPtreeOBJ$Tree.Struct
  proj.best<-PPtreeOBJ$projbest.node
  node.final<-NULL
  for(i in 1:n.class){
    node.id.o<-node.id<-which(TS[,2]==0 & TS[,3]==i)
    node.id.keep<-NULL
    var.keep<-rep(0,ncol(PPtreeOBJ$projbest.node))
    while(length(node.id)!=0){
      node.id<-which(TS[,2]==node.id.o|TS[,2]!=0 & TS[,3]==node.id.o)
      if(length(node.id)!=0){
         if(TS[node.id,2]==node.id.o){
           var.keep<-var.keep - proj.best[TS[node.id,4],]*TS[node.id,8]/N
         } else{
           var.keep<-var.keep + proj.best[TS[node.id,4],]*TS[node.id,8]/N
         }
         node.id.keep<-c(node.id.keep,node.id)
      }
      node.id.o<-node.id
    }
    var.keep<-var.keep/length(node.id.keep)
    node.final<-cbind(node.final,var.keep)
  }
  p<-ncol(proj.best)
  node.final<-round(node.final*p,3)
  colnames(node.final)<-paste("FinalNode",1:n.class)
  node.split<-data.frame(node.id=TS[which(TS[,4]!=0),
                                    1][sort.list(TS[TS[,4]!=0,4])],
                         node.n=TS[which(TS[,4]!=0),
                                   8][sort.list(TS[TS[,4]!=0,4])],
                         round(proj.best*p,3))
  node.varImp<-apply(proj.best,2,
              function(x) sum(abs(x)*node.split$node.n)/sum(node.split$node.n)*100)
  node.varImp<-round(node.varImp*p,3)


  PPimpobj<-list(imp_node_split=node.split,
                        imp_node_final=node.final,
                        imp_var=node.varImp)
  class(PPimpobj)<-"PPimportance"
  return(PPimpobj)

}
