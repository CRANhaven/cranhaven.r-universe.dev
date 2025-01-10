#'
#' Empty Matrix
#'
#' @description Creates an empty square matrix, with the number of columns
#' and the number of rows equal to the length of the \code{values}.
#'
#' @param values a list of values
#' @param data default data to be set in the matrix (default: NA)
#' @param dimNames names to be used for the colnames and rownames of the matrix (default: names(values))
#' @param makeNames whether the names of values should be converted to the R convention (default: FALSE)
#' @param uniqueNames whether the names should be converted to unique names (default: FALSE)
#'
#' @noRd
#'
emptyMatrix <- function(values, data = NA, dimNames = names(values), makeNames = FALSE, uniqueNames = FALSE) {
  sim <- matrix(data = data, nrow = length(values), ncol = length(values))

  # If no names available for the values, return current matrix
  if (is.null(dimNames)) return(sim)

  # Adjust names based on settings
  if (makeNames == TRUE) dimNames <- make.names(dimNames)
  if (uniqueNames == TRUE) dimNames <- make.unique(dimNames)

  colnames(sim) <- dimNames
  rownames(sim) <- dimNames

  return(sim)
}

#'
#' Occurence Matrix
#'
#' @description Creates an occurence matrix from a list of lists.
#'
#' @param values a list of lists
#' @param dimNames names to be used for the rownames of the matrix (default: names(values))
#' @param makeNames whether the names of values should be converted to the R convention (default: FALSE)
#' @param uniqueNames whether the names should be converted to unique names (default: FALSE)
#'
#'
#' @noRd
#'
occurenceMatrix <- function(values, dimNames = names(values), makeNames = FALSE, uniqueNames = FALSE) {
  uniqueValues <- values %>% unlist %>% unique

  m <- matrix(data = FALSE, nrow = length(values), ncol = length(uniqueValues))
  colnames(m) <- uniqueValues
  rownames(m) <- names(values)

  # Adjust occurences
  for (i in seq_along(values)) {
    m[ i, colnames(m) %in% values[[ i ]] ] <- TRUE
  }

  # Adjust names based on settings
  if (makeNames == TRUE) dimNames <- make.names(dimNames)
  if (uniqueNames == TRUE) dimNames <- make.unique(dimNames)

  rownames(m) <- dimNames

  m
}
