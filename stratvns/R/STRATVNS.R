#'STRATVNS
#'@title Vns Algorithm
#'@description This function aims at constructing optimal
#'strata with an optimization algorithm based on a global
#'optimisation technique called Variable neighborhood search (VNS).
#'The optimization algorithm is applied to solve the one
#'dimensional case, which reduces the stratification problem
#'to just determining strata boundaries. Assuming that the
#'number L of strata and the coefficient of variation are fixed,
#'it is possible to produce the strata boundaries by taking
#'into consideration an objective function associated with
#'the sample size. This function determines strata boundaries
#'so that the elements in each stratum are more homogeneous
#'among themselves and produce minimum sample size applying
#'an integer formulation proposed by Brito et al (2015).
#'@references 1. Hansen, P., Mladenovi´c, N., 2001. Variable neighborhood search:
#'Principles and applications. European Journal of Operational
#'Research 130, 3, 449 – 467.
#'@references 2. Brito, J.A.M., Silva, P.L.N., Semaan, G.S., Maculan, N.,
#'2015. Integer programming formulations applied to optimal allocation
#'in stratified sampling. Survey Methodology 41, 2, 427–442.
#'@author Leonardo de Lima, Jose Brito, Pedro Gonzalez and Breno Oliveira
#'@param X            Stratification Variable
#'@param L            Number of strata
#'@param cvt          Target cv
#'@param nhmin        Mininum sample size by stratum
#'@param maxstart     Number  of iterations in multstart
#'@param imax         Maximum Number  Iterations - VNS
#'@param kmax         Maximum Neighborhoods  = number of cut points selected to apply shaking and local search
#'@param s            Range of shaking procedure
#'@param sl           Range of RVNS procedure
#'@param tmax         Maximum number cut points in neighborhoods
#'@param nsols        Number of initial solutions generated
#'@param cputime      Maximum cpu time in seconds
#'@param nIterWithNoImpMax   Maximum number of iterations without improvement in VNS
#'@param parallelize  TRUE = Performs multiple vns calls in parallel
#'@return \item{bk}{Cut points}
#'@return \item{n}{Minimum sample size}
#'@return \item{nh}{Sample size by strata}
#'@return \item{cv}{coefficient of variation}
#'@return \item{Nh}{Strata sizes}
#'@return \item{Vh}{Strata variances}
#'@return \item{cputime}{Runtime in seconds}
#'@export
#'@import stats
#'@import utils
#'@import MultAlloc
#'@import purrr
#'@import parallel
#'@examples
#' \dontrun{
#'Example1:
#'s<-STRATVNS(U1,L=4,cvt=0.05,nhmin=3)
#'Example2:
#'s<-STRATVNS(U15,L=3)
#'#'Example3:
#'s<-STRATVNS(U21,L=5)
#'Example4:
#'s<-STRATVNS(U1,L=3,nhmin=4)
#'}


STRATVNS<-function(X,L=3,cvt=0.1,nhmin=2,maxstart=3,
                   imax=3,kmax=3,s=30,sl=50,tmax=15,nsols=20,
                   cputime=3600,
                   nIterWithNoImpMax=5,parallelize=TRUE)
{
    ####################################################################
  ######calculates population size by stratum using cutoff points
  ##av = TRUE ==> variance considering Nh in the denominator
  ####################################################################
  CalcVarNh<-function(b,X,L,av)
  {
    b<-c(-Inf,b,Inf)
    Nh<-rep(0,L)
    Vh<-rep(0,L)
    for(h in 1:L)
    {Xh<-X[which(X>b[h] & X<=b[h+1])]
    Nh[h]<-length(Xh)
    if (av==FALSE) {Vh[h]<-var(Xh)} else {Vh[h]<-var(Xh)*(Nh[h]-1)/Nh[h]}
    }
    return(c(Vh,Nh))
  }

  #####################################################################
  ##############Neyman Allocation######################################
  Neyman<-function(Vh,Nh,cvt,tx)
  {
    N=sum(Nh)
    Wl=Nh/N
    WlS2l=Wl*Vh
    WlSl=Wl*sqrt(Vh)
    soma_WlS2l=sum(WlS2l)
    soma_WlSl=sum(WlSl)
    #CÁLCULO DO TAMANHO AMOSTRAL (n)
    n=(N^2*soma_WlSl^2)/((cvt^2*tx^2)+N*soma_WlS2l)
    nh=round(n*WlSl/soma_WlSl,0)
    for(i in 1:length(Nh)) {if (nh[i]<nhmin) {nh[i]<-nhmin}}
    n<-sum(nh)
    cv<-sqrt(sum(Nh^2/nh*Vh*(1-nh/Nh)))/tx
    return(list(n=n,nh=nh,cvs=cv))
  }


  ###############################################################
  ####Build initial solution ####################################
  Build_Solution<-function(X,Q,L,nsols,tx,cvt,nhmin)
  {
    sm<-t(apply(replicate(nsols,sample(Q,L-1)),2,sort))
    SN<-t(apply(sm,1,function(b) CalcVarNh(b,X,L,TRUE)))
    feasible<-which(apply(SN,1,function(x) min(x[(L+1):(2*L)]))>=2)
    SN<-SN[feasible,]
    sm<-sm[feasible,]
    sv<-t(apply(SN,1,function(y) BSSM_FC(y[(L+1):(2*L)],y[1:L],tx,cvt,nhmin)))
    ni<-which.min(unlist(lapply(sv,function(x) x$n)))
    ##Vector with cut points, n, nh and cv
    return(c(sm[ni,],sv[[ni]]$n,sv[[ni]]$nh,sv[[ni]]$cvs))
  }

  ###############################################################
  ####Shake solution ############################################
  shaking<-function(Q,b,L,k,s,tx)
  {
    q<-match(b[1:(L-1)],Q)
    ####Construir as faixas matriz k x L-1
    l<-length(Q)
    rangesk<-rep(list(NULL),L-1)
    for(i in 1:length(q)) {rangesk[[i]]<-setdiff(max(1,(q[i]-s)):min(q[i]+s,l),q[i])}
    ng<-min(k,L-2)
    ne<-sample((L-1),ng)
    bl<-b[1:(L-1)]
    b<-bl
    feasible_solution<-FALSE
    while (feasible_solution==FALSE)
    {
      for(i in 1:length(ne)) {b[ne[i]]<-Q[sample(rangesk[[ne[i]]],1)]}
      VhNh<-CalcVarNh(b,X,L,TRUE)
      feasible_solution<-ifelse(min(VhNh[(L+1):(2*L)])<2,FALSE,TRUE)
      if (feasible_solution==FALSE) {b<-bl}
    }
    sv<-BSSM_FC(VhNh[(L+1):(2*L)],VhNh[1:L],tx,cvt,nhmin)
    ##Vector with cut points, n, nh and cv
    return(c(b,sv$n,sv$nh,sv$cvs))
  }


  ###############################################################
  ####Local Search1#### First Improvement#######################
  RVNDS<-function(Q,b,L,k,sl,maxp,tx)
  {
    q<-match(b[1:(L-1)],Q)
    ng<-min(k,L-2)
    ne<-sample((L-1),ng)
    bis<-rep(list(NULL),L-1)
    l<-length(Q)
    rangesk<-rep(list(NULL),L-1)
    for(i in 1:length(q)) {rangesk[[i]]<-max(1,(q[i]-sl)):min(q[i]+sl,l)}
    maxps<-sapply(rangesk,length)
    maxps<-ifelse(maxps<maxp,maxps,maxp)
    for(j in 1:(L-1)) {bis[[j]]<-b[j]}
    for(j in 1:length(ne)) {bis[[ne[j]]]<-sample(Q[rangesk[[ne[j]]]],maxps[ne[j]])}
    cart_b<-matrix(unlist(cross(bis)),ncol=L-1,byrow=TRUE)
    vl<-which(apply(cart_b,1,function(x) any(duplicated(x)==TRUE))==TRUE)
    if (length(vl)>0) {cart_b<-cart_b[vl,]}
    if (is.matrix(cart_b)==FALSE) {cart_b<-t(as.matrix(cart_b))}
    VhNh<-t(apply(cart_b,1,function(b) CalcVarNh(b,X,L,TRUE)))
    if (is.matrix(VhNh)==FALSE) {VhNh<-t(as.matrix(VhNh))}
    NM<-apply(VhNh,1,function(x) min(x[(L+1):(2*L)]))
    qfeasible<-which(NM>=2)
    if (length(qfeasible)>0)
    {
      VhNh<-VhNh[qfeasible,]
      cart_b<-cart_b[qfeasible,]
      if (is.matrix(VhNh)==FALSE) {VhNh<-t(as.matrix(VhNh))}
      if (is.matrix(cart_b)==FALSE) {cart_b<-t(as.matrix(cart_b))}
      sv<-t(apply(VhNh,1,function(y) Neyman(y[1:L],y[(L+1):(2*L)],cvt,tx)))
      nl<-nrow(VhNh)
      ni<-order(unlist(lapply(sv,function(x) x$n)))[1:min(10,nl)]
      VhNh<-VhNh[ni,]
      cart_b<-cart_b[ni,]
      if (is.matrix(VhNh)==FALSE) {VhNh<-t(as.matrix(VhNh))}
      if (is.matrix(cart_b)==FALSE) {cart_b<-t(as.matrix(cart_b))}
      ####Optimal allocation applied in best solution from Neyman
      sv<-apply(VhNh,1,function(y) BSSM_FC(y[(L+1):(2*L)],y[1:L],tx,cvt,nhmin))
      ix<-which.min(sapply(sv,function(x) unlist(x$n)))
      b<-cart_b[ix,]
      sv<-sv[[ix]]
      n<-sv$n
      nh<-sv$nh
      cv<-sv$cvs
      VhNh<-VhNh[ix,(L+1):(2*L)]
    } else {b=b[1:(L-1)]
    VhNh=CalcVarNh(b,X,L,TRUE)
    sv=BSSM_FC(VhNh[(L+1):(2*L)],VhNh[1:L],tx,cvt,nhmin)
    n<-sv$n
    nh<-sv$nh
    cv<-sv$cvs
    }
    return(c(b,n,nh,cv,VhNh))

  }


  #Applies an intensive search for the best solution produced by vns
  ###Fazer ajustes finais neste procedimento
  Intensive_Local_Search<-function(b,Q,X,L,si,tx)
  {
    q<-match(b[1:(L-1)],Q)
    l<-length(Q)
    rangesk<-rep(list(NULL),L-1)
    bi<-rep(list(NULL),L-1)
    for(i in 1:length(q)) {rangesk[[i]]<-max(1,(q[i]-si)):min(q[i]+si,l)}
    for(j in 1:(L-1)) {bi[[j]]<-Q[rangesk[[j]]]}
    cart_b<-matrix(unlist(cross(bi)),ncol=L-1,byrow=TRUE)
    VhNh<-t(apply(cart_b,1,function(b) CalcVarNh(b,X,L,TRUE)))
    NM<-apply(VhNh,1,function(x) min(x[(L+1):(2*L)]))
    qfeasible<-which(NM>=2)
    VhNh<-VhNh[qfeasible,]
    cart_b<-cart_b[qfeasible,]
    if (is.matrix(VhNh)==FALSE) {VhNh<-t(as.matrix(VhNh))}

    sv<-t(apply(VhNh,1,function(y) Neyman(y[1:L],y[(L+1):(2*L)],cvt,tx)))

    ni<-order(unlist(lapply(sv,function(x) x$n)))[1:round(length(sv)*0.2)]
    sv<-apply(as.matrix(ni),1,function(ni) BSSM_FC(VhNh[ni,(L+1):(2*L)],VhNh[ni,1:L],tx,cvt,nhmin))
    nu<-which.min(unlist(lapply(sv,function(x) x$n)))
    return(c(cart_b[ni[nu],],
             sv[[nu]]$n,sv[[nu]]$nh,sv[[nu]]$cvs,
             VhNh[ni[nu],(L+1):(2*L)]))

  }



  ###############################################################
  ####VNDS#######################################################
  VNDS<-function(b,Q,X,L,km,s,sl,tmax,tx)
  {
    iter_vns_no_reduction<-0
    nrvnds<-Inf
    while (iter_vns_no_reduction<nIterWithNoImpMax)
    {k<-1 #Number of neighborhood
    reduction<-FALSE
    iter_vns_no_reduction<-iter_vns_no_reduction+1
    while ((k<=km)  & (nrvnds>(L*nhmin)))
    { b1<-shaking(Q,b,L,k,s,tx)
    b2<-RVNDS(Q,b1,L,k,sl,tmax,tx)
    if (b2[L]<b[L])
    {b=b2
    k=1
    nrvnds<-b[L]
    reduction<-TRUE
    iter_vns_no_reduction<-0
    cat("Redution VNDS ",b[L],"\n")
    }
    else {k<-k+1}
    }
    if (reduction==FALSE)
    {VhNh<-CalcVarNh(b[1:(L-1)],X,L,TRUE)
    b<-c(b[1:(2*L+1)],VhNh[(L+1):(2*L)])
    }
    }
    return(b)
  }


  #################Main Procedure#########################################
  VNS_ALG<-function(L)
  {
    temp<-proc.time()
    b<-Build_Solution(X,Q,L,nsols,tx,cvt,nhmin)
    iter_VNS<-0
    nbest<-Inf

    ####Loop VNS
    while ((iter_VNS<imax) & ((proc.time()-temp)[3]<cputime) & (nbest>nhmin*L))
    {iter_VNS<-iter_VNS+1
    b1linha<-VNDS(b,Q,X,L,kmax,s,sl,tmax,tx)
    if(b1linha[L]<nbest)
    {nbest<-b1linha[L]
    bbest<-b1linha
    b<-b1linha
    tnotbest<-0
    cat("VNS Iteration ",iter_VNS," Minimum Sample Size = ",nbest,"\n")
    } else {cat("VNS Iteration ",iter_VNS,"\n")}

    }
    ###### Path Relinking
    if (nbest>nhmin*L)
    {nbli<-Intensive_Local_Search(bbest,Q,X,L,3,tx)
    if (nbli[L]<bbest[L])
    {bbest<-nbli;
    print("Intensive Local Search")
    }
    }
    temp<-(proc.time()-temp)[3]
    return(list(bk=bbest[1:(L-1)],n=bbest[L],
                nh=bbest[(L+1):(2*L)],cv=bbest[2*L+1],
                Nh=bbest[(2*L+2):(3*L+1)],
                time_exec=temp))
  }


  #################################################################
  ################################################################
  ####### Main Program############################################
  ###############################################################

  Q<-sort(unique(X)) #Defines set of cut points by removing duplicates of X
  tx<-sum(X)
  temp.global<-proc.time()
  if (maxstart>1)
  {Lp<-rep(L,maxstart)
  ###############Create Cluster ################################
  if (parallelize==TRUE)
  { cores<-parallel::detectCores()
    cat("Detected Cores ",cores,"\n\n")
    clust<-parallel::makeCluster(cores)
    parallel::clusterEvalQ(clust, library(MultAlloc))
    parallel::clusterEvalQ(clust, library(purrr))
    parallel::clusterExport(clust,varlist=c('VNS_ALG'), envir=environment())
    rvns<-parallel::clusterApplyLB(cl=clust,Lp,function(Lx) VNS_ALG(Lx))
    stopCluster(clust)
  } else {rvns<-apply(as.matrix(Lp),1,function(Lx) VNS_ALG(Lx))}
  npars<-which.min(sapply(rvns,function(x) x$n))
  rvns<-rvns[[npars]]

  }
  else {rvns<-VNS_ALG(L)}
  temp.global<-(proc.time()-temp.global)[3]
  rvns$temp.global<-temp.global
  cat("Optimal sample size = ",rvns$n,'\n')
  cat("Run time in seconds ",temp.global,"\n")
  Vh<-CalcVarNh(rvns$bk,X,L,TRUE)[1:L]
  return(list(bk=rvns$bk,n=rvns$n,nh=rvns$nh,cv=rvns$cv,
              Nh=rvns$Nh,Vh=Vh,cputime=temp.global))

}
