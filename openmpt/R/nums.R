#' Get element counts from an `openmpt` module
#' 
#' Functions that count specific elements in `openmpt` class objects and
#' returns the resulting number.
#' @param mod A tracker module object of class `openmpt`.
#' @param pattern An `integer` pattern index (starting at 0) for which to
#' get count details.
#' @param ... Ignored
#' @returns Returns an `integer` count of the requested information.
#' @examples
#' mod <- demo_mod()
#' get_num_instruments(mod)
#' get_num_samples(mod)
#' get_num_channels(mod)
#' get_num_orders(mod)
#' get_num_patterns(mod)
#' get_num_subsongs(mod)
#' get_pattern_num_rows(mod, 0L)
#' @rdname numbers
#' @export
get_num_instruments <- function(mod, ...) {
  get_num_instruments_(mod)
}

#' @rdname numbers
#' @export
get_num_samples <- function(mod, ...) {
  get_num_samples_(mod)
}

#' @rdname numbers
#' @export
get_num_channels <- function(mod, ...) {
  get_num_channels_(mod)
}

#' @rdname numbers
#' @export
get_num_orders <- function(mod, ...) {
  get_num_orders_(mod)
}

#' @rdname numbers
#' @export
get_num_patterns <- function(mod, ...) {
  get_num_patterns_(mod)
}

#' @rdname numbers
#' @export
get_num_subsongs <- function(mod, ...) {
  get_num_subsongs_(mod)
}

#' @rdname numbers
#' @export
get_pattern_num_rows <- function(mod, pattern) {
  get_pattern_num_rows_(mod, as.integer(pattern))
}
