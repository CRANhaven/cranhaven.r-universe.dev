#' Simulate longitudinal data based on a shared latent process mixed effects model (SlaPMEG)
#'
#' This is a simple function to simulate longitudinal data from a shared latent process mixed effects model
#' the data provides a good example for application of \code{slapmeg} and \code{pairslapmeg}
#' and \code{pairslapmeg} objects.
#'
#'
#' @param nY number of omics in the data
#' @param ntime number of repeated measures
#' @param nsubj number of subjects
#' @param pDif proportion of differentially expressed omics in the data (the default is 1/3)
#' @param fixed A one-sided formula for the fixed-effects excluding the group variable, the default includes an
#' intercept and time
#' @param random A one-sided formula for the random-effects, the default includes an intercept and time
#' @param fixedbeta effect size of fixed terms in formula, the length should match the fixed formula,
#' the default is 0 (intercept) and 2 (time)
#' @param randbeta effect size of random terms in formula, the length should match the random formula,
#' the default is 0 (intercept) and 2 (time)
#' @param group Vector indicating group membership, the length should match the number of subjects,
#' The default is random allocation of half of subjects to each group.
#' If use with slapmeg is intended, the group variable should have only two groups
#' @param groupbeta effect size of group variable, the default is 2
#' @param sigma.u Variance of the subject-specific random effects, the length should math the random effects defined
#' in random formula. If not specified, 2 values from normal distribution will be randomly assigned.
#' @param sigma.b  variance of the omic- / subject- specific random effects, the length should math \code{nY}.
#' If not specified, \code{nY} values from normal distribution will be randomly assigned.
#' @param seed Value of seed, if not specified a random integer will be assigned
#' @param returnpar logical if TRUE, all simulation parameters will be returned along with the simulated data.
#'
#' @return Returns a dataframe where the rows represent the observations and the columns
#' represent the subject Id, time and group variable followed by the omics in pathway; if returnpar is TRUE,
#' a list with both data and parametrs is returned
#'
#' @author Mitra Ebrahimpoor
#'
#' @seealso  \code{\link{slapmeg}}, \code{\link{pairslapmeg}}
#'
#' @keywords simulate
#'
#' @importFrom mvtnorm rmvnorm
#' @importFrom stats update  rnorm runif
#'
#' @export
#'
#'
simslapmeg<-function(nY,
           ntime,
           nsubj,
           pDif=1/3,
           fixed=~1+time,
           random=~1+time, #random effect formual
           fixedbeta=c(0,2),
           randbeta=c(0,2), #should match the formula
           group,
           groupbeta=2,
           sigma.b ,
           sigma.u , #number of simulated datasets
           seed = as.integer(runif(1, 0, .Machine$integer.max)),
           returnpar=FALSE)  {

  ####check the inputs
    afixed <- terms(fixed, specials=c("factor","contrast"))
    nfixform<-length(attr(afixed,"term.labels"))
    if(attr(afixed,"intercept")!=0 ) nfixform<-nfixform+1
    if(length(fixedbeta)!=nfixform)
      stop("A fixedbeta value should be assigned to each parameter in the fixed argument!")

    arandom <- terms(random, specials=c("factor","contrast"))
    nrandform<-length(attr(arandom,"term.labels"))
    if(attr(arandom,"intercept")!=0 ) nrandform<-nrandform+1
    if(length(randbeta)!=nrandform)
      stop("A randbeta value should be assigned to each parameter in the random argument!")


  ####set parameters
    N<-nsubj*ntime  #total number of data points
    betasX<-c(fixedbeta, groupbeta)     # fixed effects for b0 and time and group
    betasZ<-randbeta  # fixed effects for b0 and time and group
    numeff<-trunc(nY*pDif) #number of outcomes correlated with group
    npar<-1+2+4*nY  #number of parameters estimated with lcmm model

    #variables in the model and data structure
    time <- 1:ntime

    if(missing(group))  group<-rep(0:1,nsubj/2)
    if(length(group)!=nsubj)
      stop("The length of  group should match the number of subjects!")
    #make sure group is a factor
    group<-as.factor(group)

    data.str<- data.frame(ID = rep(1:nsubj, each = ntime),
                          time= rep(time, nsubj), group=rep(group, each=ntime))

    #design matrices
    fixed<-update(fixed,    ~ . + group)#add the group variable
    X <- model.matrix(fixed, data = data.str)   #fixed effects design matrix
    Z <- model.matrix(random, data = data.str)    #random effect design matrix

    nfix<-ncol(X)

    #initial variables
    data.Y<-matrix(data=NA,ncol=nY,nrow=N)
      set.seed(seed)

  ####simulation of data
      if(missing(sigma.u)) sigma.u<-abs(rnorm(nrandform, 2, 0.5))
      if(length(sigma.u)!=nrandform)
        stop("The length of  sigma.u should match the parameter in the random argument!")

      #correlation of random effects
      rho=0

      corMat <- matrix(c(sigma.u[1], rho, rho, sigma.u[2]), ncol = 2)

      ui =rmvnorm(nsubj, mean =c(0,0), sigma =corMat)    #random effects

      #shared part of model
      etai1 = X%*%betasX  + rowSums(Z*ui[data.str$ID,])
      etai0 = X[,-nfix]%*%betasZ[-nfix] + rowSums(Z*ui[data.str$ID,])

      #outcome-specific part of model
      if(missing(sigma.b)) sigma.b<-abs(rnorm(nY, 2, 0.5))
      if(length(sigma.b)!=nY)
        stop("The length of  sigma.b should match the number of omics!")

      bis = rmvnorm(nsubj, mean=rep(0,nY), sigma=diag(sigma.b)) #random effect for all y

      #residual error
      sigma.e<-abs(rnorm(nY, 2, 0.5))
      e= rmvnorm(N, mean=rep(0,nY), sigma=diag(sigma.e))   #residual error for all y

      #Ys correlated with group
      data.Y[,1:numeff]<-etai1[,rep(1,numeff)] + bis[data.str$ID,][,1:numeff] + e[,1:numeff]

      #Ys not-correlated with group
      data.Y[,(numeff+1):nY]<-etai0[,rep(1,nY-numeff)] + bis[data.str$ID,][,(numeff+1):nY] + e[,(numeff+1):nY]

      colnames(data.Y)<-paste0("Y",1:nY)
      sim_data<-cbind(data.str , data.Y)

  ####items to return
      if(returnpar==TRUE){
      sim_par<-list(nY=nY,ntime=ntime, nsubj=nsubj, pDif=pDif, fixed=fixed, random=random,
                      fixedbeta=fixedbeta, randbeta=randbeta, groupbeta=groupbeta,
                      sigma.b=sigma.b, sigma.u=sigma.u, usedseed=seed)

      return(list(sim_data=sim_data,sim_par=sim_par))
      } else
          return(sim_data=sim_data)



   }
