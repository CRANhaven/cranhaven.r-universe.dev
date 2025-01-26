################################################################################################
################################################################################################
###   Generate the history space and from Data
###   Full History structure includes Current x, y values
###   Current Delta x and Delta y
###   ALong with Six Past Delta x and six Past Delta y
###   Return a matrix with 16 collumns and the Number of rows =  data length - 7* Step
################################################################################################
##################################################################
# Writen By Patrick Fleming as part of Navel Post Graduate Grant #
# NAVSUP Grant No.: N00244-15-0052                               #
##################################################################
################################################################################################
historyslopes <- function(x,y,step,ave){

  # n = number of data points #
  n <- length(x)
  depth<-7
  # hl the the history space length
  hl <- n-((depth*step)+ave-1)
  #initialize the Delta x and y storage
  deltax<-0
  deltay<-0

  ##################################################################
  ####  make the history space for the x's and y's dx's and dy's
  history <- matrix(data=0, nrow=(hl), ncol=(2*depth+2))
  #####################################################################
  # there will be n-1 slopes (slope are  not averaged over the step size )

  for (i in 1:(n-ave)){   # 1,n-1 n-step   =+step
    deltax[i] <- (x[i+ave]-x[i])/ave #dx[i+1]       #+1]
    deltay[i] <- (y[i+ave]-y[i])/ave #dy[i+1]       #+1]
  }


  ######################################################################
  # FILL IN THE HISTORY SPACE MATRIX
  ######################################################################
  for(i in 1:hl){
    ###################################
    # FIRSTFILL IN THE  X and Y VALUES
    history[i,15]<-x[i+depth*step+ave-1]
    history[i,16]<-y[i+depth*step+ave-1]

    ############################################################################################
    # NOW FILL THE THE DELTA X AND DELTA Y VALUES FOR SINGle SIZED SLOPES (NOT AVERAGED)

    for(j in 1:depth){history[(i),j] <- deltax[i+depth*step-(1+(j-1)*step)]}  ### Delta x
    for(j in 1:depth){history[(i),j+(depth)] <- deltay[i+depth*step-(1+(j-1)*step)]}   ### delta y
    #for(j in 1:depth){history[(i),j] <- deltax[i+depth*step-(1+(j-1)*step)]}  ### Delta x
    #for(j in 1:depth){history[(i),j+(depth)] <- deltay[i+depth*step-(1+(j-1)*step)]}   ### delta y
    #########################################################################################
  }#i

  #History    row i:   xi xi-1  xi-2  xi-3 ,  yi yi-1  yi-2 yi-3,  dxi dxi-1 dxi-2 dxi-3 ,  dyi dyi-1 dyi-2 dyi-3
  K<-length(history)
  #print(K)
  return(history)
} # end of history space generator function
