#' Get a specific `openmpt` pattern table or its cells
#' 
#' Collects a specific pattern table from a tracker module and presents it as
#' a matrix of formatted `character` strings in case of `pattern()`. The other
#' functions return a single string for a specific cell inside the pattern table.
#' @param mod A tracker module object of class `openmpt`.
#' @param pattern The pattern index (starting at `0`) of the pattern to get.
#' @param row A row index (starting at `0`) for the row inside the pattern table.
#' @param channel a channel (i.e., column) index (starting at `0`) inside the pattern table. 
#' @param width The maximum number of characters the string should contain. `0` means no limit.
#' @param pad If `TRUE`, the string will be resized to the exact length provided in the width parameter.
#' @param command One of `"note"`, `"instrument"`, `"volumeffect"`, `"effect"`, `"volume"`, or
#' `"parameter"`.
#' @param ... Ignored
#' @returns A `matrix` of pattern cells formatted as `character` strings in case of `pattern()`.
#' Each column represents. All other methods return a single string for a specific cell.
#' an audio channel.
#' @examples
#' mod <- demo_mod()
#' pattern(mod)
#' format_pattern_row_channel(mod, 0L, 1L, 2L, 0L, TRUE)
#' format_pattern_row_channel_command(mod, 0L, 1L, 2L, "parameter")
#' highlight_pattern_row_channel(mod, 0L, 1L, 2L, 0L, TRUE)
#' highlight_pattern_row_channel_command(mod, 0L, 1L, 2L, "note")
#' @rdname pattern
#' @export
pattern <- function(mod, pattern = 0L, width = 0L, pad = TRUE, ...) {
  format_pattern_(mod, as.integer(pattern), width, pad)
}

#' @rdname pattern
#' @export
format_pattern_row_channel <- function(mod, pattern, row, channel, width, pad, ...) {
  format_pattern_row_channel_(mod, as.integer(pattern), as.integer(row), as.integer(channel),
                              as.integer(width), as.logical(pad))
}

#' @rdname pattern
#' @export
format_pattern_row_channel_command <- function(mod, pattern, row, channel, command, ...) {
  format_pattern_row_channel_command_(mod, as.integer(pattern), as.integer(row),
                                      as.integer(channel), .command_to_index(command))
}

#' @rdname pattern
#' @export
highlight_pattern_row_channel <- function(mod, pattern, row, channel, width, pad, ...) {
  highlight_pattern_row_channel_(mod, as.integer(pattern), as.integer(row), as.integer(channel),
                                 as.integer(width), as.logical(pad))
}

#' @rdname pattern
#' @export
highlight_pattern_row_channel_command <- function(mod, pattern, row, channel, command, ...) {
  highlight_pattern_row_channel_command_(mod, as.integer(pattern), as.integer(row),
                                         as.integer(channel), .command_to_index(command))
}

.command_to_index <- function(command) {
  pmatch(
    command,
    c("note", "instrument", "volumeffect", "effect", "volume", "parameter")
  ) - 1L
}
