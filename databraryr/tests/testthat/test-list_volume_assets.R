# list_volume_assets -----------------------------------------------
test_that("list_volume_assets returns data.frame", {
  expect_true((is.null(list_volume_assets()) ||
                 (
                   "data.frame" %in% class(list_volume_assets())
                 )))
})

test_that("list_volume_assets rejects bad input parameters", {
  expect_error(list_volume_assets(vol_id = -1))
  expect_error(list_volume_assets(vol_id = 0))
  expect_error(list_volume_assets(vol_id = "a"))
  expect_error(list_volume_assets(vol_id = list(a = 1, b = 2)))
  expect_error(list_volume_assets(vol_id = TRUE))
  
  expect_error(list_volume_assets(vb = -1))
  expect_error(list_volume_assets(vb = 3))
  expect_error(list_volume_assets(vb = "a"))
  expect_error(list_volume_assets(vb = list(a = 1, b = 2)))
  
  expect_error(list_session_activity(rq = "a"))
  expect_error(list_session_activity(rq = -1))
  expect_error(list_session_activity(rq = c(2, 3)))
  expect_error(list_session_activity(rq = list(a = 1, b = 2)))
})

test_that("list_volume_assets returns NULL for invalid/missing volume IDs",
          {
            expect_true(is.null(list_volume_assets(vol_id = 3)))
            expect_true(is.null(list_volume_assets(vol_id = 6)))
          })
