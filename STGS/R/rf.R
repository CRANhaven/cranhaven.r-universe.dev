#############################

STGS.rf<-function(X, Y, r){
  n<-nrow(X)
  p<-ncol(X)
  m<-round(n*r)
  correl<-rep(0,25)

  for (k in 1:25){
    tst<-sample(1:n,size=m,replace=FALSE)

    XTRN<-X[-tst,] ; YTRN<-Y[-tst,]
    XTST<-X[tst,] ; YTST<-Y[tst,]

    #library(randomForest)
    requireNamespace("randomForest")
    Pred<-randomForest(x=XTRN, y=YTRN, xtest=X, ytst=Y, mtry=p/3)
    Pred1<-randomForest(x=XTRN, y=YTRN, xtest=XTST, ytst=YTST, mtry=p/3)
    Pred<-Pred$test
    Pred<-c(do.call("cbind",Pred))

    Pred1<-Pred1$test
    Pred1<-c(do.call("cbind",Pred1))
    correl[k]<-cor(Pred1,YTST)
  }
  Accuracy<-mean(correl, na.rm=TRUE)
  return(list("Pred"=Pred,"Accuracy"=Accuracy))
}
