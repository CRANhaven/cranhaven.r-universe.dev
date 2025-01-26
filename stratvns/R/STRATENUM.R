#'STRATENUM
#'@title Enumeration Algorithm
#'@description This function enumerates all feasible solutions to
#'the stratification problem and produces the global optimum,
#' applying an integer formulation proposed by Brito et al (2015).
#'@references 1. Brito, J.A.M., Silva, P.L.N., Semaan, G.S., Maculan, N.,
#'2015. Integer programming formulations applied to optimal allocation
#'in stratified sampling. Survey Methodology 41, 2, 427–442.
#'@author Leonardo de Lima, Jose Brito, Pedro Gonzalez and Breno Oliveira
#'
#'@param X        Stratification Variable
#'@param L        Number of strata
#'@param cvt      Target cv
#'@param nhmin       Mininum sample size by stratum
#'@return \item{n}{Sample size}
#'@return \item{nh}{Sample size by strata}
#'@return \item{cv}{coefficient of variation}
#'@return \item{Nh}{Strata sizes}
#'@return \item{Vh}{Strata variances}
#'@return \item{totoptg}{Total global optimal solutions}
#'@return \item{tfeasible}{Total feasible solutions}
#'@return \item{cputime}{Runtime in seconds}
#'@export
#'@import stats
#'@import utils
#'@import MultAlloc
#'@import partitions
#'@import purrr
#'@import parallel
#'@examples
#' \dontrun{
#'Example1:
#'s<-STRATENUM(U21,L=3,cvt=0.05)
#'Example2:
#'s<-STRATENUM(U15,L=4)
#'Example3:
#'s<-STRATENUM(U1,L=3,nhmin=4)
#'}
STRATENUM<-function(X,L,cvt=0.1,nhmin=2)
{
  CalcVarNh2<-function(XiNi,X,P,L)
  {Nh<-rep(0,L)
  Sh2<-rep(0,L)
  li<-1
  av=TRUE
  for(h in 1:L)
  {Ni<-sum(XiNi[1:P[h],2])
  Nh[h]<-Ni
  XiNi<-XiNi[-c(1:P[h]),]
  Xh<-X[1:Ni]
  if (av==FALSE) {Sh2[h]<-var(Xh)} else {Sh2[h]<-var(Xh)*(Nh[h]-1)/Nh[h]}
  X<-X[-c(1:Ni)]
  }
  return(c(Nh,Sh2))
  }




  ########################Preprocessing#########################
  X<-sort(X)
  tx<-sum(X)
  x<-unique(X)
  n<-length(x)
  totals<-as.numeric(table(X))
  XiNi<-cbind(x,totals)
  colnames(XiNi)<-c("Xi","Ni")
  tcol<-choose(n+L-1,n)
  if (tcol>10^7)
  {cat("There are ",tcol, "solutions ")
   (return(0))
  }


  ##############################################################

  cores<-parallel::detectCores()
  cat("Detected Cores ",cores,"\n\n")
  clust<-parallel::makeCluster(cores)
  parallel::clusterEvalQ(clust, library(MultAlloc))

  cputime<-proc.time()


  #Builds all partitions ##################################
  M<-partitions::compositions(n,L,F)
  cat("Total Partitions   = ",ncol(M),"\n")
  cat("Size of Matrix  M  = ",format(utils::object.size(M),units="MB")," ",
      format(utils::object.size(M),units="GB"),"\n\n")
  ############Removes all infeasible partitions
  ql=which(apply(M,2,min)>=nhmin)
  M=M[,ql]
  cat("Total of the Feasible Partitions = ",ncol(M),"\n")
  tsv=ncol(M)
  ###Calculating Variances ande Strata sizes#################
  cat("Calculating Variances and strata sizes \n")
  NHVH<-t(parallel::parApply(cl=clust,M,2,function(P) CalcVarNh2(XiNi,X,P,L)))
  cat("Size of Matrix  NHVH ",format(utils::object.size(NHVH),units="MB")," ",
      format(utils::object.size(NHVH),units="GB"),"\n\n")
  cat("Data Generated. Applying allocation \n\n")
  rm(M)


  ###Builds all allocations applying integer programming formulation
  Sglobal<-parallel::parApply(cl=clust,NHVH,1,function(x) MultAlloc::BSSM_FC(x[1:L],x[(L+1):(2*L)],tx,cvt,nhmin))

  ns<-sapply(Sglobal,function(x) x$n)

  nglobals<-which.min(ns)
  nk=Sglobal[[nglobals]]$n
  eqn<-which(ns==nk)
  NHVH<-NHVH[eqn,]

  Sglobal<-Sglobal[eqn]

  cvg<-which.min(sapply(Sglobal,function(x) x$cv))

  cat("Total global optimum ",length(eqn),"\n")
  nh=Sglobal[[cvg]]$nh
  cv=Sglobal[[cvg]]$cvs
  cputime<-(proc.time()-cputime)[3]
  parallel::stopCluster(clust)

  cat("Optimal sample size = ",sum(nh),'\n')
  cat("Run time in seconds ",cputime,"\n")


  return(list(n=sum(nh),nh=nh,cv=cv,
              Nh=NHVH[cvg,1:L],Vh=NHVH[cvg,(L+1):(2*L)],
              totoptg=length(eqn),tfeasible=tsv,
              cputime=cputime))

}

