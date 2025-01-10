#' 
#' Connect enrichment network
#' 
#' @description Connects the enrichment network clusters into a graph and
#' calculates the optimal position for each node.
#' 
#' @param sim similarity matrix
#' @param clusters clusters of the pathways
#' @param theme object of class \code{aPEAR.theme.config}
#' 
#' @importFrom stats na.omit
#' @importFrom reshape2 melt
#' @importFrom data.table as.data.table .I ':=' setnames
#' @importFrom igraph graph_from_data_frame layout_nicely V
#' 
#' @noRd
#' 
enrichmentGraph <- function(sim, clusters, theme = aPEAR.theme) {
  edges <- sim %>%
    reshape2::melt() %>%
    data.table::as.data.table() %>%
    merge(clusters, by.x = 'Var1', by.y = 'Pathway') %>%
    merge(clusters, by.x = 'Var2', by.y = 'Pathway') %>%
    .[ Cluster.x == Cluster.y & value < theme$innerCutoff, value := NA ] %>%
    .[ Cluster.x != Cluster.y & value < theme$outerCutoff, value := NA ] %>%
    .[ value != 0 ] %>%
    stats::na.omit() %>%
    .[ , list(from = Var1, to = Var2, weight = value) ]

  g <- igraph::graph_from_data_frame(edges, directed = FALSE)

  nodes <- igraph::layout_nicely(g) %>%
    data.table::as.data.table() %>%
    data.table::setnames(c('x', 'y')) %>%
    .[ , Pathway := igraph::V(g) %>% as.list() %>% names() ]

  edges <- edges %>%
    merge(nodes, by.x = 'from', by.y = 'Pathway') %>%
    data.table::setnames(c('x', 'y'), c('xStart', 'yStart')) %>%
    merge(nodes, by.x = 'to', by.y = 'Pathway') %>%
    data.table::setnames(c('x', 'y'), c('xEnd', 'yEnd'))

  list(
    nodes = nodes,
    edges = edges
  )
}
