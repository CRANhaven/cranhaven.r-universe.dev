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

## Test for small ntree
test_that("small ntree",{
  skip_on_cran()
  expect_error(rfcca(X = train.X,
                     Y = train.Y,
                     Z = train.Z,
                     ntree = 2),
               "Some observations have empty BOP. Re-run rfcca with larger 'ntree'.")
})

## bootstrap=FALSE and bop=TRUE. We cannot get OOB predictions. We expect bop=NULL.
test_that("bootstrap arguments",{
  skip_on_cran()
  expect_warning(rf <- rfcca(X = train.X,
                             Y = train.Y,
                             Z = train.Z,
                             ntree = 50,
                             bootstrap = FALSE,
                             bop = TRUE),
                 "when bootstrap is FALSE, OOB predictions cannot be computed")
  expect_equal(rf$bop, NULL)
  expect_equal(rf$predicted.oob, NULL)
})

## importance and membership return, predict
test_that("return arguments and predict",{
  skip_on_cran()
  ## run rfcca
  rf <- rfcca(X = train.X,
              Y = train.Y,
              Z = train.Z,
              ntree = 50,
              bop = FALSE)
  expect_equal(rf$importance, NULL)
  expect_equal(rf$membership,NULL)
  expect_equal(rf$bop,NULL)
  expect_equal(sum(is.na(rf$predicted.oob)),0)
  expect_error(predict(rf, finalcca = "rcca"),"when rcca is the final estimation method, 'lambda1' and 'lambda2' should be entered")
  expect_error(predict(rf, test.Z, finalcca = "rcca"),"when rcca is the final estimation method, 'lambda1' and 'lambda2' should be entered")
})

## nodesize is smaller than px+py and final.cca = "cca". Hence, we expect an error.
test_that("nodesize",{
  skip_on_cran()
  expect_error(rfcca(X = train.X,
                     Y = train.Y,
                     Z = train.Z,
                     ntree = 50,
                     nodesize = 3),
               "Invalid choice of 'nodesize'. Cannot be smaller than total number of X and Y variables with 'cca' final estimation.")
  expect_error(rfcca(X = X,
                     Y = Y,
                     Z = Z,
                     ntree = 100,
                     nodesize = 3,
                     bop = TRUE,
                     finalcca = "scca"),NA)
  expect_error(rfcca(X = X,
                     Y = Y,
                     Z = Z,
                     ntree = 100,
                     nodesize = 3,
                     bop = TRUE,
                     finalcca = "rcca",
                     lambda1 = 0.5,
                     lambda2 = 0.5), NA)
})
