test_that("make_login_client rejects bad input parameters", {
  # expect_error(make_login_client(email = -1))
  # expect_error(make_login_client(email = c("a", "b")))
  # expect_error(make_login_client(email = list("a", "b")))
  # expect_error(make_login_client(email = TRUE))
  # 
  # expect_error(make_login_client(password = -1))
  # expect_error(make_login_client(password = 3))
  # expect_error(make_login_client(password = list("a", "b")))
  # expect_error(make_login_client(password = TRUE))
  # 
  # expect_error(make_login_client(store = -1))
  # expect_error(make_login_client(store = 'a'))
  # expect_error(make_login_client(store = list("a", "b")))
  # 
  # expect_error(make_login_client(overwrite = -1))
  # expect_error(make_login_client(overwrite = 'a'))
  # expect_error(make_login_client(overwrite = list("a", "b")))
  
  expect_error(make_login_client(vb = -1))
  expect_error(make_login_client(vb = 3))
  expect_error(make_login_client(vb = "a"))
  
  # expect_error(make_login_client(SERVICE = -1))
  # expect_error(make_login_client(SERVICE = TRUE))
  # expect_error(make_login_client(SERVICE = list("a", "b")))
  # 
  # expect_error(make_login_client(rq = 3))
  # expect_error(make_login_client(rq = "a"))
  # expect_error(make_login_client(rq = TRUE))
})