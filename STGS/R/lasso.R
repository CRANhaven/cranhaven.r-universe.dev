###########################

STGS.lasso<-function(X, Y, r){
  n<-nrow(X)
  p<-ncol(X)
  m<-round(n*r)

  correl<-rep(0,25)
  for (k in 1:25){

    tst<-sample(1:n,size=m,replace=FALSE)
    XTRN<-X[-tst,] ; YTRN<-Y[-tst,]
    XTST<-X[tst,] ; YTST<-Y[tst,]

    requireNamespace("glmnet")
    fm<-glmnet(y=YTRN,x=as.matrix(XTRN),alpha=1)
    cv<-cv.glmnet(y=YTRN,x=as.matrix(XTRN))
    Pred1<-predict(fm,as.matrix(XTST),s=cv$lambda.min)
    Pred<-predict(fm,as.matrix(X),s=cv$lambda.min)

    correl[k]<-cor(Pred1,YTST)
  }
  Accuracy<-mean(correl, na.rm=TRUE)
  return(list("fit"=fm,"Pred"=Pred,"Accuracy"=Accuracy))
}
