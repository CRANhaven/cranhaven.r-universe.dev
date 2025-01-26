#' Control the volume of a module
#' 
#' Functions to control the global volume of a module, or that
#' of specific channels in the module.
#' @param mod A tracker module object of class `openmpt`.
#' @param channel Channel index (`integer` starting at `0`) for which
#' to request or control the volume.
#' @param value Replacement value. In case of '`status`' functions
#' a `logical` value, in case of '`volume`' functions a `numeric` value.
#' @param ... Ignored
#' @returns Returns the volume (status), or the updated object in case
#' of an assign operation (`<-`).
#' @examples
#' mod <- demo_mod()
#' 
#' channel_mute_status(mod, 0L)
#' 
#' ## Mute the first channel in the module
#' channel_mute_status(mod, 0L) <- TRUE
#' 
#' ## Second channel volume at 50%
#' channel_volume(mod, 1L) <- 0.5
#' channel_volume(mod, 1L)
#' 
#' ## global volume at 90%
#' global_volume(mod) <- 0.9
#' global_volume(mod)
#' 
#' @name volume-control
#' @rdname volume-control
#' @export
channel_mute_status <- function(mod, channel, ...) {
  get_channel_mute_status_(mod, as.integer(channel))
}

#' @name volume-control
#' @rdname volume-control
#' @export
`channel_mute_status<-` <- function(mod, channel, ..., value) {
  set_channel_mute_status_(mod, as.integer(channel), as.logical(value))
}

#' @name volume-control
#' @rdname volume-control
#' @export
channel_volume <- function(mod, channel, ...) {
  get_channel_volume_(mod, as.integer(channel))
}

#' @name volume-control
#' @rdname volume-control
#' @export
`channel_volume<-` <- function(mod, channel, ..., value) {
  set_channel_volume_(mod, as.integer(channel), as.numeric(value))
}

#' @name volume-control
#' @rdname volume-control
#' @export
global_volume <- function(mod, ...) {
  get_global_volume_(mod)
}

#' @name volume-control
#' @rdname volume-control
#' @export
`global_volume<-` <- function(mod, ..., value) {
  set_global_volume_(mod, as.numeric(value))
}
