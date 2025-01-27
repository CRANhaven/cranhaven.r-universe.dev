# search_for_keywords() ---------------------------------------------------
test_that("search_for_keywords returns list", {
  expect_true(class(search_for_keywords()) == "list")
})

test_that("search_for_keywords rejects bad input parameters", {
  expect_error(search_for_keywords(search_string = -1))
  expect_error(search_for_keywords(search_string = 0))
  expect_error(search_for_keywords(search_string = list(a=1, b=2)))
  expect_error(search_for_keywords(search_string = TRUE))
  
  expect_error(search_for_keywords(vb = -1))
  expect_error(search_for_keywords(vb = 3))
  expect_error(search_for_keywords(vb = "a"))
  expect_error(search_for_keywords(vb = list(a=1, b=2)))
  
  expect_error(search_for_keywords(rq = "a"))
  expect_error(search_for_keywords(rq = -1))
  expect_error(search_for_keywords(rq = c(2,3)))
  expect_error(search_for_keywords(rq = list(a=1, b=2)))
})
