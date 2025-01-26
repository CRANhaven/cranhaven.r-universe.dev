test_that("WAV renders without problems", {
  expect_no_error({
    convert_mod(demo_mod(), tempfile(fileext = ".wav"), duration = 1)
  })
})