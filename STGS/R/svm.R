###########################################

STGS.svm<-function(X, Y, r){
  n<-nrow(X)
  p<-ncol(X)
  m<-round(n*r)

  correl<-rep(0,25)
  for (k in 1:25){
    tst<-sample(1:n,size=m,replace=FALSE)

    XTRN<-X[-tst,] ; YTRN<-Y[-tst,]
    XTST<-X[tst,] ; YTST<-Y[tst,]

    #library(kernlab)
    requireNamespace("kernlab")

    fm<-ksvm(y=YTRN,x=as.matrix(XTRN),type="eps-svr",kernel="rbfdot")
    Pred1<-predict(fm,XTST,type="response")
    Pred<-predict(fm,X,type="response")
    correl[k]<-cor(Pred1,YTST)
  }
  Accuracy<-mean(correl, na.rm=TRUE)
  return(list("fit"=fm,"Pred"=Pred,"Accuracy"=Accuracy))
}
