#' 
#' PageRank
#' 
#' @description Selects a name for each pathway cluster using PageRank method.
#' 
#' @param sim a similarity matrix used to detect the clusters
#' @param clusters a vector of clusters, with names indicating the pathway name
#' @param verbose enable / disable log messages
#'
#' @importFrom igraph graph_from_data_frame page.rank

#' @importFrom data.table setDT setnames .I
#' @importFrom reshape2 melt
#'
#' @noRd
#'
pagerank <- function(sim, clusters, verbose = FALSE) {
  if (verbose) message('Using Pagerank algorithm to assign cluster titles...')

  edges <- sim %>%
    reshape2::melt() %>%
    data.table::setDT() %>%
    data.table::setnames(c('Path1', 'Path2', 'Value')) %>%
    merge(clusters, by.x = 'Path1', by.y = 'Pathway') %>%
    merge(clusters, by.x = 'Path2', by.y = 'Pathway') %>%
    .[ ClusterID.x == ClusterID.y ] %>%
    .[ , list(from = Path1, to = Path2, weight = Value) ] %>%
    as.data.frame()

  g <- igraph::graph_from_data_frame(edges, directed = FALSE)
  scores <- igraph::page.rank(g)$vector

  if (verbose) message('Pagerank scores calculated')

  scores
}

#' 
#' HITS
#' 
#' @description Selects a name for each pathway cluster using HITS method.
#' 
#' @param sim a similarity matrix used to detect the clusters
#' @param clusters a vector of clusters, with names indicating the pathway name
#' @param verbose enable / disable log messages
#'
#' @importFrom arules hits
#' @importFrom reshape2 acast
#' @importFrom data.table setDT setnames .I ':='
#'
#' @noRd
#'
hits <- function(sim, clusters, verbose = FALSE) {
  if (verbose) message('Using HITS algorithm to assign cluster titles...')

  adjacency <- sim %>%
    reshape2::melt() %>%
    data.table::setDT() %>%
    data.table::setnames(c('Path1', 'Path2', 'Value')) %>%
    merge(clusters, by.x = 'Path1', by.y = 'Pathway') %>%
    merge(clusters, by.x = 'Path2', by.y = 'Pathway') %>%
    .[ ClusterID.x == ClusterID.y, Value := 1 ] %>%
    .[ ClusterID.x != ClusterID.y, Value := 0 ] %>%
    reshape2::acast(Path1 ~ Path2, value.var = 'Value')

  scores <- arules::hits(adjacency, type = 'relative')

  if (verbose) message('HITS scores calculated')

  scores
}

#' 
#' Cluster name
#' 
#' @description Selects the title for each cluster from precalculated cluster title scores.
#' 
#' @param scores pathway evaluation score as cluster center. It is a list with values as scores
#' and names as pathway descriptions
#' @param clusters a list of clusters, where values are cluster ID and names are pathway names
#' 
#' @importFrom data.table setnames as.data.table .I ':=' .SD .BY
#' @importFrom tibble enframe
#'
#' @noRd
#' 
selectClusterName <- function(scores, clusters) {
  scores <- scores %>%
    tibble::enframe(name = 'Pathway', value = 'Score') %>%
    data.table::as.data.table()

  merge(scores, clusters, by = 'Pathway') %>%
    .[ , .SD[ which.max(Score) ], by = ClusterID ] %>%
    .[ , list(ClusterID, Pathway) ] %>%
    .[ order(ClusterID) ] %>%
    data.table::setnames('Pathway', 'Cluster')
}

#' 
#' Assign cluster name
#' 
#' @description Assigns each pathway cluster a name using the specified method.
#'
#' @param enrichment enrichment analysis result with ranks
#' @param sim similarity matrix used to detect the clusters
#' @param clusters clusters within the data
#' @param method the method to be used for assigning the cluster names. Available methods are: \code{'pagerank'}
#' and \code{'hits'}.
#' @param verbose enable / disable log messages
#'
#' @noRd
#'
clusterName <- function(enrichment, sim, clusters, method = c('pagerank', 'hits', 'nes', 'pval'), verbose = FALSE) {
  method <- match.arg(method)

  scores <- switch(method,
                   'pagerank' = pagerank(sim, clusters, verbose),
                   'hits' = hits(sim, clusters, verbose),
                   'nes' = tibble::deframe(enrichment[ , list(Description, Ranks) ]),
                   'pval' = tibble::deframe(enrichment[ , list(Description, Ranks) ]))

  selectClusterName(scores, clusters)
}
