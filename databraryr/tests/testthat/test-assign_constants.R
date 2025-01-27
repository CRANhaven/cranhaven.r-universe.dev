test_that("assign_constants returns list", {
  expect_true("list" %in% class(assign_constants()))
})

test_that("assign_constants rejects bad input parameters", {
  expect_error(assign_constants(vb = -1))
  expect_error(assign_constants(vb = 3))
  expect_error(assign_constants(vb = "a"))
  
  expect_error(assign_constants(rq = -1))
  expect_error(assign_constants(rq = 3))
  expect_error(assign_constants(rq = "a"))
})
