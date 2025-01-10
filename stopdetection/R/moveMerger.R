#' Move Merger
#'
#' Handles move/track events that do not meet specific thresholds to be
#' considered. This is based on the researcher-decided total number of
#' allowable locations that the discarded track can consist of, as well as a
#' maximum total time length that may elapse. Tracks can be merged into the
#' preceding stop or excluded. Future versions of this should consider assigning
#' to the closest stop for \code{small_track_action = merge}.
#'
#' @param events data.table of events from \code{\link{returnStateEvents}}
#' @param small_track_action One of "merge" or "exclude" for specifying the
#'   method of handling mergeable tracks
#' @param max_locs Maximum number of locations for a track to be mergeable. Set
#'   to Inf to not consider.
#' @param max_time Maximum time elapsed (seconds) for a track to be mergeable.
#'   Set to Inf to not consider.
#' @param max_dist Maximum distance (meters) traveled while on track to be
#'   mergeable. Set to Inf to not consider.
#'
#' @return Modifies events data.table by reference

moveMerger <- function(events, small_track_action = "merge", max_locs = 1, max_time = 600, max_dist = 100){
  # condition <- events[n_locations <= max_locs & ts <= max_time, which = TRUE]
  # set(events,
  #     j = c("new_stop_id",
  #           "new_within_stop"),
  #     value = list(events[["new_stop_id"]],
  #                  !is.na(events[["stop_id"]]))
  # )
  # set(events,
  #     j = "new_stop_id",
  #     value = events[["new_stop_id"]]
  #     )

  events[, mergeable := FALSE]
  events[state == "moving",
         mergeable := n_locations <= max_locs &
           ((end_time - begin_time) <= max_time) &
           (raw_travel_dist <= max_dist | is.na(raw_travel_dist))]
  events[, `:=`(
    new_state_id = new_state_id - cumsum(mergeable),
    new_state = state
  )]

  if (small_track_action == "merge") {
    events[mergeable == TRUE, `:=`(new_state = "stopped"
    )]
    events[, mergeable := NULL]
  } else if (small_track_action == "exclude") {
    events[mergeable == TRUE,
           `:=`(new_state = "excluded",
                new_state_id = NA)]
    # events[, mergeable := NULL]
  }
  events[]
}
