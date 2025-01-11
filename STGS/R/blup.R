############################################

STGS.blup<-function(X, Y, r){
  n<-nrow(X)
  p<-ncol(X)
  m<-round(n*r)

  correl<-rep(0,25)

  for (k in 1:25){
    tst<-sample(1:n,size=m,replace=FALSE)

    XTRN<-X[-tst,] ; YTRN<-Y[-tst,]
    XTST<-X[tst,] ; YTST<-Y[tst,]

    requireNamespace("rrBLUP")

    fm<-mixed.solve(y=YTRN,Z=as.matrix(XTRN))
    mu<-rep(fm$beta,length(YTST))
    Pred1<-(as.matrix(XTST)%*%as.vector(fm$u))+mu
    Pred<-(as.matrix(X)%*%as.vector(fm$u))+mu

    correl[k]<-cor(Pred1,YTST)
  }
  Accuracy<-mean(correl, na.rm=TRUE)
  return(list("Vu"= fm$Vu, "Ve"=fm$Ve, "beta"=fm$beta,"u"= fm$u, "LL"= fm$LL,"Pred"= Pred, "Accuracy"= Accuracy))
}
