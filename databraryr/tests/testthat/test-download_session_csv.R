# download_session_csv ---------------------------------------------------------
test_that("download_session_csv rejects bad input parameters", {
  expect_error(download_session_csv(vol_id = -1))
  expect_error(download_session_csv(vol_id = 0))
  expect_error(download_session_csv(vol_id = "a"))
  expect_error(download_session_csv(vol_id = list(a=1, b=2)))
  expect_error(download_session_csv(vol_id = TRUE))
  
  expect_error(download_session_csv(file_name = 3))
  expect_error(download_session_csv(file_name = list(a=1, b=2)))
  expect_error(download_session_csv(file_name = TRUE))
  
  expect_error(download_session_csv(target_dir = 3))
  expect_error(download_session_csv(target_dir = list(a=1, b=2)))
  expect_error(download_session_csv(target_dir = TRUE))

  expect_error(download_session_csv(as_df = -1))
  expect_error(download_session_csv(as_df = 3))
  expect_error(download_session_csv(as_df = "a"))
  expect_error(download_session_csv(as_df = list(a=1, b=2)))
  
  expect_error(download_session_csv(vb = -1))
  expect_error(download_session_csv(vb = 3))
  expect_error(download_session_csv(vb = "a"))
  expect_error(download_session_csv(vb = list(a=1, b=2)))
})
