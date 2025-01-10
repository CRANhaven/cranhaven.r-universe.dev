#' Find an initial set of stops given timestamped locations
#'
#' \code{stopFinder} modifies by reference a data.table of trajectories, which
#' are clustered spatiotemporally based on a user-provided distance radius
#' parameter and time parameter. Points are evaluated sequentially to determine
#' whether they meet the criteria for being a stop (at least \code{thetaT} time
#' spent within \code{thetaD} distance of the initiating location). Points must
#' therefore have a timestamp, longitude and latitude column.
#'
#' This function has been optimized for simulation studies where it will be
#' called repeatedly. Because of this, all error-handling is done prior to this
#' step. If calling this function directly, the user must ensure that the data
#' are ordered based on the timestamp, and that the columns names are correct.
#'
#'
#' @param traj An ordered data.table with columns named timestamp, longitude and
#'   latitude
#' @param thetaD The distance parameter, represents a radius in meters for
#'   establishing how much area a stop can encompass.
#' @param thetaT The time parameter, representing the length of time that must
#'   be spent within the stop area before being considered a stop.
#'
#' @return traj is modified by reference to include a column
#'   stop_initiation_idx, which is NA for locations not belonging to a stop, and
#'   equal to the row number initiating the stop it belongs to otherwise.
#' @export
#'
#' @examples
#' # Set up data
#' library(data.table)
#' dt <- data.table(entity_id = rep(1, 27),
#' timestamp = c(1, 2, 4, 10, 14, 18, 20, 21, 24, 25, 28, 29, 45, 80, 100,
#'               120, 200, 270, 300, 340, 380, 450, 455, 460, 470, 475,
#'               490),
#' longitude = c(5.1299311, 5.129979, 5.129597, 5.130028, 5.130555, 5.131083,
#'               5.132101, 5.132704, 5.133326, 5.133904, 5.134746, 5.135613,
#'               5.135613, 5.135613, 5.135613, 5.135613, 5.135613, 5.135613,
#'               5.135613, 5.135613, 5.135613, 5.135613, 5.134746, 5.133904,
#'               5.133326, 5.132704, 5.132101),
#' latitude = c(52.092839, 52.092827, 52.092571, 52.092292, 52.092076, 52.091821,
#'              52.091420, 52.091219, 52.091343, 52.091651, 52.092138, 52.092698,
#'              52.092698, 52.092698, 52.092698, 52.092698, 52.092698, 52.092698,
#'              52.092698, 52.092698, 52.092698, 52.092138, 52.091651, 52.091343,
#'              52.091219, 52.091420, 52.091821))
#' stopFinder(dt, thetaD = 50, thetaT = 400)[]
#' plot(dt$longitude, dt$latitude, type = "b", lwd = dt$timedif, pch = 20,
#'  main = "Stay point detection from timestamped trajectory",
#'  sub = "Point size is elapsed time, points in red form a stop")
#' points(x = dt$longitude[dt$state == "stopped"],
#'  y = dt$latitude[dt$state == "stopped"],
#'  col = "red", lwd = dt$timedif[dt$state == "stopped"], pch = 20)
#'

stopFinder <- function(traj, thetaD, thetaT) {
  set(traj,
      j = "stop_initiation_idx",
      value = NA_integer_)
  # traj[, stop_id := NA_integer_]
  mat <- as.matrix(traj[, .(longitude, latitude, as.numeric(timestamp))])
  i <- 1
  j <- i + 1
  pointNum <- nrow(mat) # number of GPS points in traj

  while (i < pointNum & j < pointNum) {
    # flag <- TRUE
    while ((j < pointNum)) {
      distance <-
        haversinem(mat[c(i, j), c(1, 2)]) # most efficient, but others work
      # traj[c(i, j), geodist_vec(longitude, latitude, sequential = TRUE)]
      # traj[c(i, j), haversine(longitude, latitude)]
      # geodist(mat[c(i, j),], sequential = TRUE)
      if (distance >= thetaD) {
        time <- mat[j, 3] - mat[i, 3]
        # time <- diff(mat[c(i, j), 3])
        if ((time >= thetaT)) {
          set(traj, i = i:(j-1), j = "stop_initiation_idx", value = i)
          # traj[i:j, stop_id := i]
        }
        i <- j
        break
      } else  {
        j <- j + 1
      }
    }
  }

  # Capture the last stop if it's longer than time window
  if (mat[j, 3] - mat[i, 3] >= thetaT)
    set(traj, i = i:j, j = "stop_initiation_idx", value = i)
  # traj[i:j, stop_id := i]

  set(traj,
      j = c("timedif",
            "state_id",
            "state"),
      value = list(
        splitDiffTime(traj[["timestamp"]]),
        rleid(traj[["stop_initiation_idx"]]),
        fifelse(is.na(traj[["stop_initiation_idx"]]), "moving", "stopped")))
}
