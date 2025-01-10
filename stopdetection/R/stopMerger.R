#' Stop Merger
#'
#' Given the events data.table containing the spatiotemporally clustered stop/
#' move states, merges stops separated by less than \code{thetaD} meters.
#' Modifies events by reference.
#'
#' @param events data.table of events from \code{\link{returnStateEvents}}
#' @param thetaD maximum distance for merging subsequent stops
#'
#' @return modifies events data.table by reference, changing new_stop_id and
#'   new_state

stopMerger <- function(events, thetaD) {
  events[state != "excluded",
         `:=`(
           dist_prev_stop = geodist::geodist_vec(
             meanlat,
             meanlon,
             sequential = TRUE,
             measure = "haversine",
             pad = TRUE
           )
         )]

  events[,
         `:=`(
           new_state_id = state_id - cumsum(!is.na(dist_prev_stop) &
                                             dist_prev_stop < thetaD)
         )]


}
