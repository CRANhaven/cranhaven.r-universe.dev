# Stochastic Point Method
SI.SPM <- function(
    h,       # density h(x) to be integrated
    from,    # left end point of x
    to,      # right end point of x
    M,       # the upper bound of h(x) in [from,to]
    N        # the number of points to be generated
){
    if(length(from)!=length(to)){
        stop("Dimension not mathced!")
    }
    else{
        dimension <- length(from)
    }
    if(from>=to){
        return(list(0,0))
    }
    x <- matrix(runif(N * dimension, min = from, max = to), N, dimension, byrow = T)
    y <- runif(N, min = 0, max = M)
    hx <- h(x)
    if(length(hx)!=N){
        stop("Dimension of outputs of h(x) not mathced!")
    }
    else{
        dimension <- length(from)
    }
    p_hat <- mean(y<=hx)
    I <- p_hat * M * prod(to-from)
    Var <- I * (M * prod(to-from) - I) / N
    return(list(I,Var))
}


# Mean Value Method
SI.MVM <- function(
    h,       # density h(x) to be integrated
    from,    # left end point of x
    to,      # right end point of x
    N        # the number of points to be generated
){
    if(length(from)!=length(to)){
        stop("Dimension not mathced!")
    }
    else{
        dimension <- length(from)
    }
    if(any(from>=to)){
        return(list(0,0))
    }
    x <- matrix(runif(N * dimension, min = from, max = to), N, dimension, byrow = T)
    hx <- h(x)
    if(length(hx)!=N){
        stop("Dimension of outputs of h(x) not mathced!")
    }
    else{
        dimension <- length(from)
    }
    I <- prod(to-from) * mean(hx)
    Var <- mean(((to-from)*hx-I)^2)/N
    return(list(I,Var))
}


# Important Sampling Method
SI.ISM <- function(
    h,         # density h(x) to be integrated
    g,         # test density g(x)
    G_inv,     # inverse function of G(x)
    N,         # the number of points to be generated
    min_G = 0, # the min value of G(x)
    max_G = 1  # the max value of G(x)
){
    if(min_G>=max_G){
        return(list(0,0))
    }
    U <- runif(N,min_G,max_G)
    X <- G_inv(U)
    I <- mean(h(X)/g(X)*(max_G-min_G))
    Var <- mean((h(X)/g(X)*(max_G-min_G)-I)^2)/N
    return(list(I,Var))
}



# Stratified Sampling Method
SI.SSM <- function(
    h,       # density h(x) to be integrated
    from,    # left end point of x
    to,      # right end point of x
    level,   # the number of strata to be divided
    N        # the number of points to be generated
){
    if(any(from>=to)){
        return(list(0,0))
    }
    interval <- cbind(to,matrix(apply(c(1:level)%o% (to - from)/level,1,f<-function(x){x+to}),length(from),level))
    print(interval)
    I <- 0
    Var <- 0
    for (i in c(1:level)){
        MVMresult <- SI.MVM(h,interval[,i],interval[,i+1],as.integer(N/level))
        I <- I + MVMresult[[1]]
        Var <- Var + MVMresult[[2]]
    }
    return(list(I,Var))
}

