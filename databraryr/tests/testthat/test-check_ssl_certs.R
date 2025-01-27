test_that("check_ssl_certs rejects bad input paramaters", {
  expect_error(check_ssl_certs(host = -1))
  expect_error(check_ssl_certs(host = list(a = 1, b = 2)))
  expect_error(check_ssl_certs(host = TRUE))
})
