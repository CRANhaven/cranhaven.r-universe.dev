customEnrichment.create <- function() {
  enrich <- readRDS(testthat::test_path("fixtures", "clusterProfilerGSEA.RDS"))

  enrich <- enrich@result %>%
  	as.data.table() %>%
  	setnames('setSize', 'size') %>%
  	setnames('NES', 'nes') %>%
  	setnames('core_enrichment', 'pathwayGenes') %>%
  	.[ , list(Description, size, nes, pathwayGenes, pvalue) ]

  saveRDS(enrich, testthat::test_path("fixtures", "customEnrichment.RDS"))
}

clusterProfilerGSEA.create <- function() {
  data(geneList)

  enrich <- clusterProfiler::gseGO(geneList, OrgDb = org.Hs.eg.db, ont = 'CC')

  saveRDS(enrich, testthat::test_path("fixtures", "clusterProfilerGSEA.RDS"))
}

clusterProfilerORA.create <- function() {
  data(geneList)

  significantUp <- names(geneList)[ geneList > 2 ]
  enrich <- clusterProfiler::enrichGO(significantUp, OrgDb = org.Hs.eg.db, ont = 'CC', universe = names(geneList))

  saveRDS(enrich, testthat::test_path("fixtures", "clusterProfilerORA.RDS"))
}

gprofiler.create() <- function() {
  data(geneList)

  query <- geneList[ c(1:1000, (length(geneList) - 1000):(length(geneList))) ] %>% names()
  enrich <- gprofiler2::gost(query, organism = 'hsapiens', evcodes = TRUE)

  saveRDS(enrich, testthat::test_path("fixtures", "gprofiler2.RDS"))
}
