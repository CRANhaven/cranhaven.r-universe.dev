df <- data.frame(entity_id = rep(1, 27),
                 timestamp = c(1, 2, 4, 10, 14, 18, 20, 21, 24, 25, 28, 29, 45, 80, 100,
                               120, 200, 270, 300, 340, 380, 450, 455, 460, 470, 475,
                               490),
                 longitude = c(5.1299311, 5.129979, 5.129597, 5.130028, 5.130555, 5.131083,
                               5.132101, 5.132704, 5.133326, 5.133904, 5.134746, 5.135613,
                               5.135613, 5.135613, 5.135613, 5.135613, 5.135613, 5.135613,
                               5.135613, 5.135613, 5.135613, 5.135613, 5.134746, 5.133904,
                               5.133326, 5.132704, 5.132101),
                 latitude = c(52.092839, 52.092827, 52.092571, 52.092292, 52.092076, 52.091821,
                              52.091420, 52.091219, 52.091343, 52.091651, 52.092138, 52.092698,
                              52.092698, 52.092698, 52.092698, 52.092698, 52.092698, 52.092698,
                              52.092698, 52.092698, 52.092698, 52.092138, 52.091651, 52.091343,
                              52.091219, 52.091420, 52.091821))
data.table::setDT(df)



test_that("events are returned when there are no moves", {
  testthat::expect_equal(returnStateEvents(stopFinder(data.table::copy(df), thetaD = 1000, thetaT = 200))$state_id, 1)
})


# test_that("events are returned when there are no moves", {
#   testthat::expect_equal(returnStateEvents(stopFinder(data.table::copy(df), thetaD = 1000, thetaT = 200))$state_id, 1)
# })
#
#
