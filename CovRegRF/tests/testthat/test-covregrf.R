## Load data
data(data)
xvar.names <- colnames(data$X)
yvar.names <- colnames(data$Y)
data <- data.frame(data$X, data$Y)

## Split into train and test sets
set.seed(2345)
smp <- base::sample(1:nrow(data),round(nrow(data)*0.6))
traindata <- data[smp, ,drop=FALSE]
testdata <- data$X[-smp, ,drop=FALSE]
remove(data)

formula <- as.formula(paste(paste(yvar.names, collapse="+"), ".", sep=" ~ "))

## Test for small ntree
test_that("small ntree",{
  skip_on_cran()
  expect_error(covregrf(formula=formula,
                      data=traindata,
                      params.rfsrc=list(ntree = 2)),
               "Some observations have empty BOP. Increase the number of trees, 'ntree' in params.rfsrc.")
})

## nodesize is smaller than py
test_that("nodesize",{
  skip_on_cran()
  ## run covregrf
  rf <- covregrf(formula=formula,
                 data=traindata,
                 params.rfsrc=list(ntree = 50))
  expect_error(covregrf(formula=formula,
                      data=traindata,
                      params.rfsrc=list(ntree = 50),
                      nodesize.set = c(1,2)),
               "nodesize.set should have values more than number of response variables.")
})
