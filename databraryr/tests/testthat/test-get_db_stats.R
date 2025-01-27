# get_db_stats ---------------------------------------------------------
test_that("get_db_stats returns a data.frame by default", {
  expect_true('data.frame' %in% class(get_db_stats()))
})

test_that("get_db_stats returns a data.frame with 'good' values for type parameter", {
  expect_true(is.data.frame(get_db_stats("people")) | is.null(get_db_stats("people")))
  expect_true(is.data.frame(get_db_stats("institutions")) | is.null(get_db_stats("institutions")))
  expect_true(is.data.frame(get_db_stats("places")) | is.null(get_db_stats("places")))
  expect_true(is.data.frame(get_db_stats("datasets")) | is.null(get_db_stats("datasets")))
  expect_true(is.data.frame(get_db_stats("data")) | is.null(get_db_stats("data")))
  expect_true(is.data.frame(get_db_stats("volumes")) | is.null(get_db_stats("volumes")))
  expect_true(is.data.frame(get_db_stats("stats")) | is.null(get_db_stats("stats")))
  expect_true(is.data.frame(get_db_stats("numbers")) | is.null(get_db_stats("numbers")))
  
})

test_that("get_db_stats rejects bad input parameters", {
  expect_error(get_db_stats(type = "a"))
  expect_error(get_db_stats(type = -1))
  expect_error(get_db_stats(type = c(1,2)))
  
  expect_error(get_db_stats(vb = -1))
  expect_error(get_db_stats(vb = 3))
  expect_error(get_db_stats(vb = "a"))
  expect_error(get_db_stats(vb = list(a=1, b=2)))
})
