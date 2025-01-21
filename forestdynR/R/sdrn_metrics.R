#' @title sdrn_metrics
#'
#' @description Calculates survival, death, and recruitment metrics for forest monitoring data over time.
#'
#' @param forest_df Data frame containing the forest monitoring data.
#' @param group_var String. The name of the column used to group the data, that could be "plot" or "spp".
#' @param inv_time Numeric. The time interval between the two monitoring periods.
#'
#' @return A list containing the following metrics:
#'   - n_sur: Number of surviving trees per group.
#'   - n_death: Number of dead trees per group.
#'   - n_rec: Number of recruited trees per group.
#'   - n_n0: Total number of trees at the start of the interval per group.
#'   - n_n1: Total number of trees at the end of the interval per group.
#'   - death_rate: Annual death rate per group (%).
#'   - rec_rate: Annual recruitment rate per group (%).
#'   - nc_rate: Net change rate of tree count per group (%).
#'   - turn: Turnover rate, calculated as the mean of death and recruitment rates (%).
#'
#'
#' @export


sdrn_metrics <- function(forest_df, group_var, inv_time) {
  # n_sur, n_death and n_rec per group
  results <- by(forest_df, forest_df[[group_var]], function(sub_df) {
    n_sur <- nrow(sub_df[sub_df$DBH_1 > 0 & sub_df$DBH_2 > 0, ])
    n_death <- nrow(sub_df[sub_df$DBH_1 > 0 & sub_df$DBH_2 == 0, ])
    n_rec <- nrow(sub_df[sub_df$DBH_1 == 0 & sub_df$DBH_2 > 0, ])

    return(list(
      n_sur = n_sur,
      n_death = n_death,
      n_rec = n_rec
    ))
  })

  # Extract results
  n_sur <- sapply(results, `[[`, "n_sur")
  n_death <- sapply(results, `[[`, "n_death")
  n_rec <- sapply(results, `[[`, "n_rec")

  # Calculate n_n0 and n_n1
  n_n0 <- n_sur + n_death
  n_n1 <- n_sur + n_rec

  # Calculate group ratings
  death_rate <- (1 - (((n_n0 - n_death) / n_n0) ^ (1 / inv_time))) * 100
  rec_rate <- (1 - (1 - (n_rec / n_n1)) ^ (1 / inv_time)) * 100
  nc_rate <- (((n_n1 / n_n0) ^ (1 / inv_time)) - 1) * 100
  turn <- (death_rate + rec_rate) / 2

  return(
    list(
      n_sur = n_sur,
      n_death = n_death,
      n_rec = n_rec,
      n_n0 = n_n0,
      n_n1 = n_n1,
      death_rate = death_rate,
      rec_rate = rec_rate,
      nc_rate = nc_rate,
      turn = turn
    )
  )
}


