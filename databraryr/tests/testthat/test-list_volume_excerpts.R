# list_volume_excerpts ---------------------------------------------------------
test_that("list_volume_excerpts returns data.frame or is NULL", {
  expect_true((is.null(list_volume_excerpts()) ||
                 ("list" %in% class(list_volume_excerpts()))))
})

test_that("list_volume_excerpts rejects bad input parameters", {
  expect_error(list_volume_excerpts(vol_id = "a"))
  expect_error(list_volume_excerpts(vol_id = c(1,2)))
  expect_error(list_volume_excerpts(vol_id = TRUE))
  expect_error(list_volume_excerpts(vol_id = list(a=1, b=2)))
  expect_error(list_volume_excerpts(vol_id = -1))
  
  expect_error(list_volume_excerpts(vb = -1))
  expect_error(list_volume_excerpts(vb = 3))
  expect_error(list_volume_excerpts(vb = "a"))
  expect_error(list_volume_excerpts(vb = list(a=1, b=2)))
  
  expect_error(list_volume_excerpts(rq = "a"))
  expect_error(list_volume_excerpts(rq = -1))
  expect_error(list_volume_excerpts(rq = c(2, 3)))
  expect_error(list_volume_excerpts(rq = list(a = 1, b = 2)))
})
