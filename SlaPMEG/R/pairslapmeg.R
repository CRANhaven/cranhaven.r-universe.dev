#' @title Testing pathways using SLaPMEG (shared latent process mixed effects model and Globaltest) for
#' longitudinal Omics data based on pairwise estimation approach (a computational solution for
#' latrge pathways)
#'
#' @description This function performs pathway testing for longitudinal omics within a two-step framework
#' just as in \code{\link{slapmeg}} but instead of using a joint shared latent model in the
#' first step, it uses a pairwise approach and runs much faste for larger pathways.
#' After estimating the random effects of the joint model using pairwise fitting, the random
#' effects are used within globaltest to compare the two groups at a pathway level.
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
#' @param grouping name of the covariate representing grouping by the phenotype
#'
#' @param subject name of the covariate representing the repeated measures structure such as subject IDs.
#'
#' @param data data frame containing the variables named in \code{fixed}, \code{random},
#' \code{grouping} and \code{subject}.
#'
#'
#' @return A list is returned including: \item{call}{the matched call} \item{nfix}{Number
#' of fixed effect terms in the model, excluding the mandatory intercept} \item{nrand}{Number of
#' random effect terms in the model} \item{nsubj}{Number of subjects in the sataset} \item{nrep}{
#' Table of repeated measures, and number of subjects with the specified number of repeated measures}
#' \item{tgroup}{Table of grouping, and number of subjects in each group} \item{Ynames}{Name of the
#' Omics in the pathway} \item{slapconv}{Status of convergence: For joint method(=1 if the convergence
#' criteria were satisfied, =2 if the maximum number of iterations was reached, =4 or 5 if a problem
#' occured during optimisation); for the pairwise method, proportion of successfully converged pairs
#' is reported} \item{fixedform}{Names of Fixed effect terms} \item{randform}{Names of random effect
#' terms} \item{slapmethod}{The method which is "joint" if the original slapmeg approach is adopted
#' and pairwise for the pairwise method} \item{SLaP.par}{Fitted values for
#' the parameters in the joint class mixed model in the first step} \item{Globaltest}{The output
#' from Globaltest at the second step} \item{EB_pred}{Empirical
#' bayes estimates for the random effects from the joint model}
#'
#' @author Mitra Ebrahimpoor
#'
#' \email{m.ebrahimpoor@@lumc.nl}
#'
#' @seealso
#'
#' \code{\link{slapmeg}}, \code{\link{multslapmeg}}, \code{\link{plotslapmeg}}
#'
#' @references
#' Ebrahimpoor, Mitra, Pietro Spitali, Jelle J. Goeman, and Roula Tsonaka. "Pathway testing for longitudinal metabolomics." Statistics in Medicine (2021).
#'
#' @examples
#'
#'
#' # simulate data with 15 omics
#' testdata<-simslapmeg(nY=25, ntime=3, nsubj = 30, seed=123)
#' head(testdata)
#'
#' #fit slapmeg to test for the differential expression of a pathway of size 15
#' slapmegfit<- pairslapmeg(Y1+Y2+Y6+Y7+Y8~time, ~1, grouping="group", subject="ID", data=testdata)
#' slapmegfit
#' summary(slapmegfit)
#'
#' @importFrom lcmm multlcmm estimates
#' @importFrom stats formula as.formula terms model.matrix
#' @importFrom magic adiag
#' @importFrom utils combn
#' @importFrom reshape2 melt
#' @importFrom globaltest gt
#'
#' @export
#'

pairslapmeg<-function(fixed, random, grouping, subject, data){

  #save the call to function
  cl<-match.call()

  ##preliminary checks for formula and elements
  if(missing(fixed)) stop('The argument Fixed must be specified for all models!')
  if(!inherits(fixed, "formula")) stop("The argument Fixed must be a formula!")
  if(length(fixed[[2]])<2) stop('Pathway must include more than one feature!')

  if(random==~-1) stop("At least a random intercept is required!")
  if(missing(random)) stop("At least a random intercept is required!")

  if(missing(grouping)){ stop("The argument Grouping must be specified!")}
  gropVar <- as.character(grouping)
  if(!(gropVar %in% colnames(data))) { stop("Data should contain the Grouping variable!")}

  if(missing(subject)){ stop("The argument Subject must be specified!")}
  idNames <-as.character(subject)
  if(!(idNames %in% colnames(data))) { stop("Data should contain the Subject variable!")}

  ##check that the variables in formula match the data
  afixed <- terms(fixed, specials=c("factor","contrast"))
  fixedform<-paste(attr(afixed,"term.labels"),collapse = ",")
  if(attr(afixed,"intercept")!=0 ) fixedform<-paste("intercept", fixedform)
  nfix<- length(attr(afixed,"term.labels"))

  arandom <- terms(random, specials=c("factor"))
  randform<-paste(attr(arandom,"term.labels"),collapse = ",")
  nrand<-length(attr(arandom,"term.labels"))
  if(attr(arandom,"intercept")!=0 ) {randform<-paste("intercept", randform)
                                      nrand<-nrand+1}

  variables <- c(attr(afixed,"variables"),attr(arandom,"variables"))
  variables <- unlist(lapply(variables,all.vars))
  if(!all(variables %in% colnames(data)))
    stop(paste("Data should contain the variables",paste(unique(variables),collapse=" ")))
  if(missing(data)){ stop("The argument data should be specified and defined as a data.frame")}

  ###list of outcomes
  Ynames <- all.vars(fixed[[2]])
  nout <- length(Ynames) #number of omics in path

  ###list of all variables
  varNames <- c(all.vars(fixed[-2]), all.vars(random))
  varNames <- unique(varNames)
  varNames <- setdiff(varNames, Ynames)

  ###pair indexes for track
  nset<-2
  indx<-combn(1:nout, nset, simplify = FALSE)

  #get info on subject and grouping
  data_inf<-unique(data[,c(subject,grouping)])

  #initial values for all pairs calculated
  pairinB<-pairsetinval(indx, fixed, random, subject, data)
  parset<-length(pairinB[[1]])

  pairformula<-lapply(indx, function(ind) paste0(paste0(Ynames[ind],collapse = "+"),"~",
                                                 paste0(attr(afixed,"term.labels"),collapse = "+")))
  if(nfix==0 & attr(afixed,"intercept")!=0) pairformula<-lapply(pairformula, function(form) paste0(form,"1"))


  pairlcmm<-mapply(function(form,int) multlcmm(formula(form), random=random, subject=idNames,
                                               B=int, posfix=(parset-3):parset,
                                               randomY=TRUE, link=rep("linear",2),
                                               data=data,verbose = FALSE),pairformula,pairinB,SIMPLIFY = FALSE)

  ###get the estimates from paired fits
  allconv<-sapply(pairlcmm, function(x) x$conv)

  pairest<-lapply(pairlcmm, function(x) estimates(x, cholesky = FALSE))

  if(nfix>0){
    est.fix<-sapply(pairest, function(x) x[1:nfix])
    m.fix<-rowMeans(matrix(est.fix,nrow=nfix))
  }else
    m.fix<-NA

  if(nrand==1){
    varcov_u<-1
    sd_e<-sapply(pairest, function(x) x[(nfix+1):(nfix+nset)])
    sd_b<-sapply(pairest, function(x) x[(nfix+nset+1):(nfix+2*nset)])
  }

  if(nrand==2){
    varcov<-sapply(pairest, function(x) x[(nfix+1):(nfix+nrand)])
    varcov_m<-rowMeans(varcov)
    varcov_u<-matrix(0, nrow = nrand, ncol = nrand)
    varcov_u[lower.tri(varcov_u, diag = TRUE)]<-c(1,varcov_m)
    varcov_u[upper.tri(varcov_u, diag = TRUE)]<-c(1,varcov_m)

    sd_e<-sapply(pairest, function(x) x[(nfix+nrand+1):(nfix+nrand+nset)])
    sd_b<-sapply(pairest, function(x) x[(nfix+nrand+nset+1):(nfix+nrand+2*nset)])
  }

  if(nrand==3){
    varcov<-sapply(pairest, function(x) x[(nfix+1):(nfix+5)])
    varcov_m<-rowMeans(varcov)
    varcov_u<-matrix(0, nrow = nrand, ncol = nrand)
    varcov_u[lower.tri(varcov_u, diag = TRUE)]<-c(1,varcov_m)
    varcov_u[upper.tri(varcov_u, diag = TRUE)]<-c(1,varcov_m)

    sd_e<-sapply(pairest, function(x) x[(nfix+5+1):(nfix+5+nset)])
    sd_b<-sapply(pairest, function(x) x[(nfix+5+nset+1):(nfix+5+2*nset)])
  }

  alle<-data.frame(indx=unlist(indx),as.vector(sd_e))
  m_sd_e<-sapply(1:nout,function(num) mean(alle[alle$indx==num,2]))

  allb<-data.frame(indx=unlist(indx),as.vector(sd_b))
  m_sd_b<-sapply(1:nout,function(num) mean(allb[allb$indx==num,2]))


  data_m<-melt(data[,c(subject,varNames,Ynames)], id.vars = c(subject,varNames))
  data_m <- data_m[order(data_m[,subject]),]

  ids<-data_inf[,subject]

  numid<-length(ids)

  ###calculate the bi's and ui's per subject
  EBest<-c()
  for(sbj in 1:numid){
    k<- which(data_m[,subject]==ids[sbj])
    data_mS<-data_m[k,]

    #number of repetitions
    Xi<-model.matrix(fixed[-2], data_mS)
    Zi<-model.matrix(random, data_mS)

    ntime=dim(Xi)[1]
    rtime=table(data_mS[,"variable"])

    #zdz calculations
    zdzmat<-Zi %*% varcov_u %*% t(Zi)

    #sigmaY diagnol sd errors
    SigY<-zdzmat+
      diag(rep(m_sd_e,rtime)) +
      do.call(adiag, mapply(function(a,b)
        matrix(rep(a,b^2),ncol=b),m_sd_b,rtime,SIMPLIFY = FALSE))

    #repetitive part of joint variance matrix
    d<-matrix(c(unlist(lapply(1:(nout-1), function(x) c(rep(m_sd_b[x],rtime[x]),rep(0,ntime)))),
                rep(m_sd_b[nout],rtime[nout])),ncol=nout,nrow = ntime)

    #fixed effect fitted values
    if(nfix>0) Xbeta<-Xi %*% c(0,m.fix)
    else Xbeta<-Xi %*% c(0)


    ###Estimating the RE's based on paired models
    SigZY<-rbind(varcov_u %*% t(Zi), t(d) )

    dify<-as.matrix(data_mS[,"value"] -  Xbeta , ncol=1)

    B<-SigZY %*% solve(SigY)

    EBest<-rbind(EBest, t(B %*% dify))

  }


  #name the predicted random effects
  rand_nam<-colnames(model.matrix(random, data))
  rand_nam[rand_nam=="(Intercept)"] <- "intercept"

  colnames(EBest)<-c(rand_nam,Ynames)

  #put togehter fitted values from the pairs
  if(nrand>1){
    pair_best<-c(m.fix,varcov_m,m_sd_e,m_sd_b)
    names(pair_best)<-c(attr(afixed,"term.labels"),paste("varcov",c(1:nrand)),
                        paste("std.err",c(1:nout)),paste("std.randomY",c(1:nout)))
  }else{
    pair_best<-c(m.fix,m_sd_e,m_sd_b)
    names(pair_best)<-c(attr(afixed,"term.labels"),
                        paste("std.err",c(1:nout)),paste("std.randomY",c(1:nout)))}

  #####Second level test with GT
  EBS<-cbind(data_inf, EBest)
  gt_obj<-slapGT(EBS, data_inf, rand_nam, Ynames, grouping, Emethod="pairwise")


  ##object to return
  nsubj<-length(unique(data[,subject]))
  nrep<-table(table(data[,subject]))
  tgroup<-table(data[,grouping])
  slapconv<-sum(allconv==1)/length(indx)

  #result
  res<-list(call=cl,
            nfix=nfix,
            nrand=nrand,
            nsubj=nsubj,
            nrep=nrep,
            tgroup=tgroup,
            Ynames=Ynames,
            slapconv=slapconv,
            fixedform=fixedform,
            randform=randform,
            slapmethod="Pairwise",
            SLaP.par=pair_best,
            Globaltest=gt_obj,
            EB_pred=EBS)

  class(res) <-c("slapmeg")

  return(res)

}
