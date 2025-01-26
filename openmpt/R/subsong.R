#' Get or set the current subsong in an `openmpt` module
#' 
#' Some `openmpt` modules may contain multiple subsongs. Use these
#' functions to get the current subsong index, or select a different one.
#' @param mod A tracker module object of class `openmpt`.
#' @param ... Ignored
#' @param value An `integer` index of the subsong to select.
#' @returns Returns the `integer` index of the currently selected subsong.
#' In case of the assign operator (`<-`) it returns a version of
#' `mod` with an update selection for the subsong
#' @examples
#' mod <- demo_mod()
#' subsong(mod)
#' ## a value of -1 plays all subsongs consecutively
#' subsong(mod) <- -1
#' @rdname subsong
#' @export
subsong <- function(mod, ...) {
  get_selected_subsong_(mod)
}

#' @rdname subsong
#' @export
`subsong<-` <- function(mod, ..., value) {
  select_subsong_(mod, as.integer(value))
}