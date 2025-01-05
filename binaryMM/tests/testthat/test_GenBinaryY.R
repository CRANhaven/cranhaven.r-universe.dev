test_that("GenBinary Y returns a vector", {

  N      = 100
  nclust = sample( seq(10,10), N, replace=TRUE)
  id     = rep(seq(N), nclust)
  Xe     = rep(rbinom(N,size=1,prob=.5), nclust) # binary exposure
  time   = unlist( sapply( as.list(nclust), function(ZZ) seq(ZZ)-1 ) )
  data   = data.frame(id, time, Xe)
  data   = data[order(data$id, data$time),]
  newdat = GenBinaryY(mean.formula=~time*Xe, lv.formula=~1, t.formula=~1,
                       beta=c(-2.5, 0.25, 0.25, 0.1),
                      sigma=1, gamma=1, id=id, data=data, q=20)

  expect_equal(class(newdat), "numeric")
})

test_that("Inputs in GenBinaryY are correctly specified", {

  N      = 100
  nclust = sample( seq(10,10), N, replace=TRUE)
  id     = rep(seq(N), nclust)
  Xe     = rep(rbinom(N,size=1,prob=.5), nclust) # binary exposure
  time   = unlist( sapply( as.list(nclust), function(ZZ) seq(ZZ)-1 ) )
  data   = data.frame(id, time, Xe)
  data   = data[order(data$id, data$time),]
  newdat = GenBinaryY(mean.formula=~time*Xe, lv.formula=~1, t.formula=~1,
                      beta=c(-2.5, 0.25, 0.25, 0.1),
                      sigma=1, gamma=1, id=id, data=data, q=20)

  expect_error(GenBinaryY(mean.formula=~time*Xe,
                          beta=c(-2.5, 0.25, 0.25, 0.1),
                          id=id, data=data, q=20))
  expect_error(GenBinaryY(mean.formula=~time*Xe, lv.formula=~1, t.formula=~1,
                          sigma=1, gamma=1,
                          id=id, data=data, q=20))
  expect_error(GenBinaryY(mean.formula=~time*Xe, lv.formula=~1, t.formula=~1,
                          beta=c(-2.5, 0.25, 0.25, 0.1),
                          sigma=NULL, gamma=1,
                          id=id, data=data, q=20))
  expect_error(GenBinaryY(mean.formula=~time*Xe, lv.formula=~1, t.formula=~1,
                          beta=c(-2.5, 0.25, 0.25, 0.1),
                          sigma=1, gamma=NULL,
                          id=id, data=data, q=20))
  expect_error(GenBinaryY(mean.formula=~time*Xe,
                          beta=c(-2.5, 0.25, 0.25, 0.1),
                          id=id, data=data, q=20))

})
