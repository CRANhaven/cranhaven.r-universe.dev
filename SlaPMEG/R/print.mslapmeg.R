#' @title Print objects from \code{multslapmeg}
#'
#' @description Provides an overview of mSLaPMEG results for each pathway through \code{multslapmeg} object.
#'
#' @aliases print.mslapmeg
#'
#' @param  x an object inheriting from class \code{multslapmeg}
#'
#' @param \dots further arguments to be passed to or from other methods, which will be ignored in
#' this function.
#'
#' @return Returns result summary of mSLAPMEG approach
#'
#' @author Mitra Ebrahimpoor
#'
#' @seealso  \code{\link{multslapmeg}},\code{\link{slapmeg}}, \code{\link{pairslapmeg}}
#'
#' @keywords print
#'
#' @export
#'

print.mslapmeg <- function(x,...){
  if (!inherits(x, "mslapmeg")) stop("use only with \"mslapmeg\" objects")

  cat("SlaPMEG for multiple pathways", "\n")
  cat(length(x$Path.Name)," pathways were tested", "\n")
  cat("P-values are adjusted for multiple testing using",
      gsub("[\\(\\)]", "", regmatches(names(x)[2], gregexpr("\\(.*?\\)", names(x)[2]))),  "\n")

  cat(" \n")

  #prep output table
  dr<-data.frame(x[[1]],x[[2]],x[[3]],x[[4]])
  colnames(dr)<-c(names(x)[-4],"Method*")
  row.names(dr)<-NULL

  print(dr)
  cat(" \n")
  cat(" * Method (Joint/Pairwise) used to fit SlPMEG for each pathway.  \n")

}

