mod <- demo_mod()

test_that("Audio plays if audio device is present", {
  expect_true({
    sink(tempfile())
    success <- tryCatch({
      play(mod, duration = 1)
      TRUE
    }, error = function(e) FALSE)
    sink()
    success == has_audio_device()
  })
})

test_that("Progress report throws no errors", {
  expect_no_error({
    openmpt:::test_omt_progress(mod, "none")
    openmpt:::test_omt_progress(mod, "time")
    openmpt:::test_omt_progress(mod, "vu")
  })
})