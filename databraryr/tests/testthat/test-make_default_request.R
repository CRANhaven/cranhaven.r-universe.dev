# make_default_request ---------------------------------------------------------
test_that("make_default_request returns httr2_request", {
  expect_true("httr2_request" %in% class(make_default_request()))
})

