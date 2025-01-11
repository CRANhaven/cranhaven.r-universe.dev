###########################################

STGS.ann<-function(X, Y, r){
  n<-nrow(X)
  p<-ncol(X)
  m<-round(n*r)
  X<-as.matrix(X)
  requireNamespace("brnn")
  for(i in 1:ncol(X)){ (X[,i]<-X[,i]-mean(X[,i]))/sd(X[,i])}
  G<-tcrossprod(X)/ncol(X)

  correl<-rep(0,10)
  for (k in 1:10){
    tst<-sample(1:n,size=m,replace=FALSE)

    GTRN<-G[-tst,] ; yTRN<-Y[-tst,]
    GTST<-G[tst,] ; yTST<-Y[tst,]


    NN<-brnn(y=yTRN,x=GTRN,neurons=4, epochs=30,verbose=TRUE)
    Pred<- predict(NN, newdata=G)
    Pred1<- predict(NN, newdata=GTST)
    correl[k]<-cor(Pred1,yTST)
  }
  Accuracy<-mean(correl, na.rm=TRUE)
  return(list("fit"=NN, "Pred"=Pred,"Accuracy"=Accuracy))
}
