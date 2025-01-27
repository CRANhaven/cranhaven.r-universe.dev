# download_video ---------------------------------------------------------
test_that("download_video rejects bad input parameters", {
  expect_error(download_asset(asset_id = -1))
  expect_error(download_asset(asset_id = 0))
  expect_error(download_asset(asset_id = "a"))
  expect_error(download_asset(asset_id = list(a=1, b=2)))
  expect_error(download_asset(asset_id = TRUE))
  
  expect_error(download_asset(session_id = -1))
  expect_error(download_asset(session_id = 0))
  expect_error(download_asset(session_id = "a"))
  expect_error(download_asset(session_id = list(a=1, b=2)))
  expect_error(download_asset(session_id = TRUE))

  expect_error(download_video(file_name = 3))
  expect_error(download_video(file_name = list(a=1, b=2)))
  expect_error(download_video(file_name = TRUE))
  
  expect_error(download_video(target_dir = 3))
  expect_error(download_video(target_dir = list(a=1, b=2)))
  expect_error(download_video(target_dir = TRUE))
  
  expect_error(download_video(vb = -1))
  expect_error(download_video(vb = 3))
  expect_error(download_video(vb = "a"))
  expect_error(download_video(vb = list(a=1, b=2)))
})

# Removing 2023-10-09 until Databrary system responds more quickly
# test_that("download_video returns character string", {
#   expect_true(is.character(download_video()))
# })
