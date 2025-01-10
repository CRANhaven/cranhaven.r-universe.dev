testevents <-
  data.table(
    state_id = 1:7,
    state = c("moving", "stopped", "moving", "stopped", "stopped", "stopped", "stopped"),
    meanlat = c(NA, 52.09259, NA, 52.09259, 52.09256, 52.09258, 52.098),
    meanlon = c(NA, 5.135536, NA, 5.135536, 5.135535, 5.135534, 5.138),
    newmeanlat = c(NA, 52.09259, NA, 52.09259, 52.09256, 52.09258, 52.098),
    newmeanlon = c(NA, 5.135536, NA, 5.135536, 5.135535, 5.135534, 5.138),
    new_state_id = 1:7,
    ts = c(27, 441, 15, 441, 441, 441, 441),
    n_locations = c(11, 14, 2, 14, 14, 14, 2)
  )
te2 <- copy(rbindlist(list(testevents, testevents)))
te2[, state_id := 1:14]

testthat::test_that("stopMerger creates new_state_id correctly", {
  testthat::expect_equal(stopMerger(copy(testevents), 200)$new_state_id, c(1, 2, 3, 4, 4, 4, 5))
  testthat::expect_equal(stopMerger(copy(testevents), 3)$new_state_id, c(1, 2, 3, 4, 5, 5, 6))
  testthat::expect_equal(stopMerger(copy(te2), 200)$new_state_id, c(1, 2, 3, 4, 4, 4, 5, 6, 7, 8, 9, 9, 9, 10))
})
