## cca for final canonical correlation estimation
ccaest <- function(bop, xtrain, ytrain) {
  cca <- cancor(xtrain[bop, ], ytrain[bop, ])
  cor <- cca$cor[1]
  coefx <- cca$xcoef[,1]
  coefy <- cca$ycoef[,1]
  px <- as.numeric(ncol(as.matrix(xtrain[bop, ])))
  py <- as.numeric(ncol(as.matrix(ytrain[bop, ])))
  coef <- rep(NA,(px+py))
  px1 <- length(coefx)
  py1 <- length(coefy)
  coef[1:px1] <- coefx
  coef[(px1+1):(px1+py1)] <- coefy
  out <- c(cor,coef)
  names(out) <- c("cor",names(xtrain),names(ytrain))
  return(out)
}

## construct bop
findforestbop <- function(obs, mem.train, mem.test = NULL, inbag, ntree, bop.type) {
  if (bop.type == "oob") {
    inbag1 <- (inbag>0)*1
    mem.inbag <- mem.train*inbag1
    mem.oob <- mem.train*(1-inbag1)
    mem.obs <- mem.oob[obs, ]
    out <- lapply(1:ntree, "findtreebop", mem.train = mem.inbag, mem.test = mem.obs, inbag = inbag)
  } else if (bop.type == "test") {
    mem.obs <- mem.test[obs, ]
    out <- lapply(1:ntree, "findtreebop", mem.train = mem.train, mem.test = mem.obs, inbag = inbag)
  }
  return(out)
}

findtreebop <- function(tree, mem.train, mem.test, inbag) {
  out <- NULL
  node <- mem.test[tree]
  if (node != 0) {
    out <- which(mem.train[, tree] == node)
    out <- rep(out, inbag[out, tree])
  }
  return(out)
}

## HIDDEN VARIABLES FOLLOW:
is.hidden.do.trace <-  function (user.option) {
  if (is.null(user.option$do.trace)) {
    FALSE
  }
  else {
    as.logical(as.character(user.option$do.trace))
  }
}
is.hidden.split.depth <-  function (user.option) {
  if (is.null(user.option$split.depth)) {
    FALSE
  }
  else {
    as.character(user.option$split.depth)
  }
}
is.hidden.statistics <-  function (user.option) {
  if (is.null(user.option$statistics)) {
    FALSE
  }
  else {
    as.logical(as.character(user.option$statistics))
  }
}
is.hidden.var.used <-  function (user.option) {
  if (is.null(user.option$var.used)) {
    FALSE
  }
  else {
    as.character(user.option$var.used)
  }
}
is.hidden.lambda1 <- function (user.option) {
  if (is.null(user.option$lambda1)) {
    NULL
  }
  else {
    as.numeric(user.option$lambda1)
  }
}
is.hidden.lambda2 <- function (user.option) {
  if (is.null(user.option$lambda2)) {
    NULL
  }
  else {
    as.numeric(user.option$lambda2)
  }
}
is.hidden.rfsrc.forest <- function (user.option) {
  if (is.null(user.option$rfsrc.forest)) {
    FALSE
  }
  else {
    as.logical(as.character(user.option$rfsrc.forest))
  }
}
is.hidden.seed <- function (user.option) {
  if (is.null(user.option$seed)) {
    NULL
  }
  else {
    as.numeric(user.option$seed)
  }
}
## merge list
mergelist <- function(x) {
  Reduce(append,x)
}

## regularized cca for final canonical correlation estimation
rccaest <- function(bop, xtrain, ytrain, lambda1, lambda2) {
  rcca <- CCA::rcc(xtrain[bop,], ytrain[bop,], lambda1 = lambda1, lambda2 = lambda2)
  cor <- rcca$corr
  coefx <- rcca$xcoef
  coefy <- rcca$ycoef
  px <- as.numeric(ncol(xtrain[bop,]))
  py <- as.numeric(ncol(ytrain[bop,]))
  coef <- rep(NA,(px+py))
  px1 <- length(coefx)
  py1 <- length(coefy)
  coef[1:px1] <- coefx
  coef[(px1+1):(px1+py1)] <- coefy
  out <- c(cor,coef)
  names(out) <- c("cor",names(xtrain),names(ytrain))
  return(out)
}

## sparse cca for final canonical correlation estimation
sccaest <- function(bop, xtrain, ytrain) {
  scca <- PMA::CCA(xtrain[bop,], ytrain[bop,], trace = FALSE, typex = "standard", typez = "standard")
  cor <- scca$cors
  coefx <- scca$u[,1]
  coefy <- scca$v[,1]
  px <- as.numeric(ncol(xtrain[bop, ]))
  py <- as.numeric(ncol(ytrain[bop, ]))
  coef <- rep(NA,(px+py))
  px1 <- length(coefx)
  py1 <- length(coefy)
  coef[1:px1] <- coefx
  coef[(px1+1):(px1+py1)] <- coefy
  out <- c(cor,coef)
  names(out) <- c("cor",names(xtrain),names(ytrain))
  return(out)
}
