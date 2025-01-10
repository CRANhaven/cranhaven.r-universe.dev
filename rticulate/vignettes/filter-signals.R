## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7
)

## ----setup--------------------------------------------------------------------
library(tidyverse)
library(rticulate)
library(rcartocolor)

## ----read-data----------------------------------------------------------------
it01_dlc_path <- system.file("extdata/it01-dlc.tsv", package = "rticulate")

it01_dlc <- read_aaa(it01_dlc_path) |> 
  # Let's rename some columns.
  rename(
    date_time = `Date Time of recording`,
    time_rec = `Time of sample in recording`,
    time_annot = `Time of sample in annot`
  )

it01_dlc

## ----it01-tongue--------------------------------------------------------------
it01_tongue <- it01_dlc |> 
  filter(spline == "DLC_Tongue")

## ----fs-mean------------------------------------------------------------------
it01_dlc |>
  group_by(displ_id) |>
  mutate(dt = time_annot - lag(time_annot)) |>
  summarise(mean_dt = mean(dt, na.rm = TRUE)) |>
  summarise(mean_fs = round(mean(1/mean_dt)))

## ----it01-tongue-plot---------------------------------------------------------
it01_tongue |> 
  filter(knot == "8") |> 
  ggplot(aes(time_annot, Y, group = date_time)) +
  annotate("rect",
           ymin = -Inf, ymax = Inf, xmin = 0.3, xmax = 0.5,
           alpha = 0.25, fill = "purple") +
  geom_line()

## ----filter-sg-test-----------------------------------------------------------
sg_plot <- it01_tongue |> 
  filter(displ_id == 29) |> 
  ggplot(aes(time_annot, Y)) +
  geom_line(linetype = "dashed")

for (wl in c(5, 7, 9, 11, 15)) {
  sg_plot <- sg_plot +
    geom_line(
      aes(
        y = filter_signal(Y, order = 2, window_length = {{ wl }}, apply = 2),
        colour = as.factor({{ wl }})
      ), linewidth = 1.5, alpha = 0.7
    )
}

sg_plot + scale_colour_carto_d(palette = "Safe", name = "Window\nlength")

## ----filter-sg----------------------------------------------------------------
it01_tongue <- it01_tongue |> 
  mutate(
    Y_sm = filter_signal(Y, order = 2, window_length = 7, apply = 2),
    .by = displ_id
  )

it01_tongue |> select(time_annot, Y, Y_sm)

## ----filter-sg-plog-----------------------------------------------------------
it01_tongue |> 
  filter(knot == "8") |> 
  ggplot(aes(time_annot, Y, group = date_time)) +
  geom_line(alpha = 0.25) +
  geom_line(aes(y = Y_sm), colour = "purple")

## ----filter-sg-sample---------------------------------------------------------
set.seed(13579)
kdi <- sample(unique(it01_tongue$displ_id), 9)

it01_tongue |> 
  filter(displ_id %in% kdi) |> 
  ggplot(aes(time_annot, Y)) +
  geom_line() +
  geom_point(aes(y = Y_sm), colour = "red") +
  facet_wrap(vars(displ_id), scales = "free")

## ----filter-b-----------------------------------------------------------------
it01_tongue <- it01_tongue |> 
  mutate(
    Y_smb = filter_signal(Y, filter = "butter", cutoff_freq = 10, sampling_freq = 67),
    .by = displ_id
  )

it01_tongue |> select(time_annot, Y, Y_smb)

## ----filter-b-plot------------------------------------------------------------
it01_tongue |> 
  filter(knot == "8") |> 
  ggplot(aes(time_annot, Y, group = date_time)) +
  geom_line(alpha = 0.25) +
  geom_line(aes(y = Y_smb), colour = "orange")

## ----filter-both--------------------------------------------------------------
it01_tongue |> 
  filter(knot == "8") |> 
  ggplot(aes(time_annot, Y, group = date_time)) +
  geom_point(aes(y = Y_sm), pch = 15, size = 2, colour = "purple") +
  geom_point(aes(y = Y_smb), pch = 18, size = 1, colour = "white") +
  facet_wrap(vars(displ_id))

## ----upsample-----------------------------------------------------------------
it01_tongue_up <- it01_tongue |> 
  reframe(
    resample_signal(Y_sm, time_annot, by = 3),
    .by = displ_id
  )

# Nothing exceptional here, just doing some wrangling to get the info back
it01_tongue_up <- it01_tongue_up |> 
  left_join(y = it01_tongue |> select(Prompt, spline, knot, displ_id) |> distinct()) |> 
  rename(Y_sm_up = signal_int)

it01_tongue_up

## ----upsample-plot------------------------------------------------------------
it01_tongue_up |> 
  filter(knot == 8) |> 
  ggplot(aes(time_int, Y_sm_up, group = displ_id)) +
  geom_point(alpha = 0.25) +
  geom_line()

## ----upsample-smooth----------------------------------------------------------
it01_tongue_up <- it01_tongue_up |> 
  mutate(
    Y_sm_up_sm = filter_signal(Y_sm_up, order = 2, window_length = 7, apply = 2),
    .by = displ_id
  )

it01_tongue_up |> 
  filter(knot == 8) |> 
  ggplot(aes(time_int, Y_sm_up_sm, group = displ_id)) +
  geom_point(alpha = 0.25) +
  geom_line()

