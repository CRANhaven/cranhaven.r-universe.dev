#' Get or set the repeat count for an `openmpt` module
#' 
#' Tracker music can be composed such that it is intended to play
#' in a continuous loop. With the repeat count you can affect the number of
#' times a module is repeated when playing with [`play()`] or rendered with [`convert_mod()`].
#' @param mod A tracker module object of class `openmpt`.
#' @param ... Ignored
#' @param value An `integer` value to assign to the repeat count.
#' @returns Returns the `integer` repeat count of an `openmpt` object. In case
#' of an assign operator (`<-`) an updated `mod` is returned with the new repeat count.
#' @examples
#' mod <- demo_mod()
#' repeat_count(mod) <- 2
#' repeat_count(mod)
#' @rdname repeat
#' @export
repeat_count <- function(mod, ...) {
  get_repeat_count_(mod)
}

#' @rdname repeat
#' @export
`repeat_count<-` <- function(mod, ..., value) {
  set_repeat_count_(mod, as.integer(value))
}