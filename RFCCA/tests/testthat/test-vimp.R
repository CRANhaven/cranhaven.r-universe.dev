## Load data
data(data)
X <- data$X
Y <- data$Y
Z <- data$Z

## Split into train and test sets
set.seed(2345)
smp <- base::sample(1:dim(Z)[1],round(dim(Z)[1]*0.6))
train.X <- X[smp, ]
train.Y <- Y[smp, ]
train.Z <- Z[smp, ]
test.Z <- Z[-smp, ]

## vimp dimension
test_that("vimp.rfcca",{
  skip_on_cran()
  rf <- rfcca(X = train.X,
              Y = train.Y,
              Z = train.Z,
              ntree = 50,
              importance = FALSE)
  expect_equal(rf$importance,NULL)
  expect_equal(length(vimp(rf)$importance),dim(train.Z)[2])
})
