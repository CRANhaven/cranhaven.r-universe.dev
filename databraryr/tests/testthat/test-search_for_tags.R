# search_for_tags() ---------------------------------------------------
test_that("search_for_tags returns character", {
  expect_true("character" %in% class(search_for_tags()))
})

test_that("search_for_tags rejects bad input parameters", {
  expect_error(search_for_tags(search_string = -1))
  expect_error(search_for_tags(search_string = 0))
  expect_error(search_for_tags(search_string = list(a=1, b=2)))
  expect_error(search_for_tags(search_string = TRUE))
  
  expect_error(search_for_tags(vb = -1))
  expect_error(search_for_tags(vb = 3))
  expect_error(search_for_tags(vb = "a"))
  expect_error(search_for_tags(vb = list(a=1, b=2)))
  
  expect_error(search_for_tags(rq = "a"))
  expect_error(search_for_tags(rq = -1))
  expect_error(search_for_tags(rq = c(2,3)))
  expect_error(search_for_tags(rq = list(a=1, b=2)))
})
