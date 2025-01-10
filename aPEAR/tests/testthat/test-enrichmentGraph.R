test_that("enrichment network is created", {
  enrich <- clusterProfilerGSEA()
  expect_no_error(p <- enrichmentNetwork(enrich@result))

  enrich <- clusterProfilerORA()
  suppressWarnings(expect_warning(p <- enrichmentNetwork(enrich@result, cluster = 'h', colorType = 'pval', drawEllipses = TRUE)))

  enrich <- customEnrichment()
  expect_no_error(p <- enrichmentNetwork(enrich, colorBy = 'nes', nodeSize = 'size'))
})
