#' @title Plot the estimated random effects from SLaPMEG seperated for the study groups
#'
#' @description This plot can provide a graphical insight into the source of effect (i.e. diffrential expression)
#' in relevent pathway.
#'
#' @param obj  An slapmeg object which is the output from \code{\link{slapmeg}} or
#' \code{\link{pairslapmeg}}. Note that the \code{fullreturn=TRUE}) must have been used.
#'
#' @param \dots optional graphical parameters can be added with an \code{+} based on ggplot2 package.
#' structure.
#'
#' @return No return value, the function generates a plot and displays it.
#'
#' @author Mitra Ebrahimpoor
#'
#' \email{m.ebrahimpoor@@lumc.nl}
#'
#' @seealso
#'
#'\code{\link{slapmeg}}, \code{\link{multslapmeg}}, \code{\link{pairslapmeg}}
#'
#' @references
#' Ebrahimpoor, Mitra, Pietro Spitali, Jelle J. Goeman, and Roula Tsonaka. "Pathway testing for longitudinal metabolomics." Statistics in Medicine (2021).
#'
#' @examples
#' # simulate data with 8 omics
#' testdata<-simslapmeg(nY=8, ntime=5, nsubj = 30, seed=123)
#' head(testdata)
#'
#' #fit slapmeg to test for the differential expression of a pathway of size 5
#' fit<- slapmeg(Y1+Y2+Y6+Y7+Y8~time, ~1, grouping="group", subject="ID", data=testdata)
#'
#' #Density plots for the estimated random effects
#' plotslapmeg(fit)
#'
#' @export
#'
#' @import ggplot2


plotslapmeg<-function(obj,...){

#make sure value is known
#value=NULL

if(!inherits(obj, "slapmeg")) stop('The object should be the output of slapmeg function!')
if(is.null(obj$EB_pred)) stop('The full output by slapmeg function should be retrieved!')

#extract data from output
plotdata<-obj$EB_pred
data_m<-data.frame(rep(plotdata[,1],each=ncol(plotdata)-2),
                   rep(plotdata[,2],each=ncol(plotdata)-2),
                   rep(colnames(plotdata)[-c(1,2)],nrow(plotdata)))
names(data_m)<-c(colnames(plotdata)[1:2],"par")
data_m <-cbind(data_m,data.frame(value=c(t(plotdata[,-c(1,2)]))))

labs_group<-unique(plotdata[,2])

#plot the EBs
ggplot(data_m, aes(x=data_m$value)) +
  facet_wrap(.~data_m$par, ncol = 2, scales = "free")+
  geom_density(aes(fill=data_m$group),alpha=0.5)+
  guides(fill=guide_legend(title="Group"))+
  labs(y= "\n Density", x = "\n Estimated Effect")+
  scale_fill_discrete(labels = paste(labs_group))+
  theme_minimal()

}
