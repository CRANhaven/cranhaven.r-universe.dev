#' 
#' Default method configuration for aPEAR
#' 
#' A list with parameters for customizing how the clusters within the enrichment data
#' are calculated.
#'
#' similarity: method for calculating similarity matrix between the pathways. Available
#' methods: 'jaccard', 'cosine' and 'correlation'
#'
#' cluster: method for detecting pathway clusters. Available methods: 'markov', 'hier'
#' and 'spectral'. Using 'spectral' method requires that you have the \code{Spectrum}
#' package installed
#'
#' clusterName: method for selecting cluster names. Available methods: 'pagerank',
#' 'hits', 'nes' and 'pval'. The 'pagerank' and 'hits' algorithms analyse the connectivity
#' within the cluster to detect the most important node. The 'nes' and 'pval' methods
#' use enrichment results to determine the most important node within the cluster: the 'nes'
#' method will choose the node with the maximum absolute enrichment score value and the
#' 'pval' method will choose the node with the lowest p-value. When using the 'nes' and
#' 'pval' methods, please specify which column in the data to use with the \code{clusterNameColumn}
#' parameter
#'
#' clusterNameColumn: which column in the dataset should be used to select the cluster
#' title. Required when \code{clusterName = 'nes'} and \code{clusterName = 'pval'} 
#'
#' minClusterSize: minimum cluster size (default: 2). Clusters with less elements than
#' specified will be dropped
#'
#' @examples
#' # Display all default methods used by aPEAR
#' aPEAR.methods
#'
#' # Update methods to use different similarity metric
#' settings <- aPEAR.methods
#' settings$similarity <- 'cosine'
#' settings
#'
#' @export
#'
#' @return an object of class aPEAR.methods.config
#' 
aPEAR.methods <- list(
  similarity = 'jaccard',
  cluster = 'markov',
  clusterName = 'pagerank',
  clusterNameColumn = NULL,
  minClusterSize = 2
)
class(aPEAR.methods) <- 'aPEAR.methods.config'

#'
#' Method configuration for aPEAR
#'
#' @description Makes sure the method configuration for enrichment network
#' is correct.
#'
#' @param methods object of class \code{aPEAR.methods.config}
#' @param ... additional parameters (see \code{?aPEAR.methods})
#'
#' @noRd
#'
prepareMethods <- function(methods, ...) {
  # Get values from the arg list that are relevant for the clustering methods
  # and update them in the config object
  args <- list(...)
  args <- args[ names(args) %in% names(aPEAR.methods) ]

  for (arg in names(args)) {
    methods[[ arg ]] <- args[[ arg ]]
  }

  missing <- c(
    setdiff(names(aPEAR.methods), names(methods)),
    which(lapply(methods, is.na) == TRUE) %>% names(),
    which(lapply(methods, is.null) == TRUE) %>% names()
  ) %>% unique()

  # Skip, not always required and will validate later
  missing <- missing[ missing != 'clusterNameColumn' ]

  if (length(missing) > 0) {
    stop(paste0('Missing arguments: ', paste(missing, collapse = ', ')))
  }

  if (methods$minClusterSize < 1) {
    warning('Received minClusterSize less than 1, setting to 1')
    methods$minClusterSize <- 1
  }

  methods$similarity <- match.arg(methods$similarity, choices = c('jaccard', 'cosine', 'correlation'))
  methods$cluster <- match.arg(methods$cluster, choices = c('markov', 'hier', 'spectral'))
  methods$clusterName <- match.arg(methods$clusterName, choices = c('pagerank', 'hits', 'nes', 'pval'))

  # Will validate later if the column actually exists in the dataset
  if (methods$clusterName %in% c('nes', 'pval') && (is.null(methods$clusterNameColumn) || is.na(methods$clusterNameColumn))) {
    stop(paste0('clusterNameColumn is required when clusterName is "nes" or "pval".'))
  }

  return(methods)
}

#'
#' Default theme configuration for aPEAR
#'
#' A list with parameters for customizing the theme of the enrichment network plot.
#'
#' colorBy: which column in the data should be used to color the nodes in
#' the enrichment network plot (default: 'NES')
#'
#' nodeSize: which column in the data should be used to get the node size for the
#' enrichment network plot (default: 'setSize')
#'
#' innerCutoff: similarity cutoff for within-cluster nodes (default: 0.1). Decreasing
#' this value results in greater connectivity within the nodes in the same cluster.
#' For example, innerCutoff = 0 would display all connections within the same cluster.
#'
#' outerCutoff: similarity cutoff for between-cluster nodes (default: 0.5). Decreasing
#' this value results in greater connectivity between the nodes in different clusters.
#' For example, outerCutoff = 0 would display all connections between different clusters.
#'
#' colorType: how to colour the nodes: 'nes' - will center around 0 with blue min and
#' red max, 'pval' - will use log transform on the colorBy column and adjust color range
#' (default: 'nes')
#'
#' pCutoff: adjust p-value colouring cutoff when using \code{colorType = 'pval'} (default: -10)
#'
#' drawEllipses: enable / disable ellipse drawing (default: FALSE)
#'
#' fontSize: adjust cluster label font size (default: 3)
#'
#' repelLabels: whether the cluster label positions should be corrected (default: FALSE)
#'
#' @examples
#' # Display the default theme configuration used by aPEAR
#' aPEAR.theme
#'
#' # Update the theme to draw ellipses
#' settings <- aPEAR.theme
#' settings$drawEllipses <- TRUE
#' settings
#'
#' @export
#'
#' @return an object of class aPEAR.theme.config
#'
aPEAR.theme <- list(
  colorBy = 'NES',
  nodeSize = 'setSize',
  innerCutoff = 0.1,
  outerCutoff = 0.5,
  colorType = 'nes',
  pCutoff = -10,
  drawEllipses = FALSE,
  fontSize = 3,
  repelLabels = FALSE
)
class(aPEAR.theme) <- 'aPEAR.theme.config'

#'
#' Theme configuration for aPEAR
#'
#' @description Makes sure the theme configuration for enrichment network
#' is correct.
#'
#' @param theme object of class \code{aPEAR.theme.config}
#' @param ... additional parameters (see \code{?aPEAR.theme})
#'
#' @noRd
#'
prepareTheme <- function(theme, ...) {
  # Get values from the arg list that are relevant for the plot theme
  # and update them in the config object
  args <- list(...)
  args <- args[ names(args) %in% names(aPEAR.theme) ]

  for (arg in names(args)) {
    theme[[ arg ]] <- args[[ arg ]]
  }

  missing <- c(
    setdiff(names(aPEAR.theme), names(theme)),
    which(lapply(theme, is.na) == TRUE) %>% names(),
    which(lapply(theme, is.null) == TRUE) %>% names()
  ) %>% unique()

  if (length(missing) > 0) {
    stop(paste0('Missing arguments: ', paste(missing, collapse = ', ')))
  }

  # Adjust inner and outer cutoffs

  if (theme$innerCutoff < 0) {
    warning('Received negative innerCutoff, setting to 0')
    theme$innerCutoff <- 0
  }

  if (theme$outerCutoff < 0) {
    warning('Received negative outerCutoff, setting to 0')
    theme$outerCutoff <- 0
  }

  if (theme$innerCutoff > 1) {
    warning('Received innerCutoff greater than 1, setting to 1')
    theme$innerCutoff <- 1
  }

  if (theme$outerCutoff > 1) {
    warning('Received outerCutoff greater than 1, setting to 0')
    theme$outerCutoff <- 1
  }

  theme$colorType <- match.arg(theme$colorType, choices = c('nes', 'pval'))

  return(theme)
}
