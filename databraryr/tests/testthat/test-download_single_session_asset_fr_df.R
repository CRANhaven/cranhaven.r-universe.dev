# download_single_session_asset_fr_df ---------------------------------------------------------
test_that("download_single_session_asset_fr_df rejects bad input parameters",
          {
            expect_error(download_single_session_asset_fr_df(session_asset_entry = 3))
            expect_error(download_single_session_asset_fr_df(session_asset_entry = "a"))
            expect_error(download_single_session_asset_fr_df(session_asset_entry = TRUE))
            expect_error(download_single_session_asset_fr_df(session_asset_entry = list(a = 1, b =
                                                                                   2)))
            
            expect_error(download_single_session_asset_fr_df(target_dir = 3))
            expect_error(download_single_session_asset_fr_df(target_dir = list(a = 1, b =
                                                                          2)))
            expect_error(download_single_session_asset_fr_df(target_dir = TRUE))
            
            expect_error(download_single_session_asset_fr_df(add_session_subdir = -1))
            expect_error(download_single_session_asset_fr_df(add_session_subdir = 3))
            expect_error(download_single_session_asset_fr_df(add_session_subdir = "a"))
            expect_error(download_single_session_asset_fr_df(add_session_subdir = list(a = 1, b = 2)))

            expect_error(download_single_session_asset_fr_df(overwrite = -1))
            expect_error(download_single_session_asset_fr_df(overwrite = 3))
            expect_error(download_single_session_asset_fr_df(overwrite = "a"))
            expect_error(download_single_session_asset_fr_df(overwrite = list(a = 1, b = 2)))

            expect_error(download_single_session_asset_fr_df(make_portable_fn = -1))
            expect_error(download_single_session_asset_fr_df(make_portable_fn = 3))
            expect_error(download_single_session_asset_fr_df(make_portable_fn = "a"))
            expect_error(download_single_session_asset_fr_df(make_portable_fn = list(a = 1, b = 2)))

            expect_error(download_single_session_asset_fr_df(timeout_secs = -1))
            expect_error(download_single_session_asset_fr_df(timeout_secs = TRUE))
            expect_error(download_single_session_asset_fr_df(timeout_secs = "a"))
            expect_error(download_single_session_asset_fr_df(timeout_secs = list(a = 1, b = 2)))
            
            expect_error(download_single_session_asset_fr_df(vb = -1))
            expect_error(download_single_session_asset_fr_df(vb = 3))
            expect_error(download_single_session_asset_fr_df(vb = "a"))
            expect_error(download_single_session_asset_fr_df(vb = list(a = 1, b = 2)))
            
            expect_error(download_single_session_asset_fr_df(rq = "a"))
            expect_error(download_single_session_asset_fr_df(rq = -1))
            expect_error(download_single_session_asset_fr_df(rq = c(2, 3)))
            expect_error(download_single_session_asset_fr_df(rq = list(a = 1, b = 2)))
          })
