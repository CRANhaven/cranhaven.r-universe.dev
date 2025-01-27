# list_volume_sessions --------------------------------------------------------------
test_that("list_volume_sessions returns data.frame given valid vol_id", {
  expect_true("data.frame" %in% class(list_volume_sessions()))
})

test_that("list_volume_sessions returns NULL given a non-shared vol_id", {
  expect_true(is.null(list_volume_sessions(vol_id = 237)))
})

test_that("list_volume_sessions rejects bad input parameters", {
  expect_error(list_volume_sessions(vol_id = "a"))
  expect_error(list_volume_sessions(vol_id = TRUE))
  expect_error(list_volume_sessions(vol_id = -1))
  
  expect_error(list_volume_sessions(include_vol_data = -1))
  expect_error(list_volume_sessions(include_vol_data = 3))
  expect_error(list_volume_sessions(include_vol_data = "a"))
  
  expect_error(list_volume_sessions(vb = -1))
  expect_error(list_volume_sessions(vb = 3))
  expect_error(list_volume_sessions(vb = "a"))
  
  expect_error(list_volume_sessions(rq = -1))
  expect_error(list_volume_sessions(rq = TRUE))
  expect_error(list_volume_sessions(rq = c("a", "b")))
  expect_error(list_volume_sessions(rq = list("a" = 1, "b" = 2)))
})
