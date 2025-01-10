## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7
)

## ----setup--------------------------------------------------------------------
library(tidyverse)
library(rticulate)

## ----it01-dlc-----------------------------------------------------------------
it01_dlc_path <- system.file("extdata/it01-dlc.tsv", package = "rticulate")

it01_dlc <- read_aaa(it01_dlc_path) |> 
  # Let's rename some columns.
  rename(
    date_time = `Date Time of recording`,
    time_rec = `Time of sample in recording`,
    time_annot = `Time of sample in annot`
  )

## ----it01-up------------------------------------------------------------------
it01_up <- it01_dlc |> 
  filter(spline == "DLC_Tongue") |> 
  mutate(
    Y_sm = filter_signal(Y, order = 2, window_length = 7, apply = 2),
    .by = c(displ_id)
  ) |> 
  reframe(
    resample_signal(Y_sm, time_annot, by = 3), .by = c(displ_id, knot)
  ) |> 
  mutate(
    Y_sm_up = filter_signal(signal_int, window_length = 11, apply = 2),
    .by = c(displ_id, knot)
  )

it01_up |> 
  filter(knot == 8) |> 
  ggplot(aes(time_int, Y_sm_up)) +
  geom_point(alpha = 0.2) +
  facet_wrap(vars(displ_id))

## ----get-velocity, warning=FALSE----------------------------------------------
it01_up <- it01_up |> 
  mutate(
    Y_sm_up_vel = get_velocity(Y_sm_up)
  )

it01_up |> 
  filter(displ_id == 14) |> 
  ggplot(aes(time_int, Y_sm_up_vel)) +
  geom_point() +
  geom_line(aes(y = abs(Y_sm_up_vel)), colour = "red") +
  annotate("rect", xmin = 0.3, xmax = 0.55, ymin = -Inf, ymax = Inf, alpha = 0.3)

## ----get-landmarks, warning=FALSE---------------------------------------------
# Filter signal to include a reduced time window
it01_up_win <- it01_up |>
  filter(displ_id == 14, time_int > 0.3, time_int < 0.55)

# Get landmarks
it01_up_win_land <- get_landmarks(it01_up_win$Y_sm_up_vel, it01_up_win$time_int, 0.4, 0.5)
it01_up_win_land_long <- it01_up_win_land |> 
  pivot_longer(everything(), names_to = "land")

it01_up_win_land_long

## ----plot-landmarks, warning=FALSE, fig.asp=0.25------------------------------
it01_up_win |> 
  ggplot(aes(time_int, abs(get_velocity(Y_sm_up)))) +
  geom_point(colour = "red") +
  geom_vline(data = it01_up_win_land_long |> filter(str_detect(land, "_ons|_off")), aes(xintercept = value)) +
  labs(y = "Absolute velocity")

it01_up_win |> 
  ggplot(aes(time_int, Y_sm_up)) +
  geom_point() +
  geom_vline(data = it01_up_win_land_long |> filter(str_detect(land, "_ons|_off")), aes(xintercept = value)) +
  labs(y = "Y displacement")

## ----it01-up-lands------------------------------------------------------------
it01_up_lands <- it01_up |> 
  filter(knot == 8, time_int > 0.3, time_int < 0.55) |> 
  reframe(
    get_landmarks(Y_sm_up_vel, time_int, 0.35, 0.45),
    .by = displ_id
  )

it01_up_lands

## -----------------------------------------------------------------------------
it01_up_lands_long <- it01_up_lands |> 
  pivot_longer(-displ_id, names_to = "land")

it01_up |> 
  filter(knot == 8) |> 
  ggplot(aes(time_int, Y_sm_up)) +
  geom_point(alpha = 0.2) +
  geom_vline(data = it01_up_lands_long |> filter(str_detect(land, "_ons|_off")), aes(xintercept = value)) +
  facet_wrap(vars(displ_id))

