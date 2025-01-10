test_that("spectral clustering returns correct data format", {
  set.seed(548649)
  sim <- randomSimilarity(50)

  clusters <- spectral(sim, verbose = FALSE)

  expect_equal(length(clusters), ncol(sim))
  expect_equal(sum(table(clusters)), ncol(sim))
  expect_equal(names(clusters), colnames(sim))
})

test_that("hierarchical clustering returns correct data format", {
  set.seed(548649)
  sim <- randomSimilarity(50)

  clusters <- hierarchical(sim, verbose = FALSE)

  expect_equal(length(clusters), ncol(sim))
  expect_equal(sum(table(clusters)), ncol(sim))
  expect_equal(names(clusters), colnames(sim))
})

test_that("markov clustering returns correct data format", {
  set.seed(548649)
  sim <- randomSimilarity(50)

  clusters <- markov(sim, verbose = FALSE)

  expect_equal(length(clusters), ncol(sim))
  expect_equal(sum(table(clusters)), ncol(sim))
  expect_equal(names(clusters), colnames(sim))
})

test_that("pathwayClusters handles minClusterSize errors", {
  set.seed(548649)
  sim <- randomSimilarity(25)

  expect_error(pathwayClusters(sim, minClusterSize = 30))
  expect_error(pathwayClusters(sim, minClusterSize = NULL))
  
  expect_warning(pathwayClusters(sim, minClusterSize = NA))
  expect_warning(pathwayClusters(sim, minClusterSize = 0))
})

test_that("pathwayClusters returns something for all implemented methods", {
  set.seed(548649)
  sim <- randomSimilarity(25)

  clusters <- pathwayClusters(sim, method = 'h')
  expect_equal(nrow(clusters), ncol(sim))

  clusters <- pathwayClusters(sim, method = 'm')
  expect_equal(nrow(clusters), ncol(sim))

  clusters <- pathwayClusters(sim, method = 's')
  expect_equal(nrow(clusters), ncol(sim))
})

test_that("pathwayClusters filters out by cluster size", {
  set.seed(548649)
  sim <- randomSimilarity(25)

  clusters <- pathwayClusters(sim, method = 's', minClusterSize = 13)
  expect_true(nrow(clusters) < ncol(sim))
  expect_true(all(clusters[ , table(ClusterID) ] >= 13))
})

