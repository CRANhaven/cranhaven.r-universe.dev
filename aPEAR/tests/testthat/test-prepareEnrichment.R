test_that("clusterProfiler input is accepted", {
  enrich <- clusterProfilerGSEA()

  expect_no_error(data <- prepareEnrichment(enrich@result, requireTheme = FALSE))
  expect_no_error(data <- prepareEnrichment(enrich@result, requireTheme = TRUE))

  enrich <- clusterProfilerORA()

  expect_no_error(data <- prepareEnrichment(enrich@result, requireTheme = FALSE))

  # Adjust theme for ORA
  theme <- aPEAR.theme
  theme$colorBy <- 'pvalue'
  theme$nodeSize <- 'Count'
  expect_no_warning(data <- prepareEnrichment(enrich@result, requireTheme = TRUE, theme = theme))
})

test_that("custom input is accepted", {
  enrich <- customEnrichment()

  expect_no_error(data <- prepareEnrichment(enrich, requireTheme = FALSE))
  expect_error(data <- prepareEnrichment(enrich, requireTheme = TRUE))

  theme <- aPEAR.theme
  theme$colorBy <- 'nes'
  theme$nodeSize <- 'size'

  expect_no_error(data <- prepareEnrichment(enrich, requireTheme = TRUE, theme = theme))
})

test_that("pathways are ranked correctly when clusterName 'nes' or 'pval'", {
  # Least important pathway should have lowest score (min NES and max pval)
  enrich <- clusterProfilerGSEA()

  methods <- aPEAR.methods
  methods$clusterName <- 'nes'
  methods$clusterNameColumn <- 'NES'
  data <- prepareEnrichment(enrich@result, requireTheme = FALSE, methods = methods)

  expect_true(all(data$enrichment[ , Ranks ] %in% 1:nrow(enrich@result)))
  expect_true(data$enrichment[ which.min(abs(NES)), Ranks ] == 1)
  expect_true(data$enrichment[ which.max(abs(NES)), Ranks ] == nrow(enrich@result))

  methods <- aPEAR.methods
  methods$clusterName <- 'pval'
  methods$clusterNameColumn <- 'pvalue'
  data <- prepareEnrichment(enrich@result, requireTheme = FALSE, methods = methods)

  expect_true(all(data$enrichment[ , Ranks ] %in% 1:nrow(enrich@result)))
  expect_true(1 %in% data$enrichment[ pvalue == max(pvalue), Ranks ])
  expect_true(nrow(enrich@result) %in% data$enrichment[ pvalue == min(pvalue), Ranks ])
})

test_that("theme parameters are adjusted for clusterProfiler ORA", {
  enrich <- clusterProfilerORA()

  suppressWarnings(expect_no_error(data <- prepareEnrichment(enrich@result, requireTheme = TRUE)))

  theme <- aPEAR.theme
  theme$colorBy <- 'pvalue'
  theme$colorType <- 'pval'

  expect_warning(data <- prepareEnrichment(enrich@result, requireTheme = TRUE, theme = theme))
  expect_true(data$enrichment[ , min(Color) ] <= theme$pCutoff)

  expectColors <- log10(enrich@result[ , c('pvalue') ])
  expectColors[ expectColors <= theme$pCutoff ] <- theme$pCutoff

  expect_true(all(data$enrichment[ , list(Color) ] == expectColors))
  expect_true(all(data$enrichment[ , list(Size) ] == enrich@result[ , c('Count') ]))

  theme <- aPEAR.theme
  theme$nodeSize <- 'Count'
  expect_warning(data <- prepareEnrichment(enrich@result, requireTheme = TRUE, theme = theme))
  expect_true(data$enrichment[ , min(Color) ] <= theme$pCutoff)

  expectColors <- log10(enrich@result[ , c('pvalue') ])
  expectColors[ expectColors <= theme$pCutoff ] <- theme$pCutoff

  expect_true(all(data$enrichment[ , Color ] == expectColors))
  expect_true(all(data$enrichment[ , Size ] == enrich@result[ , c('Count') ]))
})

test_that("theme parameters are adjusted for clusterProfiler GSEA", {
  enrich <- clusterProfilerGSEA()

  expect_no_error(data <- prepareEnrichment(enrich@result, requireTheme = TRUE))
  expect_true(all(data$enrichment[ , Color ] == enrich@result[ , 'NES' ]))
  expect_true(all(data$enrichment[ , Size ] == enrich@result[ , 'setSize' ]))
})

test_that("theme parameters are adjusted for gProfiler",  {
  enrich <- gprofilerEnrichment()
  enrich <- enrich$result

  suppressWarnings(expect_warning(expect_no_error(data <- prepareEnrichment(enrich))))
  # Make sure the original data remains unchanged
  expect_true(!('Description' %in% colnames(enrich)))

  theme <- aPEAR.theme

  expectColors <- log10(enrich[ , c('p_value') ])
  expectColors[ expectColors <= theme$pCutoff ] <- theme$pCutoff

  expect_true(all(data$enrichment[ , list(Color) ] == expectColors))
  expect_true(all(data$enrichment[ , list(Size) ] == enrich[ , c('term_size') ]))

  theme <- aPEAR.theme
  theme$nodeSize <- 'query_size'
  expect_warning(data <- prepareEnrichment(enrich, requireTheme = TRUE, theme = theme))
  expect_true(data$enrichment[ , min(Color) ] <= theme$pCutoff)
  expect_true(all(data$enrichment[ , list(Size) ] == enrich[ , c('query_size') ]))

  theme <- aPEAR.theme
  theme$colorBy <- 'intersection_size'
  expect_warning(data <- prepareEnrichment(enrich, requireTheme = TRUE, theme = theme))
  expect_true(all(data$enrichment[ , list(Color) ] == enrich[ , c('intersection_size') ]))
})
