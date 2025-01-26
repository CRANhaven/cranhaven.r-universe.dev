#################################################################################
#################################################################################
##  Standardized Distance Score with structure size of 16
##  Find the past history which is the best match for the most recent history.
#################################################################################
# Writen By Patrick Fleming as part of Navel Post Graduate Grant                #
# NAVSUP Grant No.: N00244-15-0052                                              #
#################################################################################
#################################################################################
standarddistance <-function(char,History,hlength){

  #initialize some variables
  #################################################################################################################
  nn <- 1       # how much short of current should we stop thist is to avoid small delta t from producing false positives
  snum<- char #14      #  (number of structures checked is 2^snum-1)
  big<-2^snum-1
  #largest sub structure size
  n <- hlength-1   #number of past histories
  dist<-0          # temporary distance storage
  #
  ###################################################
  # Comupute the Difference matrix
  D <- matrix(data=0, nrow=(n), ncol=(snum))
  for(i in 1 : n)
    for(j in 1 :snum){
      D[i,j]<-abs(History[hlength,j]-History[i,j])
    }

  ###################################################
  #History structure matrix
  HS <- matrix(data=0, nrow=(snum), ncol=(big))
  fHS <- matrix(data=0, nrow=(snum), ncol=(65535))
  #r<-0
  #i<-7
  for(i in 1 : big){
    for(j in 1 : snum){
      HS[j,i]<-bitwAnd(1,bitwShiftR(i,j-1))
    }
  }


  #######################################
  #Compute the distance matrix
  DM<-matrix(data=0, nrow=n,ncol=(big))
  DM<-D%*%HS

  ##########################################################################
  # Compute standard deviation and mean of each column of distance matrix
  # as well and the standardised distance matrix
  SDM<-matrix(data=0, nrow=n,ncol=(big))
  stds<-0
  mns<-0
  sscore<-0
  for( i in  1 : big){
    # compute the standard deviation in distance from current within structure i
    stds[i] <- sd(DM[,i])
    # compute the mean in distance from current within structure i
    mns[i] <- mean(DM[,i])
    # compute max score for structure i (inverse of coefficient of variance)
    sscore[i] <- mns[i]/stds[i]
    # compute the Standardized distance martix
    SDM[,i] <- (DM[,i]/stds[(i)])
  }#end i

  ##############################################
  # Comupte the complete history score matrix
  CHS<-matrix(data=0, nrow=n,ncol=(big))
  for( j in  1 : big) ##j is structure
    for(i in 1 : n){  # i is the history
      CHS[i,j] <- sscore[j]-SDM[i,j]
    } #end i

  ###########################################################################
  #pull the highest score for each history 1 score, 2 structure, 3 history
  Hscore<-matrix(data=0, nrow=(n-nn),ncol=(3))
  for(i in  1 : (n-nn)){
    Hscore[i,1]<- CHS[i,1]
    Hscore[i,2]<-1
    Hscore[i,3]<-i
    for(j in 1 : big){ #j is sctructre
      if( Hscore[i,1]<= CHS[i,j]){
        Hscore[i,1] <- CHS[i,j] #### score
        Hscore[i,2] <- j        #### structure
        Hscore[i,3] <- i        #### History
      } # end if
    } # end j
  } #end i

  ##################################################
  #sort the history score so that they are ranked
  RM<-matrix(data=0, nrow=(n-nn),ncol=(3))
  RM<-Hscore[order(Hscore[,1],decreasing=TRUE),]

  #######################################################################
  # write the socre structure and history value to clhist and return it
  clhist<-0
  clhist[1]<-RM[1,1] #score in first column
  clhist[2]<-RM[1,2] #
  clhist[3]<-RM[1,3] #history in the last column
  return(clhist)
} # end Distance score  function
