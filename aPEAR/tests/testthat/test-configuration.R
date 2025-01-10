test_that('theme configuration handles missing parameters', {
  theme <- aPEAR.theme
  theme <- theme[ names(theme) != 'colorBy' ]

  expect_error(prepareTheme(theme))
  expect_error(prepareTheme(theme, colorBy = NULL))
  expect_error(prepareTheme(theme, colorBy = NA))
  expect_no_error(prepareTheme(theme, colorBy = 'NES'))
})

test_that('theme configuration inner and outer cutoffs are automatically adjusted for bad values', {
  theme <- aPEAR.theme

  expect_warning(adjusted <- prepareTheme(theme, innerCutoff = -1))
  expect_equal(adjusted$innerCutoff, 0)
  
  expect_warning(adjusted <- prepareTheme(theme, outerCutoff = -1))
  expect_equal(adjusted$outerCutoff, 0)

  expect_warning(adjusted <- prepareTheme(theme, innerCutoff = 10))
  expect_equal(adjusted$innerCutoff, 1)
  
  expect_warning(adjusted <- prepareTheme(theme, outerCutoff = 10))
  expect_equal(adjusted$outerCutoff, 1)
})

test_that('theme configuration takes in correct colorTypes', {
  theme <- aPEAR.theme

  expect_error(prepareTheme(theme, colorType = 'a'))
  expect_equal(prepareTheme(theme, colorType = 'n')$colorType, 'nes')
  expect_equal(prepareTheme(theme, colorType = 'p')$colorType, 'pval')
})

test_that('methods configuration handles missing parameters', {
  methods <- aPEAR.methods
  methods <- methods[ names(methods) != 'similarity' ]

  expect_error(prepareMethods(methods))
  expect_error(prepareMethods(methods, similarity = NULL))
  expect_error(prepareMethods(methods, similarity = NA))
  expect_no_error(prepareMethods(methods, similarity = 'jaccard'))
})

test_that('methods configuration minClusterSize is automatically adjusted for bad values', {
  methods <- aPEAR.methods

  expect_warning(adjusted <- prepareMethods(methods, minClusterSize = -10))
  expect_equal(adjusted$minClusterSize, 1)
})

test_that('methods configuration takes in correct values for similarity, clustering and cluster names', {
  methods <- aPEAR.methods

  expect_error(prepareMethods(methods, similarity = 'a'))
  expect_equal(prepareMethods(methods, similarity = 'j')$similarity, 'jaccard')
  expect_equal(prepareMethods(methods, similarity = 'cos')$similarity, 'cosine')
  expect_equal(prepareMethods(methods, similarity = 'cor')$similarity, 'correlation')

  expect_error(prepareMethods(methods, cluster = 'a'))
  expect_equal(prepareMethods(methods, cluster = 'm')$cluster, 'markov')
  expect_equal(prepareMethods(methods, cluster = 'h')$cluster, 'hier')
  expect_equal(prepareMethods(methods, cluster = 's')$cluster, 'spectral')

  expect_error(prepareMethods(methods, clusterName = 'a'))
  expect_error(prepareMethods(methods, clusterName = 'p'))
  expect_equal(prepareMethods(methods, clusterName = 'page')$clusterName, 'pagerank')
  expect_equal(prepareMethods(methods, clusterName = 'h')$clusterName, 'hits')
  
  expect_error(prepareMethods(methods, clusterName = 'n'))
  expect_error(prepareMethods(methods, clusterName = 'pval'))
  expect_equal(prepareMethods(methods, clusterName = 'n', clusterNameColumn = 'NES')$clusterName, 'nes')
  expect_equal(prepareMethods(methods, clusterName = 'pval', clusterNameColumn = 'pval')$clusterName, 'pval')
})
