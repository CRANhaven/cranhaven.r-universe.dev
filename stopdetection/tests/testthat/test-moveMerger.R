# set up data requiring a move merge

testevents <-
  data.table(
    state_id = 1:8,
    state = c("moving", "stopped", "moving", "stopped", "stopped", "moving", "stopped", "stopped"),
    meanlat = c(NA, 52.09259, NA, 52.09259, 52.09256, NA, 52.09258, 52.098),
    meanlon = c(NA, 5.135536, NA, 5.135536, 5.135535, NA, 5.135534, 5.138),
    newmeanlat = c(NA, 52.09259, NA, 52.09259, 52.09256, NA, 52.09258, 52.098),
    newmeanlon = c(NA, 5.135536, NA, 5.135536, 5.135535, NA, 5.135534, 5.138),
    new_state_id = 1:8,
    begin_time = c(1, 28, 469, 484, 925, 1366, 1396, 1837),
    end_time = c(27, 468, 483, 924, 1365, 1395, 1836, 2277),
    raw_travel_dist = c(100, NA, 100, NA, NA, 20, NA, NA),
    n_locations = c(11, 14, 2, 14, 14, 1, 14, 2)
  )

testthat::test_that("moveMerger creates new_state_id correctly", {
  testthat::expect_equal(moveMerger(copy(testevents))$new_state_id, c(1, 2, 3, 4, 5, 5, 6, 7))
  testthat::expect_equal(moveMerger(copy(testevents), max_locs = 1, max_time = 10)$new_state_id, c(1, 2, 3, 4, 5, 6, 7, 8))

})

