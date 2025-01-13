#' @title Testing multiple pathways using SLaPMEG (shared latent process mixed effects model and Globaltest) for
#' longitudinal Omics data
#'
#' @description Run slapmeg simultaneously for several pathways. For each pathway a p-value is calculated based
#' on SLaPMEG prodcedure as in \code{\link{multslapmeg}}.
#' Then the p-values are adjusted for multiple comparisons based on the selected procedure.
#'
#' @param pathlist A list of pathways to be tested.
#'
#' @param fixed A one-sided linear formula object for specifying the
#' fixed-effects in the linear mixed model at the latent process level that
#' starts with the \code{~} sign.
#'
#' @param random A one-sided formula for the random-effects in the
#' latent process mixed model and starts with the \code{~} sign. At least one random
#' effect should be included. Covariates with a random-effect are separated
#' by \code{+}.
#'
#' @param grouping name of the covariate representing the grouping structure.
#'
#' @param subject name of the covariate representing the repeated measures structure such as subject IDs.
#'
#' @param data data frame containing the variables named in list of \code{pathlist}, \code{fixed},
#' \code{random}, \code{grouping} and \code{subject}.
#'
#' @param method Correction method for p-values, the default is "BH". For more methods see\code{?p.adjust}.
#'
#' @return A datafram including the name of pathways and corresponding adjusted p-values.
#'
#' @author Mitra Ebrahimpoor
#'
#' \email{m.ebrahimpoor@@lumc.nl}
#'
#' @seealso
#'
#' \code{\link{slapmeg}}, \code{\link{pairslapmeg}}, \code{\link{plotslapmeg}}
#'
#' @references
#' Ebrahimpoor, Mitra, Pietro Spitali, Jelle J. Goeman, and Roula Tsonaka. "Pathway testing for longitudinal metabolomics." Statistics in Medicine (2021).
#'
#' @examples
#'
#' \donttest{
#' # simulate data with 20 omics
#' testdata<-simslapmeg(nY=20, ntime=5, nsubj = 30, seed=123)
#' head(testdata)
#'
#' # creat a list of 3 random pathways of different sizes
#' pathlist<-list(path1=sample(colnames(testdata)[-c(1:3)],5),
#'               path2=sample(colnames(testdata)[-c(1:3)],11),
#'               path3=sample(colnames(testdata)[-c(1:3)],9) )
#'
#'
#' #use mult slampmeg to get test for the differential expression of all pathways
#' #and get adjusted p-values
#' mfit<- multslapmeg(pathlist, ~time, ~1+time, grouping="group", subject="ID", data=testdata)
#' summary(mfit)
#' }
#'
#' @export
#'
#' @importFrom stats p.adjust formula terms

multslapmeg<-function(pathlist, fixed, random, grouping, subject, method = "BH", data){

  #check the arguments
  if(missing(fixed)) stop('The argument fixed must be specified for all models!')
  if(missing(random)) stop('The argument random must be specified for all models!')

  if (!inherits(pathlist, "list")) stop("Pathlist argument should be a list!")
  if(length(pathlist)<2) stop("Only one pathway is defined!")

  if(fixed[[1]]!="~") stop("The Fixed formula is not correctly specified! Check the vignette for help.")
  if(length(fixed)>2) stop("The Fixed formula is not correctly specified! Check the vignette for help.")


  if(! method %in% c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"))
    stop("P-value correction method is not correctly specified! Check ?p.adjust.")
  #apply slapmeg for all pathways
  fixed_forms<-sapply(pathlist,
                      function(x) paste0(paste0(x,collapse="+"),"~",Reduce(paste, deparse(fixed[[2]]))))
  fixed_forms<-lapply(fixed_forms, function(f) as.formula(f))

  slapmeg<-sapply(fixed_forms, function(forms) {
                              mod<-slapmeg(forms, random, grouping, subject, data)
                              return(list(mod$Globaltest[1], mod$slapmethod)) })
  psize<-sapply(pathlist, function(x) length(x))

  #correct the p-values and round the result
  adj.ps<-round(p.adjust(slapmeg[[1]], method), 4)

  #organize and return the output
  if(is.null(names(pathlist))) {
    path.nom<-paste0("Path", 1:length(adj.ps))} else
      path.nom<-names(pathlist)

  res<-data.frame(path.nom, adj.ps, psize, slapmeg[[2]],row.names = NULL)
  colnames(res)<-c("Path.Name",paste0("adj.P","(",paste(method),")"),"Path.size","method")

  class(res) <-c("mslapmeg")
  return(res)

}

