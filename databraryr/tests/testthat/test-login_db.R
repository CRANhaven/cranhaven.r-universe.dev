test_that("login_db rejects bad input parameters", {
  # expect_error(login_db(email = -1))
  # expect_error(login_db(email = c("a", "b")))
  # expect_error(login_db(email = list("a", "b")))
  # expect_error(login_db(email = TRUE))
  # 
  # expect_error(login_db(password = -1))
  # expect_error(login_db(password = 3))
  # expect_error(login_db(password = list("a", "b")))
  # expect_error(login_db(password = TRUE))
  # 
  # expect_error(login_db(store = -1))
  # expect_error(login_db(store = 'a'))
  # expect_error(login_db(store = list("a", "b")))
  # 
  # expect_error(login_db(overwrite = -1))
  # expect_error(login_db(overwrite = 'a'))
  # expect_error(login_db(overwrite = list("a", "b")))
  
  expect_error(login_db(vb = -1))
  expect_error(login_db(vb = 3))
  expect_error(login_db(vb = "a"))
  
  # expect_error(login_db(SERVICE = -1))
  # expect_error(login_db(SERVICE = TRUE))
  # expect_error(login_db(SERVICE = list("a", "b")))
  # 
  # expect_error(login_db(rq = 3))
  # expect_error(login_db(rq = "a"))
  # expect_error(login_db(rq = TRUE))
})
