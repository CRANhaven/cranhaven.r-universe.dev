#' Retrieve information about the OpenMPT library
#' 
#' A wrapper for the `get` function in libopenmpt (see
#' [API documentation](https://lib.openmpt.org/doc/namespaceopenmpt_1_1string.html))
#' @param key A key `character` string indicating which information to retrieve.
#' can be `"library_version"`, `"library_features"` and many others. See
#' [API documentation](https://lib.openmpt.org/doc/namespaceopenmpt_1_1string.html))
#' for all possible values.
#' @param ... Ignored
#' @returns Returns a `character` string with the requested information.
#' @examples
#' openmpt_info("library_version")
#' openmpt_info("library_features")
#' openmpt_info("url")
#' @export
openmpt_info <- function(key = "library_version", ...) {
  lompt_get_string_(key)
}

#' Get ModPlug Tracker module meta data
#' 
#' Get meta data of a tracker module such as its `"type"`, `"title"` and `"tracker"`.
#' Use [`get_metadata_keys()`] to get the available keys for a module object.
#' @param mod A tracker module object of class `openmpt`.
#' @param key A key as listed by [`get_metadata_keys()`].
#' @param ... Ignored
#' @returns A list of available keys in case of [`get_metadata_keys()`], the requested
#' information in case of [`get_metadata()`].
#' @examples
#' mod <- demo_mod()
#' get_metadata_keys(mod)
#' 
#' get_metadata(mod, "tracker")
#' @rdname get_metadata
#' @export
get_metadata <- function(mod, key = "title", ...) {
  get_metadata_(mod, key)
}

#' @rdname get_metadata
#' @export
get_metadata_keys <- function(mod, ...) {
  get_metadata_keys_(mod)
}

#' Get ModPlug Tracker module duration
#' 
#' Get the duration of the song from a `openmpt` class module object in seconds.
#' @param mod A tracker module object of class `openmpt`.
#' @param ... Ignored
#' @returns Returns a `numeric` value indicating the song duration in seconds.
#' @examples
#' mod <- demo_mod()
#' get_duration_seconds(mod)
#' @export
get_duration_seconds <- function(mod, ...) {
  get_duration_seconds_(mod)
}

#' Get and set ModPlug Tracker module position
#' 
#' Get or set the position of the music player. `rewind()` moves the position
#' to the start of the song.
#' @param mod A tracker module object of class `openmpt`.
#' @param value Position in seconds to move the player to. The value is rounded
#' to its nearest `order` and `row` position.
#' @param order Index of the position in the pattern sequence table (starts at `0`).
#' @param row Index of the row in the current pattern table (starts at `0`).
#' @param ... Ignored
#' @returns Returns `NULL` invisibly, or the updated object in case of the assign operator (`<-`).
#' @examples
#' mod <- demo_mod()
#' position_seconds(mod)
#' position_seconds(mod) <- 10.2
#' set_position_order_row(mod, 1, 4)
#' rewind(mod)
#' @rdname position
#' @export
position_seconds <- function(mod, ...) {
  get_position_seconds_(mod)
}

#' @rdname position
#' @export
`position_seconds<-` <- function(mod, ..., value) {
  set_position_seconds_(mod, value)
}

#' @rdname position
#' @export
rewind <- function(mod, ...) {
  set_position_seconds_(mod, 0)
  invisible(NULL)
}

#' @rdname position
#' @export
set_position_order_row <- function(mod, order, row, ...) {
  set_position_order_row_(mod, as.integer(order), as.integer(row))
  invisible(NULL)
}

#' Get the pattern index of an `openmpt` module at a specific order index
#' 
#' A module contains a sequence table describing the order in which to play
#' patterns. This function returns the index of the patter at specific position
#' in the sequence table.
#' @param mod A tracker module object of class `openmpt`.
#' @param order Index of the position in the pattern sequence table (starts at `0`).
#' @param ... Ignored
#' @returns Returns the `integer` index (starting at `0`) of the pattern at the
#' indicated `order` position.
#' @examples
#' mod <- demo_mod()
#' get_order_pattern(mod, 3L)
#' @export
get_order_pattern <- function(mod, order, ...) {
  get_order_pattern_(mod, order)
}
