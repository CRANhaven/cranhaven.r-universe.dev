# list_session_assets ---------------------------------------------------------
test_that("list_session_assets returns data.frame or is NULL", {
  expect_true((is.null(list_session_assets()) ||
                 ("data.frame" %in% class(list_session_assets()))))
})

test_that("list_session_assets rejects bad input parameters", {
  expect_error(list_session_assets(session_id = "a"))
  expect_error(list_session_assets(session_id = c(1,2)))
  expect_error(list_session_assets(session_id = TRUE))
  expect_error(list_session_assets(session_id = list(a=1, b=2)))
  expect_error(list_session_assets(session_id = -1))
  
  expect_error(list_session_assets(vb = -1))
  expect_error(list_session_assets(vb = 3))
  expect_error(list_session_assets(vb = "a"))
  expect_error(list_session_assets(vb = list(a=1, b=2)))
  
  expect_error(list_session_assets(rq = "a"))
  expect_error(list_session_assets(rq = -1))
  expect_error(list_session_assets(rq = c(2,3)))
  expect_error(list_session_assets(rq = list(a=1, b=2)))
})
