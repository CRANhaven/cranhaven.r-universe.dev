# list_session_activity ---------------------------------------------------------
test_that("list_session_activity returns data.frame or is NULL", {
  expect_true((is.null(list_session_activity()) ||
                 ("data.frame" %in% class(list_session_activity()))))
})

test_that("list_session_activity rejects bad input parameters", {
  expect_error(list_session_activity(session_id = "a"))
  expect_error(list_session_activity(session_id = c(1,2)))
  expect_error(list_session_activity(session_id = TRUE))
  expect_error(list_session_activity(session_id = list(a=1, b=2)))
  expect_error(list_session_activity(session_id = -1))
  
  expect_error(list_session_activity(vb = -1))
  expect_error(list_session_activity(vb = 3))
  expect_error(list_session_activity(vb = "a"))
  expect_error(list_session_activity(vb = list(a=1, b=2)))
  
  expect_error(list_session_activity(rq = "a"))
  expect_error(list_session_activity(rq = -1))
  expect_error(list_session_activity(rq = c(2,3)))
  expect_error(list_session_activity(rq = list(a=1, b=2)))
})
