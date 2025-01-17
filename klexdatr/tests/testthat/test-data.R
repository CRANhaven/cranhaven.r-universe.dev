test_that("data", {
  expect_error(chk::check_data(
    section,
    list(
      Section = factor(1),
      Habitat = factor(c("Lentic", "Lentic", "Lotic"),
        levels = c("Lentic", "Lotic")
      ),
      Bounded = c(TRUE, TRUE, FALSE)
    ),
    key = "Section"
  ), NA)

  expect_error(chk::chk_is(section, "sf"), NA)

  expect_error(chk::check_data(
    station,
    list(
      Station = factor(1),
      Section = factor(1)
    ),
    key = "Station"
  ), NA)

  expect_error(chk::chk_is(station, "sf"), NA)

  expect_error(chk::chk_join(tibble::as_tibble(station),
                            tibble::as_tibble(section), "Section"), NA)

  expect_error(chk::check_data(
    deployment,
    list(
      Station = factor(1),
      Receiver = factor(1),
      DateTimeReceiverIn = Sys.time(),
      DateTimeReceiverOut = Sys.time()
    ),
    key = c("Station", "Receiver", "DateTimeReceiverIn")
  ), NA)

  expect_error(chk::chk_join(deployment, tibble::as_tibble(station), "Station"), NA)

  expect_error(chk::check_data(
    capture,
    list(
      Capture = factor(1),
      DateTimeCapture = Sys.time(),
      SectionCapture = factor(1),
      Species = factor(""),
      Length = c(200L, 1000L),
      Weight = c(0.5, 10, NA),
      Reward1 = c(0L, 10L, 100L),
      Reward2 = c(0L, 10L, 100L, NA),
      DateTimeTagExpire = Sys.time()
    ),
    key = c("Capture")
  ), NA)

  expect_error(chk::chk_join(capture, tibble::as_tibble(section), c("SectionCapture" = "Section")), NA)

  expect_error(chk::check_data(
    recapture,
    list(
      DateTimeRecapture = Sys.time(),
      Capture = factor(1),
      SectionRecapture = factor(c(1, NA)),
      TBarTag1 = TRUE,
      TBarTag2 = TRUE,
      TagsRemoved = TRUE,
      Released = TRUE,
      Public = TRUE
    ),
    key = c("DateTimeRecapture", "Capture")
  ), NA)

  expect_error(chk::chk_join(recapture, capture, "Capture"), NA)
  #  missing values
  #  expect_error(chk::chk_join(recapture, section@data,
  #                                   c("SectionRecapture" = "Section")))

  expect_error(chk::check_data(
    detection,
    list(
      DateTimeDetection = Sys.time(),
      Capture = factor(1),
      Receiver = factor(1),
      Detections = c(1L, 300L)
    ),
    key = c("DateTimeDetection", "Capture", "Receiver")
  ), NA)

  expect_error(chk::chk_join(detection, capture, "Capture"), NA)
})
