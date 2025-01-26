dea.gem <-
function(base, noutput, fixed = NULL, rts = 2, bound = NULL, 
                    add.model = c('additive', 'RAM', 'BAM', 'MIP', 'LovPast'), 
                    whichDMUs = NULL, print.status = FALSE) {

  s <- noutput
  m <- ncol(base) - s
  n <- nrow(base)
  
  ifelse(!is.null(whichDMUs), nn <- length(whichDMUs), nn <- n)
  if (is.null(whichDMUs)) {
    whichDMUs <- 1:n
  }
  re <- data.frame(matrix(0, nrow = nn, ncol = 1 + n + s + m))
  names(re) <- c("eff", paste("lambda", 1:n, sep  = ""), 
    paste("slack.y", 1:s, sep  = ""), paste("slack.x", 1:m, sep  = ""))
  
  lpmodel <- make.lp(nrow = 0, ncol = n + s + m)
  slacks <- diag(s + m)
  slacks[1:s, ] <- -slacks[1:s, ]
  type <- rep("=", s + m)
  if (!is.null(fixed)) {
    slacks[, fixed] <- 0
    type[fixed[fixed <= s]] <- ">="
    type[fixed[fixed > s]] <- "<="
  }
  A <- cbind(t(base), slacks)
  for (i in 1:(s + m)) {
    add.constraint(lpmodel, xt = A[i, ], type = type[i], rhs = 0)
  }
  
  if (add.model == 'BAM') {
    Uo <- t(apply(data.frame(base[, 1:s]), 2, max) - t(base[, 1:s]))
    Li <- t(t(base[, (s + 1):(s + m)]) - 
      apply(data.frame(base[, (s + 1):(s + m)]), 2, min))
    if (!is.null(bound) & rts == 1) {
      index1 <- which(colSums(bound) == 0)
      bound[, index1] <- data.frame(Uo, Li)[, index1]
      if (!is.null(fixed)) {
        bound[fixed] <- 0
      }
    }
    if (is.null(bound) & rts == 1) {
      bound <- data.frame(Uo, Li)
      if (!is.null(fixed)) {
        bound[fixed] <- 0
      }
    }
  }
  if (add.model == 'RAM') {
    Ro <- apply(data.frame(base[, 1:s]), 2, max) - 
      apply(data.frame(base[, 1:s]), 2, min)
    Ri <- apply(data.frame(base[, (s + 1):(s + m)]), 2, max) - 
      apply(data.frame(base[, (s + 1):(s + m)]), 2, min)
    if (!is.null(bound) & rts == 1) {
      index1 <- which(colSums(bound) == 0)
      bound[, index1] <- t(as.data.frame(matrix(c(Ro, Ri), nrow = s + m, 
        ncol = nrow(base))))[, index1]
      if (!is.null(fixed)) {
        bound[fixed] <- 0
      }
    }
    if (is.null(bound) & rts == 1) {
      bound <- t(as.data.frame(matrix(c(Ro, Ri), 
        nrow = s + m, ncol = nrow(base))))
      if (!is.null(fixed)) {
        bound[fixed] <- 0
      }
    }
  }

  if (!is.null(bound)) {
    index <- which(colSums(bound) !=0)
    nrows <- length(index)
    A.bound <- matrix(0, nrow = nrows, ncol = n + s + m)
    k <- 0
    for (i in index) {
      k <- k + 1
      A.bound[k, n + index[k]] <- 1
    }
    A <- rbind(A, A.bound)
    for (i in 1:k) {
      add.constraint(lpmodel, xt = A[s + m + i, ], type = "<=", rhs = 0)
    }
  }
  
  syx <- rep(-1, s + m)
  syx[fixed] <- 0
  if (add.model == 'additive') {
    set.objfn(lpmodel, c(rep(0, n),  syx))
  }
  if (add.model == 'RAM') {
    Ro[Ro == 0] <- Inf
    Ri[Ri == 0] <- Inf
    Ranges <- (1 / c(Ro, Ri)) / abs(sum(syx))
    set.objfn(lpmodel, c(rep(0, n), as.numeric(syx * Ranges)))
  }
  if (add.model == 'LovPast') {
    st.dev <- apply(base, 2, sd)
    st.dev[st.dev == 0] <- Inf
    set.objfn(lpmodel, c(rep(0, n), syx / st.dev))
  }
  
  k <- 0
  if (print.status == TRUE) {
    ifelse(!is.null(whichDMUs), solution.status <- rep(0, nn), 
    solution.status <- rep(0, n))
  }
  if (rts == 2 & is.null(bound)) {
    add.constraint(lpmodel, xt = c(rep(1, n), rep(0, s + m)), 
      type  = "=", rhs = 0)
    for (i in whichDMUs) {
      k <- k + 1
      if (add.model == 'MIP') {
        set.objfn(lpmodel, c(rep(0, n), as.numeric(syx / base[i, ])))
      }
      if (add.model == 'BAM') {
        Uo[i, ][Uo[i, ] == 0] <- Inf
        Li[i, ][Li[i, ] == 0] <- Inf
        Ranges <- (1 / c(Uo[i, ], Li[i, ])) / abs(sum(syx))
        set.objfn(lpmodel, c(rep(0, n), as.numeric(syx * Ranges)))
      }
      set.rhs(lpmodel, b = as.numeric(c(base[i, ], 1)))
      x <- solve(lpmodel)
      if (print.status == TRUE) {
        solution.status[k] <- x
      }
      re[k, ] <- c(-get.objective(lpmodel), 
        tail(get.primal.solution(lpmodel), s + m + n))
      if (x != 0) {
        re[k, ] <- rep(NA, ncol(re))
      }
    }
  }
  if (rts == 2 & !is.null(bound)) {
    add.constraint(lpmodel, xt = c(rep(1, n), rep(0, s + m)), 
      type  = "=", rhs = 0)
    for (i in whichDMUs) {
      k <- k +1
      if (add.model == 'MIP') {
        set.objfn(lpmodel, c(rep(0, n), as.numeric(syx / base[i, ])))
      }
      if (add.model == 'BAM') {
        Uo[i, ][Uo[i, ] == 0] <- Inf
        Li[i, ][Li[i, ] == 0] <- Inf
        Ranges <- (1 / c(Uo[i, ], Li[i, ])) / abs(sum(syx))
        set.objfn(lpmodel, c(rep(0, n), as.numeric(syx * Ranges)))
      }
      if (add.model %in% c('RAM', 'BAM')) {
        set.rhs(lpmodel, b = as.numeric(c(base[i, ], bound[i, index], 1)))
      }
      if (sum(add.model == c('RAM', 'BAM'))== 0) {
        bound[bound == 0] <- 10 ^ 10
        set.rhs(lpmodel, b = as.numeric(c(base[i, ], bound[i, index], 1)))
      }
      solve(lpmodel)
      x <- solve(lpmodel)
      if (print.status == TRUE) {
        solution.status[k] <- x
      }
      re[k, ] <- c(-get.objective(lpmodel), 
        tail(get.primal.solution(lpmodel), s + m + n))
      if (x != 0) {
        re[k, ] <- rep(NA, ncol(re))
      }
    }
  }
  if (rts == 1 & is.null(bound)) {
    for (i in whichDMUs) {
      k <- k + 1
      if (add.model == 'MIP') {
        set.objfn(lpmodel, c(rep(0, n), as.numeric(syx / base[i, ])))
      }
      set.rhs(lpmodel, b = as.numeric(base[i, ]))
      x <- solve(lpmodel)
      if (print.status == TRUE) {
        solution.status[k] <- x
      }
      re[k, ] <- c(-get.objective(lpmodel), 
        tail(get.primal.solution(lpmodel), s + m + n))
      if (x != 0) {
        re[k, ] <- rep(NA, ncol(re))
      }
    }
  }
  if (rts == 1 & !is.null(bound)) {
    for (i in whichDMUs) {
      k <- k + 1
      if (add.model == 'MIP') {
        set.objfn(lpmodel, c(rep(0, n), as.numeric(syx / base[i, ])))
      }
      if (add.model == 'BAM') {
        Uo[i, ][Uo[i, ] == 0] <- Inf
        Li[i, ][Li[i, ] == 0] <- Inf
        Ranges <- (1 / c(Uo[i, ], Li[i, ])) / abs(sum(syx))
        set.objfn(lpmodel, c(rep(0, n), as.numeric(syx * Ranges)))
      }
      if (add.model %in% c('RAM', 'BAM')) {
        set.rhs(lpmodel, b = as.numeric(c(base[i, ], bound[i, index])))
      }
      if (sum(add.model == c('RAM', 'BAM')) == 0) {
        bound[bound == 0] <- 10 ^ 10
        set.rhs(lpmodel, b = as.numeric(c(base[i, ], bound[i, index])))
      }
      x <- solve(lpmodel)
      if (print.status == TRUE) {
        solution.status[k] <- x
      }
      ifelse(x != 0, re[k, ] <- rep(NA, ncol(re)), 
        re[k, ] <- c(-get.objective(lpmodel), 
        tail(get.primal.solution(lpmodel), s + m + n)))
    }
  }
  
  if (!is.null(fixed)) {
    re <- re[, -(1 + n + fixed)]
  }
  
  if (print.status == TRUE) {
    reList <- list()
    reList[[1]] <- re
    reList[[2]] <- solution.status
    names(reList[[2]]) <- whichDMUs
    re <- reList
  }
  return(re)
}
