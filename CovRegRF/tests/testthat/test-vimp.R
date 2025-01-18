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

test_that("vimp",{
  skip_on_cran()
  ## vimp dimension
  rf <- covregrf(formula=formula,
                 data=traindata,
                 params.rfsrc=list(ntree = 50),
                 importance=FALSE)
  expect_equal(rf$importance,NULL)
  expect_equal(length(vimp(rf)$importance),length(xvar.names))
})
