# search_for_funder() ---------------------------------------------------
test_that("search_for_funder returns NULL or list", {
 expect_true((is.null(search_for_funder()) ||"list" %in% class(search_for_funder())))
})

test_that("search_for_funder rejects bad input parameters", {
  expect_error(search_for_funder(search_string = -1))
  expect_error(search_for_funder(search_string = 0))
  expect_error(search_for_funder(search_string = list(a=1, b=2)))
  expect_error(search_for_funder(search_string = TRUE))
  
  expect_error(search_for_funder(vb = -1))
  expect_error(search_for_funder(vb = 3))
  expect_error(search_for_funder(vb = "a"))
  expect_error(search_for_funder(vb = list(a=1, b=2)))
  
  expect_error(search_for_funder(rq = "a"))
  expect_error(search_for_funder(rq = -1))
  expect_error(search_for_funder(rq = c(2,3)))
  expect_error(search_for_funder(rq = list(a=1, b=2)))
})
