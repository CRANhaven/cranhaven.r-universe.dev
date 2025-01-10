#' 
#' Pathway clustering
#' 
#' @description Finds clusters in a similarity matrix.
#' 
#' @param sim similarity matrix
#' @param minClusterSize minimum cluster size. Clusters with less elements than specified
#' will be dropped
#' @param method the method to be used for detecting clusters. Available methods are: \code{'markov'},
#' \code{'hier'} and \code{'spectral'}. Using \code{'spectral'} method requires that you have
#' \code{Spectrum} package installed
#' @param verbose enable / disable log messages
#'
#' @importFrom data.table as.data.table
#' @importFrom tibble enframe
#'
#' @noRd
#' 
pathwayClusters <- function(sim,
                            minClusterSize = 2,
                            method = c('markov', 'hier', 'spectral'),
                            verbose = FALSE
) {
  method <- match.arg(method)

  if (is.na(minClusterSize) | minClusterSize < 1) {
    warning(paste0('Invalid minClusterSize = ', minClusterSize, '. Setting minClusterSize = 2.'))
    minClusterSize <- 2
  }

  if (minClusterSize > nrow(sim)) {
    stop(paste0('minClusterSize = ', minClusterSize, ' is greater than the number of available pathways = ', nrow(sim), '.'))
  }

  clusters <- switch(method,
                     'markov' = markov(sim, verbose),
                     'hier' = hierarchical(sim, verbose),
                     'spectral' = spectral(sim, verbose))

  # Drop clusters with less elements than specified
  keep <- names(table(clusters))[ which(table(clusters) >= minClusterSize) ]
  clusters <- clusters[ clusters %in% keep ]

  if (length(clusters) == 0) {
    stop('No clusters found.')
  }

  clusters %>%
    tibble::enframe(name = 'Pathway', value = 'ClusterID') %>%
    data.table::as.data.table()
}


#'
#' Markov clustering
#' 
#' @description Finds clusters in a similarity matrix using Markov Cluster Algorithm (MCL).
#' 
#' @param sim similarity matrix
#' @param verbose enable / disable log messages
#' 
#' @importFrom MCL mcl
#'
#' @noRd
#' 
markov <- function(sim, verbose = FALSE) {
  if (verbose) message('Using Markov Cluster Algorithm to detect pathway clusters...')

  res <- MCL::mcl(sim,
                  addLoops = FALSE,
                  max.iter = 500,
                  expansion = 2,
                  inflation = 2.5,
                  allow1 = TRUE)

  if (!('Cluster' %in% names(res))) {
    stop('Unable to cluster data using Markov clustering algorithm.')
  }

  clusters <- res$Cluster
  names(clusters) <- colnames(sim)

  if (verbose) message('Clustering done')

  clusters
}

#' 
#' Hierarchical clustering
#' 
#' @description Finds clusters in a similarity matrix using hierarchical clustering algorithm.
#' 
#' @param sim similarity matrix
#' @param verbose enable / disable log messages
#'
#' @importFrom stats as.dist hclust cutree
#'
#' @noRd
#' 
hierarchical <- function(sim, verbose = FALSE) {
  if (verbose) message('Using Hierarchical Clustering to detect pathway clusters...')

  hCluster <- stats::as.dist(1 - sim) %>% stats::hclust()
  clusters <- stats::cutree(hCluster, h = 0.9)

  if (verbose) message('Clustering done')

  clusters
}

#'
#' Spectral clustering
#'
#' @description Finds clusters in a similarity matrix using adaptive spectral clustering.
#' Using this method requires that you have \code{Spectrum} package installed.
#'
#' @param sim similarity matrix
#' @param verbose enable / disable log messages
#'
#' @noRd
#'
spectral <- function(sim, verbose = FALSE) {
  if (!requireNamespace('Spectrum', quietly = TRUE)) {
    stop('Package Spectrum is required to use "spectral" clustering method.')
  }

  if (verbose) message('Using Spectral Clustering to detect pathway clusters...')

  clusters <- Spectrum::Spectrum(sim, maxk = 100, showres = FALSE, silent = !verbose, clusteralg = 'km')
  clusters <- clusters$assignments
  names(clusters) <- colnames(sim)

  if (verbose) message('Clustering done')

  clusters
}
