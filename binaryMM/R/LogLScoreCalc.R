LogLScoreCalc <-
  function( params, subjectData, ParamLengths,
            EmpiricalCheeseCalc = FALSE, Q, W, Z, AdaptiveQuad=FALSE){

    betaM <- params[1:ParamLengths[1]]
    gamma <- params[ (ParamLengths[1]+1): (ParamLengths[1]+ParamLengths[2]) ]
    sigma <- exp(params[(ParamLengths[1]+ParamLengths[2]+1): (ParamLengths[1]+ParamLengths[2]+ParamLengths[3])])

    .Call("LogLScoreCalc_CALL", betaM, gamma, sigma, subjectData,
          EmpiricalCheeseCalc, Q, W, Z,  AdaptiveQuad)
  }
