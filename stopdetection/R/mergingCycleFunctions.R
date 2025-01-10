#' Merge Stops and Clean Tracks
#'
#' Calls \code{stopMerger} and then \code{moveMerger}
#'
#' @param events data.table from \code{returnStateEvents}
#' @param thetaD how many meters away may stops be and still be merged
#' @param small_track_action one of "merge" or "exclude" for short tracks
#' @param ... additional optional arguments passed to moveMerger including max_locs, max_time and max_dist
#'
#' @return update events data.table by reference
#' @keywords internal
mergeStopsAndCleanTracks <- function(events, thetaD, small_track_action = "merge", ...) {
  stopMerger(events, thetaD = thetaD)
  moveMerger(events, small_track_action = small_track_action, ...)
}

updateDataWithEvents <- function(res, events){

  res[events, `:=`(state_id = i.new_state_id,
                   state = i.new_state), on = .(state_id)]

  is_stop <- res[["state"]] == "stopped"
  is_move <- res[["state"]] == "moving"
  move_idx <- which(is_move)
  stop_idx <- which(is_stop)

  set(res,
      i = stop_idx,
      j = "stop_id",
      value = rleid(res[["state_id"]][stop_idx]))

  set(res,
      i = move_idx,
      j = "move_id",
      value = rleid(res[["state_id"]][move_idx]))

}

#' Merging Cycle
#'
#' Runs the stop and merging cycle until no changes are seen or until the max
#' number of merges are met.
#'
#' @param res Results data.table from \code{\link{stopFinder}} containing
#'   columns timestamp, longitude, latitude and state
#' @param max_merges integer of maximum number of merges to perform
#' @param thetaD how many meters away may stops be and still be merged
#' @param small_track_action one of "merge" or "exclude" for short tracks
#' @param ... additional optional arguments passed to moveMerger including
#'   max_locs, max_time and max_dist
#'
#' @return Modifies res data.table by reference
#' @export
#' @examples
#' # Load data
#' library(data.table)
#' data(loc_data_2019); setDT(loc_data_2019)
#' # Find initial set of stops
#' stopFinder(loc_data_2019, thetaD = 200, thetaT = 300)
#' # This selection contains two short tracks to eliminate and two stops to merge
#' example <- copy(loc_data_2019[state_id %between% c(1, 11)])
#' events_pre_merge <- returnStateEvents(example)
#' # Perform the merging
#' mergingCycle(example, thetaD = 200, small_track_action = "exclude", max_locs = Inf)
#' events_post_merge <- returnStateEvents(example)
#' # From 11 states to 8 states
#' events_pre_merge[, .(state_id, state, meanlat, meanlon, n_locations)]
#' events_post_merge[, .(state_id, state, meanlat, meanlon, n_locations)]
mergingCycle <- function(res, max_merges = Inf, thetaD = 200, small_track_action = "merge", ...){
  i       <- 1
  changed <- TRUE

  while (i <= max_merges && changed == TRUE) {
    events <- returnStateEvents(res)
    mergeStopsAndCleanTracks(events = events, thetaD = thetaD, small_track_action = small_track_action, ...)
    changed <- events[state != "excluded", any(state_id != new_state_id)]
    updateDataWithEvents(res, events)
    i <- i + 1
  }

}

