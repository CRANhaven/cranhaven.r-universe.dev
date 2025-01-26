#' Get the state of specific aspects of an `openmpt` class object
#' 
#' While playing with [`play()`] or rendering with [`convert_mod()`], the
#' state of the module can change continuously (volume, speed, order index, etc.).
#' These functions return the
#' current state of an `openmpt` class object.
#' @param mod A tracker module object of class `openmpt`.
#' @param channel An `integer` channel index (starting at 0), for which
#' to get the current state.
#' @param ... Ignored
#' @returns Return `numeric` or `integer` values of the requested state.
#' Function names are pretty self-explanatory. Note that tempo and speed
#' values are tracker dependent, their meaning depend on the originating
#' tracker.
#' @examples
#' mod <- demo_mod()
#' 
#' get_current_channel_vu_left(mod, 0L)
#' get_current_channel_vu_mono(mod, 0L)
#' get_current_channel_vu_rear_left(mod, 0L)
#' get_current_channel_vu_rear_right(mod, 0L)
#' get_current_channel_vu_right(mod, 0L)
#' get_current_estimated_bpm(mod)
#' get_current_order(mod)
#' get_current_pattern(mod)
#' get_current_playing_channels(mod)
#' get_current_row(mod)
#' get_current_speed(mod)
#' get_current_tempo(mod)
#' @rdname state
#' @export
get_current_channel_vu_left <- function(mod, channel, ...) {
  get_current_channel_vu_left_(mod, as.integer(channel))
}

#' @rdname state
#' @export
get_current_channel_vu_mono <- function(mod, channel, ...) {
  get_current_channel_vu_mono_(mod, as.integer(channel))
}

#' @rdname state
#' @export
get_current_channel_vu_rear_left <- function(mod, channel, ...) {
  get_current_channel_vu_rear_left_(mod, as.integer(channel))
}

#' @rdname state
#' @export
get_current_channel_vu_rear_right <- function(mod, channel, ...) {
  get_current_channel_vu_rear_right_(mod, as.integer(channel))
}

#' @rdname state
#' @export
get_current_channel_vu_right <- function(mod, channel, ...) {
  get_current_channel_vu_right_(mod, as.integer(channel))
}

#' @rdname state
#' @export
get_current_estimated_bpm <- function(mod, ...) {
  get_current_estimated_bpm_(mod)
}

#' @rdname state
#' @export
get_current_order <- function(mod, ...) {
  get_current_order_(mod)
}

#' @rdname state
#' @export
get_current_pattern <- function(mod, ...) {
  get_current_pattern_(mod)
}

#' @rdname state
#' @export
get_current_playing_channels <- function(mod, ...) {
  get_current_playing_channels_(mod)
}

#' @rdname state
#' @export
get_current_row <- function(mod, ...) {
  get_current_row_(mod)
}

#' @rdname state
#' @export
get_current_speed <- function(mod, ...) {
  get_current_speed_(mod)
}

#' @rdname state
#' @export
get_current_tempo <- function(mod, ...) {
  get_current_tempo_(mod)
}
