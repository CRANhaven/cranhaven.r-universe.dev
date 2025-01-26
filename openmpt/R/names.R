#' Get `openmpt` module element names
#' 
#' Get names of elements in an `openmpt` class object. Use [`get_metadata()`] to get a module's name.
#' 
#' @param mod A tracker module object of class `openmpt`.
#' @param ... Ignored
#' @returns A `vector` of strings with names
#' @examples
#' mod <- demo_mod()
#' get_subsong_names(mod)
#' get_channel_names(mod)
#' get_pattern_names(mod)
#' get_order_names(mod)
#' get_instrument_names(mod)
#' get_sample_names(mod)[1:8]
#' @rdname names
#' @export
get_instrument_names <- function(mod, ...) {
  get_instrument_names_(mod)
}

#' @rdname names
#' @export
get_sample_names <- function(mod, ...) {
  get_sample_names_(mod)
}

#' @rdname names
#' @export
get_channel_names <- function(mod, ...) {
  get_channel_names_(mod)
}

#' @rdname names
#' @export
get_pattern_names <- function(mod, ...) {
  get_pattern_names_(mod)
}

#' @rdname names
#' @export
get_order_names <- function(mod, ...) {
  get_order_names_(mod)
}

#' @rdname names
#' @export
get_subsong_names <- function(mod, ...) {
  get_order_names_(mod)
}
