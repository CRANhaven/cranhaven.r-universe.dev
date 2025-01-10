## Load data
data(BostonHousing, package = "RFpredInterval")

yvar.index <- which(names(BostonHousing) == "medv")
xvar.names <- names(BostonHousing)[-yvar.index]
px <- length(xvar.names)

formula <- as.formula(medv ~ .)
alpha <- 0.05

## Split data set into train and test
## for rfpi and pibf functions
set.seed(2345)
trainindex <- base::sample(nrow(BostonHousing),round(nrow(BostonHousing)*0.7), replace = FALSE)
traindata <- BostonHousing[trainindex, ]
testdata <- BostonHousing[-trainindex, ]

## Split data set into train and test
## for piall and plot.rfpredinterval functions
set.seed(2345)
testindex2 <- 1
trainindex2 <- sample(2:nrow(BostonHousing), size = 50, replace = FALSE)
traindata2 <- BostonHousing[trainindex2, ]
testdata2 <- BostonHousing[testindex2, ]

## Set parameters for random forest
params_rfsrc <- list(mtry = ceiling(px/3),
                     ntree = 20,
                     nodesize = 3,
                     samptype = "swr")
params_ranger <- list(mtry = ceiling(px/3),
                      num.trees = 20,
                      min.node.size = 5,
                      replace = TRUE)

test_that("calibration",{
  expect_error(pibf(formula,
                    traindata = traindata,
                    testdata = testdata,
                    alpha = alpha,
                    calibration = "oob",
                    coverage_range = c(0.96,0.99)),
               "1-alpha is not within the limits of 'coverage_range'.")
  expect_error(pibf(formula,
                    traindata = traindata,
                    testdata = testdata,
                    alpha = alpha,
                    calib = "oob",
                    coverage_range = c(0.96)),
               "'coverage_range' should be a numeric vector of length 2.")
})


test_that("split.rule",{
  split_rule <- "l1"
  expect_error(rfpi(formula,
                    traindata = traindata,
                    testdata = testdata,
                    alpha = alpha,
                    split_rule = split_rule,
                    rf_package = "ranger"),
               paste0(split_rule," split rule cannot be applied with ranger package. Change rf_package to rfsrc."))
  split.rule <- "spi"
  expect_error(rfpi(formula,
                    traindata = traindata,
                    testdata = testdata,
                    alpha = alpha,
                    split_rule = split_rule,
                    rf_package = "ranger"),
               paste0(split_rule," split rule cannot be applied with ranger package. Change rf_package to rfsrc."))
})

out1 <- piall(formula,
              traindata = traindata2,
              testdata = testdata2[, xvar.names],
              num.trees = 50)

test_that("test_response",{
  expect_equal(out1$test_response, NULL)
  expect_equal(length(out1$PIBF),2)
  expect_equal(length(out1$LS_LM),2)
  expect_equal(length(out1$L1_SPI),2)
  expect_equal(length(out1$SPI_Quant),2)
  expect_equal(length(out1$LS_HDR),nrow(testdata2))
})

out2 <- out1
class(out2) <- c("wrongclass", "wrongclass")

test_that("test_id",{
  expect_error(plot.rfpredinterval(out1, test_id = 2),
               "test_id must be an integer from 1 to ntest.", fixed = TRUE)
  expect_error(plot.rfpredinterval(out2, test_id = 1),
               "This function only works for objects of class `(rfpredinterval, piall)`.", fixed = TRUE)
})


test_that("boperror",{
  params_ranger[["num.trees"]] <- 2
  params_rfsrc[["ntree"]] <- 2
  expect_error(pibf(formula,
                    traindata = traindata,
                    testdata = testdata,
                    alpha = alpha,
                    calibration = "oob",
                    params_ranger = params_ranger),
               "Some of the OOB predictions are NaN. Increase the number of trees, 'num.trees' in params_ranger.")
})
