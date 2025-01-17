#' Section Data
#'
#' Section Spatial Polygon Data
#'
#' Polygons of sections of the waterbodies.
#'
#' @format A SpatialPolygonsDataFrame with the data frame:
#' \describe{
#'   \item{Section}{The unique section code (fctr).}
#'   \item{Habitat}{The habitat type 'Lentic' or 'Lotic' (fctr).}
#'   \item{Bounded}{The polygon represents the full area (lgl).}
#'   \item{geometry}{The section polygon (MULTIPOLYGON (m)).}
#' }
"section"

#' Station Data
#'
#' A tbl data frame of detection stations.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{Station}{The unique station name (fctr).}
#'   \item{Section}{The section code (fctr).}
#'   \item{geometry}{The station point (POINT (m)).}
#' }
"station"

#' Receiver Deployment Data
#'
#' A data frame of receiver deployments by station and date times.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{Station}{The station name (fctr).}
#'   \item{Receiver}{The receiver code (fctr).}
#'   \item{DateTimeReceiverIn}{The receiver deployment date and time (time).}
#'   \item{DateTimeReceiverOut}{The receiver retrieval date and time (time).}
#' }
"deployment"

#' Fish Capture Data
#'
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{Capture}{The unique fish code (fctr).}
#'   \item{DateTimeCapture}{The date and time of capture (time).}
#'   \item{SectionCapture}{The section code (fint).}
#'   \item{Species}{The fish species 'Bull Trout', 'Lake Trout' or
#'   'Rainbow Trout' (fctr).}
#'   \item{Length}{The fork length in mm (int).}
#'   \item{Weight}{The wet mass in kg (dbl).}
#'   \item{Reward1}{The reward value of the first T-Bar tag
#'   in Canadian dollars (int).}
#'   \item{Reward2}{The reward value of the second T-Bar tag if present
#'   in Canadian dollars (int).}
#'   \item{DateTimeTagExpire}{The acoustic tag expiration date and time (time).}
#' }
"capture"

#' Fish Recapture Data
#'
#' A tbl data frame of fish recaptures. As the time of recapture
#' was not reported it is assumed to be 12:00:00.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{DateTimeRecapture}{The reported date of recapture (time).}
#'   \item{Capture}{The fish code (fctr).}
#'   \item{SectionRecapture}{The section code (fctr).}
#'   \item{TBarTag1}{The first T-Bar Tag was reported (lgl).}
#'   \item{TBarTag2}{A second T-Bar Tag was reported (lgl).}
#'   \item{TagsRemoved}{The T-Bar tags were removed from the fish (lgl).}
#'   \item{Released}{The angler reportedly released the fish (lgl).}
#'   \item{Public}{The angler was a member of the public as opposed
#'   the study team (lgl).}
#' }
"recapture"

#' Acoustic Detection Data
#'
#' Hourly acoustic detection data by fish (capture) and receiver.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{DateTimeDetection}{The detection date and hour (time).}
#'   \item{Capture}{The fish code (fctr).}
#'   \item{Receiver}{The receiver code (fctr).}
#'   \item{Detections}{The number of detections in the hour (int).}
#' }
"detection"
