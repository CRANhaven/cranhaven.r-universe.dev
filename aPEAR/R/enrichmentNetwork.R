#'
#' aPEAR enrichment network
#'
#' @description Creates an enrichment network plot. This function internally calls
#' \code{findPathClusters} to obtain pathway clusters and then \code{plotPathClusters}
#' to create the enrichment network visualization.
#'
#' @param enrichment a data.frame containing enrichment results
#' @param methods object of class \code{aPEAR.methods.config}
#' @param theme object of class \code{aPEAR.theme.config}
#' @param verbose enable / disable log messages
#' @param ... additional parameters (see \code{?aPEAR.methods} and \code{?aPEAR.theme})
#'
#' @return a \code{ggplot2} object
#'
#' @examples
#' \donttest{
#' # Load libraries
#' library(clusterProfiler)
#' library(DOSE)
#' library(org.Hs.eg.db)
#' data(geneList)
#'
#' # Perform enrichment using clusterProfiler
#' enrich <- gseGO(geneList, OrgDb = org.Hs.eg.db, ont = 'CC')
#'
#' # Create enrichment network visualization with default parameters
#' enrichmentNetwork(enrich@result)
#'
#' # Create enrichment network visualization with repelled labels and elipses
#' enrichmentNetwork(enrich@result, repelLabels = TRUE, drawEllipses = TRUE)
#' }
#'
#' @seealso \code{?findPathClusters}, \code{?plotPathClusters}
#'
#' @export
#'
enrichmentNetwork <- function(
  enrichment,
  methods = aPEAR.methods,
  theme = aPEAR.theme,
  verbose = FALSE,
  ...
) {
  data <- findPathClusters(enrichment, methods = methods, verbose = verbose, ...)

  if (verbose) message('Creating the enrichment network visualization...')
  plotPathClusters(enrichment = enrichment, sim = data$sim, clusters = data$clusters, theme = theme, verbose = verbose, ...)
}

#'
#' aPEAR enrichment network
#'
#' @description Creates enrichment network plot.
#'
#' @param enrichment a data.frame containing enrichment results
#' @param sim similarity matrix of the enriched pathways
#' @param clusters clusters of the enriched pathways
#' @param theme object of class \code{aPEAR.theme.config}
#' @param verbose enable / disable log messages
#' @param ... additional parameters (see \code{?aPEAR.theme})
#'
#' @importFrom data.table .I
#'
#' @examples
#' \donttest{
#' # Load libraries
#' library(clusterProfiler)
#' library(DOSE)
#' library(org.Hs.eg.db)
#' data(geneList)
#'
#' # Perform enrichment using clusterProfiler
#' enrich <- gseGO(geneList, OrgDb = org.Hs.eg.db, ont = 'CC')
#'
#' # Obtain clusters within the enriched pathways using default parameters
#' data <- findPathClusters(enrich@result)
#'
#' # Create the enrichment network visualization using default parameters
#' plotPathClusters(enrich@result, data$sim, data$clusters)
#'
#' # Create the enrichment network visualization with repelled labels and elipses
#' plotPathClusters(enrich@result, data$sim, data$clusters, repelLabels = TRUE, drawEllipses = TRUE)
#' }
#' 
#' @export
#'
#' @return a \code{ggplot2} object
#'
plotPathClusters <- function(
  enrichment,
  sim,
  clusters,
  theme = aPEAR.theme,
  verbose = FALSE,
  ...
) {
  if (verbose) message('Validating theme parameters...')
  theme <- prepareTheme(theme, ...)

  if (verbose) message('Preparing enrichment data for plotting...')
  data <- prepareEnrichment(enrichment, theme = theme, requireTheme = TRUE, verbose = verbose)
  
  # Merge with cluster data
  enrichment <- data$enrichment %>%
    data.table::as.data.table() %>%
    .[ , list(Pathway = Description, Color, Size) ] %>%
    merge(clusters) %>%
    .[ , ClusterSize := .N, by = Cluster ]

  if (verbose) message('Creating the enrichment graph...')
  graph <- enrichmentGraph(sim, clusters, theme)

  # Add enrichment data to the node coordinates
  nodes <- merge(graph$nodes, enrichment)

  # Filter edges to make sure we keep only those that have coordinates
  edges <- graph$edges
  edges <- edges[ from %in% nodes[ , Pathway ] & to %in% nodes[ , Pathway ] ]

  .plotNodesAndEdges(nodes = nodes, edges = edges, theme = theme)
}
