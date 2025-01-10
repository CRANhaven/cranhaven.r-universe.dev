#' Timestamped Location Data
#'
#' Real data from November 2019 extracted from Google Location History files captured with an Android smartphone. Contains two weeks of human movement behavior of a single person occurring in the Netherlands. Modes include biking, walking, bus and train.
#'
#' @format ## `loc_data_2019`
#' A data frame with 21,911 rows and 3 columns:
#' \describe{
#'   \item{latitude}{unprojected latitude coordinate using WGS84 ellipsoid}
#'   \item{longitude}{unprojected longitude coordinate using WGS84 ellipsoid}
#'   \item{timestamp}{POSIXct timestamp with date and time using fractional seconds}
#'   ...
#' }
#' @source Personal recorded location history
"loc_data_2019"
