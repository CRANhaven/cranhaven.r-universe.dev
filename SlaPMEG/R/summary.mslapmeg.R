#' @title Summary of  \code{slapmeg} objects
#'
#' @description Provides a table of sorted p-values for the output of multSLaPMEG approach within \code{multslapmeg} objects.
#'
#' @aliases summary.mslapmeg
#'
#' @param object an object inheriting from classes \code{multslapmeg}
#' @param n an integer indicating number of pathways to be printed the default is 5
#' @param \dots further arguments to be passed to or from other methods, which will be ignored in this
#' function.
#' @return 'Returns the fixed effect estimates and random effects variances from the model in step 1
#' and the details of Globaltest along with p-value from step 2.
#'
#' @author Mitra Ebrahimpoor
#'
#' @seealso  \code{\link{multslapmeg}}, \code{\link{pairslapmeg}},
#'
#' @keywords summary
#'
#' @export
#'
summary.mslapmeg<- function(object,n=5,...){

 #prep output table
  dr<-data.frame(object[[1]],object[[2]],object[[3]])
  colnames(dr)<-names(object)[-4]
  dr<-utils::head(dr[order(dr[,2]),],n)
  row.names(dr)<-NULL

  print(dr)

}
