test_that("pagerank returns correct data format", {
  set.seed(345793)
  sim <- randomSimilarity(100)
  clusters <- sample(1:10, size = 100, replace = TRUE)
  names(clusters) <- rownames(sim)
  clusters <- clusters %>%
    tibble::enframe(value = 'ClusterID', name = 'Pathway') %>%
    as.data.table()

  expect_no_error(ranks <- pagerank(sim, clusters))
  expect_equal(length(ranks), nrow(clusters))
  expect_true(all(names(ranks) %in% clusters[ , Pathway ]))
  expect_true(is.vector(ranks))
})

test_that("hits returns correct data format", {
  set.seed(345793)
  sim <- randomSimilarity(100)
  clusters <- sample(1:10, size = 100, replace = TRUE)
  names(clusters) <- rownames(sim)
  clusters <- clusters %>%
    tibble::enframe(value = 'ClusterID', name = 'Pathway') %>%
    as.data.table()

  expect_no_error(ranks <- hits(sim, clusters))
  expect_equal(length(ranks), nrow(clusters))
  expect_true(all(names(ranks) %in% clusters[ , Pathway ]))
  expect_true(is.vector(ranks))
})

test_that("selectClusterName returns correct result", {
  set.seed(438693)
  scores <- sample(1:100, size = 50, replace = TRUE) / 100
  names(scores) <- make.names(1:50)

  clusters <- sample(1:5, size = 50, replace = TRUE)
  names(clusters) <- make.names(1:50)
  clusters[ 1:5 ] <- 1:5
  scores[ 1:5 ] <- 1.1
  clusters <- clusters %>%
    tibble::enframe(value = 'ClusterID', name = 'Pathway') %>%
    as.data.table()

  expect_no_error(clusterNames <- selectClusterName(scores, clusters))

  expect_equal(nrow(clusterNames), 5)
  expect_true(all(clusterNames[ 1:5, Cluster ] == c('X1', 'X2', 'X3', 'X4', 'X5')))
})

test_that("clusterName returns something for all implemented methods", {
  set.seed(345793)
  sim <- randomSimilarity(100)
  clusters <- sample(1:10, size = 100, replace = TRUE)
  names(clusters) <- rownames(sim)
  clusters <- clusters %>%
    tibble::enframe(value = 'ClusterID', name = 'Pathway') %>%
    as.data.table()

  expect_no_error(clusterNames <- clusterName(sim = sim, clusters = clusters, method = 'page'))
  expect_equal(nrow(clusterNames), 10)

  expect_no_error(clusterNames <- clusterName(sim = sim, clusters = clusters, method = 'h'))
  expect_equal(nrow(clusterNames), 10)
})
