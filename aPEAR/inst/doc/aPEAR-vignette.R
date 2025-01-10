## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7.2,
  fig.height = 4.3,
  fig.retina = 2
)

## ---- message = FALSE, warning = FALSE----------------------------------------
# Load all the packages:
library(data.table)
library(ggplot2)
library(dplyr)
library(stringr)
library(clusterProfiler)
library(DOSE)
library(org.Hs.eg.db)
library(aPEAR)
data(geneList)

# Perform enrichment using clusterProfiler
set.seed(42)
enrich <- gseGO(geneList, OrgDb = org.Hs.eg.db, ont = 'CC')

## ---- fig.height = 6----------------------------------------------------------
set.seed(654824)
enrichmentNetwork(enrich@result)

## ---- include = FALSE, echo = FALSE-------------------------------------------
enrichmentData <- enrich@result %>%
  as.data.table() %>%
  .[ 1:5 ] %>%
  .[ , list(Description, pathwayGenes = core_enrichment, NES, Size = setSize) ] %>%
  .[ , pathwayGenes := str_trunc(pathwayGenes, 20) ]

## -----------------------------------------------------------------------------
enrichmentData[ 1:5 ]

## ---- include = FALSE, echo = FALSE-------------------------------------------
enrichmentData <- enrich@result %>%
  as.data.table() %>%
  .[ , list(Description, pathwayGenes = core_enrichment, NES, Size = setSize) ]

## -----------------------------------------------------------------------------
p <- enrichmentNetwork(enrichmentData, colorBy = 'NES', nodeSize = 'Size', verbose = TRUE)

## -----------------------------------------------------------------------------
set.seed(348934)
enrichmentNetwork(enrich@result, colorBy = 'pvalue', colorType = 'pval', pCutoff = -5)

## -----------------------------------------------------------------------------
clusters <- findPathClusters(enrich@result, cluster = 'hier', minClusterSize = 6)

clusters$clusters[ 1:5 ]

pathways <- clusters$clusters[ 1:5, Pathway ]
clusters$similarity[ pathways, pathways ]

## -----------------------------------------------------------------------------
set.seed(238923)
plotPathClusters(
  enrichment = enrich@result,
  sim = clusters$similarity,
  clusters = clusters$clusters,
  fontSize = 4,
  outerCutoff = 0.01, # Decrease cutoff between clusters and show some connections
  drawEllipses = TRUE
)

