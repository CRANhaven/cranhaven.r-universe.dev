interpolatePoints <-
  function(dt,
           max_time = lubridate::minutes(3),
           max_dist = 200) {

    # Fix note on no visible binding from data.table NSE
    time_gap_from_prev <- dist_gap_from_prev <- device_id <- data_set_days <-
      prev_lon <- prev_lat <- longitude <- latitude <- prev_ts <- timestamp <-
      next_ts <- next_lat <- minutes_gap <- next_lon <- id <- NULL

    set(dt,
        j = c("prev_ts",
              "prev_lon",
              "prev_lat"),
        value = list(
          shift(dt[["timestamp"]]),
          shift(dt[["longitude"]]),
          shift(dt[["latitude"]])
        ))

    set(dt,
        j = c("time_gap_from_prev",
              "dist_gap_from_prev"),
        value = list(
          dt[["timestamp"]] - dt[["prev_ts"]],
          geodist::geodist(cbind(lon = dt[["longitude"]], lat = dt[["latitude"]]),
                  cbind(lon = dt[["prev_lon"]], lat = dt[["prev_lat"]]),
                  paired = TRUE,
                  measure = "haversine")
        ))

    missingseg <-
      dt[time_gap_from_prev > max_time &
           dist_gap_from_prev > max_dist,
         .(
           device_id,
           data_set_days,
           prev_lon,
           prev_lat,
           next_lon = longitude,
           next_lat = latitude,
           prev_ts,
           next_ts = timestamp,
           minutes_gap = floor(lubridate::time_length(time_gap_from_prev, unit = "minute")) + 1,
           id = .I
         )]
    if (missingseg[, .N] > 0) {
      test <-
        missingseg[, .(
          timestamp = seq(
            from = prev_ts,
            to = next_ts,
            by = lubridate::seconds(60)
          ),
          latitude = seq(
            from = prev_lat,
            to = next_lat,
            length.out = minutes_gap
          ),
          longitude = seq(
            from = prev_lon,
            to = next_lon,
            length.out = minutes_gap
          ),
          accuracy = 0,
          device_id,
          data_set_days
        ), id]

      dt <-
        rbindlist(list(dt, test[, .SD[-c(1, .N)], id]), fill = TRUE)
      setorder(dt, timestamp)
    }
    set(dt,
        j = c("prev_ts", "prev_lon", "prev_lat", "time_gap_from_prev", "dist_gap_from_prev"),
        value = NULL)
    return(dt)
  }
