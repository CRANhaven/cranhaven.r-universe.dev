test_that(
  "S3 print doesn't throw errors", {
    expect_no_error({
      sink(tempfile())
      openmpt:::print.openmpt(demo_mod())
      sink()
    })
  })

test_that(
  "S3 format doesn't throw errors", {
    expect_no_error({
      openmpt:::format.openmpt(demo_mod())
    })
  })
