#download_volume_zip ---------------------------------------------------
test_that("download_volume_zip rejects bad input parameters", {
  expect_error(download_volume_zip(vol_id = -1))
  expect_error(download_volume_zip(vol_id = "a"))
  expect_error(download_volume_zip(vol_id = list(a=1, b=2)))
  expect_error(download_volume_zip(vol_id = TRUE))
  
  expect_error(download_volume_zip(out_dir = -1))
  expect_error(download_volume_zip(out_dir = list(a=1, b=2)))
  expect_error(download_volume_zip(out_dir = TRUE))
  
  expect_error(download_volume_zip(file_name = -1))
  expect_error(download_volume_zip(file_name = list(a=1, b=2)))
  expect_error(download_volume_zip(file_name = TRUE))
  
  expect_error(download_volume_zip(vb = -1))
  expect_error(download_volume_zip(vb = 3))
  expect_error(download_volume_zip(vb = "a"))
  expect_error(download_volume_zip(vb = list(a=1, b=2)))
})


test_that("download_volume_zip returns string", {
  expect_true(is.character(download_volume_zip()))
})
