#' @title ba_b_metrics
#'
#' @description Computes basal area (BA) ans Biomass(B) metrics for forest monitoring by category over a specified time interval.
#' This function calculates BA and B metrics for specified groups in a dataset, including gains, losses,
#' recruitment, and mortality.
#'
#' @param forest_df Data frame containing the forest monitoring data.
#' @param group_var String. The name of the column used to group the data, that could be "plot" or "spp".
#' @param inv_time Numeric. The time interval between the two monitoring periods.
#'
#' @return A list containing:
#' \item{sur_gain}{Matrix of basal area gain for surviving trees by group.}
#' \item{sur_loss}{Matrix of basal area loss for surviving trees by group.}
#' \item{rec_ba}{Matrix of basal area for recruited trees by group.}
#' \item{death_ba}{Matrix of basal area for dead trees by group.}
#' \item{BA_gain}{Matrix of total basal area gain by group.}
#' \item{BA_loss}{Matrix of total basal area loss by group.}
#' \item{ba_n0}{Total basal area at time 0 by group.}
#' \item{ba_n1}{Total basal area at time 1 by group.}
#' \item{loss_rate_ba}{Numeric. The basal area loss rate (percent per year) by group.}
#' \item{gain_rate_ba}{Numeric. The basal area gain rate (percent per year) by group.}
#' \item{nc_rate_ba}{Numeric. The net change rate of basal area (percent per year) by group.}
#' \item{turn_ba}{Numeric. The turnover rate of basal area (average of loss and gain rates) by group.}
#' \item{biomass_n0}{Total above-ground biomass at time 0 by group.}
#' \item{biomass_n1}{Total above-ground biomass at time 1 by group.}
#'
#'
#' @export
#'
#' @importFrom stats aggregate sd

ba_b_metrics <- function(forest_df, group_var, inv_time) {
  calculate_subset_sum <- function(sub_df, type) {
    if (type == "sur_gain") {
      sur_subset <- sub_df[sub_df$DBH_1 > 0 & sub_df$DBH_2 > 0, ]
      return(sum(sur_subset[sur_subset$SA_difference > 0, "SA_difference"]))
    } else if (type == "sur_loss") {
      sur_subset <- sub_df[sub_df$DBH_1 > 0 & sub_df$DBH_2 > 0, ]
      return(sum(sur_subset[sur_subset$SA_difference < 0, "SA_difference"]))
    } else if (type == "rec") {
      rec_subset <- sub_df[sub_df$DBH_1 == 0 & sub_df$DBH_2 > 0, ]
      return(sum(rec_subset$AS2))
    } else if (type == "death") {
      death_subset <- sub_df[sub_df$DBH_1 > 0 & sub_df$DBH_2 == 0, ]
      return(sum(death_subset$AS1))
    } else {
      return(NA)
    }
  }

  # BA metrics per group
  sur_gain <- as.matrix(by(forest_df, forest_df[[group_var]], calculate_subset_sum, type = "sur_gain"))
  sur_loss <- as.matrix(by(forest_df, forest_df[[group_var]], calculate_subset_sum, type = "sur_loss"))
  rec_ba <- as.matrix(by(forest_df, forest_df[[group_var]], calculate_subset_sum, type = "rec"))
  death_ba <- as.matrix(by(forest_df, forest_df[[group_var]], calculate_subset_sum, type = "death"))

  # BA loss and gain
  BA_gain <- sur_gain + rec_ba
  BA_loss <- sur_loss - death_ba

  # Agregate BA t=0 and t=1
  ba_n0 <- aggregate(forest_df$SA1,
                     by = list(Group = forest_df[[group_var]]),
                     FUN = sum)$x
  ba_n1 <- aggregate(forest_df$SA2,
                     by = list(Group = forest_df[[group_var]]),
                     FUN = sum)$x

  # Rates
  loss_rate_ba <- (1 - (((ba_n0 + BA_loss) / ba_n0) ^ (1 / inv_time))) * 100
  gain_rate_ba <- (1 - (1 - (BA_gain / ba_n1)) ^ (1 / inv_time)) * 100
  nc_rate_ba <- (((ba_n1 / ba_n0) ^ (1 / inv_time)) - 1) * 100
  turn_ba <- (loss_rate_ba + gain_rate_ba) / 2

  # B per groups
  biomass_n0 <- aggregate(forest_df$AGB1,
                          by = list(Group = forest_df[[group_var]]),
                          FUN = sum)$x
  biomass_n1 <- aggregate(forest_df$AGB2,
                          by = list(Group = forest_df[[group_var]]),
                          FUN = sum)$x

  return(
    list(
      sur_gain = sur_gain,
      sur_loss = sur_loss,
      rec_ba = rec_ba,
      death_ba = death_ba,
      BA_gain = BA_gain,
      BA_loss = BA_loss,
      ba_n0 = ba_n0,
      ba_n1 = ba_n1,
      loss_rate_ba = loss_rate_ba,
      gain_rate_ba = gain_rate_ba,
      nc_rate_ba = nc_rate_ba,
      turn_ba = turn_ba,
      biomass_n0 = biomass_n0,
      biomass_n1 = biomass_n1
    )
  )
}


