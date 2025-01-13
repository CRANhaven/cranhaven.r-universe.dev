#' @title Print objects from \code{slapmeg}
#'
#' @description Provides an overview of SLaPMEG approach through \code{slapmeg}
#' and \code{pairslapmeg} objects.
#'
#' @aliases print.slapmeg
#'
#' @param  x an object inheriting from class \code{slapmeg}
#'
#' @param \dots further arguments to be passed to or from other methods, which will be ignored in
#' this function.
#'
#' @return Returns result summaries of SLAPMEG approach
#'
#' @author Mitra Ebrahimpoor
#'
#' @seealso  \code{\link{slapmeg}}, \code{\link{pairslapmeg}}
#'
#' @keywords print
#'
#' @export
#'

print.slapmeg <- function(x,...){
  if (!inherits(x, "slapmeg")) stop("use only with \"slapmeg\" objects")

  cat("Shared latent Process Mixed Effects modeling with GLobaltest", "\n")
  if(x$slapmethod=="pairwise")cat("   fitted  based on the pairwise approach ","\n")
  else cat("   fitted based on the Joint likelihood", "\n")
  cat(" \n")

  cat("Dataset", "\n")
  cat("         Dataset name:", x$call$data,"\n")
  cat("   Number of subjects:", x$nsubj,"\n")
  cat("             Grouping:",paste0(names(x$tgroup)),"\n")
  cat(" \n")

  cat("Shared latent Process meodel (Step 1) : \n")
  cat("   Omics in the Pathway:", paste0(x$Ynames, collapse = ", "),"\n")
  cat("     Fixed effect terms:", x$fixedform,"\n")
  cat("    Random effect terms:", x$randform,"\n")
  cat(" \n")

  cat("Globaltest (Step 2):", "\n")

  cat(paste("      p-value:", format(x$Globaltest[1],scientific=TRUE)),"\n")

}

