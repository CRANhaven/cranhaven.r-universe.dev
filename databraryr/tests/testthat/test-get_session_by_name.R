# get_session_by_name ---------------------------------------------------------
test_that("get_session_by_name returns a list or is NULL.", {
  expect_true((is.null(get_session_by_name()) ||
                 ("list" %in% class(get_session_by_name()))))
})

test_that("get_session_by_name rejects bad input parameters", {
  expect_error(get_session_by_name(session_id = "a"))
  expect_error(get_session_by_name(session_id = -1))
  expect_error(get_session_by_name(session_id = c(2,3)))
  expect_error(get_session_by_name(session_id = TRUE))
  
  expect_error(get_session_by_name(vol_id = -1))
  expect_error(get_session_by_name(vol_id = "a"))
  expect_error(get_session_by_name(vol_id = TRUE))
  
  expect_error(get_session_by_name(vb = "a"))
  expect_error(get_session_by_name(vb = -1))
  expect_error(get_session_by_name(vb = c(2,3)))
  
  expect_error(get_session_by_name(rq = "a"))
  expect_error(get_session_by_name(rq = -1))
  expect_error(get_session_by_name(rq = c(2,3)))
  expect_error(get_session_by_name(rq = list(a=1, b=2)))
})