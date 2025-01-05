library(mvtnorm)
library(mnormt)

# This code is from the Appendix from Patrick Schlömers Dissertation:
#
# Schlömer, Patrick. 2014. “Group Sequential and Adaptive
# Designs for Three-Arm’gold Standard’non-Inferiority Trials.”
# PhD thesis, Universität Bremen. https://d-nb.info/1072225700/34.

# ################################################## #############################
# ############# #############
# ############# Calculation of the overall power in a single stage #############
# ############# three - arm non - inferiority trial #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- - mvtnorm #
# #
# REQUIRED FUNCTIONS : NONE #
# ------------------ #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the power to reject H_0, TP ^( s ) , the separate powers to reject #
# H_0, TC ^( n ) and H_0, CP ^( s ) and the overall power to reject all null #
# hypotheses.#
# #
# ################################################## #############################
ThreeArmSingleStagePower <- function (nT , nC ,nP , thetaTP , thetaTC , sigma , DeltaNI ,
                                      alpha , method = " approx " , H0CP = FALSE ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # nT | float | >0 | Sample size of the test group #
  # | | | #
  # nC | float | >0 | Sample size of the control group #
  # | | | #
  # nP | float | >0 | Sample size of the placebo group #
  # | | | #
  # thetaTP | float | | True treatment difference between #
  # | | | test and placebo group #
  # | | | #
  # thetaTC | float | | True treatment difference between #
  # | | | test and control group #
  # | | | #
  # sigma | float | >0 | Common standard deviation #
  # | | | #
  # DeltaNI | float | >0 | Non - inferiority margin #
  # | | | #
  # alpha | float | >0 & <1 | Separate significance level #
  # | | | #
  # method | string | " approx ", | Defines the method to calculate the #
  # | | " exact " | overall power : either approximative #
  # | | | by means of the normal distribution #
  # | | | ( DEFAULT ) exact with the t - distrib.#
  # | | | #
  # H0CP | logical | TRUE , | Defines if H_0, CP ^( s) also has to be #
  # | | FALSE | rejected ( TRUE ) or not ( FALSE ) , which #
  # | | | is the default value.Including #
  # | | | H_0, CP ^( s) is only allowed for #
  # | | | method =" approx ". #
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # PowerTP | float | >0 & <1 | Separate power to reject H_0, TP ^( s ) #
  # | | | #
  # PowerTC | float | >0 & <1 | Separate power to reject H_0, TC ^( n ) #
  # | | | #
  # PowerCP | float | >0 & <1 | Separate power to reject H_0, CP ^( s ) #
  # | | | #
  # Power | float | >0 & <1 | Overall power of the procedure #
  # | | | #
  # ################################################## #############################
  if ( method == " exact ") {
    # exact power using t - distribution
    # critical value
    crit <- qt ( p =1 - alpha , df = max ( round ( nT + nC +nP -3) ,1) )
    # separate power to reject H_0, TP ^( s)
    PowerTP <- 1- pt (q= crit , df = max ( round ( nT + nC + nP -3) ,1) ,
                      ncp = thetaTP / sigma * sqrt ( nT * nP /( nT + nP )))
    # separate power to reject H_0, TC ^( n)
    PowerTC <- 1- pt (q= crit , df = max ( round ( nT + nC + nP -3) ,1) ,
                      ncp =( thetaTC + DeltaNI ) / sigma * sqrt ( nT * nC /( nT + nC )) )
    # separate power to reject H_0, CP ^( s)
    PowerCP <- 1- pt (q= crit , df = max ( round ( nT + nC + nP -3) ,1) ,
                      ncp =( thetaTP - thetaTC ) / sigma * sqrt ( nC * nP /( nC + nP )) )
    # mean vector of test statistics
    theta <- c( thetaTP / sigma * sqrt ( nT * nP /( nT + nP )) ,
                ( thetaTC + DeltaNI )/ sigma * sqrt ( nT * nC / ( nT + nC )) )
    # covariance matrix of test statistics
    rho <- sqrt ( nC * nP / (( nT + nC ) *( nT + nP ) ))
    cov <- matrix ( data = c (1 , rho , rho ,1) , nrow =2 , ncol =2)
    # overall power to reject both null hypotheses
    Power <- sadmvt ( lower = c(- Inf ,- Inf ) , upper = c(- crit ,- crit ) , mean =- theta ,S= cov ,
                      df = max ( round ( nT + nC +nP -3) ,1) ) [1]
  } else if ( method == " approx ") {
    # approximative power using normal distribution
    # critical value
    crit <- qnorm ( p =1 - alpha )
    # separate power to reject H_0, TP ^( s )
    PowerTP <- pnorm ( q= thetaTP / sigma * sqrt ( nT * nP /( nT + nP )) - crit )
    # separate power to reject H_0, TC ^( s )
    PowerTC <- pnorm ( q =( thetaTC + DeltaNI ) / sigma * sqrt ( nT * nC /( nT + nC )) - crit )
    # separate power to reject H_0, CP ^( s )
    PowerCP <- pnorm ( q =( thetaTP - thetaTC ) / sigma * sqrt ( nC * nP /( nC + nP )) - crit )
    if ( H0CP == FALSE ) {
      # without H_0, CP ^( s)
      # mean vector of test statistics
      theta <- c ( thetaTP / sigma * sqrt ( nT * nP / ( nT + nP )) ,
                   ( thetaTC + DeltaNI )/ sigma * sqrt ( nT * nC / ( nT + nC ) ))
      # covariance matrix of test statistics
      rho <- sqrt ( nC * nP / (( nT + nC )* ( nT + nP ) ))
      cov <- matrix ( data =c (1 , rho , rho ,1) , nrow =2 , ncol =2)
      # overall power to reject both nullhypotheses
      Power <- sadmvn ( lower = rep (- Inf ,2) , upper = theta - rep ( crit ,2) , mean = rep (0 ,2) ,
                        varcov = cov ) [1]
    } else if ( H0CP == TRUE ) {
      # with H_0, CP ^( s)
      # mean vector of test statistics
      theta <- c ( thetaTP / sigma * sqrt ( nT * nP / ( nT + nP )) ,
                   ( thetaTC + DeltaNI )/ sigma * sqrt ( nT * nC / ( nT + nC ) ) ,
                   ( thetaTP - thetaTC )/ sigma * sqrt ( nC * nP / ( nC + nP ) ))
      # covariance matrix of test statistics
      rhoTPTC <- sqrt ( nC * nP / (( nT + nC )*( nT + nP )) )
      rhoTPCP <- sqrt ( nT * nC / (( nT + nP )*( nC + nP )) )
      rhoTCCP <- - sqrt ( nT * nP / (( nT + nC )* ( nC + nP ) ))
      cov <- matrix (c (1 , rhoTPTC , rhoTPCP , rhoTPTC ,1 , rhoTCCP , rhoTPCP , rhoTCCP ,1) ,3 ,3)
      # overall power to reject both nullhypotheses
      Power <- pmvnorm ( lower = rep (- Inf ,3) , upper = theta - rep ( crit ,3) , mean = rep (0 ,3) ,
                         sigma = cov , algorithm = TVPACK ( abseps =1e-6) ) [1]
    }
  }
  return ( list ( PowerTP = PowerTP , PowerTC = PowerTC , PowerCP = PowerCP , Power = Power ,theta=theta) )
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ) { #
  ThreeArmSingleStagePower ( nT =544 , nC =544 , nP =136 , thetaTP =0.4 , thetaTC =0 , #
                             sigma =1 , DeltaNI =0.2 , alpha =0.025) #
  # $ PowerTP #
  # [1] 0.9865279 #
  # #
  # $ PowerTC #
  # [1] 0.9096366 #
  # #
  # $ PowerCP #
  # [1] 0.9865279 #
  # #
  # $ Power #
  # [1] 0.9000693 #
} #
# ################################################## #############################
# ################################################## #############################
# ############# #############
# ############# Calculation of the required sample sizes for a #############
# ############# single stage three - arm non - inferiority trial #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- - mvtnorm #
# #
# REQUIRED FUNCTIONS : - ThreeArmSingleStagePower () #
# ------------------ #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the required sample sizes to obtain a specific overall power #
# 1- beta with prespecified allocation ratios cC = nC/nP and cP = nP/nT.#
# #
# ################################################## #############################
ThreeArmSingleStageDesign <- function ( thetaTP , thetaTC , sigma , DeltaNI , alpha , beta ,
                                        cC ,cP , method =" approx " , H0CP = FALSE ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # thetaTP | float | | True treatment difference between #
  # | | | test and placebo group #
  # | | | #
  # thetaTC | float | | True treatment difference between #
  # | | | test and control group #
  # | | | #
  # sigma | float | >0 | Common standard deviation #
  # | | | #
  # DeltaNI | float | >0 | Non - inferiority margin #
  # | | | #
  # alpha | float | >0 & <1 | Separate significance level #
  # | | | #
  # beta | float | >0 & <1 | Targeted type II error rate #
  # | | | #
  # cC | float | >0 | Relative size of the placebo group #
  # | | | ( cC = nC/nT ) #
  # | | | #
  # cP | float | >0 | Relative size of the control group #
  # | | | ( cP = nP/nT ) #
  # | | | #
  # method | string | " approx ", | Defines the method to calculate the #
  # | | " exact " | overall power : either approximative #
  # | | | by means of the normal distribution #
  # | | | ( DEFAULT ) exact with the t - distrib.#
  # | | | #
  # H0CP | logical | TRUE , | Defines if H_0, CP ^( s) also has be #
  # | | FALSE | rejected ( TRUE ) or not ( FALSE ) , which #
  # | | | is the default value.Including #
  # | | | H_0, CP ^( s) is only allowed for #
  # | | | method =" approx ". #
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # nT | float | >0 | Sample size of the test group #
  # | | | #
  # nC | float | >0 | Sample size of the control group #
  # | | | #
  # nP | float | >0 | Sample size of the placebo group #
  # | | | #
  # N | float | >0 | Overall sample size #
  # | | | #
  # | | | #
  # PowerTP | float | >0 & <1 | Separate power to reject H_0, TP ^( s ) #
  # | | | #
  # PowerTC | float | >0 & <1 | Separate power to reject H_0, TC ^( n ) #
  # | | | #
  # PowerCP | float | >0 & <1 | Separate power to reject H_0, CP ^( s ) #
  # | | | #
  # Power | float | >0 & <1 | Overall power of the procedure #
  # | | | #
  # ################################################## #############################
  # new environment
  func.env <- new.env ()
  # root finding function
  solvenT <- function ( nT ) {
    assign (" nT " ,nT , envir = func.env )
    assign (" nC " ,cC * nT , envir = func.env )
    assign (" nP " ,cP * nT , envir = func.env )
    assign (" Powers " , ThreeArmSingleStagePower ( nT = nT , nC = get ( " nC " , envir = func.env ) ,
                                                    nP = get (" nP " , envir = func.env ) ,
                                                    thetaTP = thetaTP , thetaTC = thetaTC ,
                                                    sigma = sigma , DeltaNI = DeltaNI ,
                                                    alpha = alpha ,
                                                    method = method ,
                                                    H0CP = H0CP ) , envir = func.env )
    return ( get (" Powers " , envir = func.env )$ Power -(1 - beta ) )
  }
  # determine required sample sizes & power
  opt <- uniroot ( solvenT , lower =1 , upper =1e6 )
  nT <- get (" nT " , envir = func.env )
  nC <- get (" nC " , envir = func.env )
  nP <- get (" nP " , envir = func.env )
  Powers <- get ( " Powers " , envir = func.env )
  return ( list ( nT =nT , nC = nC , nP =nP ,N = nT + nC + nP , PowerTP = Powers $ PowerTP ,
                  PowerTC = Powers $ PowerTC , PowerCP = Powers $ PowerCP , Power = Powers $ Power ))
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ){ #
  ThreeArmSingleStageDesign ( thetaTP =0.4 , thetaTC =0 , sigma =1 , DeltaNI =0.2 , #
                              alpha =0.025 , beta =0.1 , cC =1 , cP =0.25) #
  # $nT #
  # [1] 543.8802 #
  # #
  # $nC #
  # [1] 543.8802 #
  # #
  # $nP #
  # [1] 135.97 #
  # #
  # $N #
  # [1] 1223.73 #
  # #
  # $ PowerTP #
  # [1] 0.986512 #
  # #
  # $ PowerTC #
  # [1] 0.9095774 #
  # #
  # $ PowerCP #
  # [1] 0.986512 #
  # #
  # $ Power #
  # [1] 0.9 #
} #
# ################################################## #############################

# ################################################## #############################
# ############# #############
# ############# Calculation of the optimal sample sizes for a #############
# ############# single stage three - arm non - inferiority trial #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- - mvtnorm #
# #
# REQUIRED FUNCTIONS : - ThreeArmSingleStagePower () #
# ------------------ - ThreeArmSingleStageDesign () #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the optimal sample sizes to obtain a specific overall power #
# 1- beta that minimise the overall sample size.#
# #
# ################################################## #############################
ThreeArmSingleStageOptDesign <- function ( thetaTP , thetaTC , sigma , DeltaNI , alpha ,
                                           beta , H0CP = FALSE ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # thetaTP | float | | True treatment difference between #
  # | | | test and placebo group #
  # | | | #
  # thetaTC | float | | True treatment difference between #
  # | | | test and control group #
  # | | | #
  # sigma | float | >0 | Common standard deviation #
  # | | | #
  # DeltaNI | float | >0 | Non - inferiority margin #
  # | | | #
  # alpha | float | >0 & <1 | Separate significance level #
  # | | | #
  # beta | float | >0 & <1 | Targeted type II error rate #
  # | | | #
  # H0CP | logical | TRUE , | Defines if H_0, CP ^( s) also has be #
  # | | FALSE | rejected ( TRUE ) or not ( FALSE ) , which #

  # | | | is the default value.#
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # nT | float | >0 | Sample size of the test group #
  # | | | #
  # nC | float | >0 | Sample size of the control group #
  # | | | #
  # nP | float | >0 | Sample size of the placebo group #
  # | | | #
  # N | float | >0 | Overall sample size #
  # | | | #
  # PowerTP | float | >0 & <1 | Separate power to reject H_0, TP ^( s) #
  # | | | #
  # PowerTC | float | >0 & <1 | Separate power to reject H_0, TC ^( n) #
  # | | | #
  # PowerCP | float | >0 & <1 | Separate power to reject H_0, CP ^( s) #
  # | | | #
  # Power | float | >0 & <1 | Overall power of the procedure #
  # | | | #
  # ################################################## #############################
  # optimisation function
  optAlloc <- function ( c) {
    cC <- c [1]
    cP <- c [2]
    optDesign <- ThreeArmSingleStageDesign ( thetaTP = thetaTP , thetaTC = thetaTC ,
                                               sigma = sigma , DeltaNI = DeltaNI ,
                                               alpha = alpha , beta = beta , cC = cC , cP =cP ,
                                               H0CP = H0CP )
    return ( optDesign$N)
  }
  # find optimal design
  optDesign <- optim (c (0.5 ,0.5) , optAlloc , lower = rep (0.01 ,2) , upper = c (3 ,3) , method = "L-BFGS-B" )
  return ( optDesign )
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ) { #
  ThreeArmSingleStageOptDesign ( thetaTP =0.4 , thetaTC =0 , sigma =1 , DeltaNI =0.2 , #
                                 alpha =0.025 , beta =0.1) #
  # $nT #
  # [1] 546.2521 #
  # #

  # $nC #
  # [1] 533.5604 #
  # #
  # $nP #
  # [1] 142.6462 #
  # #
  # $N #
  # [1] 1222.459 #
  # #
  # $ PowerTP #
  # [1] 0.989109 #
  # #
  # $ PowerTC #
  # [1] 0.9075568 #
  # #
  # $ PowerCP #
  # [1] 0.9888057 #
  # #
  # $ Power #
  # [1] 0.9 #
} #
# ################################################## #############################

# ################################################## #############################
# ############# #############
# ############# Calculation of the group sequential boundaries #############
# ############# according to Wang & Tsiatis (1987) #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- #
# #
# REQUIRED FUNCTIONS : NONE #
# ------------------ #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the group sequential rejection boundaries for the Delta - class #
# proposed by Wang & Tsiatis (1987).Equal stage sizes are assumed.#
# #
# ################################################## #############################
WangTsiatis <- function (K , alpha , Delta ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # K | float | >1 | Number of stages #
  # | | | #
  # alpha | float | >0 & <1 | Significance level #
  # | | | #
  # Delta | float | | Parameter defining the shape of the #
  # | | | rejection boundaries.Delta =- Inf #
  # | | | returns the boundary values of the #
  # | | | common single stage design.#
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#

  # | | | #
  # bounds | Kx1 vector | | Stage - wise rejection boundaries #
  # | ( floats ) | | #
  # | | | #
  # ################################################## #############################
  # new environment
  func.env <- new.env ()
  if ( Delta == - Inf ) {
    # Delta == - Inf returns the boundaries of the common single stage design
    assign (" bounds " ,c( rep ( Inf ,K -1) , qnorm (1 - alpha )) , envir = func.env )
  } else {
    # covariance matrix of the test statistics ( equal stage sizes !)
    cov <- sapply (1: K , function ( j)
      sapply (1: K , function (i ,j) sqrt ( min (i , j) / max (i , j)) , j= j ))
    # funtion to solve for bWT
    solvebWT <- function ( bWT ) {
      assign (" bounds " ,(1: K/ K) ^( Delta -1 / 2) * bWT , envir = func.env )
      typeIerror <- 1- sadmvn ( lower = rep (- Inf ,K) , upper = get (" bounds " , envir = func.env ) ,
                                mean = rep (0 , K ) , varcov = cov ) [1]
      return ( typeIerror - alpha )
    }
    # determine boundaries
    uniroot ( solvebWT , lower =1e-10 , upper =1e10 )
  }
  return ( get (" bounds " , envir = func.env ))
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ) { #
  WangTsiatis ( K =3 , alpha =0.025 , Delta =0) #
  # [1] 3.471086 2.454429 2.004033 #
} #
# ################################################## #############################
# ################################################## #############################
# ############# #############
# ############# Calculation of the error spending function proposed #############
# ############# by Kim & DeMets (1987) #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- #
# #
# REQUIRED FUNCTIONS : NONE #
# ------------------ #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the error spending function proposed by Kim & DeMets (1987) with #
# shape parameter rho.#
# #
# ################################################## #############################
KD <- function (t , spendpar , alpha ){
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # t | float | | Time parameter #
  # | | | #
  # spendpar | float | >0 | Parameter defining the shape of the #
  # | | | spending function #
  # | | | #
  # alpha | float | >0 & <1 | Significance level #
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # f | float | >=0 | Cumulative type I error spent at #
  # | | <= alpha | time t #
  # | | | #
  # ################################################## #############################
  if (t <=0) {
    f <- 0
  } else if (t >0 && t <1) {
    f <- alpha * t^ spendpar
  } else {
    f <- alpha
  }
  return (f )
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ) { #
  KD ( t =0.5 , spendpar =1 , alpha =0.025) #
  # [1] 0.0125 #
} #
# ################################################## #############################
# ################################################## #############################
# ############# #############
# ############# Calculation of the error spending function proposed #############
# ############# by Hwang , Shih & DeCani (1990) #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- #
# #
# REQUIRED FUNCTIONS : NONE #
# ------------------ #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the error spending function proposed by Hwang , Shih & DeCani #
# (1990) with shape parameter gamma.#
# #
# ################################################## #############################
HSD <- function (t , spendpar , alpha ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # t | float | | Time parameter #
  # | | | #
  # spendpar | float | >0 | Parameter defining the shape of the #
  # | | | spending function #
  # | | | #
  # alpha | float | >0 & <1 | Significance level #
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # f | float | >=0 | Cumulative type I error spent at #
  # | | <= alpha | time t #
  # | | | #
  # ################################################## #############################
  if (t <=0) {
    f <- 0
  } else if (t >0 && t <1) {
    if ( spendpar ==0) {
      f <- alpha * t
    } else {
      f <- alpha * (1 - exp (- spendpar * t) )/ (1 - exp (- spendpar ) )
    }
  } else {
    f <- alpha
  }
  return (f )
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ) { #
  HSD (t =0.5 , spendpar =1 , alpha =0.025) #
  # [1] 0.01556148 #
} #
# ################################################## #############################
# ################################################## #############################
# ############# #############
# ############# Calculation of the group sequential boundaries for #############
# ############# error spending designs #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- #
# #
# REQUIRED FUNCTIONS : - KD () #
# ------------------ - HSD () #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the group sequential rejection boundaries for the rho - and gamma - #
# class of error spending designs proposed by Kim & DeMets (1987) and Hwang , #
# Shih & DeCani (1990) , respectively.Equal stage sizes are assumed.#
# #
# ################################################## #############################
ErrorSpending <- function (K , alpha , spendfunc , spendpar ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # K | float | >1 | Number of stages #
  # | | | #
  # alpha | float | >0 & <1 | Significance level #
  # | | | #
  # spendfunc | function | KD , HSD | Defines the family of error spending #
  # | | | functions ( KD = Kim & DeMets , HSD = #
  # | | | Hwang , Shih & DeCani ) #
  # | | | #
  # spendpar | float | KD : >0 | Parameter defining the shape of the #
  # | | | spending function.spendpar = Inf for #
  # | | | KD designs and spendpar =- Inf for HSD #
  # | | | designs return the boundary values #
  # | | | of the common single stage design , #
  # | | | i .e. Inf at stages 1 ,... , K -1 and #
  # | | | qnorm (1 - alpha ) at stage K.#
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # bounds | Kx1 vector | | Stage - wise rejection boundaries #
  # | ( floats ) | | #
  # | | | #
  # ################################################## #############################
  # new environment
  func.env <- new.env ()
  if ( as.character ( substitute ( spendfunc )) == " KD " & spendpar == Inf ) {
    # for KD designs with spendpar == Inf , return single stage design
    assign (" bounds " ,c( rep ( Inf ,K -1) , qnorm (1 - alpha )) , envir = func.env )
  } else if ( as.character ( substitute ( spendfunc )) == " HSD " & spendpar == - Inf ) {
    # for HSD designs with spendpar == - Inf , return single stage design
    assign (" bounds " ,c( rep ( Inf ,K -1) , qnorm (1 - alpha )) , envir = func.env )
  } else {
    # covariance matrix of the test statistics ( equal stage sizes !)
    cov <- sapply (1: K , function ( j)
      sapply (1: K , function (i ,j)
        sqrt ( min (i ,j) / max (i , j) ) ,j =j ))
    # calculate boundaries
    calcbounds <- function ( k) {
      if ( k ==1) {
        pk <- spendfunc (1 /K , spendpar = spendpar , alpha = alpha )
        assign ( " bounds " , qnorm (1 - pk ) , envir = func.env )
      } else {
        solvebk <- function ( bk ) {
          k <- length ( get (" bounds " , envir = func.env ) ) +1
          pk <- spendfunc (k /K , spendpar = spendpar , alpha = alpha ) -
            spendfunc ((k -1) /K , spendpar = spendpar , alpha = alpha )
          prob <- sadmvn ( lower = c( rep (- Inf ,k -1) ,bk ) ,
                           upper = c( get (" bounds " , envir = func.env ) , Inf ) ,
                           mean = rep (0 , k) , varcov = cov [1: k ,1: k ]) [1]
          return ( prob - pk )
        }
        assign ( " bounds " ,
                 c( get (" bounds " , envir = func.env ) ,
                    uniroot ( solvebk , lower =1e-10 , upper =1e10 )$ root ) , envir = func.env )
      }
    }
    sapply (1: K , calcbounds )
  }
  return ( get (" bounds " , envir = func.env ))
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ){ #
  ErrorSpending ( K =3 , alpha =0.025 , spendfunc = KD , spendpar =1) #
  # [1] 2.393980 2.293769 2.199902 #
} #
# ################################################## #############################

# ################################################## #############################
# ############# #############
# ############# Calculation of the overall power of a group #############
# ############# sequential three - arm non - inferiority design #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- #
# #
# REQUIRED FUNCTIONS : NONE #
# ------------------ #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the power to reject H_0, TP ^( s) and the overall power to reject #
# both null hypotheses.#
# #
# ################################################## #############################
ThreeArmGroupSeqPower <- function (K , nT ,nC ,nP , thetaTP , thetaTC , sigma , DeltaNI ,
                                   bTP , bTC ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # K | integer | >1 | Number of stages #
  # | | | #
  # nT | Kx1 vector | >0 | Cumulative sample sizes of the test #
  # | ( floats ) | | group #
  # | | | #
  # nC | Kx1 vector | >0 | Cumulative sample sizes of the #
  # | ( floats ) | | control group #
  # | | | #
  # nP | Kx1 vector | >0 | Cumulative sample sizes of the #
  # | ( floats ) | | placebo group #
  # | | | #
  # thetaTP | float | | True treatment difference between #
  # | | | test and placebo group #
  # | | | #
  # thetaTC | float | | True treatment difference between #
  # | | | test and control group #

  # | | | #
  # sigma | float | >0 | Common standard deviation #
  # | | | #
  # DeltaNI | float | >0 | Non - inferiority margin #
  # | | | #
  # bTP | Kx1 vector | | Stage - wise rejection boundaries for #
  # | ( floats ) | | H_0, TP ^( s ) #
  # | | | #
  # bTC | Kx1 vector | | Stage - wise rejection boundaries for #
  # | ( floats ) | | H_0, TC ^( n ) #
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # PowerTP | float | >0 & <1 | Power to reject H_0, TP ^( s ) #
  # | | | #
  # Power | float | >0 & <1 | Overall power of the procedure #
  # | | | #
  # ################################################## #############################
  # fisher informations of the test statistics :
  I_TP <- ( sigma ^2 * (1 / nT +1 / nP ) ) ^ -1
  I_TC <- ( sigma ^2 * (1 / nT +1 / nC ) ) ^ -1
  # covariance matrix of the vector (Z_TP ^(1) ,.. , Z_TP ^( K) ,Z_TC ^(1) ,.. , Z_TC ^( K) ) ’
  covTP <- sapply (1: K , function (j)
    sapply (1: K , function (i ,j )
      sqrt ( I_TP [ min (i ,j )] /I_TP [ max (i , j) ]) ,j= j))
  covTC <- sapply (1: K , function (j)
    sapply (1: K , function (i ,j )
      sqrt ( I_TC [ min (i ,j )] /I_TC [ max (i , j) ]) ,j= j))
  covTCP <- sapply (1: K , function (j )
    sapply (1: K , function (i , j)
      sigma ^2 / nT [ max (i ,j )] * sqrt (I_TP [i ]*I_TC [j ]) ,j =j) )
  cov <- rbind ( cbind ( covTP , covTCP ) , cbind (t ( covTCP ) , covTC ) )
  # power to reject H_0, TP ^( s)
  PowerTP <- 1- sadmvn ( lower = rep (- Inf ,K ) , upper = bTP - thetaTP * sqrt (I_TP ) ,
                         mean = rep (0 , K) , varcov = covTP ) [1]
  # probabilities P(A_k ) , 1 <=k <= K ( A_k = H_0, TP ^( s ) rejected at stage k and
  # H_0, TC ^( n) is not rejected at stages k ,... , K)
  CalcProbAk <- function (k ){
    if (k ==1) {
      # k =1
      ProbAk <- sadmvn ( lower =c ( bTP [1] - thetaTP * sqrt (I_TP [1]) ,rep (- Inf , K) ) ,
                         upper =c ( Inf , bTC [1: K ] -( thetaTC + DeltaNI )* sqrt (I_TC [1: K]) ) ,
                         mean = rep (0 , K +1) ,
                         varcov = cov [ -(2: K) , -(2: K) ]) [1]
    } else {
      # 2 <=k <= K
      lower <- rep (- Inf , K +1)
      lower [ k] <- bTP [ k]- thetaTP * sqrt ( I_TP [ k ])
      upper <- c( bTP [1:( k -1) ]- thetaTP * sqrt ( I_TP [1:( k -1) ]) ,Inf ,
                  bTC [k :K ] -( thetaTC + DeltaNI ) * sqrt (I_TC [k :K ]) )
      varcov <- cov [ -(( k +1) :( K+k -1) ) , -(( k +1) :( K+k -1) ) ]
      ProbAk <- sadmvn ( lower = lower , upper = upper , mean = rep (0 , K +1) , varcov = varcov ) [1]
    }
    return ( ProbAk )
  }
  # overall power
  Power <- PowerTP - sum ( sapply (1: K , CalcProbAk ))
  return ( list ( PowerTP = PowerTP , Power = Power ))
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ) { #
  ThreeArmGroupSeqPower ( K =3 , nT = cumsum ( rep (188 ,3) ) ,nC = cumsum ( rep (188 ,3) ) , #
                          nP = cumsum ( rep (47 ,3) ) , thetaTP =0.4 , thetaTC =0 , sigma =1 , #
                          DeltaNI =0.2 , bTP = c (2.741 ,2.305 ,2.083) , #
                          bTC =c (3.471 ,2.454 ,2.004) ) #
  # $ PowerTP #
  # [1] 0.9861338 #
  # #
  # $ Power #
  # [1] 0.9047309 #
} #
# ################################################## #############################
# ################################################## #############################
# ############# #############
# ############# Calculation of the required sample size for a group #############
# ############# sequential three - arm non - inferiority design #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- #
# #
# REQUIRED FUNCTIONS : - WangTsiatis () #
# ------------------ - KD () #
# - HSD () #
# - ErrorSpending () #
# - ThreeArmGroupSeqPower () #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the required sample sizes to obtain a specific overall power #
# 1- beta with prespecified allocation ratios cC = nC/nP and cP = nP/nT.Equal #
# stage sizes are assumed , i .e.nD ^( k) =k/K*nD ^( K) for D=T ,C ,P. #
# #
# ################################################## #############################
ThreeArmGroupSeqDesign <- function (K , thetaTP , thetaTC , sigma , DeltaNI , alpha , beta ,
                                    cC , cP , type , parTP , parTC ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # K | integer | >1 | Number of stages #
  # | | | #
  # thetaTP | float | | True treatment difference between #
  # | | | test and placebo group #
  # | | | #
  # thetaTC | float | | True treatment difference between #
  # | | | test and control group #
  # | | | #
  # sigma | float | >0 | Common standard deviation #
  # | | | #
  # DeltaNI | float | >0 | Non - inferiority margin #
  # | | | #
  # alpha | float | >0 & <1 | Separate significance level #
  # | | | #
  # beta | float | >0 & <1 | Targeted type II error rate #
  # | | | #
  # cC | float | >0 | Relative size of the placebo group #
  # | | | ( cC = nC/nT ) #
  # | | | #
  # cP | float | >0 | Relative size of the control group #
  # | | | ( cP = nP/nT ) #
  # | | | #
  # type | string | " WT " ," KD " ,| Defines the type of the rejection #
  # | | " HSD " | boundaries that are calulated (" WT "= #
  # | | | Wang Tsiatis , " KD "= Kim & DeMets #
  # | | | error spending , " HSD "= Hwang , Shih & #
  # | | | DeCani error spending ) #
  # | | | #
  # parTP | float | type =" KD ":| Parameter that defines the rejection #
  # | | >0 | boundaries for H_0, TP ^( s ) #
  # | | | #
  # parTC | float | type =" KD ":| Parameter that defines the rejection #
  # | | >0 | boundaries for H_0, TC ^( n ) #
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # bTP | Kx1 vector | | Stage - wise rejection boundaries for #
  # | ( floats ) | | H_0, TP ^( s) #
  # | | | #
  # bTC | Kx1 vector | | Stage - wise rejection boundaries for #
  # | ( floats ) | | H_0, TC ^( n) #
  # | | | #
  # nT | Kx1 vector | >0 | Cumulative sample sizes of the test #
  # | ( floats ) | | group #
  # | | | #
  # nC | Kx1 vector | >0 | Cumulative sample sizes of the #
  # | ( floats ) | | control group #
  # | | | #
  # nP | Kx1 vector | >0 | Cumulative sample sizes of the #
  # | ( floats ) | | placebo group #
  # | | | #
  # N | Kx1 vector | >0 | Cumulative overall sample sizes #
  # | ( floats ) | | #
  # | | | #
  # PowerTP | float | >0 & <1 | Power to reject H_0, TP ^( s) #
  # | | | #
  # Power | float | >0 & <1 | Overall power of the procedure #
  # | | | #
  # ################################################## #############################
  # new environment
  func.env <- new.env ()
  # rejection boundaries
  if ( type == "WT" ) {
    bTP <- WangTsiatis ( K=K , alpha = alpha , Delta = parTP )
    bTC <- WangTsiatis ( K=K , alpha = alpha , Delta = parTC )
  } else if ( type == "KD" ) {
    bTP <- ErrorSpending (K =K , alpha = alpha , spendfunc =KD , spendpar = parTP )
    bTC <- ErrorSpending (K =K , alpha = alpha , spendfunc =KD , spendpar = parTC )
  } else if ( type == "HSD") {
    bTP <- ErrorSpending (K =K , alpha = alpha , spendfunc = HSD , spendpar = parTP )
    bTC <- ErrorSpending (K =K , alpha = alpha , spendfunc = HSD , spendpar = parTC )
  }
  # root finding function
  solvenTK <- function ( nTK ) {
    assign ( " nT " ,1: K/K * nTK , envir = func.env )
    assign ( " nC " ,cC * 1: K/ K* nTK , envir = func.env )
    assign ( " nP " ,cP * 1: K/ K* nTK , envir = func.env )
    assign ( " Powers " , ThreeArmGroupSeqPower ( K=K , nT = get (" nT " , envir = func.env ) ,
                                                  nC = get (" nC " , envir = func.env ) ,
                                                  nP = get (" nP " , envir = func.env ) ,
                                                  thetaTP = thetaTP , thetaTC = thetaTC ,
                                                  sigma = sigma , DeltaNI = DeltaNI ,
                                                  bTP = bTP , bTC = bTC ) , envir = func.env )
    return ( get (" Powers " , envir = func.env )$ Power -(1 - beta ) )
  }
  # determine required sample sizes & power
  uniroot ( solvenTK , lower =1 , upper =1e6 )
  nT <- get (" nT " , envir = func.env )
  nC <- get (" nC " , envir = func.env )
  nP <- get (" nP " , envir = func.env )
  Powers <- get ( " Powers " , envir = func.env )
  return ( list ( bTP = bTP , bTC = bTC , nT = nT , nC =nC , nP = nP ,N= nT + nC +nP ,
                  PowerTP = Powers $ PowerTP , Power = Powers $ Power ))
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ){ #
  ThreeArmGroupSeqDesign ( K =3 , thetaTP =0.4 , thetaTC =0 , sigma =1 , DeltaNI =0.2 , #
                           alpha =0.025 , beta =0.1 , cC =1 , cP =0.25 , type = " WT " , parTP =0.25 , #
                           parTC =0) #
  # $ bTP #
  # [1] 2.741137 2.305013 2.082814 #
  # #
  # $ bTC #
  # [1] 3.471086 2.454429 2.004033 #
  # #
  # $nT #
  # [1] 185.2007 370.4013 555.6020 #
  # #
  # $nC #
  # [1] 185.2007 370.4013 555.6020 #
  # #
  # $nP #
  # [1] 46.30016 92.60033 138.90049 #
  # #
  # $N #
  # [1] 416.7015 833.4029 1250.1044 #
  # #
  # $ PowerTP #
  # [1] 0.9849846 #
  # #
  # $ Power #
  # [1] 0.9 #
} #
# ################################################## #############################

# ################################################## #############################
# ############# #############
# ############# Calculation of the expected sample size for a group #############
# ############# sequential three - arm non - inferiority design #############
# ############# #############
# ################################################## #############################
# #
# Author : Patrick Schlömer #
# Last update : 13/ May/ 2014 #
# #
# ################################################## #############################
# #
# REQUIRED PACKAGES : - mnormt #
# ----------------- #
# #
# REQUIRED FUNCTIONS : NONE #
# ------------------ #
# #
# ################################################## #############################
# #
# THIS FUNCTION : #
# -------------- #
# Calculates the expected sample sizes of a group sequential three - arm #
# non - inferiority design at a specific alternative thetaTP and thetaTC.#
# #
# ################################################## #############################
ThreeArmGroupSeqASN <- function (K ,nT ,nC , nP , thetaTP , thetaTC , sigma , DeltaNI ,
                                 bTP , bTC ) {
  # ################################################## #############################
  # #
  # INPUT - PARAMETERS : #
  # ----------------- #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # K | integer | >1 | Number of stages #
  # | | | #
  # nT | Kx1 vector | >0 | Cumulative sample sizes of the test #
  # | ( floats ) | | group #
  # | | | #
  # nC | Kx1 vector | >0 | Cumulative sample sizes of the #
  # | ( floats ) | | control group #
  # | | | #
  # nP | Kx1 vector | >0 | Cumulative sample sizes of the #
  # | ( floats ) | | placebo group #
  # | | | #
  # thetaTP | float | | Treatment difference between test and #
  # | | | placebo for which ASN is calculated #
  # | | | #
  # thetaTC | float | | Treatment difference between test and #
  # | | | control for which ASN is calculated #

  # | | | #
  # sigma | float | >0 | Common standard deviation #
  # | | | #
  # DeltaNI | float | >0 | Non - inferiority margin #
  # | | | #
  # bTP | Kx1 vector | | Stage - wise rejection boundaries for #
  # | ( floats ) | | H_0, TP ^( s) #
  # | | | #
  # bTC | Kx1 vector | | Stage - wise rejection boundaries for #
  # | ( floats ) | | H_0, TC ^( n) #
  # | | | #
  # -------------------------------------------------- --------------------------- #
  # #
  # OUTPUT - PARAMETERS : #
  # ------------------ #
  #______________________________________________________________________________#
  # | | | #
  # VARIABLE | FORMAT | RANGE | DESCRIPTION #
  #_____________|____________|___________|_______________________________________#
  # | | | #
  # ASnP | float | >0 | Expected placebo group size #
  # | | | #
  # ASN | float | >0 | Expected overall sample size #
  # | | | #
  # ################################################## #############################
  # fisher informations of the test statistics :
  I_TP <- ( sigma ^2 * (1 / nT +1 / nP )) ^ -1
  I_TC <- ( sigma ^2 * (1 / nT +1 / nC )) ^ -1
  # covariance matrix of the vector (Z_TP ^(1) ,.. , Z_TP ^( K) ,Z_TC ^(1) ,.. , Z_TC ^( K )) ’
  covTP <- sapply (1: K , function ( j)
    sapply (1: K , function (i ,j)
      sqrt ( I_TP [ min (i ,j )]/ I_TP [ max (i ,j ) ]) ,j =j ))
  covTC <- sapply (1: K , function ( j)
    sapply (1: K , function (i ,j)
      sqrt ( I_TC [ min (i ,j )]/ I_TC [ max (i ,j ) ]) ,j =j ))
  covTCP <- sapply (1: K , function (j)
    sapply (1: K , function (i ,j )
      sigma ^2 / nT [ max (i ,j) ]* sqrt ( I_TP [ i] *I_TC [j ]) ,j= j))
  cov <- rbind ( cbind ( covTP , covTCP ) , cbind ( t( covTCP ) , covTC ))
  # probabilities P (E_k1 ,k) , 2 <=k <=K , 0 <= k1 <=k -1
  CalcProbEk1k <- function ( k1 ,k ){
    if ( k1 ==0) {
      # no rejection of H_0, TP ^( s)
      ProbEk1k <- sadmvn ( lower = rep (- Inf ,k -1) ,
                           upper = bTP [1:( k -1) ]- thetaTP * sqrt (I_TP [1:( k -1) ]) ,
                           mean = rep (0 ,k -1) , varcov = covTP [ -( k: K) ,-( k: K) ]) [1]
    } else if ( k1 ==1) {
      # rejection of H_0, TP ^( s) at the first stage
      ProbEk1k <- sadmvn ( lower = c( bTP [1] - thetaTP * sqrt ( I_TP [1]) , rep (- Inf ,k -1) ) ,
                           upper = c( Inf , bTC [1:( k -1) ]-
                                        ( thetaTC + DeltaNI )* sqrt ( I_TC [1:( k -1) ]) ) ,
                           mean = rep (0 , k) ,
                           varcov = cov [- c (2: K ,( K+ k) :(2 *K )) ,-c (2: K ,( K +k ) :(2 * K) ) ])

    } else {
      # rejection of H_0, TP ^( s ) at stage k1 , 2 <= k1 <=k -1
      lower <- rep (- Inf ,k)
      lower [ k1 ] <- bTP [ k1 ]- thetaTP * sqrt ( I_TP [ k1 ])
      upper <- c ( bTP [1:( k1 -1) ]- thetaTP * sqrt (I_TP [1:( k1 -1) ]) ,Inf ,
                   bTC [ k1 :( k -1) ] -( thetaTC + DeltaNI )* sqrt ( I_TC [ k1 :( k -1) ]))
      varcov <- cov [- c (( k1 +1) :( K+ k1 -1) ,( K+ k) :(2 *K) ) ,
                     -c (( k1 +1) :( K+ k1 -1) ,( K+ k) :(2 *K) )]
      ProbEk1k <- sadmvn ( lower = lower , upper = upper , mean = rep (0 ,k) , varcov = varcov ) [1]
    }
    return ( ProbEk1k )
  }
  # probabilities P(E_k ) , 2 <=k <= K
  CalcProbEk <- function (k ){
    sum ( sapply (0:( k -1) , CalcProbEk1k ,k= k) )
  }
  # average sample number of the test and control group
  ASnT <- nT [1] + sum (( nT [2: K]- nT [1:( K -1) ]) * sapply (2: K , CalcProbEk ) )
  ASnC <- nC [1] + sum (( nC [2: K]- nC [1:( K -1) ]) * sapply (2: K , CalcProbEk ) )
  # average sample number of placebo group
  ASnP <- nP [1] + sum (( nP [2: K]- nP [1:( K -1) ]) * sapply (2: K , CalcProbEk1k , k1 =0) )
  # overall average sample number
  ASN <- ASnT + ASnC + ASnP
  return ( list ( ASnT = ASnT , ASnC = ASnC , ASnP = ASnP , ASN = ASN ) )
}
# ################################################## #############################
# EXAMPLE : #
# -------- #
if ( FALSE ){ #
  ThreeArmGroupSeqASN (K =3 , nT = cumsum ( rep (188 ,3) ) , nC = cumsum ( rep (188 ,3) ) , #
                       nP = cumsum ( rep (47 ,3) ) , thetaTP =0.4 , thetaTC =0 , sigma =1 , #
                       DeltaNI =0.2 , bTP =c (2.741 ,2.305 ,2.083) , #
                       bTC =c (3.471 ,2.454 ,2.004) ) #
  # $ ASnT #
  # [1] 450.0797 #
  # #
  # $ ASnC #
  # [1] 450.0797 #
  # #
  # $ ASnP #
  # [1] 81.42504 #
  # #
  # $ ASN #
  # [1] 981.5844 #
} #
# ################################################## #############################[1]
