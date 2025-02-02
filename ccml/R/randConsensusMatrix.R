randConsensusMatrix <- function(l.seed,l.label=label,l.ns=ns,l.nc=nc,l.nv=nv,l.index=index,l.pair.ind=pair.ind,l.ppath=ppath,l.plot=plot){
  #' Calculate consensus weight matrix based on the permuted input label matrix. Internal function used by \code{callNCW}
  #' @param l.seed A numerical value to set the random seed for reproducible results, 1000 random label matrix will be generated based on this seed number.
  #' @param l.label A matrix or data frame of input labels, columns=different clustering results and rows are samples.
  #' @param l.ns A integer value of number of samples, =\code{nrow(l.label)}
  #' @param l.nc A integer value of number of samples, =\code{ncol(l.label)}
  #' @param l.nv A integer vector of the number of non missing values for each column in \code{l.label}
  #' @param l.index A list of index with length of \code{l.nc} of non missing values for each column in \code{l.label}
  #' @param l.pair.ind A n-by-2 index matrix of array indices of upper triangular of \code{l.label} with non missing values
  #' @param l.ppath A character value for output directory.
  #' @param l.plot character value. NULL(default) - print to screen, 'pdf', 'png', 'pngBMP' for bitmap png, helpful for large datasets, or 'pdf'.
  #' @return A character of finished seed.
  #' @return Write a binary file of 1000 random consensus weight matrix(as a vector n-by-1, n= nrow(\code{l.pair.ind})) with the seed \code{l.seed}, output file name: paste0("s",\code{l.seed},"rcw").
  #' @import diceR
  #' @export
  #'
  #'


  # require(diceR)
  requireNamespace("diceR")

  fname = paste0(l.ppath,paste0("s",l.seed,"rcw"))
  cc.rand <- lapply(1:1000,function(b){

    tmp.sample <- lapply(l.nv,sample);
    tmp.group <- sapply(1:l.nc,function(i){
      tmp.rand <- rep(NA,length=l.ns)
      tmp.rand[l.index[[i]]] <- l.label[l.index[[i]],i][tmp.sample[[i]]]
      return(tmp.rand)
    });
    return(tmp.group)})
  res <- lapply(cc.rand,diceR::consensus_matrix)
  res <- sapply(res,function(a){a[l.pair.ind]})
  t = as.vector(res)
  if(is.null(l.plot)==FALSE){
    writeBin(t,fname)
  }

  # return(paste0("Finished", l.seed))
  return(t)

}
