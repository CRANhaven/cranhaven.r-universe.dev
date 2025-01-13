#' @title Testing pathways using SLaPMEG (shared latent process mixed effects model and Globaltest) for
#' longitudinal Omics data
#'
#' @description A two-step procedure is adopted, first a joint latent process mixed effects model
#' is fitted and on the longitudinal data to summarize the temporal trend in terms of
#' several random effects. For computational efficacy, if the size of pathway is
#' larger than 10 a paired approah is used to estimate the random effects with the
#' \code{pairslapmeg} function. The random effects are the input for globaltest which
#' is used to compare the two groups at a pathway level.
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
#' @param nlimit A controling arguments telling slapmeg to use pairwise approach for pathways larger than this value,
#' default is 10. Note: fitting the joint model may take long for pathways larger than 20 omics.
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
#' \code{\link{multslapmeg}}, \code{\link{pairslapmeg}}, \code{\link{plotslapmeg}}
#'
#' @references
#' Ebrahimpoor, Mitra, Pietro Spitali, Jelle J. Goeman, and Roula Tsonaka. "Pathway testing for longitudinal metabolomics." Statistics in Medicine (2021).
#'
#' @examples
#'
#' #simulate data with 8 omics
#' testdata<-simslapmeg(nY=8, ntime=5, nsubj = 30, seed=123)
#' head(testdata)
#'
#' #fit slapmeg to test for the differential expression of a pathway of size 5
#' fit<- slapmeg(Y1+Y2+Y6+Y7+Y8~time, ~1, grouping="group", subject="ID", data=testdata)
#' fit
#' summary(fit)
#'
#' @importFrom lcmm multlcmm estimates
#' @importFrom stats as.formula formula terms model.matrix
#' @importFrom globaltest gt
#' @export

slapmeg<-function(fixed, random, grouping, subject, data, nlimit=10){

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
  if(length(levels(data[,c(grouping)]))!=2) { stop("The Grouping variable should have two levels!")}

  if(missing(subject)){ stop("The argument Subject must be specified!")}
  idNames <-as.character(subject)
  if(!(idNames %in% colnames(data))) { stop("Data should contain the Subject variable!")}

  ##check that the variables in formula match the data
  afixed <- terms(fixed, specials=c("factor","contrast"))
  fixedform<-paste(attr(afixed,"term.labels"),collapse = ",")
  nfix<-length(attr(afixed,"term.labels"))
  if(attr(afixed,"intercept")!=0 ) fixedform<-paste("intercept", fixedform)

  arandom <- terms(random, specials=c("factor"))
  randform<-paste(attr(arandom,"term.labels"),collapse = ",")
  nrand<- length(attr(arandom,"term.labels"))
  if(attr(arandom,"intercept")!=0 ) {randform<-paste("intercept", randform)
                                      nrand<-nrand+1}

  variables <- c(attr(afixed,"variables"),attr(arandom,"variables"))
  variables <- unlist(lapply(variables,all.vars))
  if(!all(variables %in% colnames(data))) stop(paste("Data should contain the variables",paste(unique(variables),collapse=" ")))
  if(missing(data)){ stop("The argument data should be specified and defined as a data.frame")}

  ###fit the original or pairwise lcmm
  #list of outcomes
  Ynames <- all.vars(fixed[[2]])
  nout <- length(Ynames) #number of omics in path

  if(nout>nlimit){
    #get the initial values from setinval
    res<-do.call(pairslapmeg,list(fixed, random, grouping, idNames, data))

  }else{

    ###list of all variables
    varNames <- c(all.vars(fixed[-2]), all.vars(random))
    varNames <- unique(varNames)
    varNames <- setdiff(varNames, Ynames)

    #initial values
    inB=do.call(setinval,list(fixed, random, idNames, data))

    #number of parameters in joint model
    npar<-length(inB)

    #fit the full joint model
    lcmm_full<-multlcmm(fixed=fixed, random=random, subject=substitute(idNames),
                        B=inB, posfix=(npar-2*nout+1):npar,
                        randomY=TRUE, link=rep("linear",nout),
                        data=data, verbose = FALSE)

        #get info on subject and grouping
    data_inf<-unique(data[,c(subject,grouping)])

    #name the predicted random effects
    out_nam<-unlist(lapply(attr(afixed,"variables"),all.vars)[[2]])

    rand_nam<-colnames(model.matrix(random, data))
    rand_nam[rand_nam=="(Intercept)"] <- "intercept"

    #GT with estimates

    EBS<-cbind(data_inf, lcmm_full$predRE[,-1], lcmm_full$predRE_Y[,-1])
    if(nrand==1) names(EBS)<-c(colnames(data_inf),rand_nam,colnames(lcmm_full$predRE_Y[,-1]))

    gt_obj<-slapGT(EBS, data_inf, rand_nam, Ynames, grouping, Emethod="joint")

    #object to return
    nsubj<-length(unique(data[,subject]))
    nrep<-table(table(data[,subject]))
    tgroup<-table(data[,grouping])
    full_best<-lcmm_full$best[-c((npar-2*nout+1):npar)]
    slapconv=lcmm_full$conv

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
              slapmethod="Joint",
              SLaP.par=full_best,
              Globaltest=gt_obj,
              EB_pred=EBS)


    class(res) <-c("slapmeg")
    return(res)

    }



  }
