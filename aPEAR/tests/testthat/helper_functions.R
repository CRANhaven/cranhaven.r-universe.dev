randomSimilarity <- function(dimensions = 10) {
  library(dplyr)
  counts <- rnorm(dimensions * dimensions) %>%
    rescale() %>%
    matrix(nrow = dimensions, ncol = dimensions)

  diag(counts) <- 1

  counts <- pmax(counts, t(counts))
  rownames(counts) <- make.names(seq(from = 1, to = dimensions))
  colnames(counts) <- make.names(seq(from = 1, to = dimensions))

  return(counts)
}

rescale <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

clusterProfilerGSEA <- function() {
  readRDS(testthat::test_path("fixtures", "clusterProfilerGSEA.RDS"))
}

clusterProfilerORA <- function() {
  readRDS(testthat::test_path("fixtures", "clusterProfilerORA.RDS"))
}

customEnrichment <- function() {
  readRDS(testthat::test_path("fixtures", "customEnrichment.RDS"))
}

gprofilerEnrichment <- function() {
  readRDS(testthat::test_path("fixtures", "gprofiler2.RDS"))
}
