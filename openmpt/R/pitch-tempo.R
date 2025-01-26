#' Control the pitch and tempo of a module
#' 
#' Functions to control the pitch and tempo of a module.
#' @param mod A tracker module object of class `openmpt`.
#' @param value Replacement value. A `numeric` factor with which
#' to adjust the tempo or pitch of a module
#' @param ... Ignored
#' @returns Returns current factor, or the updated object in case
#' of an assign operation (`<-`).
#' @examples
#' mod <- demo_mod()
#' 
#' ## Increase the module pitch with a factor 2
#' pitch_factor(mod) <- 2
#' pitch_factor(mod)
#' 
#' ## Increase the module tempo with a factor 2
#' tempo_factor(mod) <- 2
#' tempo_factor(mod)
#' @name pitch-tempo
#' @rdname pitch-tempo
#' @export
pitch_factor <- function(mod, ...) {
  get_pitch_factor_(mod)
}

#' @name pitch-tempo
#' @rdname pitch-tempo
#' @export
`pitch_factor<-` <- function(mod, ..., value) {
  set_pitch_factor_(mod, as.numeric(value))
}

#' @name pitch-tempo
#' @rdname pitch-tempo
#' @export
tempo_factor <- function(mod, ...) {
  get_tempo_factor_(mod)
}

#' @name pitch-tempo
#' @rdname pitch-tempo
#' @export
`tempo_factor<-` <- function(mod, ..., value) {
  set_tempo_factor_(mod, as.numeric(value))
}
