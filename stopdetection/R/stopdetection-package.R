#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom data.table .BY
#' @importFrom data.table .EACHI
#' @importFrom data.table .GRP
#' @importFrom data.table .I
#' @importFrom data.table .N
#' @importFrom data.table .NGRP
#' @importFrom data.table .SD
#' @importFrom data.table :=
#' @importFrom data.table data.table
## usethis namespace: end
NULL

globalVariables(c("state", "state_id", "new_state_id", "timestamp", "longitude",
                  "latitude", "move_id", "stop_id", "meanlat", "meanlon",
                  "mergeable", "n_locations", "end_time", "begin_time",
                  "raw_travel_dist", "timedif", "dist_prev_stop",
                  "i.new_state_id", "i.new_state"))
