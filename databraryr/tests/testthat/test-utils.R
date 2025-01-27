# get_file_duration ---------------------------------------------------------
test_that("get_file_duration returns an integer array", {
  expect_true(class(get_file_duration()) == "integer")
  expect_true(length(get_file_duration()) == 1)
})

test_that("get_file_duration rejects bad input parameters", {
  expect_error(get_file_duration(asset_id = "a"))
  expect_error(get_file_duration(asset_id = -1))
  expect_error(get_file_duration(asset_id = c(1, 3)))
  
  expect_error(get_file_duration(vb = "a"))
  expect_error(get_file_duration(vb = -1))
  expect_error(get_file_duration(vb = c(2, 3)))
})

# get_asset_segment_range ------------------------------------
test_that("get_asset_segment_range returns an integer array", {
  expect_true(class(get_asset_segment_range()) == "integer")
  expect_true(length(get_asset_segment_range()) == 2)
})

test_that("get_asset_segment_range rejects bad input parameters", {
  expect_error(get_asset_segment_range(vol_id = "a"))
  expect_error(get_asset_segment_range(vol_id = -1))
  expect_error(get_asset_segment_range(vol_id = c(1, 3)))
  
  expect_error(get_asset_segment_range(session_id = "a"))
  expect_error(get_asset_segment_range(session_id = -1))
  expect_error(get_asset_segment_range(session_id = c(1, 3)))
  
  expect_error(get_asset_segment_range(asset_id = "a"))
  expect_error(get_asset_segment_range(asset_id = -1))
  expect_error(get_asset_segment_range(asset_id = c(1, 3)))
  
  expect_error(get_asset_segment_range(vb = "a"))
  expect_error(get_asset_segment_range(vb = -1))
  expect_error(get_asset_segment_range(vb = c(2, 3)))
})

# get_permission_levels ---------------------------------------------------------
test_that("get_permission_levels returns a character array", {
  expect_true(class(get_permission_levels()) == "character")
  expect_true(length(get_permission_levels()) == 6)
})

test_that("get_permission_levels rejects bad input parameters", {
  expect_error(get_permission_levels(vb = "a"))
  expect_error(get_permission_levels(vb = -1))
  expect_error(get_permission_levels(vb = c(2, 3)))
})

# get_release_levels ---------------------------------------------------------
test_that("get_release_levels returns a character array", {
  expect_true(class(get_release_levels()) == "character")
  expect_true(length(get_release_levels()) == 4)
})

test_that("get_release_levels rejects bad input parameters", {
  expect_error(get_release_levels(vb = "a"))
  expect_error(get_release_levels(vb = -1))
  expect_error(get_release_levels(vb = c(2, 3)))
})

# get_supported_file_types ---------------------------------------------------------

test_that("get_supported_file_types returns data.frame", {
  expect_true(is.data.frame(get_supported_file_types()))
})

test_that("get_supported_file_types rejects bad input parameters", {
  expect_error(get_supported_file_types(vb = -1))
  expect_error(get_supported_file_types(vb = 3))
  expect_error(get_supported_file_types(vb = "a"))
})

# HHMMSSmmm_to_ms ---------------------------------------------------
test_that("HHMMSSmmm_to_ms returns number", {
  expect_true(class(HHMMSSmmm_to_ms()) == "numeric")
})

test_that("HHMMSSmmm_to_ms rejects bad input parameters", {
  expect_error(HHMMSSmmm_to_ms(HHMMSSmmm = -1))
  #expect_error(HHMMSSmmm_to_ms(HHMMSSmmm = "a"))
  #expect_error(HHMMSSmmm_to_ms(HHMMSSmmm = list(a=1, b=2)))
  expect_error(HHMMSSmmm_to_ms(HHMMSSmmm = TRUE))
})

# is_institution ---------------------------------------------------
test_that("is_institution returns logical", {
  expect_true(class(is_institution()) == "logical")
})

test_that("is_institution rejects bad input parameters", {
  expect_error(is_institution(party_id = -1))
  expect_error(is_institution(party_id = "a"))
  expect_error(is_institution(party_id = list(a = 1, b = 2)))
  expect_error(is_institution(party_id = TRUE))
})

# is_person ---------------------------------------------------
test_that("is_person returns logical", {
  expect_true(class(is_person()) == "logical")
})

test_that("is_person rejects bad input parameters", {
  expect_error(is_person(party_id = -1))
  expect_error(is_person(party_id = "a"))
  expect_error(is_person(party_id = list(a = 1, b = 2)))
  expect_error(is_person(party_id = TRUE))
})

# make_fn_portable ---------------------------------------------------
test_that("make_fn_portable returns string", {
  expect_true("character" %in% class(make_fn_portable("}*&!@#$%^+.pdf")))
})

test_that("make_fn_portable rejects bad input parameters", {
  expect_error(make_fn_portable(fn = -1))
  expect_error(make_fn_portable(fn = list(a = 1, b = 2)))
  expect_error(make_fn_portable(fn = TRUE))
  
  expect_error(make_fn_portable(vb = -1))
  expect_error(make_fn_portable(vb = list(a = 1, b = 2)))
  expect_error(make_fn_portable(vb = 'a'))
  
  expect_error(make_fn_portable(replace_regex = -1))
  expect_error(make_fn_portable(replace_regex = list(a = 1, b = 2)))
  expect_error(make_fn_portable(replace_regex = TRUE))
  
  expect_error(make_fn_portable(replacement_char = -1))
  expect_error(make_fn_portable(replacement_char = list(a = 1, b = 2)))
  expect_error(make_fn_portable(replacement_char = TRUE))
  
})
