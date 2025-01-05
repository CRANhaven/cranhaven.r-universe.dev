test_that("mm returns an object of class MMLong", {

  N      = 100
  nclust = sample( seq(10,10), N, replace=TRUE)
  id     = rep(seq(N), nclust)
  Xe     = rep(rbinom(N,size=1,prob=.5), nclust) # binary exposure
  time   = unlist( sapply( as.list(nclust), function(ZZ) seq(ZZ)-1 ) )
  data   = data.frame(id, time, Xe)
  data   = data[order(data$id, data$time),]
  Y      = GenBinaryY(mean.formula=~time*Xe, t.formula=~1,
                      beta=c(-2.5, 0.25, 0.25, 0.1),
                      gamma=1, id=id, data=data, q=20)
  newdat = data.frame(data, Y = Y)

  fit <- mm(Y~time*Xe, t.formula=~1, data=newdat, id=id, step.max=4, verbose=FALSE)

  expect_equal(class(fit), "MMLong")

})

test_that("Inputs of mm are correct", {

  N      = 100
  nclust = sample( seq(10,10), N, replace=TRUE)
  id     = rep(seq(N), nclust)
  Xe     = rep(rbinom(N,size=1,prob=.5), nclust) # binary exposure
  time   = unlist( sapply( as.list(nclust), function(ZZ) seq(ZZ)-1 ) )
  data   = data.frame(id, time, Xe)
  data   = data[order(data$id, data$time),]
  Y      = GenBinaryY(mean.formula=~time*Xe, t.formula=~1,
                      beta=c(-2.5, 0.25, 0.25, 0.1),
                      gamma=1, id=id, data=data, q=20)
  newdat = data.frame(data, Y = Y)

  expect_error(mm(Y~time*Xe, data=newdat,
                    id=id, step.max=4, verbose=FALSE))

})
