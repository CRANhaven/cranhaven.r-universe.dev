#' 
#' Find pathway clusters
#' 
#' @description Calculates the clusters within the enrichment data based on
#' pathway similarity.
#' 
#' @param enrichment a data.frame containing enrichment results
#' @param methods methods for calculating the pathway clusters within the enrichment
#' result (object of class aPEAR.methods; default: aPEAR.methods)
#' @param verbose enable / disable log messages (default: FALSE)
#' @param ... additional parameters (see \code{?aPEAR.methods})
#'
#' @return a list of two objects: \code{sim} - pathway similarity matrix; and
#' \code{clusters} - pathway clusters
#'
#' @importFrom methods is
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
#' data$clusters
#'
#' # Obtain clusters within the enriched pathways using hierarchical clustering
#' # and minClusterSize = 1
#' data <- findPathClusters(enrich@result, cluster = 'hier', minClusterSize = 1)
#' data$clusters
#' }
#' 
#' @export
#'
#' @return a list of clusters and similarity matrix
#' 
findPathClusters <- function(
  enrichment,
  methods = aPEAR.methods,
  verbose = FALSE,
  ...
) {
  if (!methods::is(enrichment, 'data.frame')) {
    stop(paste0('Unrecognized data type for parameter "enrichment": ',
                paste(class(enrichment), collapse = ', '), '. Please provide a data.frame.'))
  }

  if (verbose) message('Validating parameters...')
  methods <- prepareMethods(methods, ...)

  if (verbose) message('Validating enrichment data...')
  data <- prepareEnrichment(enrichment, methods = methods, verbose = verbose, requireTheme = FALSE)

  sim <- similarity(values = data$genes, method = methods$similarity, verbose = verbose)
  clusters <- pathwayClusters(sim = sim, minClusterSize = methods$minClusterSize, method = methods$cluster, verbose = verbose)

  clusterNames <- clusterName(enrichment = data$enrichment, sim = sim, clusters = clusters, method = methods$clusterName, verbose = verbose)

  clusters <- clusters %>%
    merge(clusterNames, by = 'ClusterID') %>%
    .[ , list(Pathway, Cluster) ]

  return(list(clusters = clusters, similarity = sim))
}
