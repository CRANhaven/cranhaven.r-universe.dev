# download_session_asset ---------------------------------------------------------
test_that("download_session_asset rejects bad input parameters", {
  expect_error(download_session_asset(asset_id = -1))
  expect_error(download_session_asset(asset_id = 0))
  expect_error(download_session_asset(asset_id = "a"))
  expect_error(download_session_asset(asset_id = list(a=1, b=2)))
  expect_error(download_session_asset(asset_id = TRUE))
  
  expect_error(download_session_asset(session_id = -1))
  expect_error(download_session_asset(session_id = 0))
  expect_error(download_session_asset(session_id = "a"))
  expect_error(download_session_asset(session_id = list(a=1, b=2)))
  expect_error(download_session_asset(session_id = TRUE))
  
  expect_error(download_session_asset(file_name = 3))
  expect_error(download_session_asset(file_name = list(a=1, b=2)))
  expect_error(download_session_asset(file_name = TRUE))
  
  expect_error(download_session_asset(target_dir = 3))
  expect_error(download_session_asset(target_dir = list(a=1, b=2)))
  expect_error(download_session_asset(target_dir = TRUE))
  
  expect_error(download_session_asset(vb = -1))
  expect_error(download_session_asset(vb = 3))
  expect_error(download_session_asset(vb = "a"))
  expect_error(download_session_asset(vb = list(a=1, b=2)))
  
  expect_error(download_session_asset(rq = "a"))
  expect_error(download_session_asset(rq = -1))
  expect_error(download_session_asset(rq = c(2,3)))
  expect_error(download_session_asset(rq = list(a=1, b=2)))
})
