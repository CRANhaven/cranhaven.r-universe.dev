callNCW <- function(title="",label,nperm = 10, ncore=1,seedn=100,stability=TRUE,plot=NULL) {
  #' Calculate normalized consensus weight(NCW) matrix based on permutation.
  #'
  #' @param title A character value for output directory. Directory is created only if not existed. This title can be an abosulte or relative path.
  #' @param label A matrix or data frame of input labels, columns=different clustering results and rows are samples.
  #' @param nperm A integer value of the permutation numbers, or nperm=10(default), which means \code{nperm}*1000 times of permutation.
  #' @param ncore A integer value of cores to use, or ncore=1 (default). It's the input core numbers for the parallel computation in this package \code{parallel}.
  #' @param seedn A numerical value to set the start random seed for reproducible results, or seedn=100 (default). For every 1000 iteration, the seed will +1 to get repeat results.
  #' @param stability A logical value. Should estimate the stability of normalized consensus weight based on permutation numbers (default stability=TRUE), or not?
  #' @param plot character value. NULL(default) - print to screen, 'pdf', 'png', 'pngBMP' for bitmap png, helpful for large datasets, or 'pdf'. Input for \code{randConsensusMatrix}.
  #' @export
  #' @import diceR parallel tidyr ggplot2
  #' @return A matrix of normalized consensus weights.
  #' @examples
  #'
  #' # load data
  #' data(example_data)
  #' label=example_data
  #'
  #' # if plot is not NULL, results will be saved in "result_output" directory
  #' title="result_output"
  #'
  #' \donttest{
  #' # run ncw
  #' ncw<-callNCW(title=title,label=label,stability=TRUE,nperm=4,ncore=1)
  #' }
  #'




  ## checking input----
  message("Step 1/3: Checking of inputs...")

  # message(paste0("shuru!!  title:",title))


  requireNamespace("diceR")
  requireNamespace("parallel")
  requireNamespace("tidyr")
  requireNamespace("ggplot2")
  # requireNamespace("ConsensusClusterPlus")


  # require(diceR); require(parallel); require(tidyr);require(ggplot2)
  if(is.null(plot)==FALSE){
    if(title==""){
      stop("A 'title' of a character value for output directory must be provided when plot not NULL")
    }

  }
  if(missing(title)){
    stop("A 'title' of a character value for output directory must be provided") }
  if(!is.character(title)){
    stop("A 'title' of a character value for output directory must be provided") }
  if(missing(label)){
    stop("A input 'label' as matrix or data frame must be provided") }
  if(!is.matrix(label)&!is.data.frame(label)){
    stop("A input 'label' as matrix or data frame must be provided") }

  ## convert 'title' for output directory to formated absolute path
  ### add "/" at the end of title
  if (!substr(title,nchar(title),nchar(title))=="/") {
    title = paste0(title,"/")
  }




  if (substr(title,1,2)=="./") {
    ### relative path to absolute path
    message(paste0("The first choice:",title))
    title = paste0(getwd(),"/",substr(title,3,nchar(title)))
    # message(paste0("The first choice:",title))
  } else if (substr(title,1,1)=="D" | substr(title,1,1)=="E" | substr(title,1,1)=="F"| substr(title,1,1)=="C" |substr(title,1,1)=="G"){
    ### character input to absolute path
    title = title
  }else if (!substr(title,1,1)=="/"){
    ### character input to absolute path
    title = paste0(getwd(),"/",title)
    # message(paste0("The second choice:",title))
  }

  ## path for cache permuation result
  ppath = paste0(title,"permutation/")

  ## create folders of title and title/permutation ----
  if(is.null(plot)==FALSE){
    if (!dir.exists(title)){
      dir.create(title,recursive = T)
      message(paste("- Created a new folder:\n", title))
      dir.create(ppath,recursive = T)
    } else {
      message(paste(" - The directory already existed.\nNew results will be added to:\n", title))
      if (!dir.exists(ppath)){
        dir.create(ppath,recursive = T)
        message(paste(" - Created a new folder for cache permutation results:\n", ppath))
        } else {
          message(paste(" - The cache directory already existed.\n -New permutation results will be added to:\n", ppath))
        }
    }

  }


  ## permute labels------
  step = 1000 # number of random consensus weight matrix in each seed

  ## mc.cores, number of cores will be used
  ncore = min(parallel::detectCores(),ncore)


  ### number of non missing values for each column
  nv <- colSums(!is.na(label))
  nc <- ncol(label) # number of clustering labels
  ns <- nrow(label) # number of samples
  index <- apply(label,2,function(b){which(!is.na(b))})
  ### list of index of non missing values for each column


  ### consensus matrix of label
  cm <- diceR::consensus_matrix(label)

  ### pair wise index of sample pairs with non missing values
  pair.ind = which(!is.na(cm),arr.ind = T)
  pair.ind = pair.ind[pair.ind[,1]-pair.ind[,2]<0,]

  ### check existed randome consensus weight matrix in the results folder
  if(is.null(plot)==TRUE){
    filename=c()
  }else{
    filename = dir(ppath)
  }

  # filename = dir(ppath)
  filename = filename[grepl("rcw$",filename)]    ##find "rcw$" in ppath
  if (length(filename)>0) {
    filename = gsub("s","",filename)
    seede = as.integer(gsub("rcw","",filename)) # existed seed results

  } else {seede=NULL}
  seeda = seedn+0:(nperm-1) # all seeds
  seedL = setdiff(seeda,seede) # seeds need to be run

  ## calculate rand consensus matrix, output to binary files----


  message(paste("\nStep 2/3: Calculating of", nperm*step, "random consensus matrixes...\n"))
  ppath = paste0(title,"permutation/")


  randL <- parallel::mclapply(seedL,function(x){randConsensusMatrix(l.seed=x,l.label=label,l.ns=ns,l.nc=nc,l.nv=nv,l.index=index,l.pair.ind=pair.ind,l.ppath=ppath,l.plot=plot)},mc.cores=ncore)

  ## calculate NCW----
  ### import all random consensus matrixes to randCM

  if(is.null(plot)==TRUE){
    randCM<-lapply(1:nperm,function(a){
      tmp = matrix(randL[[a]],nrow=nrow(pair.ind),ncol=step)
      return(tmp)
    })

  }else{
    randCM<- lapply(seeda,function(a){
      fname = file.path(ppath,paste0("s",a,"rcw"))
      tmp <- readBin(fname,"numeric",n=nrow(pair.ind)*step)
      tmp = matrix(tmp,nrow=nrow(pair.ind),ncol=step)
      return(tmp)
    })
  }


  randCM <- as.matrix(cbind.data.frame(randCM))

  ## estimation of stability of permutation number----
  if(stability==T){
    message(paste("Step3/3: Calculating & Estimating the stability of permuation number for normalized consensus weight...\n"))
    res.ecdf <- sapply(1:nrow(pair.ind),function(a){
      v = cm[pair.ind[a,1],pair.ind[a,2]]
      t = randCM[a,]
      r = sapply(seq(step,ncol(randCM),length.out=length(seeda)),function(b){ecdf(t[1:b])(v)})
      return(r)
    })
    res.ecdf <- t(res.ecdf)
    colnames(res.ecdf) <- seq(step,ncol(randCM),length.out=length(seeda))

    ## for 0 and 1 setup min and max values based on permutation numbers
    for (i in 1:ncol(res.ecdf)){
      res.ecdf[res.ecdf[,i]==0,i] = 1/(1000*i)
      res.ecdf[res.ecdf[,i]==1,i] = 1-1/(1000*i)
    }

    res.ncw <- res.ecdf[,ncol(res.ecdf)]
    # the difference (Squared Euclidean Distance of NCW) for every step(1000) permutation
    res.ecdf.diff <- matrix(0,nrow=nrow(res.ecdf),ncol=ncol(res.ecdf)-1)
    for(i in 2:ncol(res.ecdf)){
      res.ecdf.diff[,i-1]=(res.ecdf[,i]-res.ecdf[,(i-1)])^2
    }

    colnames(res.ecdf.diff) = colnames(res.ecdf)[2:ncol(res.ecdf)]
    a<-as.data.frame(cbind.data.frame(pair=1:nrow(res.ecdf.diff),
                                      res.ecdf.diff))
    b<-tidyr::gather(a,colnames(res.ecdf.diff),key="reps",value= "diff2")
    b<-as.data.frame(b)
    pdata<-b


    class(pdata$reps) = "integer"
    pdata$reps = pdata$reps/step
    class(pdata$reps) = "integer"


    pdata2 <- cbind.data.frame(reps=as.integer(colnames(res.ecdf.diff)),y=colSums(res.ecdf.diff))

    pdata2$reps = pdata2$reps/step
    class(pdata2$reps) = "integer"

    sf = max(pdata2$y)/max(pdata$diff2) # scaling factor

    if(is.null(plot)==TRUE){
      print(ggplot() +
        geom_boxplot(pdata, mapping=aes(x=reps, y=diff2*sf,group=reps)) +
        geom_line(data=pdata2,aes(x=reps, y=y,group=1),color="blue") +
        geom_point(data=pdata2,aes(x=reps, y=y,group=1),size=3,shape=23,fill = "blue") +
        scale_y_continuous(name="Overall Squared Euclidean Distance of NCW",sec.axis = sec_axis(~ ./sf, name="Squared Euclidean Distance of NCW"))+
        scale_x_continuous(name="Permutation numbers(*1000)",breaks=unique(pdata2$reps),labels=as.character(unique(pdata2$reps)))+
        ggtitle("Stability of permutation numbers for NCW calculation")+
        theme_bw(base_size = 14) +
        theme(axis.text.y.left = element_text(color = "blue"),plot.title = element_text(hjust = 0.5)))

    }else{
      p1<-ggplot() +
        geom_boxplot(pdata, mapping=aes(x=reps, y=diff2*sf,group=reps)) +
        geom_line(data=pdata2,aes(x=reps, y=y,group=1),color="blue") +
        geom_point(data=pdata2,aes(x=reps, y=y,group=1),size=3,shape=23,fill = "blue") +
        scale_y_continuous(name="Overall Squared Euclidean Distance of NCW",sec.axis = sec_axis(~ ./sf, name="Squared Euclidean Distance of NCW"))+
        scale_x_continuous(name="Permutation numbers(*1000)",breaks=unique(pdata2$reps),labels=as.character(unique(pdata2$reps)))+
        ggtitle("Stability of permutation numbers for NCW calculation")+
        theme_bw(base_size = 14) +
        theme(axis.text.y.left = element_text(color = "blue"),plot.title = element_text(hjust = 0.5))

      ggsave(paste0(title,"stability.seed",seedn,".n",nperm,"K.",plot),width=max(8,nperm*0.5),height=5)
    }

    message(paste("Finished estimation of stability of permutation numbers for normalized consensus weight:\n"))

  }else{
    message(paste("Step3/3: Calculating the matrix of normalized consensus weight...\n"))
    res.ecdf <- sapply(1:nrow(pair.ind),function(a){
      v = cm[pair.ind[a,1],pair.ind[a,2]]
      t = randCM[a,]
      r = ecdf(t)(v)
      return(r)
    })
    res.ncw <- res.ecdf
  }


  res.ncw[res.ncw==1] = 1-1/(1000*nperm) # max based on permutation times
  res.ncw[res.ncw==0] = 1/(1000*nperm) # min


  ## output to matrix of NCW ----
  ncw <- cm
  ncw[pair.ind]=res.ncw
  ncw[pair.ind[,c(2,1)]]=res.ncw

  ### add rownames to ncw
  if (!is.null(rownames(label))) {
    rownames(ncw) = rownames(label)
    colnames(ncw) = rownames(label)
  }

  return(ncw)
}
