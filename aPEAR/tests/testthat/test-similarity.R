test_that("Jaccard matrix calculated correctly", {
  dt <- list(list(1, 2, 3, 4), list(2, 3, 4, 5), list(1, 3))
  res <- similarity(dt, method = 'jaccard')

  expect_equal(res[ 1, 2 ], 0.6)
  expect_equal(res[ 1, 3 ], 0.5)
  expect_equal(res[ 2, 3 ], 0.2)

  expect_equal(res[ 1, 2 ], res[ 2, 1 ])
  expect_equal(res[ 1, 3 ], res[ 3, 1 ])
  expect_equal(res[ 2, 3 ], res[ 3, 2 ])

  expect_equal(diag(res), c(1, 1, 1))
})

test_that("Cosine matrix calculated correctly", {
  dt <- list(list(1, 2, 3, 4), list(2, 3, 4, 5), list(1, 3))
  res <- similarity(dt, method = 'cosine')

  expect_equal(res[ 1, 2 ], 0.75)
  expect_equal(round(res[ 1, 3 ], 5), 0.70711)
  expect_equal(round(res[ 2, 3 ], 5), 0.35355)

  expect_equal(res[ 1, 2 ], res[ 2, 1 ])
  expect_equal(res[ 1, 3 ], res[ 3, 1 ])
  expect_equal(res[ 2, 3 ], res[ 3, 2 ])

  expect_equal(diag(res), c(1, 1, 1))
})

test_that("correlation matrix calculated", {
  dt <- list(list(1, 2, 3, 4), list(2, 3, 4, 5), list(1, 3))
  expect_no_error(res <- similarity(dt, method = 'correlation'))

  expect_equal(diag(res), c(1, 1, 1))
  expect_true(all(res >= 0))
  expect_true(all(res <= 1))
})
