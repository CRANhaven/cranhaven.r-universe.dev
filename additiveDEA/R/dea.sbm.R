dea.sbm <-
function(base, noutput, fixed = NULL, rts = 2, bound = NULL, 
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
  
  slacks <- diag(s + m)
  slacks[1:s, ] <- -slacks[1:s, ]
  type <- rep("=", s + m)
  if (!is.null(fixed)) {
    slacks[, fixed] <- 0
    type[fixed[fixed <=s]] <- ">="
    type[fixed[fixed > s]] <- "<="
  }
  
  k <- 0
  A.aux <- cbind(t(base), slacks)
  index.fixed.y <- fixed[which(fixed %in% 1:s)]
  index.fixed.x <- fixed[which(fixed %in% (s + 1):(s + m))]
  S <- s - length(index.fixed.y)
  M <- m - length(index.fixed.x)
  if (print.status == TRUE) {
    ifelse(!is.null(whichDMUs), solution.status <- rep(0, nn), 
    solution.status <- rep(0, n))
  }
  if (rts == 2 & is.null(bound)) {
    for (i in whichDMUs) {
      k <- k + 1
      lpmodel <- make.lp(nrow = 0, ncol = 1 + n + s + m)
      A <- cbind(-t(base)[, i], A.aux)
      xt <- as.numeric((1 / S) * (1 / base[i, 1:s]))
      if (!is.null(fixed)) {
        xt[index.fixed.y] <- 0
      }
      xt <- c(1, rep(0, n), xt, rep(0, m))
      add.constraint(lpmodel, xt = xt, type  = "=", rhs = 0)
      for (j in 1:(s + m)) {
        add.constraint(lpmodel, xt = A[j, ], type = type[j], rhs = 0)
      }
      add.constraint(lpmodel, xt = c(-1, rep(1, n), rep(0, s + m)), 
        type = "=", rhs = 0)
      set.rhs(lpmodel, b = c(1, rep(0, s + m + 1)))
      obj <- as.numeric((-1 / M) * (1 / base[i, (s + 1):(s + m)]))
      if (!is.null(fixed)) {
        obj[index.fixed.x - s] <- 0
      }
      obj <- c(1, rep(0, n + s), obj)
      set.objfn(lpmodel, obj = obj)
      x <- solve(lpmodel)
      if (print.status == TRUE) {
        solution.status[k] <- x
      }
      re[k, ] <- c(get.objective(lpmodel), 
       tail(get.primal.solution(lpmodel), n + s + m) / 
       get.primal.solution(lpmodel)[1 + 1 + s + m + 1 + 1])
      if (x != 0) {
        re[k, ] <- rep(NA, ncol(re))
      }
    }
  }
  if (rts == 2 & !is.null(bound)) {
    index <- which(colSums(bound) != 0)
    nrows <- length(index)
    A.bound <- matrix(0, nrow = nrows, ncol = n + s + m)
    kk <- 0
    for (i in index) {
      kk <- kk + 1
      A.bound[kk, n + index[kk]] <- 1
    }
    A.bound <- cbind(0, A.bound)
    for (i in whichDMUs) {
      A.bound <- matrix(0, nrow = nrows, ncol = n + s + m)
      kk <- 0
      for (j in index) {
        kk <- kk + 1
        A.bound[kk, n + index[kk]] <- 1
      }
      A.bound <- cbind(0, A.bound)
      k <- k + 1
      lpmodel <- make.lp(nrow = 0, ncol = 1 + n + s + m)
      A <- cbind(-t(base)[, i], A.aux)
      A.bound[, 1] <- as.numeric(-bound[i, index])
      A.bound[A.bound[, 1] == 0, ] <- 0
      A <- rbind(A, A.bound)
      xt <- as.numeric((1 / S) * (1 / base[i, 1:s]))
      if (!is.null(fixed)) {
        xt[index.fixed.y] <- 0
      }
      xt <- c(1, rep(0, n), xt, rep(0, m))
      add.constraint(lpmodel, xt = xt, type  = "=", rhs = 0)
      for (j in 1:(s + m)) {
        add.constraint(lpmodel, xt = A[j, ], type = type[j], rhs = 0)
      }
      add.constraint(lpmodel, xt = c(-1, rep(1, n), rep(0, s + m)), 
        type = "=", rhs = 0)
      for (l in 1:kk) {
        add.constraint(lpmodel, xt = A[s + m + l, ], type = "<=", rhs = 0)
      }
      set.rhs(lpmodel, b = c(1, rep(0, s + m + 1 + l)))
      obj <- as.numeric((-1 / M) * (1 / base[i, (s + 1):(s + m)]))
      if (!is.null(fixed)) {
        obj[index.fixed.x - s] <- 0
      }
      obj <- c(1, rep(0, n + s), obj)
      set.objfn(lpmodel, obj = obj)
      x <- solve(lpmodel)
      if (print.status == TRUE) {
        solution.status[k] <- x
      }
      re[k, ] <- c(get.objective(lpmodel), 
        tail(get.primal.solution(lpmodel), n + s + m) / 
        get.primal.solution(lpmodel)[1 + 1 + s + m + 1 +  
          sum(colSums(bound) != 0) + 1])
      if (x != 0) {
        re[k, ] <- rep(NA, ncol(re))
      }
    }
  }
  if (rts == 1 & is.null(bound)) {
    for (i in whichDMUs) {
      k <- k + 1
      lpmodel <- make.lp(nrow = 0, ncol = 1 + n + s + m)
      A <- cbind(-t(base)[, i], A.aux)
      xt <- as.numeric((1 / S) * (1 / base[i, 1:s]))
      if (!is.null(fixed)) {
        xt[index.fixed.y] <- 0
      }
      xt <- c(1, rep(0, n), xt, rep(0, m))
      add.constraint(lpmodel, xt = xt, type  = "=", rhs = 0)
      for (j in 1:(s + m)) {
        add.constraint(lpmodel, xt = A[j, ], type = type[j], rhs = 0)
      }
      set.rhs(lpmodel, b = c(1, rep(0, s + m)))
      obj <- as.numeric((-1 / M) * (1 / base[i, (s + 1):(s + m)]))
      if (!is.null(fixed)) {
        obj[index.fixed.x - s] <- 0
      }
      obj <- c(1, rep(0, n + s), obj)
      set.objfn(lpmodel, obj = obj)
      x <- solve(lpmodel)
      if (print.status == TRUE) {
        solution.status[k] <- x
      }
      re[k, ] <- c(get.objective(lpmodel), 
        tail(get.primal.solution(lpmodel), n + s + m) / 
        get.primal.solution(lpmodel)[1 + 1 + s + m + 1])
      if (x != 0) {
        re[k, ] <- rep(NA, ncol(re))
      }
    }
  }
  if (rts == 1 & !is.null(bound)) {
    index <- which(colSums(bound) != 0)
    nrows <- length(index)
    A.bound <- matrix(0, nrow = nrows, ncol = n + s + m)
    kk <- 0
    for (i in index) {
      kk <- kk + 1
      A.bound[kk, n + index[kk]] <- 1
    }
    A.bound <- cbind(0, A.bound)
    for (i in whichDMUs) {
      k <- k + 1
      lpmodel <- make.lp(nrow = 0, ncol = 1 + n + s + m)
      A <- cbind(-t(base)[, i], A.aux)
      A.bound[, 1] <- as.numeric(-bound[i, index])
      A.bound[A.bound[, 1] == 0, ] <- 0
      A <- rbind(A, A.bound)
      xt <- as.numeric((1 / S) * (1 / base[i, 1:s]))
      if (!is.null(fixed)) {
        xt[index.fixed.y] <- 0
      }
      xt <- c(1, rep(0, n), xt, rep(0, m))
      add.constraint(lpmodel, xt = xt, type  = "=", rhs = 0)
      for (j in 1:(s + m)) {
        add.constraint(lpmodel, xt = A[j, ], type = type[j], rhs = 0)
      }
      for (l in 1:kk) {
        add.constraint(lpmodel, xt = A[s + m + l, ], type = "<=", rhs = 0)
      }
      set.rhs(lpmodel, b = c(1, rep(0, s + m + l)))
      obj <- as.numeric((-1 / M) * (1 / base[i, (s + 1):(s + m)]))
      if (!is.null(fixed)) {
        obj[index.fixed.x - s] <- 0
      }
      obj <- c(1, rep(0, n + s), obj)
      set.objfn(lpmodel, obj = obj)
      x <- solve(lpmodel)
      if (print.status == TRUE) {
        solution.status[k] <- x
      }
      re[k, ] <- c(get.objective(lpmodel), 
        tail(get.primal.solution(lpmodel), n + s + m) / 
        get.primal.solution(lpmodel)[1 + 1 + s + m +  
          sum(colSums(bound) != 0) + 1])
      if (x != 0) {
        re[k, ] <- rep(NA, ncol(re))
      }
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
