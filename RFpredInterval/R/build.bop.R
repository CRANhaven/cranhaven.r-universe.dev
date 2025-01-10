# to eliminate check note for data.table
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(".", "tree", "terminalnode", "trainid", "testid",
                           "bop", "residual", "response", "ib_count"))
}

## build test-BOP with oob neighbors of observations in terminal nodes
buildtestbop <- function (mem.train, mem.test, inbag, residual) {
  ## Inputs
  # mem.train: the terminal node membership of training observations
  # mem.test: the terminal node membership of test observations
  # inbag: inbag counts of training observations
  # residual: predicted OOB residuals

  ## Output
  # Test-BOP: a list of length ntest

  ## convert mem.test to data.table and set key
  mem.test.dt <- data.table::melt(
    data.table::as.data.table(mem.test)[, `:=`(testid = .I)],
    id.vars = c("testid"),
    measure.vars = 1:ncol(mem.test),
    variable.name = "tree",
    value.name = "terminalnode",
    variable.factor = FALSE)
  data.table::setkey(mem.test.dt, tree, terminalnode)

  ## get the terminal node membership of the training observations
  ## in trees where they are oob
  mem.train[inbag != 0] <- NA

  ## convert mem.train to data.table
  mem.train.dt <- data.table::melt(
    data.table::as.data.table(mem.train)[, `:=`(trainid = .I, residual = residual)],
    id.vars = c("trainid", "residual"),
    measure.vars = 1:ncol(mem.train),
    variable.name = "tree",
    value.name = "terminalnode",
    variable.factor = FALSE,
    na.rm = TRUE)

  mem.train.dt <- mem.train.dt[,
                               .(bop = list(residual)),
                               keyby = c("tree", "terminalnode")]

  ## build test BOP
  BOPtest <- mem.train.dt[mem.test.dt,
                          .(tree, terminalnode, testid, bop)][,
                                                              .(bop = list(sort(unlist(bop)))),
                                                              keyby = c("testid")]

  return(BOPtest$bop)
}


## build oob-BOP with oob neighbors of observations in terminal nodes
buildoobbop <- function (mem.train, inbag, residual) {
  ## Inputs
  # mem.train: the terminal node membership of training observations
  # inbag: inbag counts of training observations
  # residual: predicted OOB residuals

  ## Output
  # OOB-BOP: a list of length ntrain

  ## mem.test will be mem.train with only OOB memberships
  mem.test <- mem.train
  mem.test[inbag != 0] <- NA

  ## convert mem.test to data.table and set key
  mem.test.dt <- data.table::melt(
    data.table::as.data.table(mem.test)[, `:=`(testid = .I)],
    id.vars = c("testid"),
    measure.vars = 1:ncol(mem.test),
    variable.name = "tree",
    value.name = "terminalnode",
    variable.factor = FALSE,
    na.rm = TRUE)
  data.table::setkey(mem.test.dt, tree, terminalnode)

  ## get the terminal node membership of the training observations
  ## in trees where they are oob
  mem.train[inbag != 0] <- NA

  ## convert mem.train to data.table
  mem.train.dt <- data.table::melt(
    data.table::as.data.table(mem.train)[, `:=`(trainid = .I, residual = residual)],
    id.vars = c("trainid", "residual"),
    measure.vars = 1:ncol(mem.train),
    variable.name = "tree",
    value.name = "terminalnode",
    variable.factor = FALSE,
    na.rm = TRUE)

  mem.train.dt <- mem.train.dt[,
                               .(bop = list(trainid)),
                               keyby = c("tree", "terminalnode")]

  ## build OOB-BOP with observation IDs
  BOPoob <- mem.train.dt[mem.test.dt,
                         .(tree, terminalnode, testid, bop)][,
                                                             .(bop = list(sort(unlist(bop)))),
                                                             keyby = c("testid")]

  ## remove the observation itself from its OOB-BOP
  BOPoob2 <- lapply(1:nrow(BOPoob), function(x) BOPoob$bop[[x]][BOPoob$bop[[x]]!=BOPoob$testid[x]])

  ## re-format OOB-BOP with corresponding OOB residuals
  BOPoob <- lapply(BOPoob2, function (x, res) residual[x], res = residual)

  return(BOPoob)
}


## build test-BOP with inbag neighbors of observations in terminal nodes
buildtestbop_ib <- function (mem.train, mem.test, inbag, yvar) {
  ## Inputs
  # mem.train: the terminal node membership of training observations
  # mem.test: the terminal node membership of test observations
  # inbag: inbag counts of training observations
  # yvar: true response for training observations

  ## Output
  # Test-BOP: a list of length ntest

  ## convert mem.test to data.table and set key
  mem.test.dt <- data.table::melt(
    data.table::as.data.table(mem.test)[, `:=`(testid = .I)],
    id.vars = c("testid"),
    measure.vars = 1:ncol(mem.test),
    variable.name = "tree",
    value.name = "terminalnode",
    variable.factor = FALSE)
  data.table::setkey(mem.test.dt, tree, terminalnode)

  ## get the terminal node membership and inbag counts of the training
  ## observations in trees where they are inbag
  mem.train[inbag == 0] <- NA
  inbag[inbag == 0] <- NA

  ## convert inbag to data.table
  inbag.dt <- data.table::melt(
    data.table::as.data.table(inbag)[, `:=`(trainid = .I)],
    id.vars = c("trainid"),
    measure.vars = 1:ncol(inbag),
    variable.name = "tree",
    value.name = "ib_count",
    variable.factor = FALSE,
    na.rm = TRUE)

  ## convert mem.train to data.table
  mem.train.dt <- data.table::melt(
    data.table::as.data.table(mem.train)[, `:=`(trainid = .I, response = yvar)],
    id.vars = c("trainid", "response"),
    measure.vars = 1:ncol(mem.train),
    variable.name = "tree",
    value.name = "terminalnode",
    variable.factor = FALSE,
    na.rm = TRUE)

  ## merge inbag counts to mem.train.dt and remove inbag.dt
  mem.train.dt <- merge(mem.train.dt, inbag.dt, by = c("trainid","tree"))
  remove(inbag.dt)
  mem.train.dt <- mem.train.dt[,
                               .(bop = list(rep(response, ib_count))),
                               keyby = c("tree", "terminalnode")]

  ## build test-BOP
  BOPtest <- mem.train.dt[mem.test.dt,
                          .(tree, terminalnode, testid, bop)][,
                                                              .(bop = list(sort(unlist(bop)))),
                                                              keyby = c("testid")]

  return(BOPtest$bop)
}


## build oob-BOP with inbag neighbors of observations in terminal nodes
buildoobbop_ib <- function (mem.train, inbag, yvar) {
  ## Inputs
  # mem.train: the terminal node membership of training observations
  # inbag: inbag counts of training observations
  # yvar: true response for training observations

  ## Output
  # OOB-BOP: a list of length ntrain

  ## mem.test will be mem.train with only OOB memberships
  mem.test <- mem.train
  mem.test[inbag != 0] <- NA

  ## convert mem.test to data.table and set key
  mem.test.dt <- data.table::melt(
    data.table::as.data.table(mem.test)[, `:=`(testid = .I)],
    id.vars = c("testid"),
    measure.vars = 1:ncol(mem.test),
    variable.name = "tree",
    value.name = "terminalnode",
    variable.factor = FALSE,
    na.rm = TRUE)
  data.table::setkey(mem.test.dt, tree, terminalnode)

  ## get the terminal node membership and inbag counts of the training
  ## observations in trees where they are inbag
  mem.train[inbag == 0] <- NA
  inbag[inbag == 0] <- NA

  ## convert inbag to data.table
  inbag.dt <- data.table::melt(
    data.table::as.data.table(inbag)[, `:=`(trainid = .I)],
    id.vars = c("trainid"),
    measure.vars = 1:ncol(inbag),
    variable.name = "tree",
    value.name = "ib_count",
    variable.factor = FALSE,
    na.rm = TRUE)

  ## convert mem.train to data.table
  mem.train.dt <- data.table::melt(
    data.table::as.data.table(mem.train)[, `:=`(trainid = .I, response = yvar)],
    id.vars = c("trainid", "response"),
    measure.vars = 1:ncol(mem.train),
    variable.name = "tree",
    value.name = "terminalnode",
    variable.factor = FALSE,
    na.rm = TRUE)

  ## merge inbag counts to mem.train.dt and remove inbag.dt
  mem.train.dt <- merge(mem.train.dt, inbag.dt, by = c("trainid","tree"))
  remove(inbag.dt)
  mem.train.dt <- mem.train.dt[,
                               .(bop = list(rep(response, ib_count))),
                               keyby = c("tree", "terminalnode")]

  ## build OOB-BOP
  BOPoob <- mem.train.dt[mem.test.dt,
                         .(tree, terminalnode, testid, bop)][,
                                                             .(bop = list(sort(unlist(bop)))),
                                                             keyby = c("testid")]

  return(BOPoob$bop)
}
