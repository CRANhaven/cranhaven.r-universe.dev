mod <- demo_mod()

test_that(
  "Set control character to NA is not accepted", {
    expect_error({
      control(mod, "play.at_end") <- NA_character_
    })
  })

test_that(
  "Set control real to NA is not accepted", {
    expect_error({
      control(mod, "play.pitch_factor") <- NA_real_
    })
  })

test_that(
  "Set control logical to NA is not accepted", {
    expect_error({
      control(mod, "load.skip_plugins") <- as.logical(NA)
    })
  })

test_that(
  "Set control integer to NA is not accepted", {
    expect_error({
      control(mod, "dither") <- NA_integer_
    })
  })

test_that(
  "Setting multiple control characters is not accepted", {
    expect_error({
      control(mod, "play.at_end") <- c("fadeout", "stop")
    })
  })

test_that(
  "Setting multiple control reals is not accepted", {
    expect_error({
      control(mod, "play.pitch_factor") <- c(1, 2)
    })
  })

test_that(
  "Setting multiple control logicals is not accepted", {
    expect_error({
      control(mod, "load.skip_plugins") <- c(TRUE, FALSE)
    })
  })

test_that(
  "Setting multiple control integers is not accepted", {
    expect_error({
      control(mod, "dither") <- c(1L, 2L)
    })
  })

test_that(
  "Setting incorrect control type is not accepted", {
    expect_error({
      control(mod, "load.skip_plugins") <- 4L
    })
  })

test_that(
  "Setting incorrect control type is not accepted", {
    expect_error({
      control(mod, "load.skip_plugins") <- 4L
    })
  })

test_that(
  "Module cannot be obtained from incorrect type/class", {
    expect_error({
      openmpt:::test_get_mod(1)
    })
  })

test_that(
  "Cannot retrieve non-existing render param", {
    expect_error({
      render_param(demo_mod(), "foobar")
    })
  })

test_that(
  "Cannot read module from text connection", {
    expect_error({
      con <- file(system.file("cyberrid", "cyberrid.mod", package = "openmpt"), "rt")
      tryCatch({
        mod <- read_mod(con)
      }, finally = {
        close(con)
      })
    })
  })
