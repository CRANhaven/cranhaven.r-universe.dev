## Load data
data(data)
X <- data$X
Y <- data$Y
Z <- data$Z

## Subsample data to make test faster
set.seed(2345)
smp <- base::sample(1:dim(Z)[1],round(dim(Z)[1]*0.5))
samp.X <- X[smp, ]
samp.Y <- Y[smp, ]
samp.Z <- Z[smp, ]


test_that("nodesize",{
  skip_on_cran()
  sig <- global.significance(X = samp.X,
                             Y = samp.Y,
                             Z = samp.Z,
                             ntree = 50,
                             nperm = 10)
  expect_gte(sig$pvalue,0)
  expect_lte(sig$pvalue,1)
})
