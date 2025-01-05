#' Model-Free Feature Screening Based on the Projection Correlation
#'
#' A model-free screening method is based on the projection correlation
#' which measures the dependence between two random vectors.
#' This projection correlation based method does not require specifying a
#' regression model, and applies to data in the presence of heavy tails
#' and multivariate responses. It enjoys both sure screening and
#' rank consistency properties under weak assumptions.
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by PCSIS. The default is n/log(n).
#' @return the labels of first nsis largest active set of all predictors
#'
#' @import reticulate
#' @importFrom reticulate py_config
#' @importFrom reticulate source_python
#' @import foreach
#' @import parallel
#' @import doParallel
#'
#' @export
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @examples
#'
#' # have_numpy=reticulate::py_module_available("numpy")
#' # if (have_numpy){
#' # req_py()
#' n=100;
#' p=200;
#' rho=0.5;
#' data=GendataLM(n,p,rho,error="gaussian")
#' data=cbind(data[[1]],data[[2]])
#' colnames(data)[1:ncol(data)]=c(paste0("X",1:(ncol(data)-1)),"Y")
#' data=as.matrix(data)
#' X=data[,1:(ncol(data)-1)];
#' Y=data[,ncol(data)];
#' # A=PCSIS(X,Y,n/log(n));A
#' # }else{
#' #    print('You should have the Python testing environment!')
#' #}
#'
#' @references
#'
#' Zhu, L., K. Xu, R. Li, and W. Zhong (2017). Projection correlation between two random vectors. Biometrika 104(4), 829–843.
#'
#' Liu, W., Y. Ke, J. Liu, and R. Li (2020). Model-free feature screening and FDR control with knockoff features. Journal of the American Statistical Association, 1–16.
PCSIS=function(X,Y,nsis=(dim(X)[1])/log(dim(X)[1])){
  if (dim(X)[1]!=length(Y)) {
    stop("X and Y should have same number of rows!")
  }
  if (missing(X)|missing(Y)) {
    stop("The data is missing!")
  }
  if (TRUE%in%(is.na(X)|is.na(Y)|is.na(nsis))) {
    stop("The input vector or matrix cannot have NA!")
  }
  if (inherits(Y,"Surv")) {
    stop("PCSIS can not implemented with object  of Surv")
  }
  req_py()
  reticulate::py_config()
  py_path=system.file("python", "PCSIS.py", package="MFSIS")
  reticulate::source_python(py_path,envir=globalenv())
  n=dim(X)[1];
  p=dim(X)[2];
  A_y=get_arccos(Y)
  if (n*p<=100000){
    result=vector(mode="numeric",length=p)
    for (j in 1:p){
      result[j]=Cor(X[,j],A_y,n)
    }
  }else{
    # Real physical cores in the computer
    cores=detectCores(logical=FALSE)
    cl=makeCluster(cores)
    registerDoParallel(cl,cores=cores)
    j=NULL;
    result=foreach::foreach(j=1:p, .combine='c',
    .export=c("get_arccos","projection_corr"),
    .packages=c("reticulate")) %dopar%
      Cor(X[,j],A_y,n)
    stopImplicitCluster()
    stopCluster(cl)
  }
  A=order(result,decreasing=TRUE)
  return (A[1:nsis])
}


#' Arccos function
#'
#' This is a function to get a arccos value based on projection correlation from the Python language.
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#'
#' @import reticulate
#' @importFrom reticulate py_config
#' @importFrom reticulate source_python
#' @export
#' @return the arccos value
#'
#'
get_arccos=function(X){
  get_arccos_1d=NULL;
  py_path=system.file("python", "PCSIS.py", package="MFSIS")
  reticulate::source_python(py_path,envir=globalenv())
  A_x=get_arccos_1d(X);
  return (A_x)
}


#' Projection correlation function
#'
#' Projection correlation between X[,j] and Y from the Python language
#'
#' @param A_x  The arccos value about X
#' @param A_y  The arccos value about Y
#' @param n    The sample size
#' @import reticulate
#' @importFrom reticulate py_config
#' @importFrom reticulate source_python
#' @export
#' @return the projection correlation
#'
#'
projection_corr=function(A_x,A_y,n){
  projection_corr_1d=NULL;
  py_path=system.file("python", "PCSIS.py", package="MFSIS")
  reticulate::source_python(py_path,envir=globalenv())
  corr=projection_corr_1d(A_x,A_y,n);
  return(corr)
}


#' Parallel function
#' This is a parallel function about the projection correlation.
#'
#' @param Xj Each column from design matrix of dimensions n * p
#' @param A_y The arccos value about Y
#' @param n The sample size
#'
#' @return the projection correlation between Xj and A_y
#' @export
#'
Cor=function(Xj,A_y,n){
  A_x=get_arccos(Xj)
  corr=projection_corr(A_x,A_y,n);
  return (corr)
}






