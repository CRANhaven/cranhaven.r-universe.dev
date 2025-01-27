test_that("logout_db rejects bad input parameters", {
  expect_error(logout_db(vb = -1))
  expect_error(logout_db(vb = 3))
  expect_error(logout_db(vb = "a"))
  expect_error(logout_db(vb = c(TRUE, FALSE)))
})

test_that("logout_db returns logical", {
  expect_true(is.logical(logout_db()))
})

# Actually log out
logout_db()
