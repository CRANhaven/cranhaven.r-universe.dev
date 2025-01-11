####################################

STGS.rr<-function(X, Y, r){
  n<-nrow(X)
  p<-ncol(X)
  m<-round(n*r)

  correl<-rep(0,25)
  for (k in 1:25){
    tst<-sample(1:n,size=m,replace=FALSE)

    XTRN<-X[-tst,] ; YTRN<-Y[-tst,]
    XTST<-X[tst,] ; YTST<-Y[tst,]

    X1<-as.matrix(cbind(1,XTRN))
    Y1<-YTRN
    C<-crossprod(X1)
    rhs<-crossprod(X1,Y1)
    MSx<-0 ; for(i in 1:ncol(X1)){ MSx<-MSx+var(X1[,i])}
    h2<-0.4
    lambda<-MSx*(1-h2)/h2
    for(i in 2:ncol(C)){ C[i,i]<-C[i,i]+lambda }
    CInv<-chol2inv(chol(C))
    bHatRR<-crossprod(CInv,rhs)
    Pred<-as.matrix(cbind(1,X))%*%bHatRR
    Pred1<-as.matrix(cbind(1,XTST))%*%bHatRR
    correl[k]<-cor(Pred1,YTST)
  }
  Accuracy<-mean(correl, na.rm=TRUE)
  return(list("bhat"=bHatRR, "Pred"=Pred,"Accuracy"=Accuracy))
}
