#' @title Summary of  \code{slapmeg} objects
#'
#' @description Provides a summary of values estimated with SLaPMEG approach within \code{slapmeg}
#' and \code{pairslapmeg} objects.
#'
#' @aliases summary.slapmeg
#'
#' @param object an object inheriting from classes \code{slapmeg}
#' @param \dots further arguments to be passed to or from other methods, which will be ignored in this
#' function.
#' @return 'Returns the fixed effect estimates and random effects variances from the model in step 1
#' and the details of Globaltest along with p-value from step 2.
#'
#' @author Mitra Ebrahimpoor
#'
#' @seealso  \code{\link{slapmeg}}, \code{\link{pairslapmeg}},
#'
#' @keywords summary
#'
#' @export
#'
summary.slapmeg<- function(object,...){
  if (!inherits(object, "slapmeg")) stop("use only with \"slapmeg\" objects")

  cat("Shared latent Process Mixed Effects modeling with GLobaltest", "\n")
  if(object$slapmethod=="pairwise") cat("   fitted  based on the pairwise approach ","\n")
  else cat("   fitted based on the Joint likelihood", "\n")

  cat(" \n")
  dput(object$call)
  cat(" \n")

  cat("Dataset", "\n")
  cat("   Dataset name:", object$call$data,"\n")
  cat("   Number of subjects:", object$nsubj,"\n")
  cat("   Grouping:",paste0(names(object$tgroup)),"\n")
  cat("            ",paste0(object$tgroup),"\n")
  cat("   Repeated measures:", paste(names(object$nrep)),"\n")
  cat("                     ", paste(object$nrep),"\n")
  cat(" \n")

  cat("Shared latent Process meodel (Step 1) : \n")
  if(object$slapconv%%1!=0) cat("     Convergence criteria satisfied for",round(object$slapconv,2),
                           "of the pairwise models", "\n")
  if(object$slapconv==1) cat("     Model(s) Converged \n")
  if(object$slapconv==2) cat("     Maximum number of iteration reached without convergence \n")
  if(object$slapconv==3) cat("     Convergence with restrained Hessian matrix \n")
  if(object$slapconv==4|object$slapconv==12) {
    cat("     The program stopped abnormally. No results can be displayed.\n")
  }else{
    cat(paste("     Number of parameters:", length(object$SLaP.par))," \n")
    cat(paste("     The Pathway:", paste0(object$Ynames, collapse = ", ")),"\n")
    cat("     Fixed effect terms:", object$fixedform,"\n")
    cat("     Subject-specific random effect terms:", object$randform,"\n")
    cat(" \n")

    cat(" \n")
    cat("Estimated parameters: \n")
    cat("intercept is not estimated \n")
    print(object$SLaP.par)
    cat(" \n")


    cat("Globaltest (Step 2):", "\n")
    cat(paste("      p-value:", format(object$Globaltest[1],digits=4,scientific=TRUE)),"\n")
    cat(paste("      Test statistic:", format(object$Globaltest[2],digits=4,scientific=TRUE)),"\n")
    cat(paste("      Expected value:", object$Globaltest[3]),"\n")
    cat(paste("      Std.dev:", format(object$Globaltest[4]),digits=4,scientific=TRUE),"\n")
    cat(paste("      #Cov:", object$Globaltest[5]),"\n")
    cat(paste("      GT.model:", object$Globaltest[6]),"\n")
  }

}
