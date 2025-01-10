#'
#' Jaccard similarity
#' 
#' @description Calculates jaccard similarity between lists.
#'
#' @param x list of lists.
#'
#' @importFrom bayesbio jaccardSets
#'
#' @noRd
#'
jaccard <- function(x) {
  sim <- emptyMatrix(x)

  for (i in seq_along(x)) {
    for (j in seq_along(x)) {
      if (j > i) { break }
      sim[ i, j ] <- bayesbio::jaccardSets(x[[i]], x[[j]])
      sim[ j, i ] <- sim[ i, j ]
    }
  }

  sim
}

#'
#' Cosine similarity
#'
#' @description Calculates cosine similarity between lists.
#'
#' @param x list of lists.
#'
#' @importFrom lsa cosine
#'
#' @noRd
#'
cosine <- function(x) {
  sim <- emptyMatrix(x)
  m <- occurenceMatrix(x)

  for (i in seq_along(x)) {
    sim[ i, i ] <- 1.0
    for (j in seq_along(x)) {
      if (j >= i) { break }

      # Get only common terms between both lists
      terms <- unique(c(x[[i]], x[[j]]))
      t <- m[ c(i, j), colnames(m) %in% terms ] %>%
        matrix(nrow = 2)

      # Calculate cosine similarity
      sim[ i, j ] <- lsa::cosine(t[ 1, ], t[ 2, ])
      sim[ j, i ] <- sim[ i, j ]
    }
  }

  sim
}

#'
#' Correlation similarity
#'
#' @description Calculates correlation between lists.
#'
#' @param x list of lists.
#'
#' @importFrom stats cor
#'
#' @noRd
#'
correlation <- function(x) {
  m <- occurenceMatrix(x)
  sim <- stats::cor(t(m))
  sim[ sim < 0 ] <- 0
  sim
}

#'
#' Similarity matrix
#'
#' @description Calculates a similarity matrix between the values.
#'
#' @param values list of lists.
#' @param method method to be used. Available values: \code{'jaccard'}, \code{'cosine'} and \code{'correlation'}.
#' @param verbose enable / disable log messages (default: FALSE)
#'
#' @noRd
#'
similarity <- function(values, method = c('jaccard', 'cosine', 'correlation'), verbose = FALSE) {
  method <- match.arg(method)

  if (verbose) message('Calculating pathway similarity using method ', method)

  switch(method,
         'jaccard' = jaccard(values),
         'cosine' = cosine(values),
         'correlation' = correlation(values)
  )
}
