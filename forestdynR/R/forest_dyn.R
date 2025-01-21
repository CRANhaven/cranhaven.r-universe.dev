#' @title forest_dyn
#'
#' @description
#' Function to calculate forest dynamics, including abundance, mortality and recruitment rates,
#' basal area, and biomass. The function uses diameter at breast height (DBH) data to estimate forest dynamics over time.
#'
#' @param forest_df A dataframe containing the forest plot data, with columns for species name (spp),
#'                  and two DBH (Diameter at breast height) values (DBH_1 and DBH_2).
#' @param inv_time The number of years between the two forest measurements (time interval between observations).
#' @param coord A vector of geographic coordinates (longitude and latitude) for biomass calculation.
#' @param add_wd Additional wood density data that can be provided for species not included in the database.
#'
#' @return A list containing the forest community dynamics, with abundance metrics, dynamic rates,
#'         basal area, and biomass by year.
#'
#' @examples
#' forest_df <- data(forest_df_example)
#' coord <- c(-50.17,-27.71)
#' dyn_object <- forest_dyn(forest_df, inv_time = 5, coord = coord)
#'
#' @export
#'
#' @importFrom BIOMASS getWoodDensity computeAGB
#' @importFrom utils write.table



forest_dyn <- function(forest_df, inv_time, coord, add_wd = NULL) {
  # Testing initial data:
  if (missing(forest_df))
    stop("ERROR:Dataframe is missing")

  forest_df <- as.data.frame(forest_df)
  forest_df[is.na(forest_df)] <- 0
  message("NA's were turned into 0")


  check_result <- check_format(forest_df)
  if (check_result$status == FALSE)
    return(paste("ERROR:", check_result$message))

  # Creating the objects:
  spp <- as.character(forest_df$spp)
  words <- strsplit(as.character(spp), " ")
  genus <- sapply(words, "[", 1)
  specie <- sapply(words, "[", 2)

  # Getting wood density:

  wd <- BIOMASS::getWoodDensity(genus = genus,
                                species = specie,
                                addWoodDensityData = add_wd)
  forest_df$wd <- wd$meanWD

  # Above-ground biomass (ton):

  #First measure:
  forest_df$AGB1 <- BIOMASS::computeAGB(forest_df$DBH_1, forest_df$wd, coord = coord)

  #Second Measure:
  forest_df$AGB2 <- BIOMASS::computeAGB(forest_df$DBH_2, forest_df$wd, coord = coord)

  # Sectional area:
  forest_df$SA1 <- (pi * forest_df$DBH_1 ^ 2) / 40000
  forest_df$SA2 <- (pi * forest_df$DBH_2 ^ 2) / 40000
  forest_df$SA_difference <- forest_df$SA2 - forest_df$SA1

  # Survivors, deaths, recruits, n0 and n1 per plot:
  n_sur_plot <- sdrn_metrics(forest_df, "plot", inv_time)$n_sur
  n_death_plot <- sdrn_metrics(forest_df, "plot", inv_time)$n_death
  n_rec_plot <- sdrn_metrics(forest_df, "plot", inv_time)$n_rec

  n_n0_plot <- sdrn_metrics(forest_df, "plot", inv_time)$n_n0
  n_n1_plot <- sdrn_metrics(forest_df, "plot", inv_time)$n_n1

  # Survivors, deaths, recruits, n0 and n1 per species:
  n_sur_spp <- sdrn_metrics(forest_df, "spp", inv_time)$n_sur
  n_death_spp <- sdrn_metrics(forest_df, "spp", inv_time)$n_death
  n_rec_spp <- sdrn_metrics(forest_df, "spp", inv_time)$n_rec

  n_n0_spp <- sdrn_metrics(forest_df, "spp", inv_time)$n_n0
  n_n1_spp <- sdrn_metrics(forest_df, "spp", inv_time)$n_n1

  # Rates per plot:
  death_rate_plot <- sdrn_metrics(forest_df, "plot", inv_time)$death_rate
  rec_rate_plot <- sdrn_metrics(forest_df, "plot", inv_time)$rec_rate
  nc_rate_plot <- sdrn_metrics(forest_df, "plot", inv_time)$nc_rate
  turn_plot <- sdrn_metrics(forest_df, "plot", inv_time)$turn

  # Rates per species:
  death_rate_spp <- sdrn_metrics(forest_df, "spp", inv_time)$death_rate
  rec_rate_spp <- sdrn_metrics(forest_df, "spp", inv_time)$rec_rate
  nc_rate_spp <- sdrn_metrics(forest_df, "spp", inv_time)$nc_rate
  turn_spp <- sdrn_metrics(forest_df, "spp", inv_time)$turn

  # Basal area and Biomass
  basal_area_biomass_metrics_plot <- ba_b_metrics(forest_df, "plot", inv_time)
  basal_area_biomass_metrics_spp <- ba_b_metrics(forest_df, "spp", inv_time)

  # Metrics per plot
  ba_n0_plot <- basal_area_biomass_metrics_plot$ba_n0
  biomass_n0_plot <- basal_area_biomass_metrics_plot$biomass_n0
  sur_gain_ba_plot <- basal_area_biomass_metrics_plot$sur_gain
  sur_loss_ba_plot <- basal_area_biomass_metrics_plot$sur_loss
  death_ba_plot <- basal_area_biomass_metrics_plot$death_ba
  rec_ba_plot <- basal_area_biomass_metrics_plot$rec_ba
  ba_n1_plot <- basal_area_biomass_metrics_plot$ba_n1
  biomass_n1_plot <- basal_area_biomass_metrics_plot$biomass_n1
  loss_rate_ba_plot <- basal_area_biomass_metrics_plot$loss_rate_ba
  gain_rate_ba_plot <- basal_area_biomass_metrics_plot$gain_rate_ba
  nc_rate_ba_plot <- basal_area_biomass_metrics_plot$nc_rate_ba
  turn_ba_plot <- basal_area_biomass_metrics_plot$turn_ba

  # Metrics per spp
  ba_n0_spp <- basal_area_biomass_metrics_spp$ba_n0
  biomass_n0_spp <- basal_area_biomass_metrics_spp$biomass_n0
  sur_gain_ba_spp <- basal_area_biomass_metrics_spp$sur_gain
  sur_loss_ba_spp <- basal_area_biomass_metrics_spp$sur_loss
  death_ba_spp <- basal_area_biomass_metrics_spp$death_ba
  rec_ba_spp <- basal_area_biomass_metrics_spp$rec_ba
  ba_n1_spp <- basal_area_biomass_metrics_spp$ba_n1
  biomass_n1_spp <- basal_area_biomass_metrics_spp$biomass_n1
  loss_rate_ba_spp <- basal_area_biomass_metrics_spp$loss_rate_ba
  gain_rate_ba_spp <- basal_area_biomass_metrics_spp$gain_rate_ba
  nc_rate_ba_spp <- basal_area_biomass_metrics_spp$nc_rate_ba
  turn_ba_spp <- basal_area_biomass_metrics_spp$turn_ba

  # Results
  plot_ind_data <- list(
    n_n0_plot,
    n_sur_plot,
    n_death_plot,
    n_rec_plot,
    n_n1_plot,
    death_rate_plot,
    rec_rate_plot,
    nc_rate_plot,
    turn_plot
  )
  plot_ind_names <- c(
    "n0",
    "survivor",
    "death",
    "recruitment",
    "n1",
    "death_rate",
    "recruitment_rate",
    "net_change_rate",
    "turn"
  )

  spp_ind_data <- list(
    n_n0_spp,
    n_sur_spp,
    n_death_spp,
    n_rec_spp,
    n_n1_spp,
    death_rate_spp,
    rec_rate_spp,
    nc_rate_spp,
    turn_spp
  )
  spp_ind_names <- plot_ind_names

  plot_ba_data <- list(
    ba_n0_plot,
    biomass_n0_plot,
    sur_gain_ba_plot,
    sur_loss_ba_plot,
    death_ba_plot,
    rec_ba_plot,
    ba_n1_plot,
    biomass_n1_plot,
    loss_rate_ba_plot,
    gain_rate_ba_plot,
    nc_rate_ba_plot,
    turn_ba_plot
  )
  plot_ba_names <- c(
    "BA_0",
    "AGB_0",
    "sur_gain",
    "sur_loss",
    "BA_m",
    "BA_r",
    "BA_1",
    "AGB_1",
    "BA_loss_rate",
    "BA_gain_rate",
    "BA_net_change_rate",
    "BA_turn"
  )

  spp_ba_data <- list(
    ba_n0_spp,
    biomass_n0_spp,
    sur_gain_ba_spp,
    sur_loss_ba_spp,
    death_ba_spp,
    rec_ba_spp,
    ba_n1_spp,
    biomass_n1_spp,
    loss_rate_ba_spp,
    gain_rate_ba_spp,
    nc_rate_spp,
    turn_spp
  )
  spp_ba_names <- plot_ba_names

  # Creating data frames:
  dyn_plot_ind <- create_dyn_df(plot_ind_data, plot_ind_names, 2)
  dyn_spp_ind <- create_dyn_df(spp_ind_data, spp_ind_names, 2)
  dyn_ba_plot <- create_dyn_df(plot_ba_data, plot_ba_names, 4)
  dyn_ba_spp <- create_dyn_df(spp_ba_data, spp_ba_names, 4)

  # Creating final list:
  dynamics <- list(
    n_plot = dyn_plot_ind,
    n_species = dyn_spp_ind,
    basal_area_plot = dyn_ba_plot,
    basal_area_species = dyn_ba_spp
  )


  sum_and_sd <- function(x) {
    list(sum = sum(x), sd = sd(x))
  }

  # Abundance
  n0_stats <- sum_and_sd(dyn_plot_ind[, 1])
  n_death <- sum(dyn_plot_ind[, 3])
  n_rec <- sum(dyn_plot_ind[, 4])
  n1_stats <- sum_and_sd(dyn_plot_ind[, 5])

  # Basal area
  ba_sur_gain <- sum(dyn_ba_plot[, 3])
  ba_sur_loss <- sum(dyn_ba_plot[, 4])
  ba_rec <- sum(dyn_ba_plot[, 6])
  ba_death <- sum(dyn_ba_plot[, 5])
  BA_0_stats <- sum_and_sd(dyn_ba_plot[, 1])
  ba_1_stats <- sum_and_sd(dyn_ba_plot[, 7])

  # Biomass
  BAS1_stats <- sum_and_sd(dyn_ba_plot[, 2])
  BAS2_stats <- sum_and_sd(dyn_ba_plot[, 8])

  # Richness
  get_richness <- function(year_col) {
    subset_year <- forest_df[forest_df[[year_col]] > 0, ]
    spp_matrix <- table(subset_year$plot, subset_year$spp)
    ncol(spp_matrix[, apply(spp_matrix, 2, sum) > 0])
  }

  s_year_1 <- get_richness("DBH_1")
  s_year_2 <- get_richness("DBH_2")

  # N total
  n_dyn_total <- apply(dynamics[[1]], 2, sum)
  n_death_rate_total <- (1 - (((n_dyn_total[1] - n_dyn_total[3]) / n_dyn_total[1]
  ) ^ (1 / inv_time))) * 100
  n_rec_rate_total <- (1 - (1 - (n_dyn_total[4] / n_dyn_total[5])) ^ (1 / inv_time)) * 100
  n_nc_rate_total <- ((n_dyn_total[5] / n_dyn_total[1]) ^ (1 / inv_time) - 1) * 100
  n_turn_total <- (n_death_rate_total + n_rec_rate_total) / 2

  # BA total
  ba1_dyn_total <- apply(dynamics[[3]], 2, sum)
  BA_gain_total <- ba1_dyn_total[3] + ba1_dyn_total[6]
  BA_loss_total <- ba1_dyn_total[4] - ba1_dyn_total[5]
  ba_total_loss_rate <- (1 - (((ba1_dyn_total[1] + BA_loss_total) / ba1_dyn_total[1]
  ) ^ (1 / inv_time))) * 100
  ba_total_gain_rate <- (1 - (1 - (BA_gain_total / ba1_dyn_total[7])) ^ (1 / inv_time)) * 100
  ba_total_nc_rate <- ((ba1_dyn_total[7] / ba1_dyn_total[1]) ^ (1 / inv_time) - 1) * 100
  ba_total_turn <- (ba_total_loss_rate + ba_total_gain_rate) / 2

  format_message <- function(label, value, unit = "", precision = 2) {
    sprintf("%s = %.2f %s", label, round(value, precision), unit)
  }

  # Criar o data frame com as seções e métricas
  report_df <- data.frame(
    Section = c(
      "Richness",
      "Richness",
      "Abundance",
      "Abundance",
      "Dynamics Rate",
      "Dynamics Rate",
      "Dynamics Rate",
      "Dynamics Rate",
      "Basal Area",
      "Basal Area",
      "Basal Area",
      "Basal Area",
      "Basal Area",
      "Basal Area",
      "Biomass",
      "Biomass"
    ),
    Metric = c(
      "Richness year 1",
      "Richness year 2",
      "Abundance year 1",
      "Abundance year 2",
      "Mortality Rate",
      "Recruitment Rate",
      "Net Change Rate in n",
      "Turnover Rate in n",
      "Basal Area year 1",
      "Basal Area year 2",
      "Basal Area Loss Rate",
      "Basal Area Gain Rate",
      "Net Change Rate in BA",
      "Turnover Rate in BA",
      "Biomass year 1",
      "Biomass year 2"
    ),
    Value = c(
      s_year_1,
      s_year_2,
      n0_stats$sum,
      n1_stats$sum,
      n_death_rate_total,
      n_rec_rate_total,
      n_nc_rate_total,
      n_turn_total,
      BA_0_stats$sum,
      ba_1_stats$sum,
      ba_total_loss_rate,
      ba_total_gain_rate,
      ba_total_nc_rate,
      ba_total_turn,
      BAS1_stats$sum,
      BAS2_stats$sum
    ),
    Unit = c(
      "species",
      "species",
      "ind",
      "ind",
      "% year",
      "% year",
      "% year",
      "% year",
      "m2",
      "m2",
      "% year",
      "% year",
      "% year",
      "% year",
      "tons",
      "tons"
    ),
    stringsAsFactors = FALSE
  )

  # Saving files in your computer
  save_dyn_files(dynamics)

  return(list(dynamics = dynamics, report_df = report_df))
}
