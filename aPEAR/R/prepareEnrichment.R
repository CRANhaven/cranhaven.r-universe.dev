#'
#' Prepare enrichment data
#'
#' @description Prepares enrichment data for clustering and plotting.
#'
#' @param enrichment a data.frame containing enrichment results
#' @param methods object of class \code{aPEAR.methods.config}
#' @param theme object of class \code{aPEAR.theme.config}
#' @param requireTheme whether to validate the theme parameters for plotting (default: TRUE)
#' @param verbose enable / disable log messages (default: FALSE)
#'
#' @importFrom tibble deframe
#' @importFrom data.table as.data.table setnames ':=' .I .N
#'
#' @noRd
#'
prepareEnrichment <- function(enrichment, methods = aPEAR.methods, theme = aPEAR.theme, requireTheme = TRUE, verbose = FALSE) {
  enrichmentType <- detectEnrichment(enrichment)
  if (is.null(enrichmentType$enrichmentType)) stop('Unrecognized enrichment type. The "enrichment" variable should have columns "Description" and "pathwayGenes".')
  if (verbose) message('Detected enrichment type ', enrichmentType$enrichmentType)

  if (enrichmentType$enrichmentType == 'gprofiler2') {
    enrichment <- data.table::as.data.table(enrichment) %>%
      data.table::setnames('term_name', 'Description')
  }

  #
  # Prepare initial data using the info we have
  #
  result <- list()
  result$enrichment <- enrichment %>%
    data.table::as.data.table() %>%
    data.table::setnames(enrichmentType$genesCol, 'Genes') %>%
    .[ , Ranks := 0 ]
  result$genes <- result$enrichment[ , list(Description, Genes) ] %>%
    tibble::deframe() %>%
    lapply(\(x) strsplit(x, split = '/')[[1]])

  # If cluster name is nes or pval, check if specified column exists, rank pathways add it to data
  if (methods$clusterName == 'nes') {
    if (!(methods$clusterNameColumn %in% colnames(result$enrichment))) {
      stop(paste0('Enrichment data does not contain column "', methods$clusterNameColumn, '"'))
    }

    result$enrichment <- result$enrichment %>%
      .[ , Ranks := abs(get(methods$clusterNameColumn)) ] %>%
      .[ order(Ranks, decreasing = FALSE), Ranks := 1:.N ]
  }

  if (methods$clusterName == 'pval') {
    if (!(methods$clusterNameColumn %in% colnames(result$enrichment))) {
      stop(paste0('Enrichment data does not contain column "', methods$clusterNameColumn, '"'))
    }

    result$enrichment <- result$enrichment %>%
      .[ order(get(methods$clusterNameColumn), decreasing = TRUE), Ranks := 1:.N ]
  }

  # If requirement for theme is off, do not verify further and return result as is
  if (requireTheme == FALSE) return(result)

  ########################## Adjust node color ##########################

  # Check if column for node colors exist
  if (!(theme$colorBy %in% colnames(result$enrichment))) {
    # If we know the enrichment type, set the theme color automatically
    if (enrichmentType$enrichmentType %in% c('enrichDOSE', 'gseDOSE', 'gprofiler2')) {
      set <- theme$colorBy

      theme$colorBy <- switch(
        enrichmentType$enrichmentType,
        'enrichDOSE' = 'pvalue',
        'gseDOSE' = 'NES',
        'gprofiler2' = 'p_value'
      )

      theme$colorType <- switch(
        theme$colorBy,
        'pvalue' = 'pval',
        'p_value' = 'pval',
        'NES' = 'nes'
      )

      warning(paste0('Enrichment data does not contain column "', set, '" required for node colors. Adjusting colorBy = "', theme$colorBy, '".'))
    }
  }

  # If failed to adjust, throw an error
  if (!(theme$colorBy %in% colnames(result$enrichment))) {
    stop(paste0('Enrichment data does not contain column "', theme$colorBy, '" required for node colors.'))
  }

  # Set color in the enrichment data
  result$enrichment <- result$enrichment[ , Color := get(theme$colorBy) ]
  if (theme$colorType == 'pval') {
    result$enrichment <- result$enrichment %>%
      .[ , Color := log10(Color) ] %>%
      .[ Color < theme$pCutoff, Color := theme$pCutoff ]
  }

  ########################## Adjust node size ###########################

  # Check if column for node size exist
  if (!(theme$nodeSize %in% colnames(result$enrichment))) {
    # If we know the enrichment type, set the theme node size automatically
    if (enrichmentType$enrichmentType %in% c('enrichDOSE', 'gseDOSE', 'gprofiler2')) {
      set <- theme$nodeSize

      theme$nodeSize <- switch(
        enrichmentType$enrichmentType,
        'enrichDOSE' = 'Count',
        'gseDOSE' = 'setSize',
        'gprofiler2' = 'term_size'
      )

      warning(paste0('Enrichment data does not contain column "', set, '" required for node size Adjusting nodeSize = "', theme$nodeSize, '".'))
    }
  }

  # If failed to adjust, throw an error
  if (!(theme$nodeSize %in% colnames(result$enrichment))) {
    stop(paste0('Enrichment data does not contain column "', theme$nodeSize, '" required for node colors.'))
  }

  result$enrichment <- result$enrichment[ , Size := get(theme$nodeSize) ]

  # Keep only the data we actually need
  result$enrichment <- result$enrichment[ , list(Description, Genes, Color, Size, Ranks) ]

  return(result)
}

#'
#' Detect enrichment type
#'
#' @description Detects which columns in the enrichment data can be used
#' for pathway clustering. Currently works with clusterProfiler, gProfileR
#' and custom inputs.
#'
#' @param enrichment a data.frame containing enrichment results
#'
#' @noRd
#'
detectEnrichment <- function(enrichment) {
  enrichmentType <- NULL
  genesCol <- NULL

  if (all(c('term_name', 'p_value', 'term_size', 'intersection') %in% colnames(enrichment))) {
    enrichmentType <- 'gprofiler2'
    genesCol <- 'intersection'
  }

  if (all(c('Description', 'pathwayGenes') %in% colnames(enrichment))) {
    enrichmentType <- 'custom'
    genesCol <- 'pathwayGenes'
  }

  if (all(c('Description', 'geneID', 'pvalue', 'Count') %in% colnames(enrichment))) {
    enrichmentType <- 'enrichDOSE'
    genesCol <- 'geneID'
  }

  if (all(c('Description', 'core_enrichment', 'NES', 'setSize') %in% colnames(enrichment))) {
    enrichmentType <- 'gseDOSE'
    genesCol <- 'core_enrichment'
  }

  return(list(enrichmentType = enrichmentType, genesCol = genesCol))
}
