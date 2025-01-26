##################################################################
# closest History Flow Field Forecasting                         #
##################################################################
# Writen By Patrick Fleming as part of Navel Post Graduate Grant #
# NAVSUP Grant No.: N00244-15-0052                               #
##################################################################

CHFF <-function(data,num,step){ #History,hlength,width){
  dlength <-nrow(data)
  #set up an array to stor the forecasted values
  ave=1 #averaging slopes over ave points
  char=14 #char is the number of chararacteistics to consider
  forecasts <- matrix(data=0, nrow=(num),ncol=(2))


  print("CHFF Closest History Flow Field Forecasting")

  # Define the x and y vectors from the data
  x <- data[1:(dlength),1]    # remove the - num when done testing
  y <- data[1:(dlength),2]

  ##########################################################################################
  ##some initializing
  current<-0
  xhs <- 0
  #######################  history from data ##############################################
  hspace <- historyslopes(x,y,step,ave)
  size<-(length(hspace)/(2*7+2))
  #print(size)
  #############################################################################################
  # find the closest history
  structure<-standarddistance(char,hspace,size)
  #############################################################################################
  # Transfer history to an updatable version before making forecasts
  fullhist <- matrix(data=0, nrow=(size+num), ncol=(16))
  for(i in 1:size){
    fullhist[i,15] <- hspace[i,15]
    fullhist[i,16] <- hspace[i,16]
    for(j in 1:(14)){
      fullhist[i,j] <- hspace[i,j]
    }#j
  }#i

  ## define the first current full history
  for(i in 1:(16)) current[i]<-fullhist[size,i]

  ###########################################################
  # The  forcast loop
  ###########################################################
  fullsize<-size
  for(ww in 1: (num)){
    # Compute new x and y values from the change observed in the winning history
    newx<-current[15]+(fullhist[structure[3]+ww,1]) ## 18 in the winning position, x=1,y=5,dx=9,dy=13
    newy<-current[16]+(fullhist[structure[3]+ww,8])

    #################################################################################################
    # Store the forecasted values of x and y
    forecasts[ww,1]<- newx
    forecasts[ww,2]<- newy
    #################################################################################################
    # Update the the history
    # define a full updatable history
    #1 - 7 are the x slopes, 8-14 are the y slopes, 15 is the x value and 16 is the y value
    fullhist[size+1,1]<-newx-fullhist[1+size-step,15]
    fullhist[size+1,2]<-fullhist[size,1]
    fullhist[size+1,3]<-fullhist[size,2]
    fullhist[size+1,4]<-fullhist[size,3]
    fullhist[size+1,5]<-fullhist[size,4]
    fullhist[size+1,6]<-fullhist[size,5]
    fullhist[size+1,7]<-fullhist[size,6]
    fullhist[size+1,8]<-newy-fullhist[1+size-step,16]
    fullhist[size+1,9]<-fullhist[size,8]
    fullhist[size+1,10]<-fullhist[size,9]
    fullhist[size+1,11]<-fullhist[size,10]
    fullhist[size+1,12]<-fullhist[size,11]
    fullhist[size+1,13]<-fullhist[size,12]
    fullhist[size+1,14]<-fullhist[size,13]
    fullhist[size+1,15]<-newx
    fullhist[size+1,16]<-newy

    #### Update the new current history
    for(i in 1:16)current[i]<-fullhist[size+1,i]
    #  Increase the size for the next forecast
    fullsize<-fullsize+1
  } ## ww loop

  ########################################################################
  #Close up plots
  # Last 10 Data points in black forecasts start in green and in red
  plot(data[(dlength-(10)):dlength,(1)],data[(dlength-(10)):dlength,(2)],col="black",pch=20,cex=.9,
       xlim=c(min(forecasts[1:num,1],data[(dlength-(10)):dlength,(1)]),
              max(forecasts[1:num,1],data[(dlength-(10)):dlength,(1)])),
       ylim=c(min(forecasts[1:num,2],data[(dlength-(10)):dlength,(2)]),
              max(forecasts[1:num,2],data[(dlength-(10)):dlength,(2)])),
       xlab="x",ylab="y")
  points(forecasts[1:num,1],forecasts[1:num,2],col="blue",cex=0.9)
  points(forecasts[1,1],forecasts[1,2],col="green",cex=0.9)
  points(forecasts[num,1],forecasts[num,2],col="red",cex=0.9)

  ##################################################################################

  #print the forecasted x and y values
  print("the X and y forecasts")
  print(forecasts)
}#end of CPA function
