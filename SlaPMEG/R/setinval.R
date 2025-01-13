#' @title Estimating initial values for slapmeg based on seperate lme models
#'
#' @description A seperate lme model is fited per omic in the pathway and the estimates are combined to create
#' initial values for the \code{\link{slapmeg}} function.
#'
#' @param fixed A two-sided linear formula object for specifying the
#' fixed-effects in the linear mixed model at the latent process level. Names
#' of omics in the pathway are separated by \code{+} on the left of \code{~} and the
#' covariates are separated by \code{+} on the right of the \code{~}. For
#' identifiability purposes, the intercept should always be present in the model.
#'
#' @param random A one-sided formula for the random-effects in the
#' latent process mixed model and starts with the \code{~} sign. At least one random
#' effect should be included. Covariates with a random-effect are separated
#' by \code{+}.
#'
#' @param subject name of the covariate representing the repeated measures structure such as subject IDs.
#'
#' @param data data frame containing the variables named in \code{fixed}, \code{random},
#' \code{grouping} and \code{subject}.
#'
#' @return A vector of initial values to be used as input for multlcmm function
#'
#' @author Mitra Ebrahimpoor
#'
#' \email{m.ebrahimpoor@@lumc.nl}
#'
#' @importFrom lme4 lmer

setinval<-function(fixed, random, subject, data){

  #identify elements
  fixed<-as.formula(fixed)
  Ynames <-  all.vars(fixed[[2]])
  nout <- length(Ynames)
  bfixed <- terms(fixed, specials=c("factor"))
  if(attr(bfixed,"intercept")==0 ) stop("An intercept should be included in fixed for identifiability!")

  brandom <- terms(random, specials=c("factor"))
  if(length(all.vars(random))>1) stop("The package does not allow multiple variables as random slops!")

  #create formula for lmme4
  formrand<-paste0("(", deparse(random[[2]]) , "|",subject , ")")
  lmm.formula<-paste0(deparse(fixed[[3]]),"+",formrand)


  #run the lme4 and save convergance status
  lmer.allformulas<-paste0(Ynames,"~",lmm.formula)
  lmer_model<-lapply(lmer.allformulas, function(x)
    lme4::lmer(x,REML=TRUE, data=data,
               control = lme4::lmerControl(check.conv.grad = "ignore",
                                           check.conv.singular="ignore",
                                           check.conv.hess ="ignore")))
  convmodel<-lapply(lmer_model,function(x) lme4::isSingular(x))

    ##extract initial values from individual models
  # fixed effects
  nfix<-length(attr(bfixed,"term.labels"))
  if(attr(bfixed,"intercept")!=0 ) nfix<-nfix+1
  varfix<-lapply(lmer_model, function(x) summary(x)$coefficients[-1,1])
  varfix<-matrix(unlist(varfix), nrow = nout, byrow = TRUE)

  #get the number of random effects in the model
  nrand<- length(attr(brandom,"term.labels"))
  if(attr(brandom,"intercept")!=0 ) nrand<-nrand+1

  #more than one random term in the model
  if(nrand>1){
    covmat<-matrix(unlist(lapply(lmer_model,
                                 function(x) as.data.frame(lme4::VarCorr(x))[,5])),
                   byrow = TRUE, nrow=nout)
    #remove unsuccessful lmm fits
    varfix[sapply(convmodel, function(x) x==TRUE)]<-NA
    covmat[sapply(convmodel, function(x) x==TRUE),]<-NA

    if(nfix==1){
      inB<-c(colMeans(cbind(covmat[,(nrand+2):ncol(covmat)-1],NA),na.rm=T)[-(nrand)], #corr. random terms
             colMeans(cbind(covmat[,2:nrand]^2,NA),na.rm=T)[-(nrand)], #variance of the random terms
             covmat[,ncol(covmat)], #std error of the outcomes
             covmat[,1], #variance of the random intercepts as the std of randomY
             rep(0:1,nout)) #trans. parameters fixed at 0 and 1
    }else

      inB<-c(colMeans(varfix,na.rm=T), #fixed effects
             colMeans(cbind(covmat[,(nrand+2):ncol(covmat)-1],NA),na.rm=T)[-(nrand)], #corr. random terms
             colMeans(cbind(covmat[,2:nrand]^2,NA),na.rm=T)[-(nrand)], #variance of the random terms
             covmat[,ncol(covmat)], #std error of the outcomes
             covmat[,1], #variance of the random intercepts as the std of randomY
             rep(0:1,nout)) #trans. parameters fixed at 0 and 1
  }else{

    # variance of random effects
    covmat<-matrix(unlist(lapply(lmer_model,
                                 function(x) as.data.frame(lme4::VarCorr(x))[,5])),
                   byrow = TRUE, nrow=nout)

    #remove unsuccessful lmm fits
    varfix[sapply(convmodel, function(x) x==TRUE)]<-NA
    covmat[sapply(convmodel, function(x) x==TRUE),]<-NA

    if(nfix==1){
      inB<-c(covmat[,2], #std error of the outcomes
             covmat[,1], #std of the random intercepts as the std of randomY
             rep(0:1,nout)) #trans. parameters fixed at 0 and 1
    }else
      inB<-c(colMeans(varfix,na.rm=T), #fixed effects
             covmat[,2], #std error of the outcomes
             covmat[,1], #std of the random intercepts as the std of randomY
             rep(0:1,nout)) #trans. parameters fixed at 0 and 1

}

  #in case no lmms run successfully
  inB[is.na(inB)]<-1

  return(inB)
}
