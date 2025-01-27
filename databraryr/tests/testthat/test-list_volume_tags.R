# list_volume_tags ---------------------------------------------------------
test_that("list_volume_tags returns data.frame or is NULL", {
  expect_true((is.null(list_volume_tags()) ||
                 ("data.frame" %in% class(list_volume_tags()))))
})

test_that("list_volume_tags rejects bad input parameters", {
  expect_error(list_volume_tags(vol_id = "a"))
  expect_error(list_volume_tags(vol_id = c(1,2)))
  expect_error(list_volume_tags(vol_id = TRUE))
  expect_error(list_volume_tags(vol_id = list(a=1, b=2)))
  expect_error(list_volume_tags(vol_id = -1))
  
  expect_error(list_volume_tags(vb = -1))
  expect_error(list_volume_tags(vb = 3))
  expect_error(list_volume_tags(vb = "a"))
  expect_error(list_volume_tags(vb = list(a=1, b=2)))
  
  expect_error(list_volume_tags(rq = "a"))
  expect_error(list_volume_tags(rq = -1))
  expect_error(list_volume_tags(rq = c(2,3)))
  expect_error(list_volume_tags(rq = list(a=1, b=2)))
})

test_that("list_volume_tags returns NULL for volume without tags", {
  expect_true(is.null(list_volume_tags(vol_id = 3)))
})
